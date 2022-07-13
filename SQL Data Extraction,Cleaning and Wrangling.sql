CREATE DATABASE NASHVILLE_HOUSING 

--
SELECT * 
FROM NASHVILLE_HOUSING..nashvillehousing
--


/* CLEANING DATAS FROM SQL QUERIES */

--------------------------------------------------------------------------------------------------------------------------------------------

/* 1. Standardring SALE DATE */

SELECT SaleDate
FROM NASHVILLE_HOUSING..nashvillehousing

--
SELECT SaleDate
,CONVERT(varchar,SaleDate,106)
FROM NASHVILLE_HOUSING..nashvillehousing
GROUP BY SaleDate

--
UPDATE NASHVILLE_HOUSING..nashvillehousing
SET SaleDate = CONVERT(varchar,SaleDate,106)

--ELSE IF THIS IS NOT WORKING then,

--Creating of a new column named Sales_Date

ALTER TABLE nashvillehousing
ADD Sales_Date date;

UPDATE nashvillehousing
SET Sales_Date = CONVERT(date,SaleDate,106)

--

SELECT *
FROM NASHVILLE_HOUSING..nashvillehousing


--------------------------------------------------------------------------------------------------------------------------------------------


/* 2. Populate the Property Address Datas */

--
SELECT PropertyAddress
FROM NASHVILLE_HOUSING..nashvillehousing
WHERE PropertyAddress is null 

--29 null values 

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress 
FROM NASHVILLE_HOUSING..nashvillehousing a
JOIN NASHVILLE_HOUSING..nashvillehousing b
ON  a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null 

--Checking

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NASHVILLE_HOUSING..nashvillehousing a
JOIN NASHVILLE_HOUSING..nashvillehousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)

FROM NASHVILLE_HOUSING..nashvillehousing a
JOIN NASHVILLE_HOUSING..nashvillehousing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]

SELECT *
FROM NASHVILLE_HOUSING..nashvillehousing
--WHERE PropertyAddress is null 


--------------------------------------------------------------------------------------------------------------------------------------------


/* 3. Breaking out Property Address by Address,City,State */
--BY THE USE OF 'SUBSTRING' 


SELECT PropertyAddress
FROM NASHVILLE_HOUSING..nashvillehousing

--Checking
SELECT 
SUBSTRING(PropertyAddress,0, CHARINDEX(',',PropertyAddress)) 'Property Address',
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,DATALENGTH(PropertyAddress))'Property City'

FROM NASHVILLE_HOUSING..nashvillehousing
--
ALTER TABLE nashvillehousing
ADD Property_Address varchar(255) 

UPDATE nashvillehousing
SET Property_Address = SUBSTRING(PropertyAddress,0, CHARINDEX(',',PropertyAddress))


ALTER TABLE nashvillehousing
ADD Property_City varchar(255) 

UPDATE NASHVILLE_HOUSING..nashvillehousing
SET Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, DATALENGTH(PropertyAddress))


SELECT *
FROM NASHVILLE_HOUSING..nashvillehousing


--------------------------------------------------------------------------------------------------------------------------------------------


/* 4. Breaking out Owner Address by Address,City,State */
--BY THE USE OF 'PARSENAME'

SELECT OwnerAddress
FROM NASHVILLE_HOUSING..nashvillehousing

--
SELECT OwnerAddress

,PARSENAME (REPLACE(OwnerAddress,',','.'),3)
,PARSENAME (REPLACE(OwnerAddress,',','.'),2)
,PARSENAME (REPLACE(OwnerAddress,',','.'),1)

FROM NASHVILLE_HOUSING..nashvillehousing



--
ALTER TABLE nashvillehousing
ADD Owner_Address varchar(255)

UPDATE NASHVILLE_HOUSING..nashvillehousing
SET Owner_Address = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE nashvillehousing
ADD Owner_City varchar(255)

UPDATE NASHVILLE_HOUSING..nashvillehousing
SET Owner_City = PARSENAME (REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE nashvillehousing
ADD Owner_State varchar(255)

UPDATE NASHVILLE_HOUSING..nashvillehousing
SET Owner_State = PARSENAME (REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NASHVILLE_HOUSING..nashvillehousing


--------------------------------------------------------------------------------------------------------------------------------------------


/* 5. Changing 'Y' and 'N' to 'Yes' and 'No' */
--CASE STATEMENTS 

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant) 'Total Count'
FROM NASHVILLE_HOUSING..nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2 desc

/*  Have 399 as 'N'		 4623 as 'Yes'		 52 as 'Y'      and		 51403 as 'No'.  */


SELECT SoldAsVacant
,
CASE
	WHEN SoldAsVacant = 'Y' THEN  'Yes'
	WHEN SoldAsVacant = 'N' THEN  'No'
	ELSE SoldAsVacant
END 

FROM NASHVILLE_HOUSING..nashvillehousing
ORDER BY 1 desc 

--
UPDATE NASHVILLE_HOUSING..nashvillehousing
SET SoldAsVacant = CASE
						WHEN SoldAsVacant = 'Y' THEN  'Yes'
						WHEN SoldAsVacant = 'N' THEN  'No'
						ELSE SoldAsVacant
					END 


SELECT SoldAsVacant
FROM NASHVILLE_HOUSING..nashvillehousing
--WHERE SoldAsVacant In ('Y','N') 


-------------------------------------------------------------------------------------------------------------------------------------------------------

/* Removing Duplicated */

--Normally, deleting of DATAS is not a standard practice,
--Instead we can place the duplicates by creating TEMP TABLEs or by other approaches, which is favoured.

SELECT *
FROM NASHVILLE_HOUSING..nashvillehousing

--WE can do it By Using Group By and Having Clause, MAX, CTE, RANK etc.

----BY THE USE OF 'CTE'

WITH redup 
as (
SELECT *
,ROW_NUMBER() OVER(PARTITION BY ParcelID,PropertyAddress,SalePrice,SoldAsVacant,LegalReference,Sales_Date,Acreage ORDER BY ParcelID ) duplicates
FROM NASHVILLE_HOUSING..nashvillehousing
)
---Checking
--SELECT *
--FROM redup
--WHERE duplicates >1 
--ORDER BY PropertyAddress
--

DELETE
FROM redup
WHERE duplicates >1 

SELECT *
FROM NASHVILLE_HOUSING..nashvillehousing


-------------------------------------------------------------------------------------------------------------------------------------------------------


/* Deleting Unused Columns */

--Normally, deleting of DATAS is not a standard practice.
--Instead we can place the duplicates by creating TEMP TABLEs or by other approaches, which is favoured.

ALTER TABLE NASHVILLE_HOUSING..nashvillehousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress

--
SELECT *
FROM NASHVILLE_HOUSING..nashvillehousing


-------------------------------------------------------------------------------------------------------------------------------------------------------


