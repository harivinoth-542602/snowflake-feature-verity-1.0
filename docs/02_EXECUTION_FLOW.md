# 02 — Execution Flow & Technical Contracts

## Flow A: source onboarding

1. Confirm the approved table exists and is accessible with a least-privilege role.
2. Call the **existing** `VERITY_V2.ENGINE.SP_DQ_ONBOARD_TABLE(<FQN>)`.
3. Verify exactly one enabled registration in `CONFIG.DQ_SOURCE` and inspect any automatically generated DRAFT rules.
4. Do not assume the onboarding procedure creates an entire best-practice rule library: it generated only CUSTOMER_ID NOT_NULL on an earlier source 601 test.

## Flow B: automatic structured-column profiling (**new work**)

1. Read column metadata from the database's `INFORMATION_SCHEMA.COLUMNS`.
2. Exclude unsupported types (`VARIANT`, `OBJECT`, `ARRAY`, GEOGRAPHY etc.) from this release; record a skipped/unsupported outcome rather than failing silently.
3. For each type family, select bounded built-in metrics; no per-column DQ_RULE_CATALOG entry required.
4. Batch compatible expressions into as few table scans as practical; profile only approved columns; account for wide tables and sampling.
5. Store aggregate metric name, source ID, column name, value, observed time, query ID, and sample scope. The existing `DQ_METRIC_HISTORY` stores numerical values; design a compatible strategy for date extrema and profile-run correlation **before** altering schema.
6. Do not export raw emails or other sensitive source values into AI prompts or Git.

| Column family | Proposed profiling metrics | Interpretation |
|---|---|---|
| Text | TOTAL, NULL_COUNT, BLANK_COUNT, EDGE_SPACE_COUNT, DISTINCT_COUNT, length min/max | A finding; business determines invalidity |
| Numeric | TOTAL, NULL_COUNT, NEGATIVE_COUNT, ZERO_COUNT, MIN, MAX, DISTINCT_COUNT | Negative is not universally invalid |
| Timestamp/date | NULL_COUNT, observed temporal min/max, FUTURE_COUNT where meaningful | Policy/timezone needed for freshness judgments |
| Identifier-like | NULL_COUNT, DISTINCT_COUNT, DUPLICATE_EXCESS | UNIQUE only if identity semantics approved |

`TRIM()` in the pilot identifies **ordinary space characters**. Tabs, Unicode whitespace, and non-breaking spaces are separate edge cases to define and test. `COUNT(DISTINCT ...)` may be resource intensive; prefer approximate distinct only when the documented metric explicitly identifies it as approximate.

## Flow C: evidence → AI → approval (**new integration**)

1. Show actual recorded profiling metrics and existing ACTIVE + DRAFT rule coverage to the existing rule-recommendation context and Cortex Agent.
2. Request recommendation with: source ID, column, observed signal, proposed rule type, proposed parameters, correction suggestion, confidence, why/why not, and human-approval requirement.
3. AI must distinguish **observed facts** from **inferred business expectations**; never claim that nullability metadata proves observed nulls.
4. A steward reviews whether whitespace should be rejected or normalized. Do not auto-activate.
5. Prevent exact duplicate ACTIVE/DRAFT proposals by `(SOURCE_ID, COLUMN_NAME, RULE_TYPE)` and appropriate parameters. Decide whether recommendations should be persisted in `DQ_RULE_CATALOG` as DRAFT or introduced via an auditable proposal action; **not implemented yet**.

## Flow D: rule enforcement (**extend working V3**)

1. Select ACTIVE rules from `CONFIG.DQ_RULE_CATALOG`.
2. Reuse `ENGINE.SP_DQ_EXECUTE_HYBRID_V3(VARCHAR)`; preserve its verified RANGE/VALUE_SET/CONDITIONAL_REQUIRED semantics.
3. Add a tested `NO_EDGE_WHITESPACE` SQL handler with a defined null/blank policy. For an ordinary-space-only example, invalid predicate can be `EMAIL IS NOT NULL AND EMAIL <> TRIM(EMAIL)`.
4. Store results in `DQ_RUN` and `DQ_RULE_RESULT`; return existing procedure status. Do not change public status fields or versions without migration planning.
5. Explicitly distinguish procedure execution failure from a DQ rule failure.

## Example acceptance SQL (read only)

```sql
SELECT CUSTOMER_ID, EMAIL, TRIM(EMAIL) AS TRIMMED_EMAIL
FROM VERITY_V2.PRACTICE.DEMO_CUSTOMER_DQ
WHERE EMAIL IS NOT NULL AND EMAIL <> TRIM(EMAIL);
```

## Existing version compatibility

- Deployed working entry point: `SP_DQ_EXECUTE_HYBRID_V3(VARCHAR)`.
- Design brief's `SP_DQ_EXECUTE_HYBRID` is a conceptual term, **not a verified deployable object**.
- Existing V3 returns `DONE` or `DONE_WITH_DQ_FAILURES`; `PASS/DQ_FAIL/EXECUTION_ERROR` is an aspirational *external classification*, not a current persisted status.
- Existing `SP_DQ_RECONCILE(NUMBER)` takes **RECON_ID**, not SOURCE_ID; reconciliation changes are outside this phase.
- Avoid modifying JSON branches while implementing structured rule types.
