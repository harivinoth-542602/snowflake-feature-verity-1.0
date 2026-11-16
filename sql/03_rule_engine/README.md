# 03 — New Rule Handler (IMPLEMENTATION PENDING)

Extend the deployed and version-controlled `SP_DQ_EXECUTE_HYBRID_V3(VARCHAR)` with `NO_EDGE_WHITESPACE`, while preserving verified NOT_NULL, UNIQUE, RANGE, VALUE_SET, CONDITIONAL_REQUIRED, DMF and JSON branches. Avoid overwriting the deployed body using the older historical V3 source without comparing `GET_DDL`. Do not insert ACTIVE whitespace rules before the deployed handler supports them.
