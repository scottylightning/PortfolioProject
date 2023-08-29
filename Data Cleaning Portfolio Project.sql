--Cleaning data in sql queries

Select *
from PortfolioProject.dbo.NashvilleHousing

--Standardize Data Format

Select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = convert(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = convert(date, SaleDate)

--populate property address data 

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select*
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null
	
--Breaking out Address into individual columns(address, city, state)

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as City

from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity NvarChar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) 

select *
from PortfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
Add OwnerSplitAddressNew Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddressNew = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousing
Add OwnerSplitCityNew NvarChar(255);

update NashvilleHousing
SET OwnerSplitCityNew = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE NashvilleHousing
Add OwnerSplitStateNew NvarChar(255);

update NashvilleHousing
SET OwnerSplitStateNew = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

select *
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and NO in "Sold as vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'yes'
     when SoldAsVacant = 'n' then 'no'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'yes'
     when SoldAsVacant = 'n' then 'no'
	 else SoldAsVacant
	 end 

--Remove duplicates

select *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				    UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select *
from PortfolioProject.dbo.NashvilleHousing



WITH RowNumCTE AS(
select *,
   ROW_NUMBER() OVER(
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				    UniqueID
					) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

--DELETE
select *
from RowNumCTE
Where row_num > 2
Order by PropertyAddress


--delete unused columns

select *
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

