--DATA CLEANING IN SQL 


SELECT *
FROM [Portfolio Project]..NashvilleHousing

--Standardize Date Format


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate Missing Property Address


SELECT *
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress	
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out Property Address into Individual Columns (Address, City, State)


ALTER TABLE NashvilleHousing
ADD Address nvarchar(255)

UPDATE NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE NashvilleHousing
ADD City nvarchar(255)

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Breaking out Owner Address into Individual Columns (Address, City, State)


SELECT 
PARSENAME (REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)
FROM [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddressFixed nvarchar(255)

UPDATE NashvilleHousing
SET OwnerAddressFixed = PARSENAME (REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCityFixed nvarchar(255)

UPDATE NashvilleHousing
SET OwnerCityFixed = PARSENAME (REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerStateFixed nvarchar(255)

UPDATE NashvilleHousing
SET OwnerStateFixed = PARSENAME (REPLACE(OwnerAddress, ',', '.'),1)


--Standardize Sold to Vacant into 'Yes' or 'No'

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM [Portfolio Project]..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END


--Remove Duplicates


WITH RowNumCTE AS(
SELECT*, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM [Portfolio Project]..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1


--Delete unused columns


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
	