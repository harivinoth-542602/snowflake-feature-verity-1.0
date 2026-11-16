# 01 — Verity 1.0 Snowflake Foundation

The previous scaffold omitted infrastructure DDL because it targeted the **already deployed** `VERITY_V2` POC. The new release will be deployed in a **separate** `VERITY_V1_0` database: include foundational infrastructure explicitly and keep V2 intact.

## Approved execution order

1. `00_create_database.sql` — new control-plane database.
2. `01_create_warehouse.sql` — **optional**, dedicated XSMALL DEV warehouse; review budget and reuse existing warehouse if preferred.
3. `02_create_core_schemas.sql` — CONFIG, ENGINE, RESULTS, MONITORING.
4. `03_create_practice_schema_dev_only.sql` — optional nonproduction fixture schema.
5. `04_verify_foundation.sql` — read-only verification.

**All CREATE commands use `IF NOT EXISTS`.** Do not use `CREATE OR REPLACE`, `DROP`, `ALTER DATABASE ... RENAME`, or `CLONE VERITY_V2` as an unreviewed shortcut.

## What these scripts do NOT deploy

`DQ_SOURCE`, `DQ_RULE_CATALOG`, `DQ_METRIC_HISTORY`, `DQ_RUN`, `DQ_RULE_RESULT`, `SP_DQ_ONBOARD_TABLE`, `SP_DQ_EXECUTE_HYBRID_V3` and the Cortex Agent **do not yet exist** in the new database merely because its schemas were created. Export the actual deployed definitions from `VERITY_V2` using `sql/00_preflight/01_inventory.sql`; review hardcoded `VERITY_V2` references, exact signatures, status semantics, dependencies and grants; then add **version-controlled, ordered table/procedure/view/Agent migrations**. Deploy and test each dependency before proceeding to profiling implementation. Do not execute procedure DDL blindly after a textual replace.

The legacy demo table `VERITY_V2.PRACTICE.DEMO_CUSTOMER_DQ` remains in V2. Either reference it with explicit, approved read-only grants or create separate V1 DEV fixtures; it is NOT automatically moved. Consult `docs/09_FOUNDATION_BOOTSTRAP.md`.
