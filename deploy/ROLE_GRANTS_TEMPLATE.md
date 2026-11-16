# Role Grants — Example Template Only (DO NOT EXECUTE WITHOUT REVIEW)

We will begin with a **single project**. These are **illustrative** grants for a proposed profile role. The live security owner must confirm every privilege and whether the procedure is caller-rights.

```sql
-- Example only: replace role names and exact table permissions after approval.
-- Run with an authorized grants administrator. DO NOT run as an unreviewed batch.
-- CREATE ROLE IF NOT EXISTS VERITY_PROFILE_EXEC;
-- GRANT USAGE ON WAREHOUSE VERITY_V2_WH TO ROLE VERITY_PROFILE_EXEC;
-- GRANT USAGE ON DATABASE VERITY_V2 TO ROLE VERITY_PROFILE_EXEC;
-- GRANT USAGE ON SCHEMA VERITY_V2.PRACTICE TO ROLE VERITY_PROFILE_EXEC;
-- GRANT USAGE ON SCHEMA VERITY_V2.CONFIG TO ROLE VERITY_PROFILE_EXEC;
-- GRANT USAGE ON SCHEMA VERITY_V2.ENGINE TO ROLE VERITY_PROFILE_EXEC;
-- GRANT USAGE ON SCHEMA VERITY_V2.MONITORING TO ROLE VERITY_PROFILE_EXEC;
-- GRANT SELECT ON TABLE VERITY_V2.PRACTICE.DEMO_CUSTOMER_DQ TO ROLE VERITY_PROFILE_EXEC;
-- GRANT SELECT ON TABLE VERITY_V2.CONFIG.DQ_SOURCE TO ROLE VERITY_PROFILE_EXEC;
-- GRANT SELECT ON TABLE VERITY_V2.CONFIG.DQ_RULE_CATALOG TO ROLE VERITY_PROFILE_EXEC;
-- INSERT to the exact deployed metric table is subject to its schema and procedure model.
-- GRANT INSERT ON TABLE VERITY_V2.MONITORING.DQ_METRIC_HISTORY TO ROLE VERITY_PROFILE_EXEC;
```

**Important:** Existing `SP_DQ_EXECUTE_HYBRID_V3(VARCHAR)` uses `EXECUTE AS CALLER` in the inspected source. Its runtime role needs SELECT on source/config and INSERT on deployed DQ_RUN and DQ_RULE_RESULT, with suitable USAGE and any nested dependencies. Keep execution and profiling roles separate unless security approves combination. Never grant UPDATE or DELETE on project source tables to Verity just to enable profiling.
