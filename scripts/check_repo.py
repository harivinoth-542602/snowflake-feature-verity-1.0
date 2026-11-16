"""Offline repository-structure check; intentionally performs NO Snowflake calls."""
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
required = [
    "README.md",
    "docs/01_PRODUCT_AND_HLD.md",
    "docs/02_EXECUTION_FLOW.md",
    "docs/03_DEPLOYMENT_RUNBOOK.md",
    "docs/04_SECURITY_AND_ACCESS.md",
    "docs/05_ROADMAP_AND_NEXT_AGENDA.md",
    "docs/06_ACCEPTANCE_TESTS.md",
    "docs/07_ENGINEERING_DECISIONS.md",
    "docs/08_RELEASE_CHECKLIST.md",
    "sql/00_preflight/00_session_and_objects.sql",
    "sql/00_preflight/01_inventory.sql",
    "sql/00_preflight/02_email_baseline.sql",
    "deploy/ROLE_GRANTS_TEMPLATE.md",
]
missing = [name for name in required if not (root / name).is_file()]
if missing:
    print("Missing required files:", *missing, sep="\n  - ")
    sys.exit(1)
for sql in (root / "sql/00_preflight").glob("*.sql"):
    data = sql.read_text().upper()
    forbidden = ["TRUNCATE TABLE ", "DROP TABLE ", "CREATE OR REPLACE ", "DELETE FROM ", "UPDATE VERITY_V2."]
    if any(token in data for token in forbidden):
        print(f"Review potentially mutating preflight SQL: {sql}")
        sys.exit(1)
print("OK: repository baseline and read-only preflight checks verified.")
