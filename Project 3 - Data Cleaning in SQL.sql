

-- Data Cleaning in SQL

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


-- Populate Property Adress Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE Propertyaddress is null
ORDER BY parcelid


SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, ISNULL (a.propertyaddress, b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
 ON a.parcelid = b.parcelid
 AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null

UPDATE a
SET propertyaddress =  ISNULL (a.propertyaddress, b.propertyaddress)
FROM PortfolioProject.dbo.NashvilleHousing a
 JOIN PortfolioProject.dbo.NashvilleHousing b
 ON a.parcelid = b.parcelid
 AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

-- (Property Address)

SELECT propertyaddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE Propertyaddress is null
--ORDER BY parcelid

SELECT 
SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address 
, SUBSTRING (propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING (propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

-- (Checking the columns have been added successfully to the table)
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


--(Owner Address)

SELECT owneraddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 

-- (Checking the columns have been added successfully to the table)
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(soldasvacant), count(soldasvacant)
FROM PortfolioProject.dbo.NashvilleHousing
group by (soldasvacant)
order by 2


SELECT distinct soldasvacant
, CASE when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
	   ELSE soldasvacant
	   END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET soldasvacant = CASE when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
	   ELSE soldasvacant
	   END


-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY parcelid,
	             propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
				   uniqueid
				   ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
-- ORDER BY parcelid
)
DELETE
FROM RowNumCTE
where row_num > 1
--ORDER BY propertyaddress

--(Veryfing that there are none duplicates)
WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
	PARTITION BY parcelid,
	             propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY
				   uniqueid
				   ) row_num

FROM PortfolioProject.dbo.NashvilleHousing
-- ORDER BY parcelid
)
SELECT *
FROM RowNumCTE
where row_num > 1
--ORDER BY propertyaddress


-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN owneraddress, taxdistrict, propertyaddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN saledate