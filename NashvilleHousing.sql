-------------------------------------------------------------------------------

-- Cleaning Data in SQL Queries

select*
from Covid.dbo.NashvilleHousing

---------------------------------------------------------
--Standarize the Data Format

select SaleDateConverted, CONVERT(Date, SaleDate)
From Covid.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--populate new property address

select *
From Covid.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select *
From Covid.dbo.NashvilleHousing
where PropertyAddress is null


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Covid.dbo.NashvilleHousing a
JOIN Covid.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----Update---
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Covid.dbo.NashvilleHousing a
JOIN Covid.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------------------------------------------------------------

--- Beaking out Address into Individuals Columns (Address, City, State)

select PropertyAddress
From Covid.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address 
From Covid.dbo.NashvilleHousing

--- by puting -1 it will elimate (,) from output
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From Covid.dbo.NashvilleHousing

---- update, Alert address.
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as Address
From Covid.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(225);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
add PropertySplitCity Nvarchar(225);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

---- Result after spliting Property Address


Select*
From Covid.dbo.NashvilleHousing


--- Change/split in Owner Address--------------------

Select OwnerAddress
From Covid.dbo.NashvilleHousing

-----using different method of PARSENAME

SELECT 

PARSENAME(REPLACE(OwnerAddress, ',','.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
from Covid.dbo.NashvilleHousing

----it goes backward so starting from backward
SELECT 

PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from Covid.dbo.NashvilleHousing


--- Add new Columns and Values
SELECT 

PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from Covid.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress Nvarchar(225);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)


ALTER TABLE NashvilleHousing
add OwnerSplitCity Nvarchar(225);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvilleHousing
add OwnerSplitState Nvarchar(225);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

---lets see Result -------------------------------------------

Select*
From Covid.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

----Change Y and N to YES and NO in "Sold as vaccant " feild

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Covid.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

--Coverting into Yes Or No

Select SoldAsVacant
, Case when  SoldAsVacant = 'Y' then 'YES'
	When SoldAsVacant = 'N' Then 'NO'
	Else SoldAsVacant
	End

From Covid.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when  SoldAsVacant = 'Y' then 'YES'
	When SoldAsVacant = 'N' Then 'NO'
	Else SoldAsVacant
	End

---- Results ---------------


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Covid.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


----------------------------------------------------------------------------------------------------------

---- Remove Duplicate and UnUSed Columns----------------------


Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by
		UniqueID
		) row_num

From Covid.dbo.NashvilleHousing
order by ParcelID

------- CTE method---
WITH	RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by
		UniqueID
		) row_num

From Covid.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

------- remove Duplicate ---------------------------
WITH	RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by
		UniqueID
		) row_num

From Covid.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1

----- Results ----------------------------------
WITH	RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by
		UniqueID
		) row_num

From Covid.dbo.NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-----------------------------------------------------------------------------------------------------------------------------------------------


--- Deleting UnUsed Columns -------------
select*
From Covid.dbo.NashvilleHousing

ALTER TABLE Covid.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Covid.dbo.NashvilleHousing
DROP COLUMN SaleDate

------------------------------------------------------------------------------------------------------------------------------------------------