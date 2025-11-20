-----------------------------------------------------------------------------------------------------

-- 1. Výzkumná otázka

-----------------------------------------------------------------------------------------------------

WITH wage_changes AS (
    SELECT
        industry_name,
        year,
        avg_wage,
        avg_wage - LAG(avg_wage) OVER (PARTITION BY industry_name ORDER BY year) AS wage_change
    FROM t_jmeno_prijmeni_project_SQL_primary_final
    WHERE industry_name IS NOT NULL
)
SELECT
    industry_name,
    COUNT(CASE WHEN wage_change > 0 THEN 1 END) AS years_increase,
    COUNT(CASE WHEN wage_change < 0 THEN 1 END) AS years_decrease,
    ROUND(AVG(wage_change), 2) AS avg_yearly_change,
    CASE
        WHEN AVG(wage_change) > 0 THEN 'rostou'
        WHEN AVG(wage_change) < 0 THEN 'klesají'
        ELSE 'stagnují'
    END AS overall_trend
FROM wage_changes
GROUP BY industry_name
ORDER BY overall_trend DESC, avg_yearly_change DESC;

-----------------------------------------------------------------------------------------------------------------------

-- komentář: Průměrné mzdy v jednotlivých odvětvích jsme analyzovali za období 2000–2021 (dle dostupných dat
-- v primární tabulce). Dotaz ukazuje, že ve většině odvětví mzdy rostly, avšak v některých letech došlo k poklesu mezd.
-- Sloupec years_increase ukazuje, kolik let mzdy rostly, years_decrease kolik let klesaly, a avg_yearly_change udává
-- průměrný roční přírůstek. Celkový trend (overall_trend) shrnuje, zda mzdy v daném odvětví spíše rostou, klesají nebo
-- stagnují.

-----------------------------------------------------------------------------------------------------------------------

-- 2. Výzkumná otázka

-----------------------------------------------------------------------------------------------------------------------

WITH wages_per_year AS (
    SELECT year, ROUND(AVG(avg_wage), 2) AS avg_wage
    FROM t_jmeno_prijmeni_project_SQL_primary_final
    WHERE industry_name IS NOT NULL
    GROUP BY year
),
relevant_data AS (
    SELECT
        p.year,
        p.category_name,
        p.avg_price,
        w.avg_wage,
        ROUND(w.avg_wage / p.avg_price, 2) AS units
    FROM t_jmeno_prijmeni_project_SQL_primary_final p
    JOIN wages_per_year w
        ON p.year = w.year
    WHERE p.category_name IN ('Chléb konzumní kmínový', 'Mléko polotučné pasterované')
)
SELECT DISTINCT
    category_name,
    FIRST_VALUE(year) OVER (PARTITION BY category_name ORDER BY year ASC) AS first_year,
    FIRST_VALUE(avg_wage) OVER (PARTITION BY category_name ORDER BY year ASC) AS wage_first_year,
    FIRST_VALUE(avg_price) OVER (PARTITION BY category_name ORDER BY year ASC) AS price_first_year,
    FIRST_VALUE(units) OVER (PARTITION BY category_name ORDER BY year ASC) AS units_first_year,
    FIRST_VALUE(year) OVER (PARTITION BY category_name ORDER BY year DESC) AS last_year,
    FIRST_VALUE(avg_wage) OVER (PARTITION BY category_name ORDER BY year DESC) AS wage_last_year,
    FIRST_VALUE(avg_price) OVER (PARTITION BY category_name ORDER BY year DESC) AS price_last_year,
    FIRST_VALUE(units) OVER (PARTITION BY category_name ORDER BY year DESC) AS units_last_year
FROM relevant_data
ORDER BY category_name;

-----------------------------------------------------------------------------------------------------------------------

-- komentář: Pracovník si na začátku období mohl za průměrnou mzdu koupit téměř 1465 litrů mléka a téměř 1313 kg chleba,
-- na konci období 1669 litrů mléka a 1365 kg chleba.
-- Kupní síla se tedy v čase změnila, přičemž je vidět, jak růst mezd a cen ovlivnil dostupnost základních potravin.

-----------------------------------------------------------------------------------------------------------------------

-- 3. Výzkumná otázka

-----------------------------------------------------------------------------------------------------------------------

WITH price_changes AS (
    SELECT
        category_name,
        year,
        avg_price,
        LAG(avg_price) OVER (PARTITION BY category_name ORDER BY year) AS prev_price
    FROM t_jmeno_prijmeni_project_SQL_primary_final
    WHERE category_name IS NOT NULL
)
SELECT
    category_name,
    ROUND(AVG((avg_price - prev_price) / prev_price * 100), 2) AS avg_yearly_pct_change
FROM price_changes
WHERE prev_price IS NOT NULL
GROUP BY category_name
ORDER BY avg_yearly_pct_change ASC
LIMIT 1;

------------------------------------------------------------------------------------------------------------------

-- komentář: Nejpomaleji se meziročními změnami cen zdražoval cukr krystalový, jehož průměrná cena v daném období
-- dokonce klesala o 1,92 % ročně.

------------------------------------------------------------------------------------------------------------------

-- 4. Výzkumná otázka

------------------------------------------------------------------------------------------------------------------

WITH food_prices AS (
    SELECT
        year,
        AVG(avg_price) AS avg_price_food
    FROM t_jmeno_prijmeni_project_SQL_primary_final
    WHERE category_name IS NOT NULL
    GROUP BY year
),
wages AS (
    SELECT
        year,
        AVG(avg_wage) AS avg_wage
    FROM t_jmeno_prijmeni_project_SQL_primary_final
    WHERE industry_name IS NOT NULL
    GROUP BY year
),
price_changes AS (
    SELECT
        f.year,
        f.avg_price_food,
        LAG(f.avg_price_food) OVER (ORDER BY f.year) AS prev_price_food
    FROM food_prices f
),
wage_changes AS (
    SELECT
        w.year,
        w.avg_wage,
        LAG(w.avg_wage) OVER (ORDER BY w.year) AS prev_wage
    FROM wages w
)
SELECT
    p.year,
    ROUND(((p.avg_price_food - p.prev_price_food)/p.prev_price_food)*100, 2) AS price_change_pct,
    ROUND(((w.avg_wage - w.prev_wage)/w.prev_wage)*100, 2) AS wage_change_pct,
    ROUND((((p.avg_price_food - p.prev_price_food)/p.prev_price_food) - ((w.avg_wage - w.prev_wage)/w.prev_wage))*100, 2) AS difference_pct,
    CASE
        WHEN (((p.avg_price_food - p.prev_price_food)/p.prev_price_food) - ((w.avg_wage - w.prev_wage)/w.prev_wage))*100 > 10 
        THEN 'ceny rostou výrazně rychleji než mzdy'
        ELSE 'bez výrazného rozdílu'
    END AS comment
FROM price_changes p
JOIN wage_changes w ON p.year = w.year
WHERE p.prev_price_food IS NOT NULL
ORDER BY p.year;

-----------------------------------------------------------------------------------------------------------------------

-- komentář: Analýza meziročního růstu ukazuje, že v žádném roce (mezi lety 2006 - 2018) nedošlo k růstu cen potravin
-- výrazně vyššímu než růstu mezd (většímu než 10 %). V některých letech rostly ceny pomaleji než mzdy
-- (záporné hodnoty ve sloupci difference).
-- Nejvyšší rozdíl nastal v roce 2013, kdy ceny potravin rostly o 6,65 % rychleji než mzdy.

-----------------------------------------------------------------------------------------------------------------------

-- 5. Výzkumná otázka

-----------------------------------------------------------------------------------------------------------------------

WITH cr_data AS (
    SELECT 
        s.year,
        ROUND(s.gdp_million, 2) AS gdp_million,
        ROUND(AVG(p.avg_wage), 2) AS avg_wage,
        ROUND(AVG(p.avg_price), 2) AS avg_price
    FROM t_jmeno_prijmeni_project_SQL_secondary_final s
    JOIN t_jmeno_prijmeni_project_SQL_primary_final p
        ON s.year = p.year
    WHERE s.country_name = 'Czech Republic'
    GROUP BY s.year, s.gdp_million
),
yearly_change AS (
    SELECT
        year,
        gdp_million,
        avg_wage,
        avg_price,
        avg_wage - LAG(avg_wage) OVER (ORDER BY year) AS wage_change,
        avg_price - LAG(avg_price) OVER (ORDER BY year) AS price_change,
        CASE WHEN LAG(avg_wage) OVER (ORDER BY year) IS NOT NULL 
             THEN ROUND(100 * (avg_wage - LAG(avg_wage) OVER (ORDER BY year)) / LAG(avg_wage) OVER (ORDER BY year), 2)
             ELSE NULL
        END AS wage_change_pct,
        CASE WHEN LAG(avg_price) OVER (ORDER BY year) IS NOT NULL 
             THEN ROUND(100 * (avg_price - LAG(avg_price) OVER (ORDER BY year)) / LAG(avg_price) OVER (ORDER BY year), 2)
             ELSE NULL
        END AS price_change_pct,
        gdp_million - LAG(gdp_million) OVER (ORDER BY year) AS gdp_change
    FROM cr_data
)
SELECT
    year,
    gdp_million,
    ROUND(gdp_change, 2) AS gdp_change_million,
    avg_wage,
    ROUND(wage_change, 2) AS wage_change,
    wage_change_pct,
    CASE 
        WHEN wage_change > 0 THEN 'Mzdy rostly'
        WHEN wage_change < 0 THEN 'Mzdy klesaly'
        ELSE NULL
    END AS wage_comment,
    avg_price,
    ROUND(price_change, 2) AS price_change,
    price_change_pct,
    CASE 
        WHEN price_change > 0 THEN 'Ceny potravin rostly'
        WHEN price_change < 0 THEN 'Ceny potravin klesaly'
        ELSE NULL
    END AS price_comment
FROM yearly_change
ORDER BY year;

-----------------------------------------------------------------------------------------------------------------------

-- komentář: Analýza vlivu HDP na mzdy a ceny potravin (ČR):
-- V období 2000 - 2020 nevykazují meziroční změny mezd přímou souvislost s ročními výkyvy HDP. I v letech s
-- výraznějším růstem HDP se mzdy zvyšovaly jen mírně nebo v roce 2014 naopak mírně klesaly – pokles HDP se téměř
-- neprojevil snížením mezd.
-- Meziroční změny cen potravin období 2007–2018 rovněž nevykazují silnou závislost na růstu HDP.
-- I v letech s vyšším nárůstem HDP nebyl nárůst cen potravin výrazně rychlejší než průměrný trend, s maximálním
-- meziročním rozdílem cca 6,65 % v roce 2013.

-- Shrnutí: Výraznější roční růst HDP se nepromítá jednoznačně do výraznějšího růstu mezd ani cen potravin
-- v daném nebo následujícím roce. Data tedy nenaznačují silnou bezprostřední závislost mezi HDP a těmito ukazateli.
-- *HDP pro rok 2021 v secondary tabulce chybí, resp. tato data nejsou ve zdrojové tabulce economies

-----------------------------------------------------------------------------------------------------------------------