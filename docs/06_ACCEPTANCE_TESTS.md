# 06 — Test Strategy and Acceptance Matrix

These are planned tests. No result should be marked PASS until executed in Snowflake with the new code.

**New:** the 12-scenario intelligent profiling discovery catalog appears below the original acceptance matrix.

| ID | Test input / setup | Expected result |
|---|---|---|
| T01 | Onboard approved structured demo table | One enabled registry entry, no duplicate source |
| T02 | Profile text column with no corresponding rule | EDGE_SPACE metric generated anyway |
| T03 | EMAIL = `' priya@example.com'` | `NOT_NULL` passes; EDGE_SPACE_COUNT increments |
| T04 | EMAIL = `'priya@example.com '` | Trailing ordinary-space detection increments |
| T05 | EMAIL = `'priya@example.com'` | No edge-space detection |
| T06 | EMAIL = NULL | Null metric increments; no whitespace failure unless separately defined |
| T07 | EMAIL = `'   '` | Blank metric increments; edge-space behavior documented and consistent |
| T08 | Empty table | Counts are 0; percentages safely defined, never division by zero |
| T09 | Numeric AGE = -5, 16, 70 | Numeric min/max and negative counts accurate; policy recommendation not automatically enforced |
| T10 | DATE/TIMESTAMP NULL and future values | Type-aware metrics accurate; no automatic business semantics |
| T11 | Same rule exists as DRAFT | AI recommendation does not duplicate exact rule |
| T12 | Same rule exists as ACTIVE | AI does not recommend exact duplicate |
| T13 | New rule left DRAFT | Hybrid V3 does not execute it |
| T14 | Approved NO_EDGE_WHITESPACE made ACTIVE | Engine flags violating row with correct count and FAIL status |
| T15 | Corrected owned fixture and rerun | Rule returns PASS, old history retained |
| T16 | Execute existing RANGE/VALUE_SET/CONDITIONAL_REQUIRED tests | Results unchanged by new handler |
| T17 | Role without SELECT on source | Profile/validate blocked; no privilege escalation |
| T18 | Role without write permission on results | Clear execution error; never reported as DQ PASS |
| T19 | Unsupported VARIANT column in mixed table | Skipped with explicit reason, no destructive side effects |
| T20 | AI context has no actual profile evidence | AI does not claim observed whitespace rate |
| T21 | Sampled profiling | Sample size and method reported; no assertion about exact full-table rate |
| T22 | V3 response `DONE_WITH_DQ_FAILURES` | Classification means DQ fail, not procedure crash |

## Known test history (pre-1.0, already observed)

| Reference | Actual observed outcome |
|---|---|
| `SOURCE_ID=701` business-rule fixture | VALUE_SET 1/5, CONDITIONAL_REQUIRED 1/5, RANGE 2/5 |
| `RECON_ID=1` value comparison | Source total 1050 vs target 1100; 1 mismatched row; FAIL |
| Cortex Agent | Exists and Playground tested; need a new profile-driven evaluation |

These historical demonstrations are **not evidence** that the new structured profiler or whitespace handler is implemented.

## Suggested evidence capture

Save `tests/evidence/` files **without raw data or credentials**: screenshot of profile counts; `RUN_ID`, source, rule ID and result status; query ID and performance; normalized/redacted AI recommendation; Git commit and tested role. The `tests/evidence/` folder includes a `.gitkeep`; attach real evidence only after security review.

## Independent reference test SQL

Use `sql/00_preflight/02_email_baseline.sql` and `sql/05_smoke_tests/00_readonly_email_checks.sql`. Both are read-only and establish the expected count for the new profiler.

## Intelligent Profiling Discovery Test Catalog (added 16 Nov 2026)

**Purpose:** verify Verity can discover *unconfigured* structured-data quality signals, attach numerical evidence, propose a reviewable action, and then enforce **only approved** rules. These are **planned acceptance scenarios**, not implemented or executed profiler features. Test identifiers `TC_01`–`TC_12` are separate from the existing platform/integration test IDs `T01`–`T22` above.

**Scope guardrails:** single Snowflake project (`VERITY_V2.PRACTICE`), structured columns only. **Core** is the planned 1.0 release path; **Stretch** is a candidate beyond the Nov 20 acceptance gate if time permits. Profiling is observation, not a business-rule FAIL. Proposed rules require steward approval. No raw PII or full source records are sent to Cortex; only aggregate, policy-approved evidence.

| ID | Priority | Hidden-data scenario | Controlled input (illustrative) | What profiler should report | AI suggestion / review required |
|---|---|---|---|---|---|
| **TC_01** | **Core** | Edge whitespace in text/email | `' priya@example.com '`, `'arun@example.com'` | `EDGE_SPACE_COUNT`, affected count/denominator, ordinary leading/trailing spaces | Review `TRIM(EMAIL)` and `NO_EDGE_WHITESPACE`; never auto-update Gold |
| **TC_02** | **Core** | Blank but non-NULL text | `CUSTOMER_NAME='   '` | `BLANK_AFTER_TRIM_COUNT`; contrast against `NULL_COUNT` | Review required-nonblank validation; ordinary `NOT_NULL` alone misses this |
| **TC_03** | Stretch | Inconsistent case | `STATUS='active'`, `'ACTIVE'` | Case-collapsed variant frequency where safely computed | Review `UPPER()`/canonical mapping, **only if** policy requires standardized case |
| **TC_04** | **Core** | Duplicates after normalization | `CUSTOMER_CODE='ABC101'` and `' ABC101 '` | Raw vs `TRIM`-normalized distinct counts; duplicate excess attributable to normalization | Review trim + normalized uniqueness; confirm column is a business key |
| **TC_05** | **Core** | Negative numeric values | `AMOUNT=-500` | `NEGATIVE_COUNT`, numeric min/max, sample denominator | Investigate refunds/credits; suggest `RANGE(min=0)` **only after** business approval |
| **TC_06** | **Core** | Extreme numeric min/max | `AGE=150` | Observed min/max and optionally extreme-value count **only against an agreed limit** | Ask steward to confirm age limits; observed max alone is not proof of invalid data |
| **TC_07** | Stretch | Unexpected/rare categorical value | `STATUS='ACTVE'` next to `ACTIVE` | New/rare value frequency; baseline or approved set required to call it unexpected | Recommend `VALUE_SET` review / possible spelling mapping; don't invent allowed list |
| **TC_08** | Stretch | Suspected email format anomaly | `EMAIL='priya@gmail'` | Count that fails a **documented heuristic**, not a deliverability verdict | Recommend format review and approved pattern check; avoid claiming valid email syntax from weak regex |
| **TC_09** | Stretch | Future date/timestamp | `CREATED_AT='2099-01-01'` | `FUTURE_TIMESTAMP_COUNT` relative to a documented clock/time zone | Review `CREATED_AT <= CURRENT_TIMESTAMP()` rule if future dates are forbidden |
| **TC_10** | **Core** | NULLs in candidate mandatory field | `EMAIL=NULL` | `NULL_COUNT` and percent; existing rule coverage | Suggest `NOT_NULL` only if EMAIL is mandatory and no ACTIVE/DRAFT equivalent exists |
| **TC_11** | **Core** | Duplicate candidate identifier | `CUSTOMER_ID=101` repeated | Non-null duplicate excess; NULLs measured separately | Suggest `UNIQUE` after steward verifies identifier/business-key semantics |
| **TC_12** | Stretch | Distribution drift between runs | 90% ACTIVE historical vs 20% ACTIVE current | Per-run category proportions + baseline difference, with history sufficiency documented | Investigate upstream change; propose anomaly monitor only after enough baseline history |

### Core test trace and expected evidence

| Gate | Evidence and expected behavior |
|---|---|
| **1. Rule-independent discovery** | For `TC_01`, `TC_02`, `TC_04`, `TC_05`, `TC_06`, `TC_10`, `TC_11`, the profiler runs and reports metrics even if there is no corresponding rule in `DQ_RULE_CATALOG`. `TC_06` reports min/max by default, not an unsupported outlier judgment. |
| **2. Quantitative correctness** | Compare `affected_count`, `total_rows`, denominator and percent against independent reference SQL on isolated fixtures. Empty table reports 0 counts and a documented null/not-applicable percentage. NULL text is not an edge-whitespace violation. |
| **3. Evidence-grounded AI** | Agent names actual metrics, observed source and column, avoids invented percentages, distinguishes suspicious patterns from confirmed violations, and explains why any new rule would help. |
| **4. No duplicate recommendations** | If an equivalent rule is `DRAFT` or `ACTIVE`, the Agent identifies coverage and must not propose duplicate catalog insertion. Recommendation creation and activation require explicit human review. |
| **5. Enforced new rule** | `NO_EDGE_WHITESPACE` must detect ordinary space violations only **after** rule activation. `DRAFT` is ignored by Hybrid V3. Corrected fixture returns PASS; prior results persist. |
| **6. Existing rule regression** | `NOT_NULL`, `UNIQUE`, `RANGE`, `VALUE_SET`, and `CONDITIONAL_REQUIRED` continue to return the same results as verified in earlier tests. |
| **7. Safe isolation** | Testing uses dedicated `VERITY_V2.PRACTICE.DEMO_PROFILE_DQ` or another approved fixture; never mutate `DEMO_CUSTOMER_DQ` or production Gold tables merely to trigger findings. |

### Test fixture design and semantics

- Create **dedicated, controlled test rows** for each scenario and keep an explicit expected-results manifest. Avoid mixing unrelated violations when counting expected failures. No fixture DDL or data mutation is included in this documentation-only update.
- For **edge whitespace**, use ordinary ASCII space (U+0020) for the 1.0 milestone: `COL IS NOT NULL AND COL <> TRIM(COL)`. Tabs, nonbreaking spaces, Unicode normalization, internal spaces and invisible characters require a *separate* defined policy and tests.
- For **blank text**, use `COL IS NOT NULL AND TRIM(COL) = ''`; this is not equivalent to NULL.
- For **normalized duplicates**, compare `COUNT(COL) - COUNT(DISTINCT COL)` with `COUNT(COL) - COUNT(DISTINCT TRIM(COL))` on **non-null** values and interpret the difference cautiously. Case-folding is a separate business/policy decision.
- For **negative numeric values**, `AMOUNT < 0` is a signal; refunds, reversals and credits may legitimately be negative. For extreme min/max, do not claim a range violation before business limits are approved.
- For **categorical drift**, distinguish a value absent from the approved allowed set from one merely rare or new relative to historic data; these are different checks. `TC_12` requires historical evidence and is not a first-scan feature.
- For **date signals**, use consistent `DATE`/`TIMESTAMP` handling and document clock/time-zone assumptions; future-dated events may be valid for scheduling datasets.
- **AI is advisory**: it may recommend `TRIM`, normalization, or a prospective rule, but it does not execute source `UPDATE`, approve an ACTIVE rule, or invent unobserved sample values.

### Recommended delivery ordering

1. **Core vertical slice:** `TC_01` → `TC_02` → `TC_10` (text whitespace, blank, NULL), including actual metric persistence and Cortex explanation.
2. **Core structured coverage:** `TC_05` → `TC_06` → `TC_11` → `TC_04` (numeric/key profiling and normalization-sensitive uniqueness).
3. **Controlled enforcement:** approve `NO_EDGE_WHITESPACE`, run FAIL → correction in owned fixture → PASS, preserving `RANGE` / `VALUE_SET` / `CONDITIONAL_REQUIRED` regressions.
4. **Stretch:** `TC_03`, `TC_07`, `TC_08`, `TC_09`, `TC_12` only after core release gates pass.

**Release rule:** A scenario is **PASS** only with executed Snowflake evidence (profiling metrics, query/run ID where available, AI response, and validation result if enforceable). This added test plan does **not** claim any new capability has already been deployed.
