-- Run AFTER the bootstrap. Read only.
SELECT CURRENT_ACCOUNT() AS ACCOUNT_NAME,
       CURRENT_ROLE() AS EXECUTING_ROLE,
       CURRENT_WAREHOUSE() AS CURRENT_WAREHOUSE;
SHOW DATABASES LIKE 'VERITY_V1_0';
SHOW WAREHOUSES LIKE 'VERITY_V1_0_WH';
SHOW SCHEMAS IN DATABASE VERITY_V1_0;
-- This script verifies only foundation objects. The catalogs/procedures/agent
-- are NOT yet deployed; do not assume they exist after this check.
