--Cleaning data in SQL queries
SELECT *
FROM PortfolioProject..[Nashville Housing]

--Standardize Date Format

--This query is used as once the column is created it needs to be deleted
ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN SaleDateConverted;

--Adding the column once it is dropped
ALTER TABLE PortfolioProject..[Nashville Housing]
ADD SaleDateConverted Date;

--SaleDate which included both Date time needs to be updated and is converted it into date format
UPDATE PortfolioProject..[Nashville Housing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

--To display the converted SaleDate
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..[Nashville Housing]

--Populate Property Address data
SELECT * 
FROM PortfolioProject..[Nashville Housing]
ORDER BY ParcelID

--Some ParcelID's were same but didn't have the same PropertyAddress so this query fills the respective PropertyAddress of the parcelID 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
	ON 
		a.ParcelID = b.ParcelID
	AND
		a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Updating the values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
	ON 
		a.ParcelID = b.ParcelID
	AND
		a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Breaking down Address into Individual Columns (Address,City,State)
--For PropertyAddress
SELECT PropertyAddress
FROM PortfolioProject..[Nashville Housing]

--Splitting the address into street,city columns
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProject..[Nashville Housing]

--Adding columns of the splitted address
ALTER TABLE PortfolioProject..[Nashville Housing]
ADD PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProject..[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE PortfolioProject..[Nashville Housing]
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject..[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 
FROM PortfolioProject..[Nashville Housing]

--For OwnerAddress
SELECT OwnerAddress
FROM PortfolioProject..[Nashville Housing]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
FROM PortfolioProject..[Nashville Housing]

ALTER TABLE PortfolioProject..[Nashville Housing]
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProject..[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..[Nashville Housing]
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject..[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..[Nashville Housing]
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject..[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM PortfolioProject..[Nashville Housing]

--Change Y and N to Yes and No in the "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..[Nashville Housing]

UPDATE PortfolioProject..[Nashville Housing]
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates
WITH RowNumCTE AS(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS ROW_NUM
    FROM PortfolioProject..[Nashville Housing]
)

DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1

SELECT *
FROM PortfolioProject..[Nashville Housing]

--Delete Unused Columns
SELECT *
FROM PortfolioProject..[Nashville Housing]

ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate	