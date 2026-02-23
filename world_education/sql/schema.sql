-- world_education SQLite schema
-- ==========================================
-- This file defines the core tables for the project.
-- You can load it in sqlite3 with:
--   .read sql/schema.sql
--
-- Design goals:
-- - One row per country in each core table.
-- - Surrogate key: country_id (integer) in the lookup table; all other tables reference it.
-- - Joins use country_id; country name lives only in continents.
-- - Use clean snake_case column names. Use TEXT / INTEGER / REAL types.

PRAGMA foreign_keys = ON;


-- 1. Lookup table: continents (country dimension)
--    Source CSV: data/continents.csv
--    Columns in CSV: country, continent, subregion
-- country_id is the surrogate key (1, 2, 3...). INTEGER PRIMARY KEY AUTOINCREMENT
-- assigns it. Keep "country" as the unique name to match CSVs when loading.

CREATE TABLE IF NOT EXISTS continents (
    country_id INTEGER PRIMARY KEY AUTOINCREMENT,
    country    TEXT NOT NULL UNIQUE,   -- e.g. 'Afghanistan'
    continent  TEXT NOT NULL,
    subregion  TEXT
);


-- 2. Economy table
--    Source CSV: data/economy.csv
--    Join key: country_id → continents(country_id). Do not store country name
--    here; get it by joining to continents in queries.

CREATE TABLE IF NOT EXISTS economy (
    country_id                  INTEGER PRIMARY KEY,
    population_2020             INTEGER,
    gdp_per_capita_2020_usd     REAL,
    avg_gov_exp_edu_gdp_pct_20y REAL,
    FOREIGN KEY (country_id) REFERENCES continents(country_id)
);


-- 3. Population table
--    Source CSV: data/population.csv
--    CSV columns: Country, Population (2020), Urban Pop %, GDP per capita 2020 (USD)

CREATE TABLE IF NOT EXISTS population (
    country_id              INTEGER PRIMARY KEY,
    population_2020         INTEGER,
    urban_pop_pct           REAL,
    gdp_per_capita_2020_usd REAL,
    FOREIGN KEY (country_id) REFERENCES continents(country_id)
);


-- 4. Education table
--    Source CSV: data/education.csv
--    CSV columns:
--      Country,
--      Avg primary enrollment ratio (%),
--      Avg primary completion rate (%),
--      Avg secondary enrollment ratio (%),
--      Avg secondary completion rate (%),
--      Avg terciary enrollment ratio (%),
--      Avg terciary completion rate (%)

CREATE TABLE IF NOT EXISTS education (
    country_id                     INTEGER PRIMARY KEY,
    avg_primary_enrollment_pct     REAL,
    avg_primary_completion_pct     REAL,
    avg_secondary_enrollment_pct  REAL,
    avg_secondary_completion_pct  REAL,
    avg_tertiary_enrollment_pct   REAL,
    avg_tertiary_completion_pct   REAL,
    FOREIGN KEY (country_id) REFERENCES continents(country_id)
);


-- 5. Education quality (PISA) table
--    Source CSV: data/quality_education.csv
--    CSV columns:
--      Country,
--      Avg PISA performance_reading,
--      Avg PISA performance_mathematics,
--      Avg PISA performance_science

CREATE TABLE IF NOT EXISTS education_quality (
    country_id           INTEGER PRIMARY KEY,
    avg_pisa_reading     REAL,
    avg_pisa_mathematics REAL,
    avg_pisa_science     REAL,
    FOREIGN KEY (country_id) REFERENCES continents(country_id)
);


-- 6. Indexes (optional, for performance)

CREATE INDEX IF NOT EXISTS idx_economy_gdp_per_capita
    ON economy (gdp_per_capita_2020_usd);

CREATE INDEX IF NOT EXISTS idx_education_primary_enrollment
    ON education (avg_primary_enrollment_pct);

