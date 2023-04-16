/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject1..NashvilleHousing

----------------------------------------------------------------------
--Standardize Date Format

Select SaleDateConverted, Convert(date, SaleDate)
From PortfolioProject1..NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(date, SaleDate)

Select *
From PortfolioProject1..NashvilleHousing


----------------------------------------------------------------------
--Populate Property Address Data

Select *
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOin PortfolioProject1..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1..NashvilleHousing a
JOin PortfolioProject1..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



----------------------------------------------------------------------
--Breaking out Adress into Individual Column (Adress, City, State)

Select PropertyAddress
From PortfolioProject1..NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As Address
From PortfolioProject1..NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject1..NashvilleHousing


Select OwnerAddress
From PortfolioProject1..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject1..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject1..NashvilleHousing



----------------------------------------------------------------------
--change Y and N to Yes and No in 'Sold as Vacant' field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject1..NashvilleHousing
Group by SoldAsVacant
ORder by 2

Select SoldAsVacant, 
Case	when SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject1..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case	when SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End


----------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID) row_num 
From PortfolioProject1..NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



----------------------------------------------------------------------
--Delete Unused Columns

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT *
FROM PortfolioProject1..NashvilleHousing

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN SaleDate