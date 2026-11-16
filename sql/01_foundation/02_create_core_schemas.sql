-- VERITY 1.0: ONE-TIME CONTROL PLANE SCHEMAS
-- Requires ownership/CREATE SCHEMA privilege on VERITY_V1_0.
-- Does not create catalog tables, procedures or grants.
CREATE SCHEMA IF NOT EXISTS VERITY_V1_0.CONFIG
    COMMENT = 'Approved source and rule configuration';
CREATE SCHEMA IF NOT EXISTS VERITY_V1_0.ENGINE
    COMMENT = 'Controlled data quality execution procedures';
CREATE SCHEMA IF NOT EXISTS VERITY_V1_0.RESULTS
    COMMENT = 'Data quality run and rule outcomes';
CREATE SCHEMA IF NOT EXISTS VERITY_V1_0.MONITORING
    COMMENT = 'Aggregate profiling metrics and Cortex analysis context';
