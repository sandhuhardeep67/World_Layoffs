# World_Layoffs

Project Overview:
This project focuses on analyzing layoffs data to provide valuable insights and visualizations. The data is cleaned and processed using SQL Server Management Studio (SSMS), and interactive dashboards are created using Power BI. The aim is to identify trends, patterns, and significant factors contributing to layoffs across different industries and countries.

Table of Contents:
Data Sources
Data Cleaning and Preparation
Exploratory Data Analysis (EDA)
Power BI Measures
Visualizations
Conclusion

Data Sources :
The primary data source for this project is the WorldLayoffs database, which contains detailed information about layoffs across various companies, industries, and countries from 2020 to 2023.

Data Cleaning and Preparation:
To ensure data quality and consistency, the following steps were taken;
-Creating a Duplicate Table
A duplicate table, layoffs_analysis, was created to preserve the integrity of the raw data.
-Removing Duplicate Entries
Common Table Expressions (CTEs) were used to eliminate duplicate entries.
-Standardizing Data
Data was standardized by trimming unnecessary spacing and correcting inconsistent values.
-Handling Null and Blank Values
Blank values and the string 'NULL' were converted to actual NULL values to ensure consistency.
-Updating Missing Values Using Self Join
Missing industry values were filled in using a self-join on the company column.

Exploratory Data Analysis (EDA) :
-Company-wise Layoffs
-Industry-wise Layoffs
-Country-wise Layoffs
-Yearly Layoffs
-Rolling Total Layoffs
-Highest Layoffs by Company (Yearly)
-Country-wise Top Industry Layoffs

Power BI Measures:
Measures were created in Power BI to enhance the visualizations and provide deeper insights. Examples include calculating rolling totals, ranking industries, and identifying the top industries by layoffs in each country.

Visualizations:
The cleaned and analyzed data was used to create interactive visualizations in Power BI. A star schema was implemented to organize the data into facts and dimensions tables for efficient querying and reporting.

Conclusion:
This project demonstrates the end-to-end process of data cleaning, exploratory data analysis, and visualization using SSMS and Power BI. The insights derived from the analysis can help to understand trends and patterns in layoffs, identify the most affected industries and countries, and make data-driven decisions for future planning and interventions.
