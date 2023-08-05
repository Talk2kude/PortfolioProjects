-- Data cleaning in SQL queries

Select * from NashvilleHousing;
--------------------------------------------------------------------------------------------------------------------------

1 -- Standardize Date Format

Select SaleDate, CONVERT(date,saledate)
	from NashvilleHousing;

Update NashvilleHousing
	Set SaleDate = CONVERT(date,saledate);

Select SaleDate
	from NashvilleHousing;

--Below will add a new Column to NashvilleHousing (without data)

Alter Table NashvilleHousing
	Add Sale_Date_Converted date;

--Below will add data the newly created Column, by copying the data in col SaleDate and coverting it to our requirement	
Update NashvilleHousing
	Set Sale_Date_Converted  = CONVERT(date,saledate);
-------------------------------------------------------------------------------------------------------------------------------------------
2 --Populate Property Address Data

Select * from NashvilleHousing
	order by ParcelID;



Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
	from NashvilleHousing A
	Join NashvilleHousing B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ]<> B.[UniqueID ]
	Where A.PropertyAddress is null;

--Now that we have pulled out NULL propertyaddress and found out that its counterparts have address, we will populate the former with the latter using "Isnull" syntax

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
	from NashvilleHousing A
	Join NashvilleHousing B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ]<> B.[UniqueID ]
	Where A.PropertyAddress is null;

--Now that a new Column Address (No column Name) has been populated for Table A, we will update Table A PropertyAddress with it using the UPDATE ... SET syntax
--When updating a table with Join in the syntax, you don't state the full name (NashvilleHousing), instead you use its Alias, A in this case)

Update A
	Set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
	from NashvilleHousing A
	Join NashvilleHousing B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ]<> B.[UniqueID ]
	Where A.PropertyAddress is null;

3-- Spliting Address into individual columns (Address, City, State)

Select PropertyAddress
	from NashvilleHousing

--Since the address has a comma separating it from the City, the comma "," can be used as a delimiter - to split the data into a new column using the Substring syntax

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) As Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) As Address 
from NashvilleHousing

 --Below will create new columns where the newly split addresses will be stored
Alter Table NashvilleHousing
	Add Property_Split_Address Nvarchar (255);

Update NashvilleHousing
	Set Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);


Alter Table NashvilleHousing
	Add Property_Split_City Nvarchar (255);

Update NashvilleHousing
	Set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress));

--Or Parsename could be used to achieve the same purpose of cleaning and formating/spliting the address (OwnerAddress column)

Select OwnerAddress from NashvilleHousing;

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing;

--Now we add three new column and update them with 3 newly split addresses

Alter Table NashvilleHousing
	Add Owner_Split_Address Nvarchar (255);

Update NashvilleHousing
	Set Owner_Split_Address = PARSENAME(Replace(OwnerAddress, ',', '.'), 3);


Alter Table NashvilleHousing
	Add Owner_Split_City Nvarchar (255);

Update NashvilleHousing
	Set Owner_Split_City = PARSENAME(Replace(OwnerAddress, ',', '.'), 2);

Alter Table NashvilleHousing
	Add Owner_Split_State Nvarchar (255);

Update NashvilleHousing
	Set Owner_Split_State = PARSENAME(Replace(OwnerAddress, ',', '.'), 1);

----------------------------------------------------------------------------------------------------------------------------------
4-- Change Y and N to Yes and No in the "Sold as Vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant) as Total_Count from NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant, (
	Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End) as Sold_as_Vacant
from NashvilleHousing

Update NashvilleHousing
	Set SoldAsVacant = Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

---------------------------------------------------------------------------------------------------------------------------------------
--5 Remove Duplicates (best practice is never to delete anything from your database, better to create Temp Table and remove duplicates therein)

Select *,
	ROW_NUMBER() Over 
	(Partition by ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
	Order by UniqueID) As Row_Num
from NashvilleHousing
Order by ParcelID

-- Now we add above query into a CTE and then search for duplicates using the Where clause

With Row_NumCTE as (
Select *,
	ROW_NUMBER() Over 
	(Partition by ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
	Order by UniqueID) As Row_Num
from NashvilleHousing
--Order by ParcelID
)
Select * from Row_NumCTE
Where Row_Num > 1
Order by PropertyAddress

--Now that we have found the duplicates, we can change the 2nd "Select *" to Delete

With Row_NumCTE as (
Select *,
	ROW_NUMBER() Over 
	(Partition by ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
	Order by UniqueID) As Row_Num
from NashvilleHousing
--Order by ParcelID
)
Delete from Row_NumCTE
Where Row_Num > 1
--Order by PropertyAddress

--6---Delete unused columns (best practice - do these only on your Views, not on your raw data)

Alter table NashvilleHousing
	Drop column OwnerAddress,
				TaxDistrict,
				PropertyAddress,
				SaleDate




