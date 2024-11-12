USE WorldLayoffs ;

SELECT * FROM layoffs_analysis;


----------------------------------------------------           Creation Of FACT TABLE             ---------------------------

CREATE VIEW Fact_layoffs AS
SELECT
	 date,
	 company,
	 industry,
	 location,
	 country,
	 total_laid_off AS total_layoffs,
	 percentage_laid_off
FROM
	layoffs_analysis;



---------------------------------------------------         CREATION OF DIMENSION TABLES             ----------------------------------------

---- Date Dimension ----

CREATE VIEW dim_date AS
SELECT DISTINCT
	  COALESCE(date,'01-01-9999') AS date,
	  COALESCE(YEAR(date),'9999') AS YEAR,
	  COALESCE(MONTH(date),'01') AS MONTH,
	  COALESCE(DAY(date),'01') AS day
FROM 
	layoffs_analysis ;


---- Company Dimension -----

CREATE VIEW dim_company AS
SELECT DISTINCT
	  company
FROM
	layoffs_analysis ;


---- Industry Dimension ------

CREATE VIEW dim_industry AS
SELECT DISTINCT
      COALESCE(industry,'Unknown') AS industry
FROM 
	layoffs_analysis ;



----  Location Dimension --------

CREATE VIEW dim_location AS
SELECT DISTINCT
	  location
FROM
	layoffs_analysis;


---- Country Dimension -----

CREATE VIEW dim_country AS 
SELECT DISTINCT
	  country 
FROM
	layoffs_analysis ;
