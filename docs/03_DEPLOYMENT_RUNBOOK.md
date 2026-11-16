# 03 — Environment Setup, Deployment and Rollback Runbook

**Status:** A manual, staged release plan. **No implementation scripts have been deployed in this repository.**  
**Target release:** November 20, 2026. The date is a delivery target, not verified readiness.

## Environments and naming

| Logical environment | Snowflake account/object | Policy |
|---|---|---|
| DEV / initial pilot | Existing `VERITY_V2` database; `PRACTICE` demo schema; `VERITY_V2_WH` | Reuse objects, avoid destructive DDL |
| TEST | Separate role/schema or cloned isolated objects **after approval** | Never clone personal data into unsecured test access |
| PROD | Organization-managed promotion destination **TBD** | No deployment before migration and security review |

Use the same release source code and an **explicit environment mapping**. Do not infer that Git branch names automatically map to Snowflake databases.

## One-time Git setup

1. Create a **private** organization GitHub repository.
2. Extract scaffold; `git init && git add . && git commit ...` as in root README.
3. Enforce PR reviews and no direct commits to `main`; no live secret/PII in Git.
4. Create issues for each TODO; place each approved DDL change in its folder as a numbered migration rather than editing live procedures in an untracked worksheet.

## Ordered deployment stages

| Order | Stage | Execute now? | Evidence |
|---|---|---|---|
| 00 | Confirm role, warehouse, database and approved pilot table | **Yes — read-only** | `sql/00_preflight/00_session_and_objects.sql` |
| 01 | Inventory live schemas, procedures and tables; export actual `GET_DDL` snapshots | **Yes — read-only** | `sql/00_preflight/01_inventory.sql` |
| 02 | Define role grants for approved source and existing result tables | **Review first; do not apply sample template blindly** | `deploy/ROLE_GRANTS_TEMPLATE.md` |
| 03 | Confirm source 601 metadata and establish edge-whitespace baseline | **Yes — read-only** | `sql/00_preflight/02_email_baseline.sql` |
| 04 | Add structured profiler procedure and reviewed metric persistence | **No — code TBD** | `sql/02_profiling/README.md` |
| 05 | Add `NO_EDGE_WHITESPACE` to **deployed V3**, version-control reviewed DDL | **No — code TBD** | `sql/03_rule_engine/README.md` |
| 06 | Extend AI context + Agent tool instructions to consume aggregate evidence | **No — code TBD** | `sql/04_ai/README.md` |
| 07 | End-to-end controlled demo in practice schema, including DRAFT/ACTIVE gate | **After stages 04–06** | `docs/06_ACCEPTANCE_TESTS.md` |
| 08 | Review and approve release checklist; tag Git release | **Only after proof** | `docs/08_RELEASE_CHECKLIST.md` |

### Stage 00: preflight

Execute all files under `sql/00_preflight/` in order. They are intentionally read-only. Capture outputs and verify that source 601 is the correct table **in the environment you are connected to**.

### Stage 01: export baseline

Export `GET_DDL` for the deployed source catalog, rules, metric history, run/results and the existing Hybrid V3 procedure. GET_DDL can expose comments or SQL text; review before committing snapshots. Record procedure signature and `EXECUTE AS` rights, role grants, status mappings, and dependencies. **Never execute historical V1/V2/V3 CREATE OR REPLACE files in bulk.**

### Stage 02: security

The inspected V3 uses `EXECUTE AS CALLER`, which means the invoking role's effective privileges matter: `USAGE` on objects/schemas, SELECT on source/config, and INSERT on result tables. Confirm actual nested procedures and any additional required privileges before final grants. Restrict project source access to read-only. `deploy/ROLE_GRANTS_TEMPLATE.md` is documentation, not executable SQL.

### Stage 03: baseline (no mutation)

Use existing rows to count ordinary edge whitespace. If the table has no affected row, create a **separate, uniquely named test fixture** under `PRACTICE` after review, rather than mutating the approved shared demo dataset without notice. Do not truncate shared catalog, metric history or results.

### Stage 04: deploy profiler (pending)

PR: initial metadata query; safe identifiers, type dispatch, bounded metric count; sampling; metrics recording; NULL/zero-row behavior; privilege failures; performance/cost telemetry. Deploy only after tests and DDL export.

### Stage 05: deploy whitespace handler (pending)

PR: patch existing V3 in DEV with new branch; retain all existing SQL, DMF, JSON branches; preserve status/contract. Do **not** run `CREATE OR REPLACE` until backup and rollback are available.

### Stage 06: AI extension (pending)

Capture existing 7-tool Agent LIVE specification before making changes. `ALTER AGENT ... MODIFY LIVE VERSION SET SPECIFICATION` replaces the entire tool specification; don't inadvertently remove tools. Restrict AI input to aggregated evidence; verify Playground responses.

### Stage 07: smoke test

- Profile a table without creating any new rule.
- Detect ordinary leading spaces; numbers reconcile to reference SQL.
- AI recommendation cites metric and explicitly requests business approval.
- DRAFT check must not execute; ACTIVE check must execute.
- Verify FAIL then PASS after correcting only owned test data.
- Existing V3 RANGE/VALUE_SET/CONDITIONAL_REQUIRED regression tests must remain correct.
- Check no source data changed from Verity processes.

### Stage 08: release/rollback

1. Require PR approval, documented applied migration order, role-grant approval, smoke-test evidence and rollback artifact.
2. Tag a release such as `v1.0.0-rc1` only when acceptance tests pass.
3. For rollback, restore the **specific** procedure/view from a verified prior `GET_DDL` or Git artifact; do not drop shared data tables, reset streams or truncate results.
4. Existing historical results must remain inspectable; document any partial profile-run rows and retry strategy.

## Deployment safety rules

- No production deploy from a developer laptop without approved credentials and CI/CD design.
- No plaintext private keys, OAuth secrets, account tokens, or PII in Git.
- Never treat `DONE_WITH_DQ_FAILURES` as an infrastructure exception; DQ failure and execution failure are distinct.
- No automatic activation of AI rules; no source data UPDATE/DELETE privilege to the profiler.
- Snowflake SQL dynamic identifiers should be built from validated objects with `IDENTIFIER()`/bindings; reject unapproved FQNs and quoted-name variants until explicitly supported.
