/*

Cleaning Data in SQL Queries

*/

--------------------------------------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  Server Configuration 

sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

USE PortfolioProject 

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

GO 


-- Importing Data Using BULK INSERT

USE PortfolioProject;
GO
BULK INSERT nashvilleHousing FROM 'C:\Users\ALOUI\Documents\SQL Server Management Studio\Nashville Housing Data.csv'
   WITH (
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n'
);
GO


-- Importing Data Using OPENROWSET
USE PortfolioProject;
GO
SELECT * INTO NashvilleHousing
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0; Database=C:\Users\ALOUI\Documents\SQL Server Management Studio\Nashville Housing Data.csv', [NashvilleHousing]);
GO


Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate) as "yyy-mm-dd"
From NashvilleHousing


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


-- See if a correct address is already givin for the same ParcelID shown Null value
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Remplace NULL value with a correct address
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Separate Property Address into Individual Columns (Address, City)


Select PropertyAddress
From NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ), -- -1 to eliminate the comma
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) -- +1 to eliminate the comma
From NashvilleHousing

-- Add new column for property Adress
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- Add new column for property City
ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From NashvilleHousing


-- Separate Owner Address into Individual Columns (Address, City, State)

Select OwnerAddress
From NashvilleHousing

-- Another way to separate Adress by using PARSENAME
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing


-- Add new column for Owner Adress
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


-- Add new column for Owner City
ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


-- Add new column for Owner State
ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	               When SoldAsVacant = 'N' THEN 'No'
	               ELSE SoldAsVacant
	               END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Use CTE so we can put condition "where row_num > 1"
WITH RowNumCTE AS(
Select *,ROW_NUMBER() OVER (
	                  PARTITION BY ParcelID,
				                   PropertyAddress,
				                   SalePrice,
				                   SaleDate,
				                   LegalReference
				                     ORDER BY
					                    UniqueID
					                       ) row_num
From NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1


Select *
From NashvilleHousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

Select *
From NashvilleHousing


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
