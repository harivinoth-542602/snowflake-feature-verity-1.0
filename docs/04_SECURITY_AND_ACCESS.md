# 04 — Single-Project RBAC & Least-Privilege Design

## Access philosophy

For Verity 1.0, operate in **one pilot project**. The project owns source tables; Verity uses read-only SELECT. Result writers can INSERT into Verity result tables but must not update business data. Later multi-project expansion reuses the model with separate grants, not another copy of the framework.

## Candidate roles (names subject to security approval)

| Role | Can do | Cannot do |
|---|---|---|
| `VERITY_DEV_DEPLOY` | Version-controlled DDL in designated DEV control-plane objects | Automatically gain project write access |
| `VERITY_PROFILE_EXEC` | SELECT approved project table, read metadata, write approved profile results | UPDATE/DELETE/TRUNCATE source; manage grants |
| `VERITY_DQ_EXEC` | Call Hybrid engine; SELECT source/config; INSERT run/results | Modify source records; approve rules |
| `VERITY_RULE_STEWARD` | Review/activate approved catalog rules through controlled workflow | Bypass approvals through unrestricted account admin |
| `VERITY_AI_READER` | Read approved aggregate profile/context views, use Cortex Agent | Access individual email values unless separately authorized |

**Current implementation nuance:** inspected `SP_DQ_EXECUTE_HYBRID_V3(VARCHAR)` is `EXECUTE AS CALLER`, so the caller needs the effective permissions for operations inside the procedure, including result writes. Do not assume `GRANT USAGE ON PROCEDURE` alone is sufficient.

## Access map for initial pilot

| Object | Profile role | DQ execution role | AI reader |
|---|---|---|---|
| `VERITY_V2.PRACTICE.DEMO_CUSTOMER_DQ` | SELECT | SELECT | No direct access required |
| `<pilot DB>.INFORMATION_SCHEMA.COLUMNS` | Metadata visibility via relevant privileges | Metadata visibility | No direct access required |
| `VERITY_V2.CONFIG.DQ_SOURCE` | SELECT | SELECT | Via aggregate view |
| `VERITY_V2.CONFIG.DQ_RULE_CATALOG` | SELECT | SELECT | Via aggregate view |
| `VERITY_V2.MONITORING.DQ_METRIC_HISTORY` | INSERT and relevant SELECT | As needed | Read via context view |
| `VERITY_V2.RESULTS.DQ_RUN`, `DQ_RULE_RESULT` | None | INSERT and required read | Read via context view |
| `VERITY_V2.ENGINE.SP_DQ_EXECUTE_HYBRID_V3(VARCHAR)` | None | USAGE | None |
| `VERITY_V2.MONITORING.VERITY_AI_ASSISTANT` | None | None | USAGE plus required Cortex privileges |

## Access approval steps

1. Security owner identifies the pilot database, schema and list of tables.
2. Data owner approves the requested profiling scans and aggregate metrics.
3. Snowflake admin grants `USAGE` on warehouse / database / schema and `SELECT` on **approved table(s)**.
4. Grant execution on only relevant stored procedures; additional result DML rights are dictated by procedure rights.
5. Confirm no INSERT/UPDATE/DELETE/TRUNCATE on the source to Verity runtime roles.
6. Test an unauthorized table request and ensure it fails clearly.
7. Verify Agent cannot access arbitrary raw project data; ensure context views and semantic views are appropriately secured.

A commented grant template appears in [`../deploy/ROLE_GRANTS_TEMPLATE.md`](../deploy/ROLE_GRANTS_TEMPLATE.md). It is intentionally not executed as part of repository setup.

## Metadata, SQL injection and safety

- Validate FQN against approved `DQ_SOURCE` entries and allowed identifier formats before dynamic SQL; use Snowflake `IDENTIFIER()` for dynamic object access.
- Schema metadata visibility depends on grants; do not assume all Snowflake tables are globally discoverable.
- Never interpolate arbitrary user-provided predicates into a profiling query.
- Keep AI evidence aggregated. Sensitive counts may themselves be restricted; establish data classification and limits.
- Use query tags where available to help attribute profiling runs to Verity rather than to business transformations.

## Before adding the second project

Reassess ownership, grants and cross-project aggregation policy, then onboard the second schema under its separately approved table grants. Multi-project is explicitly deferred from the Nov 20 delivery.
