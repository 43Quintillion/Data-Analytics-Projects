-- Data Cleaning Project
-- Data set on kaggle at https://www.kaggle.com/datasets/swaptr/layoffs-2022
SELECT * 
FROM layoffs;

-- Remove Duplicates
-- Standardise
-- Null values
-- Remove colums or rows

# Removing duplicates
	#Creating a staging table to work with and a table of raw data to come back to. 
CREATE TABLE layoffs_staging
LIKE layoffs; 

INSERT layoffs_staging
SELECT *
FROM layoffs; 

	# Creating a row_num column to see if there are any duplicates using the partition by function
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging; 

	# Creating a CTE to view the potential duplicates
WITH duplicate_CTE AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_CTE
where row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = "Casper"; 



# Creating a second staging table to edit and delete the duplicates found. 
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_staging2;

	# Inserting the data from staging 1 table to the newly created staging 2
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging; 

# Deleting the duplcates from the staging 2 table. 
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;   

DELETE 
FROM layoffs_staging2
WHERE row_num > 1; 

# Standardising data -> Removing spaces, weird symbols and incosistencies in data

SELECT company, TRIM(company)
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET company = TRIM(company); 

SELECT DISTINCT industry
FROM layoffs_staging2 
ORDER BY industry; #Found that there are several categories of cryptocurrency industries that can be grouped into one

#Seletcing and updating the rows withe different crypto categoeries to just crypto 
SELECT *
FROM layoffs_staging2 
WHERE industry LIKE "Crypto%"; 

UPDATE layoffs_staging2
SET industry = "Crypto"
WHERE industry LIKE 'Crypto%'; 

# These lines can be mannually ran with all different column variables e.g., date, country, ect... to see if there are any issues with starndardisation.

SELECT DISTINCT country
FROM layoffs_staging2 
ORDER BY 1; #Found that there are duplicate in united states where someone typed "United States." 

SELECT DISTINCT country, TRIM(TRAiLING '.' FROM country)
FROM layoffs_staging2 
ORDER BY 1; 

UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'; 

#Change the date variable type from text to date/time

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2; 

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;  

ALTER TABLE  layoffs_staging2 
MODIFY COLUMN `date` DATE; 

# Dealing with nulls and blank values

SELECT *
FROM layoffs_staging2; 

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2	#Updating all blank values to null to make it more consistent to change later on
SET industry = null
WHERE industry = ""; 

SELECT *
FROM layoffs_staging2 
WHERE industry IS NULL
OR industry = ''; 

SELECT *
FROM layoffs_staging2
WHERE company = "Airbnb"; 

#Filling in the nulls for industry column using other similar entries that have the same company
SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL; 


UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL; 

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%'; 

	#Removing uneeded columns and rows 

#Companies with total laid off and percetage laid off missing can potentially be removed.
SELECT *
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num; 

SELECT *
FROM layoffs_staging2; 


