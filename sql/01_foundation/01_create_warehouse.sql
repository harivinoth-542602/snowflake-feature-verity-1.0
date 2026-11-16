-- VERITY 1.0: ONE-TIME DEV WAREHOUSE BOOTSTRAP
-- Run after DBA/FinOps approval using a role with CREATE WAREHOUSE on ACCOUNT.
-- Separate warehouse is OPTIONAL; reusing a permitted existing warehouse is also valid.
-- IF NOT EXISTS does not modify an existing warehouse's configuration.
-- Snowflake will incur compute credits when queries resume this warehouse.
CREATE WAREHOUSE IF NOT EXISTS VERITY_V1_0_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
         AUTO_SUSPEND = 60
         AUTO_RESUME = TRUE
         INITIALLY_SUSPENDED = TRUE
         COMMENT = 'Verity 1.0 DEV validation and profiling';
