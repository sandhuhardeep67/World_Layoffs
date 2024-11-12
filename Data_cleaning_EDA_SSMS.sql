USE WorldLayoffs;

SELECT * FROM layoffs;


------- A duplicate table is created to preserve the integrity of the raw data,
------ ensuring that the original dataset remains untouched for future reference and validation.


SELECT *
INTO layoffs_analysis
FROM layoffs
WHERE 1 = 0 ;

INSERT INTO layoffs_analysis
SELECT *
FROM layoffs ;

SELECT * FROM layoffs_analysis;


-------------------------------------                                DATA CLEANING                               ------------------------------------------




------------------------------- To efficiently eliminate duplicate entries, I used a Common Table Expression (CTE) -----------------------------

WITH duplicate_cte AS 
	(SELECT *,
	ROW_NUMBER() OVER
	(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions ORDER BY company) AS row_num
	FROM layoffs_analysis)
DELETE
FROM duplicate_cte
WHERE row_num > 1;



------------------------------- 1. Standardizing Data -----------------------------------------


------ Trimming any unnesessary spacing -------

UPDATE layoffs_analysis 
SET	company = TRIM(company),
	location = TRIM(location),
	industry = TRIM(industry),
	total_laid_off = TRIM(total_laid_off),
	percentage_laid_off = TRIM(percentage_laid_off),
	date = TRIM(date),
	stage = TRIM(stage),
	country = TRIM(country),
	funds_raised_millions = TRIM(funds_raised_millions) ;


------ Correcting Inconsistent Data ------

-- Through manual analysis, I discovered that the industry column contained few entries with the same text but inconsistent formatting,
--  so to ensure the data consistency I standardized these values.
SELECT *
FROM layoffs_analysis
WHERE industry LIKE 'crypto%' ;

UPDATE layoffs_analysis
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%' ;

-- Through careful analysis, I identified that one of the country names had been entered with a trailing period. 
-- I corrected this inconsistency to ensure the column is standardized and uniform.

SELECT DISTINCT country
FROM layoffs_analysis
ORDER BY 1;

UPDATE layoffs_analysis
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%' ;




----------------------------------------2. Null and Blank Values ----------------------------------

----Standardized the data by converting blank values and the string 'NULL' to actual NULL values, ensuring consistency and improving data quality.

UPDATE layoffs_analysis
SET 
    company = NULLIF(company, 'NULL'),
    location = NULLIF(location, 'NULL'),
    industry = NULLIF(industry, 'NULL'),
    total_laid_off = NULLIF(total_laid_off, 'NULL'),
    percentage_laid_off = NULLIF(percentage_laid_off, 'NULL'),
    date = NULLIF(date, 'NULL'),
    stage = NULLIF(stage, 'NULL'),
    country = NULLIF(country, 'NULL'),
    funds_raised_millions = NULLIF(funds_raised_millions, 'NULL')
WHERE 
    company = 'NULL' OR company = '' OR
    location = 'NULL' OR location = '' OR
    industry = 'NULL' OR industry = '' OR
    total_laid_off = 'NULL' OR total_laid_off = '' OR
    percentage_laid_off = 'NULL' OR percentage_laid_off = '' OR
    date = 'NULL' OR date = '' OR
    stage = 'NULL' OR stage = '' OR
    country = 'NULL' OR country = '' OR
    funds_raised_millions = 'NULL' OR funds_raised_millions = '';



---- using self join, updating some missing values----


-- After identifying that the industry values were missing for some locations, I used a self-join on the company column to fill in the missing data.
-- This ensured that all entries now have the correct industry values based on their associated company.

SELECT l1.company,l1.industry, l2.industry 
FROM layoffs_analysis l1
JOIN layoffs_analysis l2
	ON l1.company = l2.company
AND l1.location = l2.location
WHERE l1.industry IS NULL
AND l2.industry IS NOT NULL ;

UPDATE l1
SET l1.industry = l2.industry
FROM layoffs_analysis l1
JOIN layoffs_analysis l2
ON l1.company = l2.company
WHERE l1.industry IS NULL
AND l2.industry IS NOT NULL;



--I have deleted records where total_laid_off and percentage_laid_off values were NULL at the same time.
-- I have made this decision because these records were not useful for further Exploratory Data Analysis (EDA), 
-- as there were no related columns available to calculate these values.

DELETE 
FROM layoffs_analysis
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL ;

SELECT * 
FROM layoffs_analysis;




-------------------------------------------------         EXPLORATORY DATA ANALYSIS                -------------------------------------------------------


--- company wise layoffs from 2020 to 2023. -----

CREATE VIEW layoffsbycompanies AS
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
GROUP BY company
ORDER BY 2 DESC ;


--- Industry wise layoffs from 2020 to 2023. ------

CREATE VIEW layoffsbyindustry AS
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
GROUP BY industry
ORDER BY 2 DESC;


--- Country wise layoffs from 2020 to 2023 ------

CREATE VIEW layoffsbycountry AS
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
GROUP BY country
ORDER BY 2 DESC ;


--- Yearly layoffs from 2020 to 2023 -------

CREATE VIEW yearly_layoffs AS 
SELECT YEAR(date) AS Year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
GROUP BY YEAR(date)
ORDER BY 1 DESC ;



--- Analyzing  Rolling total Layoffs with CTE from 2020 to 2023 -------

CREATE VIEW rolling_total_layoffs AS
WITH Rolling_total_layoffs AS
	(SELECT date, SUM(total_laid_off) AS total_layoffs
	FROM layoffs_analysis
	GROUP BY date)
SELECT *, sum(total_layoffs) OVER (ORDER BY date) AS rolling_total
FROM Rolling_total_layoffs ;


---- Yearly Analysis of Companies with the Highest Layoffs using CTE and Dense_Rank ----.

CREATE VIEW highest_layoffs_company_yearly AS
WITH yearly_rank (company, Year, total_laid_off) AS
	(SELECT company,YEAR(date), SUM(total_laid_off)
	FROM
	layoffs_analysis 
	GROUP BY company, YEAR(date)
	), companies_yearly_rank AS
	(SELECT *, DENSE_RANK() OVER(PARTITION BY YEAR ORDER BY total_laid_off DESC) AS Ranking
	FROM yearly_rank
	WHERE Year IS NOT NULL
	)
SELECT *
FROM companies_yearly_rank
WHERE Ranking = 1 ;



---- Yearly Analysis of industry with the Highest Layoffs using CTE and Dense_Rank ----.

CREATE VIEW highest_layoffs_industry_yearly AS
WITH yearly_rank (industry, Year, total_laid_off) AS
	(SELECT industry,YEAR(date), SUM(total_laid_off)
	FROM
	layoffs_analysis 
	GROUP BY industry, YEAR(date)
	), industry_yearly_rank AS
	(SELECT *, DENSE_RANK() OVER(PARTITION BY YEAR ORDER BY total_laid_off DESC) AS Ranking
	FROM yearly_rank
	WHERE Year IS NOT NULL
	)
SELECT *
FROM industry_yearly_rank
WHERE Ranking = 1 ;



------ Country wise top industry layoffs ---------

CREATE VIEW top_industry_withHighest_layoffs_bycountry AS
WITH industrycountry_rank (country,industry, total_laid_off) AS
	(SELECT country,industry, SUM(total_laid_off)
	FROM
	layoffs_analysis 
	GROUP BY country,industry
	), industry_country_rank AS
	(SELECT *, DENSE_RANK() OVER(PARTITION BY country ORDER BY total_laid_off DESC) AS Ranking
	FROM industrycountry_rank
	WHERE country IS NOT NULL
	)
SELECT *
FROM industry_country_rank
WHERE Ranking = 1
ORDER BY total_laid_off DESC;





