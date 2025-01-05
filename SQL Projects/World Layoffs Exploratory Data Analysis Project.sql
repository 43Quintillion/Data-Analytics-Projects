-- Exploratory Data Analysis


SELECT *
FROM layoffs_staging2; 

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 

-- Looking at various statistics to see how big these layoffs were
	#Companies who went out of business
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
; 

	#Companies with largest total layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 

SELECT MIN(`date`), MAX(`date`) 
FROM layoffs_staging2; 

#Countries with highest total layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC; 

	#Year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`) 
ORDER BY 1 DESC; 

-- Looking at the stats below shows that the type of companies who had the most layoffs are larger companies Post-IPO
	#However previously looking at the companies who laid off 100% i.e., went out of business, most were start up companies
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage  
ORDER BY 2 DESC; 

-- Querying the total laid off by months for rolling total later 
SELECT *
FROM layoffs_staging2;

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) 
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY `MONTH` 
ORDER BY 1 ASC 
;

#Finding average percentage laid off
SELECT stage, ROUND(AVG(percentage_laid_off),2) AS avg_p_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

#Finding rolling total of total employees laid off grouped by months
WITH Rolling_Total AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)  AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY `MONTH` 
ORDER BY 1 ASC 
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total; 

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

#Looking at companies with most layoffs per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;
