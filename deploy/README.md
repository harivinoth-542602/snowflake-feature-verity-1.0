# Deployment area

All deployment to Snowflake is intentionally **manual and approval-gated** in this first repository baseline. No auto-deploy workflow or credentials are provided. See `../docs/03_DEPLOYMENT_RUNBOOK.md` and the commented role-grant template. Implemented SQL migration scripts will be added later under the matching numbered `sql` directory, reviewed in PRs, and deployed DEV → TEST → PROD only after corresponding approvals.
