-- World Education analysis queries (SQLite)
-- =========================================
-- These queries and views perform a exploratory data analysis
-- in the database world_indicators.db, using a cleaned schema:
--
--   continents(country_id, country, continent, subregion)
--   economy(country_id, population_2020, gdp_per_capita_2020_usd, avg_gov_exp_edu_gdp_pct_20y)
--   population(country_id, population_2020, urban_pop_pct, gdp_per_capita_2020_usd)
--   education(country_id, avg_*_enrollment_pct, avg_*_completion_pct)
--   education_quality(country_id, avg_pisa_reading, avg_pisa_mathematics, avg_pisa_science)
--
-- Usage from sqlite3:
--   .read sql/analysis_queries.sql
--
-- Then you can SELECT from the views defined below.


-- 1. Country-level summary view
--    (GDP, gov exp, enrollment/completion, PISA)

DROP VIEW IF EXISTS v_country_summary;

CREATE VIEW v_country_summary AS
SELECT
    c.country_id,
    c.country,
    c.continent,
    c.subregion,
    e.gdp_per_capita_2020_usd              AS avg_gdp_per_capita_2020_usd,
    e.avg_gov_exp_edu_gdp_pct_20y          AS avg_gov_exp_edu_gdp_pct_20y,
    ed.avg_primary_enrollment_pct,
    ed.avg_primary_completion_pct,
    ed.avg_secondary_enrollment_pct,
    ed.avg_secondary_completion_pct,
    ed.avg_tertiary_enrollment_pct,
    ed.avg_tertiary_completion_pct,
    eq.avg_pisa_reading,
    eq.avg_pisa_mathematics,
    eq.avg_pisa_science,
    CAST(
        (IFNULL(eq.avg_pisa_reading, 0.0)
        + IFNULL(eq.avg_pisa_mathematics, 0.0)
        + IFNULL(eq.avg_pisa_science, 0.0)) / 3.0
        AS INTEGER
    ) AS avg_pisa
FROM continents AS c
LEFT JOIN economy           AS e  ON e.country_id  = c.country_id
LEFT JOIN education         AS ed ON ed.country_id = c.country_id
LEFT JOIN education_quality AS eq ON eq.country_id = c.country_id;


-- Example usage:
--   SELECT country, continent, avg_gdp_per_capita_2020_usd, avg_pisa
--   FROM v_country_summary
--   WHERE avg_pisa IS NOT NULL
--   ORDER BY avg_pisa DESC
--   LIMIT 10;


-- 2. Subregion-level summary view
--    (aggregate of the country summary)

DROP VIEW IF EXISTS v_subregion_summary;

CREATE VIEW v_subregion_summary AS
SELECT
    c.subregion,
    c.continent,
    CAST(AVG(e.gdp_per_capita_2020_usd) AS INTEGER)       AS avg_gdp_per_capita_2020_usd,
    AVG(e.avg_gov_exp_edu_gdp_pct_20y)                    AS avg_gov_exp_edu_gdp_pct_20y,
    AVG(ed.avg_primary_enrollment_pct)                    AS avg_primary_enrollment_pct,
    AVG(ed.avg_primary_completion_pct)                    AS avg_primary_completion_pct,
    AVG(ed.avg_secondary_enrollment_pct)                  AS avg_secondary_enrollment_pct,
    AVG(ed.avg_secondary_completion_pct)                  AS avg_secondary_completion_pct,
    AVG(ed.avg_tertiary_enrollment_pct)                   AS avg_tertiary_enrollment_pct,
    AVG(ed.avg_tertiary_completion_pct)                   AS avg_tertiary_completion_pct,
    CAST(AVG(eq.avg_pisa_reading)     AS INTEGER)         AS avg_pisa_reading,
    CAST(AVG(eq.avg_pisa_mathematics) AS INTEGER)         AS avg_pisa_mathematics,
    CAST(AVG(eq.avg_pisa_science)     AS INTEGER)         AS avg_pisa_science,
    CAST(AVG(
        (IFNULL(eq.avg_pisa_reading, 0.0)
        + IFNULL(eq.avg_pisa_mathematics, 0.0)
        + IFNULL(eq.avg_pisa_science, 0.0)) / 3.0
    ) AS INTEGER)                                         AS avg_pisa
FROM continents AS c
LEFT JOIN economy           AS e  ON e.country_id  = c.country_id
LEFT JOIN education         AS ed ON ed.country_id = c.country_id
LEFT JOIN education_quality AS eq ON eq.country_id = c.country_id
GROUP BY c.subregion, c.continent;


-- Example usage:
--   SELECT * FROM v_subregion_summary
--   ORDER BY avg_gdp_per_capita_2020_usd DESC;


-- 3. Continent-level summary view

DROP VIEW IF EXISTS v_continent_summary;

CREATE VIEW v_continent_summary AS
SELECT
    c.continent,
    CAST(AVG(e.gdp_per_capita_2020_usd) AS INTEGER)       AS avg_gdp_per_capita_2020_usd,
    AVG(e.avg_gov_exp_edu_gdp_pct_20y)                    AS avg_gov_exp_edu_gdp_pct_20y,
    AVG(ed.avg_primary_enrollment_pct)                    AS avg_primary_enrollment_pct,
    AVG(ed.avg_primary_completion_pct)                    AS avg_primary_completion_pct,
    AVG(ed.avg_secondary_enrollment_pct)                  AS avg_secondary_enrollment_pct,
    AVG(ed.avg_secondary_completion_pct)                  AS avg_secondary_completion_pct,
    AVG(ed.avg_tertiary_enrollment_pct)                   AS avg_tertiary_enrollment_pct,
    AVG(ed.avg_tertiary_completion_pct)                   AS avg_tertiary_completion_pct,
    CAST(AVG(eq.avg_pisa_reading)     AS INTEGER)         AS avg_pisa_reading,
    CAST(AVG(eq.avg_pisa_mathematics) AS INTEGER)         AS avg_pisa_mathematics,
    CAST(AVG(eq.avg_pisa_science)     AS INTEGER)         AS avg_pisa_science,
    CAST(AVG(
        (IFNULL(eq.avg_pisa_reading, 0.0)
        + IFNULL(eq.avg_pisa_mathematics, 0.0)
        + IFNULL(eq.avg_pisa_science, 0.0)) / 3.0
    ) AS INTEGER)                                         AS avg_pisa
FROM continents AS c
LEFT JOIN economy           AS e  ON e.country_id  = c.country_id
LEFT JOIN education         AS ed ON ed.country_id = c.country_id
LEFT JOIN education_quality AS eq ON eq.country_id = c.country_id
GROUP BY c.continent;


-- Example usage:
--   SELECT * FROM v_continent_summary
--   ORDER BY avg_gdp_per_capita_2020_usd DESC;


-- 4. Helper queries

-- 4.1 Countries ordered by GDP per capita

-- SELECT c.country, e.gdp_per_capita_2020_usd AS gdp_per_capita
-- FROM continents AS c
-- JOIN economy   AS e ON e.country_id = c.country_id
-- ORDER BY gdp_per_capita DESC;


-- 4.2 Countries ordered by average government expenditure on education

-- SELECT c.country, e.avg_gov_exp_edu_gdp_pct_20y AS avg_gov_exp_edu
-- FROM continents AS c
-- JOIN economy   AS e ON e.country_id = c.country_id
-- ORDER BY avg_gov_exp_edu DESC;


-- 4.3 Relation between GDP per capita and enrollment/completion (primary example)

-- SELECT
--     c.country,
--     c.continent,
--     e.gdp_per_capita_2020_usd          AS gdp_per_capita,
--     e.avg_gov_exp_edu_gdp_pct_20y      AS avg_gov_exp_edu,
--     ed.avg_primary_enrollment_pct      AS primary_enrollment_pct,
--     ed.avg_primary_completion_pct      AS primary_completion_pct
-- FROM continents AS c
-- LEFT JOIN economy   AS e  ON e.country_id  = c.country_id
-- LEFT JOIN education AS ed ON ed.country_id = c.country_id
-- ORDER BY gdp_per_capita DESC;


-- 4.4 PISA by country (filtering out rows where PISA is missing)

-- SELECT
--     c.country,
--     c.continent,
--     c.subregion,
--     eq.avg_pisa_reading     AS reading,
--     eq.avg_pisa_mathematics AS mathematics,
--     eq.avg_pisa_science     AS science,
--     CAST(
--         (IFNULL(eq.avg_pisa_reading, 0.0)
--        + IFNULL(eq.avg_pisa_mathematics, 0.0)
--        + IFNULL(eq.avg_pisa_science, 0.0)) / 3.0
--         AS INTEGER
--     ) AS avg_pisa
-- FROM continents AS c
-- LEFT JOIN education_quality AS eq ON eq.country_id = c.country_id
-- WHERE eq.avg_pisa_reading IS NOT NULL
-- ORDER BY avg_pisa DESC;

