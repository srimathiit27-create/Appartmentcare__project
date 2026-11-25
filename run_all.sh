#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
echo '=== STAGE 1: Seed offline database ==='
python database/seed_generator.py
python database/sqlite_tests.py
echo '=== STAGE 2: Compile and run Java ==='
mkdir -p java/target/classes
find java/src/main/java -name '*.java' -print0 | xargs -0 javac -d java/target/classes
java -cp java/target/classes com.apartment.ui.Main --demo
echo '=== STAGE 3: Python analytics ==='
python python/analyze.py
echo '=== STAGE 4: Headless website test ==='
python website/test_site.py
echo '=== STAGE 5: Documentation and deployment artifacts ==='
for file in docs/SRS.md docs/diagrams.md docs/normalization.md docs/test-plan.md docs/estimation.md docs/traceability.md docs/syllabus-mapping.md README.md .github/workflows/pages.yml; do test -s "$file"; done
echo 'DOCUMENTATION CHECK PASS'
echo '=== CROSS-CHECK ==='
python - <<'PY'
import sqlite3,json
c=sqlite3.connect('database/apartment_demo.sqlite')
sql={'apartments':c.execute('select count(*) from apartment').fetchone()[0],'charges':c.execute('select count(*) from maintenance_charge').fetchone()[0],'complaints':c.execute('select count(*) from complaint').fetchone()[0]}
py=json.load(open('python/output/metrics.json'))
jv=json.load(open('java/target/java-counts.json'))
print('SQL counts:',sql); print('Java counts:',jv); print('Python counts:',{k:py[k] for k in sql})
assert all(sql[k]==py[k]==jv[k] for k in sql)
print('CROSS-CHECK PASS')
PY

echo 'ALL OFFLINE STAGES PASSED'
