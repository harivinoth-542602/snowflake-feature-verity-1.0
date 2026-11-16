-- VERITY 1.0: ONE-TIME DATABASE BOOTSTRAP (DEV)
-- Run after DBA approval with a role possessing CREATE DATABASE on ACCOUNT.
-- Safe for an existing VERITY_V1_0: IF NOT EXISTS, no replacement or rename.
-- Does NOT copy objects from or change VERITY_V2.
CREATE DATABASE IF NOT EXISTS VERITY_V1_0
    COMMENT = 'Verity 1.0 - structured data quality control plane';
