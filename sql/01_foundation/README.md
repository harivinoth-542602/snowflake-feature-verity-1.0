# 01 — Existing Control-Plane Foundation

**Status: REUSE / EXPORT LIVE DDL; no CREATE OR REPLACE scripts yet.**

Current known objects: `DQ_SOURCE`, `DQ_RULE_CATALOG`, `DQ_METRIC_HISTORY`, `DQ_RUN`, `DQ_RULE_RESULT`, existing on-boarder, Hybrid V3 and seven-tool agent. Use `sql/00_preflight/01_inventory.sql` to export/compare actual deployed definitions. Before adding a migration, check it against live DDL; do not fabricate a new definition or reset shared tables.
