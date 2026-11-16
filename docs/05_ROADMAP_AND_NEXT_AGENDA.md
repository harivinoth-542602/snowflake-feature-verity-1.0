# 05 — November 16–20 Delivery Roadmap & Next Meeting Agenda

**Planning date:** 16 Nov 2026.  **Target:** 20 Nov 2026.  **Scope:** Single-project, structured only.

The period is short; milestones are **target checkpoints**, not claims of implementation. De-scope rather than ship unverified source mutation or unsafe rule activation.

## Milestones and gates

| Target | Milestone | Deliverable | Definition of done |
|---|---|---|---|
| **16 Nov** | M0: architecture + Git baseline | This repository, HLD, RBAC, release plan, read-only inventory | PR reviewed; real source/catalog object inventory captured |
| **17 Nov** | M1: reusable structured profiler | `SP_DQ_PROFILE_TABLE` implementation and profile evidence output | Automatically profiles text/number/date/keys on test fixtures; no DQ rules required |
| **18 Nov** | M2: whitespace discovery + rules | EDGE_SPACE evidence, new `NO_EDGE_WHITESPACE` handler in V3 | Correct violation counts, preserved existing V3 regression outcomes |
| **19 Nov** | M3: Cortex recommendations and stewardship | Context/view + Agent instruction adjustment; DRAFT proposal path | Agent grounds suggestions in actual metrics; no auto-activation; duplicate suppression |
| **20 Nov** | M4: single-project end-to-end acceptance | FAIL→recommend→approve→enforce→retest evidence, access tests, release decision | Passes acceptance matrix; rollback verified; security approvals documented |

The **minimum end-to-end milestone** is edge-space detection and rule enforcement, not full Unicode/format normalization. The expanded test catalog defines seven **Core** profiling scenarios and five **Stretch** scenarios; Core profiling breadth must be tracked against actual execution evidence and any uncompleted Core scenario explicitly recorded as a release gap. See [`06_ACCEPTANCE_TESTS.md`](06_ACCEPTANCE_TESTS.md).

## Immediate next agenda (meeting / working session)

1. **Confirm scope (10 min):** one project, `VERITY_V2.PRACTICE`, relational only; accept Nov 20 target and release cut criteria.
2. **Confirm current objects (15 min):** preflight SQL; actual source 601, catalog columns, metric history schema, V3 DDL/status, Agent tool inventory.
3. **Approve profiler contract (20 min):** type families, what EDGE_WHITESPACE means, sample limits, zero-row and NULL handling, performance budget, result storage.
4. **Confirm security (10 min):** read-only source grants, caller-rights result inserts, who approves ACTIVE rules.
5. **Allocate changes (15 min):** one PR each for profiler, V3 handler, Cortex context, acceptance automation.
6. **Lock acceptance demonstration (10 min):** email edge spaces pass existing NOT_NULL but are discovered by profiler and enforced only after approved rule.

## Work breakdown

### Workstream A — Foundation

- Complete and review baseline object inventory; archive verified deployed DDL.
- Verify `SOURCE_ID=601` only in actual connected environment.
- Choose whether separate fixture table is needed; never overwrite shared demo data without agreement.

### Workstream B — Profiling

- Implement metadata lookup and supported data-type dispatch.
- Produce numeric profiling metrics compatible with existing monitoring storage.
- Record percent denominators, timestamp and query ID; add a profile-run linkage design if multiple statements are required.
- Cap scans; document exact vs approximate distinct behavior and query/credit telemetry.

### Workstream C — Validation extension

- Implement `NO_EDGE_WHITESPACE` only after its semantics are approved.
- Use existing rule catalog and V3 results model; add regression tests covering NULL, blank, space and valid email.

### Workstream D — Cortex and review

- Extend existing recommendation context to include profiler metrics.
- Test prompt with actual SQL-backed evidence, not invented null/whitespace percentages.
- Human approval workflow, duplicate suppression, no direct corrections.

### Workstream E — Release and quality

- Verify Snowflake execution permissions; validate rollback of one modified procedure; collect counts and query IDs; PR and signoff.

## Priority sequence for the next turn

**Start with the three safe SQL preflight files**, review output, then implement the first smallest vertical slice: **single-table, text-column EDGE_SPACE_COUNT profiling**. Generalize to other column types only after the slice is accurate.

## Scope cut if needed

If deadlines force a smaller release, deliver validated text profiling + Cortex recommendation + steward approval + whitespace rule first. Min/max and advanced date profiling can follow as documented gaps; do **not** mark the complete design implemented unless all acceptance tests pass.

## Expanded profiling test execution agenda (added 16 Nov 2026)

- Review controlled fixtures and expected numerical evidence for `TC_01`–`TC_12` before writing profiling SQL.
- Implement the **Core** scenarios incrementally: text (`TC_01`, `TC_02`, `TC_10`), numeric (`TC_05`, `TC_06`), identifier (`TC_11`, `TC_04`).
- Treat the **Stretch** cases (`TC_03`, `TC_07`, `TC_08`, `TC_09`, `TC_12`) as follow-up work, not implicit Nov 20 release commitments.
- Retain negative/positive fixtures, zero-row/NULL cases, permission-denied tests and existing Hybrid V3 regressions.
- Present both (a) previously unknown quality pattern detection and (b) approved-rule enforcement, with AI recommendations clearly identified as advisory.
