-- View price_clean

-- DROP VIEW IF EXISTS price_clean; // smazání view

CREATE VIEW price_clean AS
SELECT 
    category_code,
    EXTRACT(YEAR FROM date_from)::INT AS year,
    ROUND(AVG(value)::numeric, 2) AS avg_price
FROM czechia_price
WHERE region_code IS NOT NULL
  AND value IS NOT NULL
GROUP BY 
    category_code,
    EXTRACT(YEAR FROM date_from)
ORDER BY 
    year,
    category_code;

--------------------------------------------------------------------------------------------
-- View price_clean_with_names

-- DROP VIEW IF EXISTS price_clean_with_names;

CREATE OR REPLACE VIEW price_clean_with_names AS
SELECT 
    p.category_code,
    pc.name AS category_name,
    pc.price_unit AS unit,
    EXTRACT(YEAR FROM p.date_from) AS year,
    ROUND(AVG(p.value)::numeric, 2) AS avg_price,
    w.avg_wage,
    ROUND((w.avg_wage / AVG(p.value))::numeric, 2) AS units_per_wage
FROM czechia_price p
JOIN czechia_price_category pc
    ON p.category_code = pc.code
JOIN wage_clean_final w
    ON w.year = EXTRACT(YEAR FROM p.date_from)
WHERE p.region_code IS NOT NULL
GROUP BY 
    p.category_code,
    pc.name,
    pc.price_unit,
    EXTRACT(YEAR FROM p.date_from),
    w.avg_wage
ORDER BY 
    year,
    p.category_code;

--------------------------------------------------------------------------------------------
-- View wage_clean

-- DROP VIEW IF EXISTS wage_clean;

CREATE VIEW wage_clean AS
SELECT
    payroll_year AS year,
    ROUND(AVG(value)::numeric, 2) AS avg_wage
FROM czechia_payroll
WHERE value IS NOT NULL
GROUP BY payroll_year
ORDER BY payroll_year;

--------------------------------------------------------------------------------------------
-- View wage_clean_final

-- DROP VIEW IF EXISTS wage_clean_final;

CREATE OR REPLACE VIEW wage_clean_final AS
SELECT
    p.payroll_year AS year,
    ROUND(AVG(p.value)::numeric, 2) AS avg_wage
FROM czechia_payroll p
WHERE p.value_type_code = 5958   -- průměrná hrubá mzda na zaměstnance
  AND p.calculation_code = 200   -- přepočtené hodnoty
  AND p.unit_code = 200          -- jednotka používána pro mzdy (Kč)
GROUP BY p.payroll_year
ORDER BY p.payroll_year;

---------------------------------------------------------------------------------------------
-- View wage_by_industry_final

-- DROP VIEW IF EXISTS wage_by_industry_final;

CREATE VIEW wage_by_industry_final AS
SELECT
    p.payroll_year AS year,
    i.name AS industry_name,
    ROUND(AVG(p.value)::numeric, 2) AS avg_wage
FROM czechia_payroll p
JOIN czechia_payroll_industry_branch i
    ON p.industry_branch_code = i.code
WHERE p.value_type_code = 5958    -- průměrná hrubá mzda
  AND p.calculation_code = 200     -- přepočtené hodnoty
  AND p.unit_code = 200            -- jednotka Kč
GROUP BY p.payroll_year, i.name
ORDER BY p.payroll_year, i.name;

------------------------------------------------------------------------------------------------

-- Primary table

------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS t_pavol_medo_project_SQL_primary_final;

CREATE TABLE t_pavol_medo_project_SQL_primary_final AS

-- Část 1: mzdy podle odvětví
SELECT
    w.year AS year,
    w.industry_name,
    ROUND(w.avg_wage, 2) AS avg_wage,
    NULL::varchar AS category_name,
    NULL::numeric AS avg_price,
    NULL::numeric AS units
FROM wage_by_industry_final w

UNION ALL

-- Část 2: ceny potravin a jednotky, kolik si lze koupit
SELECT
    p.year AS year,
    NULL::varchar AS industry_name,
    NULL::numeric AS avg_wage,
    p.category_name,
    ROUND(p.avg_price, 2) AS avg_price,
    ROUND(w.avg_wage / p.avg_price, 2) AS units
FROM price_clean_with_names p
JOIN wage_clean_final w
    ON p.year = w.year;

-------------------------------------------------------------------------------------------------

-- Secondary table

-------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS t_pavol_medo_project_SQL_secondary_final;

CREATE TABLE t_pavol_medo_project_SQL_secondary_final AS
SELECT
    c.country AS country_name,
    e.year,
    ROUND(e.gdp::numeric / 1000000, 2) AS gdp_million,  -- HDP v milionech
    e.population
FROM countries c
JOIN economies e
    ON c.country = e.country
WHERE e.year IN (SELECT DISTINCT year FROM t_pavol_medo_project_SQL_primary_final)
ORDER BY c.country, e.year;


--------------------------------------------------------------------------------------------------
