## # Projekt: Projekt z SQL

**Úvod do projektu:**
Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

# Tento projekt vznikl v rámci Engeto Data Akademie a jeho cílem je pomocí SQL odpovědětna výzkumné otázky:
1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách     
   potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

Projekt využívá dvě vlastní čisté tabulky:

- **Primary:** `t_pavol_medo_project_SQL_primary_final`
- **Secondary:** `t_pavol_medo_project_SQL_secondary_final`

Obě tabulky byly vytvořeny transformací a očištěním dat dostupných v systému PostgreSQL.

---

## 📁 Struktura projektu



/projekt_SQL
├─ README.md                  # Popis projektu, použité zdroje, shrnutí výsledků a komentáře k výzkumným otázkám
├─ 01_create_tables.sql       # Skript vytvářející primary a secondary tabulky, včetně potřebných view a mezikroků
├─ 02_research_queries.sql    # Skript obsahující odpovědi/komentáře k jednotlivým výzkumným otázkám


---

# 📘 1. Popis tabulek

## **1. Primary table**  
` t_Pavol_Medo_project_SQL_primary_final `  

### **Sloupce:**
| Sloupec        | Popis |
|----------------|-------|
| year           | Rok |
| industry_name  | Název odvětví |
| avg_wage       | Průměrná mzda v odvětví |
| category_name  | Název potraviny |
| avg_price      | Průměrná cena potraviny |
| units          | Jednotka (kg / l) |

---

## **2. Secondary table**  
` t_Pavol_Medo_project_SQL_secondary_final `  

### **Sloupce:**
| Sloupec        | Popis |
|----------------|-------|
| country_name   | Název státu |
| year           | Rok |
| gdp_million    | HDP v milionech (zaokrouhlené) |
| population     | Populace |

---

# 🎯 2. Odpovědi na výzkumné otázky a SQL dotazy

Součástí projektu je sada SQL dotazů, které získávají datový podklad k odpovědím na výzkumné otázky:

---

## **1️⃣ Otázka:**  
**Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**

➡ SQL dotaz analyzuje růst mezd v období 2000–2021 a počítá meziroční procentuální změnu.

---

## **2️⃣ Otázka:**  
**Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**

➡ Dotaz porovnává kupní sílu mezd vůči cenám dvou položek:  
- *Chléb konzumní kmínový*  
- *Mléko polotučné pasterované*

---

## **3️⃣ Otázka:**  
**Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

➡ Dotaz počítá průměrné meziroční procentuální zdražení u všech potravin a určuje kategorii s nejnižším růstem.

---

## **4️⃣ Otázka:**  
**Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

➡ Dotaz porovnává meziroční růst cen potravin a mezd a identifikuje největší rozdíly.

---

## **5️⃣ Otázka:**  
**Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**

➡ Dotaz porovnává změny HDP s meziroční změnou mezd a cen potravin pro Českou republiku.  
Výsledná tabulka zobrazuje:
- růst HDP,
- meziroční růst mezd,
- meziroční růst cen potravin (2007–2018),
- procentuální změny,
- orientační interpretaci.

---

# 📊 3. Shrnutí výsledků analýzy

### **1. Mzdy**
Mzdy dlouhodobě rostly

### **2. Kupní síla (mléko & chléb)**
Kupní síla se zvýšila – za průměrnou mzdu je možné koupit výrazně více chleba i mléka než na začátku období.

### **3. Nejpomaleji zdražující potravina**
Nejnižší meziroční procentuální růst vykázal **cukr krystalový**.

### **4. Roky s vyšším růstem cen než mezd**
V několika letech ceny rostly rychleji než mzdy, ale žádný rok nepřekročil hranici +10 % rozdílu.

### **5. Vliv HDP na mzdy a ceny**
Výraznější roční růst HDP se nepromítá jednoznačně do výraznějšího růstu mezd ani cen potravin v daném nebo následujícím roce.

---

# 🛠 4. Použité SQL dotazy

Všechny finální dotazy pro výzkumné otázky jsou uloženy v souboru:  

➡ `02_research_queries.sql`

---

# 💡 5. Závěr

Projekt ukazuje, že:
- mzdy v ČR rostly dlouhodobě stabilně,
- kupní síla domácností výrazně posílila,
- nejnižší meziroční procentuální růst vykázal cukr,
- nejvyšší rozdíl nastal v roce 2013, kdy ceny potravin rostly o 6,65 % rychleji než mzdy,
- růst HDP se výrazně nepromítá do růstu mezd a cen potravin.

Tento projekt tak demonstruje použití SQL při analýze reálných ekonomických dat.

---

# 👤 Autor

*Pavol Medo* 
2025


