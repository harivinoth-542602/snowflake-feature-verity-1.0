# 08 — Release Checklist: Verity 1.0

**Release candidate:** __________  
**Owner:** __________  
**Snowflake role:** __________  
**Target environment:** __________  
**Git commit:** __________

## Foundation

- [ ] `main` protected, PR approved, no credentials or raw PII in Git.
- [ ] Deployed objects exported via `GET_DDL`; dependencies and signatures reviewed.
- [ ] Existing rule catalog, metric and run/result data preserved.
- [ ] Existing stored procedure rights model verified (`EXECUTE AS CALLER`).

## Profiling

- [ ] Structured type dispatch works for text, numeric, date/timestamp and identifiers.
- [ ] Nulls, blanks, whitespace, distinct and min/max reference counts match tests.
- [ ] Profiling works without a pre-existing rule.
- [ ] Unsupported data types reported as skipped.
- [ ] Query count, warehouse/time/credit impact measured and documented.

## Intelligent profiling test coverage

- [ ] Core `TC_01`, `TC_02`, `TC_04`, `TC_05`, `TC_06`, `TC_10`, `TC_11` each have expected-vs-actual profiling evidence or an explicit release exception.
- [ ] Stretch `TC_03`, `TC_07`, `TC_08`, `TC_09`, `TC_12` have documented ownership and deferment status; do not silently mark them complete.
- [ ] Reference counts and denominators are validated on dedicated nonproduction fixtures; edge whitespace definition remains ordinary U+0020.
- [ ] AI recommendations distinguish observed evidence from policy assumptions; raw identifying values are not sent to Cortex.

## Recommendations and rule governance

- [ ] Cortex Agent uses actual aggregate profile evidence.
- [ ] Observed vs suggested facts distinguished; duplicates excluded.
- [ ] New recommendation enters DRAFT review; human activation required.
- [ ] No source mutations performed by Agent or profiler.

## Validation / regression

- [ ] `NO_EDGE_WHITESPACE` handler deployed with approved semantics.
- [ ] Existing NOT_NULL/UNIQUE/RANGE/VALUE_SET/CONDITIONAL_REQUIRED tests still pass.
- [ ] Expected failure and corrected-data pass both persisted.
- [ ] DQ failures are not misclassified as infrastructure errors.
- [ ] Read-only source role verified; denied-access test verified.

## Deployment decision

- [ ] Release owner confirms scope and evidence.
- [ ] Rollback artifact saved and tested for changed object.
- [ ] Final deployment timestamp and applied migrations recorded.
- [ ] Signoff: ________  Date: ________

**No unchecked item may be represented as 'implemented' or 'verified'.**
