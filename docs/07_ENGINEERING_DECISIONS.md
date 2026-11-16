# 07 — Design Decisions and Open Questions

## Decided

| ID | Decision | Why |
|---|---|---|
| ADR-001 | Pilot one project only, `VERITY_V2.PRACTICE` | Ship correct core discovery before multi-project RBAC |
| ADR-002 | Reuse existing `CONFIG.DQ_SOURCE`, `DQ_RULE_CATALOG`, `DQ_METRIC_HISTORY`, `DQ_RUN`, `DQ_RULE_RESULT` | Avoid duplicate control-plane state |
| ADR-003 | Keep current deployed Hybrid V3; extend narrowly | Protect tested rule types and statuses |
| ADR-004 | Profiling is *discovery* and requires no predefined rule | Distinguishes Verity from a catalog-only testing framework |
| ADR-005 | AI must not auto-approve or alter source data | Business semantics and ownership |
| ADR-006 | Scope excludes JSON, dashboard and ticketing | Matches updated Verity 1.0 brief |
| ADR-007 | Deploy via reviewed, version-controlled migrations | Reproducible, reversible change history |

## Open decisions — must be resolved before coding/merging

| ID | Question | Owner / gate |
|---|---|---|
| Q01 | What counts as edge whitespace—ordinary space only or tabs / Unicode too? | Data steward + engineer |
| Q02 | How do we represent date extrema and sample scope in numerical `DQ_METRIC_HISTORY`? | Data model review |
| Q03 | Does one profiler call store grouped metrics under a profile-run ID or stable query ID? | Observability design |
| Q04 | Full or sampled scanning by default? What cost/time budget? | Engineering owner |
| Q05 | Where do AI proposals persist, if at all, before approval? Is writing DRAFT into current catalog adequate? | Governance owner |
| Q06 | Exact `NO_EDGE_WHITESPACE` semantics for NULL and blank strings? | Rule steward |
| Q07 | Should whitespace be a WARNING or FAIL by default? | Business owner |
| Q08 | Which non-PRACTICE project schema is approved for later roll-out? | Deferred |
| Q09 | Do we need a stable external status API now or next release? | Deferred |

## Explicit naming distinction

The product name is **Verity 1.0**. The real existing Snowflake database is **`VERITY_V2`**. The release does *not* automatically rename databases, schemas or procedures. The latest tested execution entry point is `VERITY_V2.ENGINE.SP_DQ_EXECUTE_HYBRID_V3(VARCHAR)`.
