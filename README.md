# ApartmentCare – Apartment Maintenance & Resident Complaint Management

A multi-technology assessment project for Java, DBMS, Python/Data Science and Software Engineering.

## Project structure
- `database/`: MariaDB schema, triggers, views, advanced queries, seeded offline SQLite fixture and data generator.
- `java/`: layered Java/JDBC source with generic DAO, services, transactions and `--demo` concurrency run.
- `python/`: pandas + matplotlib + seaborn analytics; output contains cleaned data, 12 charts and insight report.
- `website/`: responsive, self-contained static dashboard/portal/building view.
- `docs/`: SRS, ER/class/architecture diagrams, BCNF, test plan, estimation, traceability and syllabus mapping.
- `.github/workflows/pages.yml`: GitHub Pages deployment.

## One-command offline run
Requirements: Python 3.10+, Java 17+. Python packages are pandas, matplotlib, seaborn and Playwright (for browser test). Chromium is needed for the headless browser check.

```bash
./run_all.sh
```

The script rebuilds the seeded SQLite demonstration database, runs integrity tests, compiles Java, runs the Java demo, creates analytics/charts, headless-tests the website, and reconciles apartment/charge/complaint totals across SQL, Java CSV counts and Python. This proves the portable offline path. MariaDB production DDL is supplied separately and is not silently substituted by SQLite.

## MariaDB setup
Install MariaDB 10.6+ or MySQL 8.0+, then:

```bash
mariadb -u root -p < database/schema.sql
```
Run `python database/seed_generator.py` to create `database/mariadb_seed.sql`, then import it with `mariadb -u root -p < database/mariadb_seed.sql`. Configure Java with `DB_URL`, `DB_USER`, and `DB_PASSWORD`, then run the JDBC console app with the MariaDB JDBC driver (Maven dependency in `java/pom.xml`).

## Java
```bash
javac -d java/target/classes $(find java/src/main/java -name '*.java')
java -cp java/target/classes com.apartment.ui.Main --demo
```
For JDBC mode, configure `DB_URL`, `DB_USER`, and `DB_PASSWORD`, then run `cd java && mvn exec:java -Dexec.mainClass=com.apartment.ui.Main`. `--demo` does not require a database.

## Python analytics
```bash
python database/seed_generator.py
python python/analyze.py
```
Charts and report are in `python/output/`. By default analytics reads the offline SQLite fixture. To read MariaDB directly, set `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` before running the script (install `python/requirements.txt`).

## Website
Open `website/index.html` in a browser. The site is a local prototype: state is stored in browser localStorage, payments are simulated, and no production authentication or server-side authorization is implemented. Use “Load sample data” to reset the demonstration.

## GitHub Pages
Push the repository to GitHub, enable Actions, and set Pages source to GitHub Actions. The workflow deploys `website/` only; it does not deploy a database or backend.

## GitHub push guide
```bash
git init
git add .
git commit -m "Build ApartmentCare assessment project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/apartmentcare.git
git push -u origin main
```

## Verification and limitations
See `screenshots/` and `docs/test-plan.md`. The MariaDB schema/triggers and Java JDBC integration require a MariaDB server; they are provided but not represented as executed in the offline build. The offline test fixture validates uniqueness, foreign keys, payment limits, occupancy, future-date rejection, complaint transitions/audit history, and seeded volumes. Website actions are demonstrative and should not be used for real financial transactions.
