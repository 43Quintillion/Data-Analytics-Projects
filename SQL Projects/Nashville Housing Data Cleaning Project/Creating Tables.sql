DROP TABLE if exists "NashvilleHousingDC".NashvilleHousing;
CREATE TABLE "NashvilleHousingDC".NashvilleHousing (
UniqueID INT,
ParcelID VARCHAR(30),
LandUse VARCHAR(50),
PropertyAddress	VARCHAR(60),
SaleDate VARCHAR(50),
SalePrice VARCHAR(50),
LegalReference VARCHAR(50),
SoldAsVacant VARCHAR(10),
OwnerName VARCHAR(100),
OwnerAddress VARCHAR(100),
Acreage	NUMERIC, 
TaxDistrict VARCHAR(70),
LandValue BIGINT,
BuildingValue BIGINT,
TotalValue BIGINT,
YearBuilt INT,
Bedrooms INT,
FullBath INT,
HalfBath INT
)