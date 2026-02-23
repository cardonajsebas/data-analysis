# Global Education & Economic Indicators: A Full-Stack Data Analysis Pipeline

![Python](https://img.shields.io/badge/Python-3.12-blue) ![SQL](https://img.shields.io/badge/SQL-SQLite-orange) ![Tableau](https://img.shields.io/badge/Visualization-Tableau-blueviolet)

Project in SQL and Python: process and analyze datasets on world population, economy, and education. Personal project to demonstrate data cleaning and validation, SQL (schema, joins, aggregations), exploratory analysis in Python, and storytelling in Tableau.

## Project Overview
How does a nation's wealth impact its educational outcomes? This project explores the relationship between GDP per capita, government education spending, and student performance (PISA) across 200+ countries. 

Unlike simple CSV-to-Pandas projects, this utilizes a **professional data engineering workflow**: raw data is cleaned, standardized, and loaded into a relational database (SQLite) where complex analytical views are created for downstream analysis.

### Project Links
* **Interactive Dashboard:** [View on Tableau Public](https://public.tableau.com/views/Eduacationintheworld/Dashboard1)

---

## Tech Stack & Methodology
* **Data Engineering:** SQL (SQLite), Python (Pandas)
* **Database Design:** Relational schema with primary/foreign keys and analytical views (CTEs).
* **EDA:** Seaborn/Matplotlib for correlation analysis and trend identification.
* **Cleaning:** Handled country-name normalization across 5 distinct data sources and resolved statistical anomalies (e.g., PISA score zero-handling).

## Key Insights
* **Wealth vs. Quality:** There is a strong logarithmic correlation between GDP per capita and PISA scores; however, the relationship plateaus after a certain wealth threshold.
* **The Spending Paradox:** Government expenditure as a % of GDP does not always translate to higher PISA scores, suggesting that **educational efficiency** is more impactful than sheer volume of funding.
* **Regional Disparities:** Primary completion rates have reached near-saturation globally, but tertiary enrollment remains heavily skewed by sub-region.

---

## Project structure

- **`data/`** — Raw CSVs (economy, population, education, quality_education, continents; plus OWID files in `Economy/` and `Education/`).
- **`data/processed/`** — Cleaned CSVs produced by the pipeline (continents, economy, population, education, education_quality).
- **`notebooks/`** — Jupyter notebooks: data overview, cleaning, DB build, populate, EDA.
- **`sql/`** — SQLite schema (`schema.sql`) and analysis queries/views (`analysis_queries.sql`).
- **`scripts/`** — Optional Python scripts (e.g. build DB from CLI).

## Pipeline (recommended order)

1. **`01_data_overview.ipynb`** — Inspect raw CSVs and document schema.
2. **`02_build_sqlite_db.ipynb`** — Create the SQLite database and run `sql/schema.sql` (or use the CLI steps below).
3. **`03_data_cleaning_and_standardization.ipynb`** — Normalize country names, validate data, export cleaned CSVs to `data/processed/`.
4. **`04_populate_data.ipynb`** — Load cleaned CSVs into the DB (continents first, then economy, population, education, education_quality using `country_id`).
5. **`05_python_eda.ipynb`** — Exploratory analysis and visualizations from the database (queries and plots).
6. **Analysis views** — Run `sql/analysis_queries.sql` to create summary views; use them in Tableau or in the EDA notebook.

---

## How to Run
1. Clone the repository.
2. Install dependencies: `pip install -r requirements.txt`.
3. Run the notebooks in numerical order to build the local database and generate the analysis.

### Creating the database

The SQLite database and tables are defined in `sql/schema.sql`. You can create the database in either of these ways:

#### Option A — sqlite3 CLI

From the project root (`world_education/`):

```bash
cd world_education
sqlite3 world_education.db
```

At the `sqlite>` prompt:

```sql
.read sql/schema.sql
.tables
.quit
```

This creates `world_education.db` with empty tables. To use the same file as the notebooks (e.g. `world_indicators.db`), run `sqlite3 world_indicators.db` instead.

#### Option B — Python (Jupyter notebook)

Run **`notebooks/02_build_sqlite_db.ipynb`** from the project root. It runs `sql/schema.sql` and creates the database (e.g. `world_indicators.db` by default).

### Populating the database

After the schema exists, run **`notebooks/04_populate_data.ipynb`** from the project root (with the notebook’s working directory set so that `..` is `world_education/`). It reads from `data/processed/` and inserts rows in order: continents first (to get `country_id`), then economy, population, education, education_quality. The notebook uses the DB path defined inside it (e.g. `world_indicators.db`).

### Analysis queries and views

**`sql/analysis_queries.sql`** defines three views that mirror the original SQL Server summary tables:

- **`v_country_summary`** — One row per country: GDP per capita, gov expenditure on education, enrollment/completion (primary, secondary, tertiary), PISA scores and average PISA.
- **`v_subregion_summary`** — Same metrics aggregated by subregion and continent.
- **`v_continent_summary`** — Same metrics aggregated by continent.

Create the views (after the DB is populated) by running the script in sqlite3:

```bash
sqlite3 world_indicators.db
```

```sql
.read sql/analysis_queries.sql
SELECT * FROM v_continent_summary ORDER BY avg_gdp_per_capita_2020_usd DESC LIMIT 5;
```

You can also run the script from Python and then query the views with `pandas.read_sql()` for EDA or for exporting CSVs for Tableau.

---

## Data sources

The datasets used in this project are public and were obtained from:

- https://ourworldindata.org/
- https://www.worldbank.org/en/home
- https://worldpopulationreview.com/

---

By, John S Cardona
