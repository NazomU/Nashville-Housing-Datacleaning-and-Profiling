--Nahsville Dataset Cleanup on SQL Server
--Cleaning Data in SQL Queries
select *
from
[SQL Portfolio]..NashvilleHousing

--Converting and Standardizing SaleDate Format
select
SaleDate,
Convert(Date,SaleDate) as SalesDate
From [SQL Portfolio]..NashvilleHousing

Alter table NashvilleHousing
Add SalesDate Date

--Run the query to see the column added
--select *
--from
--[SQL Portfolio]..NashvilleHousing

Update NashvilleHousing
Set SalesDate = Convert (Date,SaleDate)

--Run the query to see the data added to the column
--select *
--from
--[SQL Portfolio]..NashvilleHousing

-- 2 Populate Property Address Data by updating null values column
select *
from
[SQL Portfolio]..NashvilleHousing
where 
PropertyAddress is null
--order BY ParcelID
-- from the data quality check, property id can be populated using the parcel id


--3 we joined the table to itself where the parcel id is the same but not in the same row
Select 
a.ParcelID, 
a.PropertyAddress, 
b.ParcelID, 
b.PropertyAddress 
From [SQL Portfolio]..NashvilleHousing a
JOIN [SQL Portfolio]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--4 this query uses ISNULL to populate the column that has Null values
Select 
a.ParcelID, 
a.PropertyAddress, 
b.ParcelID, 
b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress) as NewPropertyAddress
From [SQL Portfolio]..NashvilleHousing a
JOIN [SQL Portfolio]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--5 To Update the PropertyAddress Null Columns
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [SQL Portfolio]..NashvilleHousing a
JOIN [SQL Portfolio]..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
-- Once the update query has been run, go back and check query 4 to see that there are no longer null propertyaddress and brings out an empty result


-- 6 Next cleaning stage is to seperate the PropertyAddress into seperate columns (Address,City,State) using Substring and Character Index
Select PropertyAddress
From [SQL Portfolio]..NashvilleHousing
Where PropertyAddress is not null
order by ParcelID

 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From [SQL Portfolio]..NashvilleHousing


-- 7 Next we need to create new columns to accomodate the split
ALTER TABLE [SQL Portfolio]..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [SQL Portfolio]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [SQL Portfolio]..NashvilleHousing
Add PropertyCity Nvarchar(255);

Update [SQL Portfolio]..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- To view the added and updated columns
Select *
From [SQL Portfolio]..NashvilleHousing


--8 Next cleaning stage is to seperate the OwnerAddress into seperate columns (Address,City,State) using Substring and Character Index
Select OwnerAddress
From [SQL Portfolio]..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [SQL Portfolio]..NashvilleHousing


ALTER TABLE [SQL Portfolio]..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [SQL Portfolio]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [SQL Portfolio]..NashvilleHousing
Add OwnerCity Nvarchar(255);

Update [SQL Portfolio]..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE [SQL Portfolio]..NashvilleHousing
Add OwnerState Nvarchar(255);

Update [SQL Portfolio]..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From [SQL Portfolio]..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------
-- In the SoldAsVacant we have Columns with Y, Yes, No and N so we Change Y and N to Yes and No in "Sold as Vacant" field for uniformity
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [SQL Portfolio]..NashvilleHousing
Group by SoldAsVacant
order by 2


-- 9 To make the changes we use a case when statement
Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [SQL Portfolio]..NashvilleHousing

-- 10 Next we update the SoldasVacant Column with the case when statement
Update [SQL Portfolio]..NashvilleHousing
SET SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

	 Select *
From [SQL Portfolio]..NashvilleHousing


---------------------------------------------------------------------------------------------------------

--11 Delete Unused Columns
Select *
From [SQL Portfolio]..NashvilleHousing

ALTER TABLE [SQL Portfolio]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


