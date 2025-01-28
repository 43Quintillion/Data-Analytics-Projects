-- Data Cleaning in SQL Queries

SELECT * FROM "NashvilleHousingDC".nashvillehousing;


/* -------------------------------------- Standardise Date Formats ---------------------------- */ 

SELECT SaleDate, CAST(SaleDate AS DATE) AS ConvertedDate
FROM "NashvilleHousingDC".NashvilleHousing;

DROP TABLE IF EXISTS "NashvilleHousingDC".data_staging;
CREATE TABLE "NashvilleHousingDC".data_staging (LIKE "NashvilleHousingDC".nashvillehousing INCLUDING ALL);
INSERT INTO "NashvilleHousingDC".data_staging SELECT * FROM "NashvilleHousingDC".nashvillehousing;

-- UPDATE "NashvilleHousingDC".data_staging
-- SET SaleDate = CAST(SaleDate AS DATE);

ALTER TABLE "NashvilleHousingDC".data_staging
ADD SaleDateConverted DATE; 
UPDATE "NashvilleHousingDC".data_staging
SET SaleDateConverted = CAST(SaleDate AS DATE);

SELECT * FROM "NashvilleHousingDC".data_staging; 

/* ------------------------------- Populate Property Address Data ---------------------------- */ 

-- Looking at the null values 
SELECT *
FROM "NashvilleHousingDC".data_staging
where PropertyAddress IS NULL; 

DROP TABLE IF EXISTS "NashvilleHousingDC".data_staging1;
CREATE TABLE "NashvilleHousingDC".data_staging1 (LIKE "NashvilleHousingDC".data_staging INCLUDING ALL);
INSERT INTO "NashvilleHousingDC".data_staging1 SELECT * FROM "NashvilleHousingDC".data_staging;

-- From existing data the properties with the same parcelid have the same address
-- Therefore using joins on the parcelid column to fill out the null values

SELECT * FROM "NashvilleHousingDC".data_staging1; 

SELECT a.ParcelID, 
a.PropertyAddress, 
b.ParcelID, 
b.PropertyAddress, 
COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM "NashvilleHousingDC".data_staging1 a
JOIN "NashvilleHousingDC".data_staging1 b 
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL;


UPDATE "NashvilleHousingDC".data_staging1 AS a
SET PropertyAddress = b.PropertyAddress
FROM "NashvilleHousingDC".data_staging1 AS b
WHERE a.PropertyAddress IS NULL
  AND a.ParcelID = b.ParcelID
  AND a.UniqueID != b.UniqueID;

/* ------------------------------- Breaking Addresses into Address, City and State ---------------------------- */

DROP TABLE IF EXISTS "NashvilleHousingDC".data_staging2;
CREATE TABLE "NashvilleHousingDC".data_staging2 (LIKE "NashvilleHousingDC".data_staging1 INCLUDING ALL);
INSERT INTO "NashvilleHousingDC".data_staging2 SELECT * FROM "NashvilleHousingDC".data_staging1;

-- Working with Property Address -> Address, City

SELECT *
FROM "NashvilleHousingDC".data_staging2; 

SELECT 
SPLIT_PART(PropertyAddress, ',', 1) AS Address,
SPLIT_PART(PropertyAddress, ',', -1) AS Address
FROM "NashvilleHousingDC".data_staging2;

ALTER TABLE "NashvilleHousingDC".data_staging2
ADD PropertySplitAddress VARCHAR(255);
UPDATE "NashvilleHousingDC".data_staging2
SET PropertySplitAddress = SPLIT_PART(PropertyAddress, ',', 1);

ALTER TABLE "NashvilleHousingDC".data_staging2
ADD PropertySplitCity VARCHAR(255);
UPDATE "NashvilleHousingDC".data_staging2
SET PropertySplitCity = SPLIT_PART(PropertyAddress, ',', -1);

-- Working with OwnerAddress

SELECT *
FROM "NashvilleHousingDC".data_staging2
WHERE OwnerAddress IS NOT NULL; 

SELECT
SPLIT_PART(OwnerAddress, ',', 1),
SPLIT_PART(OwnerAddress, ',', 2),
SPLIT_PART(OwnerAddress, ',', 3)
FROM "NashvilleHousingDC".data_staging2
WHERE OwnerAddress IS NOT NULL; 

ALTER TABLE "NashvilleHousingDC".data_staging2
ADD OwnerSplitAddress VARCHAR(255);
UPDATE "NashvilleHousingDC".data_staging2
SET OwnerSplitAddress = SPLIT_PART(OwnerAddress, ',', 1);

ALTER TABLE "NashvilleHousingDC".data_staging2
ADD OwnerSplitCity VARCHAR(255);
UPDATE "NashvilleHousingDC".data_staging2
SET OwnerSplitCity = SPLIT_PART(OwnerAddress, ',', 2);

ALTER TABLE "NashvilleHousingDC".data_staging2
ADD OwnerSplitState VARCHAR(255);
UPDATE "NashvilleHousingDC".data_staging2
SET OwnerSplitState = SPLIT_PART(OwnerAddress, ',', 3);


/* ------------------------------- Change Y/N to Yes/No in "SoldAsVacant" ---------------------------- */

DROP TABLE IF EXISTS "NashvilleHousingDC".data_staging3;
CREATE TABLE "NashvilleHousingDC".data_staging3 (LIKE "NashvilleHousingDC".data_staging2 INCLUDING ALL);
INSERT INTO "NashvilleHousingDC".data_staging3 SELECT * FROM "NashvilleHousingDC".data_staging2;

SELECT * FROM "NashvilleHousingDC".data_staging3; 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM "NashvilleHousingDC".data_staging3
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM "NashvilleHousingDC".data_staging3; 

UPDATE "NashvilleHousingDC".data_staging3
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;


/* ------------------------------- Removing Duplicates ---------------------------- */

DROP TABLE IF EXISTS "NashvilleHousingDC".data_staging4;
CREATE TABLE "NashvilleHousingDC".data_staging4 (LIKE "NashvilleHousingDC".data_staging3 INCLUDING ALL);
INSERT INTO "NashvilleHousingDC".data_staging4 SELECT * FROM "NashvilleHousingDC".data_staging3;

WITH rnCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
	) AS rn
FROM "NashvilleHousingDC".data_staging4
)
DELETE 
FROM "NashvilleHousingDC".data_staging4
WHERE UniqueID IN(
SELECT UniqueID FROM rnCTE
WHERE rn > 1); 

	-- Checking
-- WITH rnCTE AS(
-- SELECT *,
-- 	ROW_NUMBER() OVER (
-- 	PARTITION BY ParcelID, 
-- 				 PropertyAddress,
-- 				 SalePrice,
-- 				 SaleDate,
-- 				 LegalReference
-- 				 ORDER BY UniqueID
-- 	) AS rn
-- FROM "NashvilleHousingDC".data_staging4
-- )
-- SELECT *
-- FROM rnCTE
-- WHERE rn > 1
-- ORDER BY PropertyAddress; 


/* ------------------------------- Removing Unused Columns ---------------------------- */

DROP TABLE IF EXISTS "NashvilleHousingDC".data_staging5;
CREATE TABLE "NashvilleHousingDC".data_staging5 (LIKE "NashvilleHousingDC".data_staging4 INCLUDING ALL);
INSERT INTO "NashvilleHousingDC".data_staging5 SELECT * FROM "NashvilleHousingDC".data_staging4;

SELECT * FROM "NashvilleHousingDC".data_staging5;

-- Dropping columns that may or may not be useful

ALTER TABLE "NashvilleHousingDC".data_staging5
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate; 