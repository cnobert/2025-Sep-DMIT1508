/*
List active pets, including Pet Name and Service Title, and &nbsp;Order by pet name.
Show the ChipNumbers of all pets who have been serviced by the ‘General’ department.
Show pet names of pets who were enrolled after May 21, 2025.
Show each pet’s name and the year it was born.
List all pets whose owners have an email address that ends in 'example.ca'. Show columns: Pet Name, Owner FullName and Email.
Show how many pet services were enrolled in 2025.
Show how many Service Assessment Due Dates happened in each month (May, June, etc.) Display month name and count.
Show the average base fee for each department.&nbsp;
Create one list that shows: 1. All pets without a microchip, and 2. All pets without an owner. Use a union.
Show the names of owners who have at least one pet with a microchip.
Use a subquery in the WHERE clause.
Show column: FullName.
Show the names of pets that have never been enrolled in a service.
Use a subquery in the WHERE clause.
Create a view named vwPetOwners that shows each pet’s name and its owner’s full name.
Then select all rows from the view.
*/

--Q1: List active pets, including Pet Name and Service Title, and Order by pet name.

select p.PetName 'Active Pets', s.Title
from Pet p join PetService ps on p.PetId = ps.PetId
join Service s on ps.ServiceId = s.ServiceId
where ps.Status = 'Active'
order by p.PetName

--Q2 Show the ChipNumbers of all pets who have been serviced by the ‘General’ department.
SELECT m.ChipNumber
FROM dbo.Microchip m
JOIN dbo.Pet p ON p.PetID = m.PetID
JOIN dbo.PetService ps ON ps.PetID = p.PetID
JOIN dbo.Service s ON s.ServiceID = ps.ServiceID
WHERE s.Department = 'General';

--Q3 Show pet names of pets who were enrolled after May 21, 2025.
SELECT distinct p.PetName
FROM dbo.Pet p
JOIN dbo.PetService ps ON ps.PetID = p.PetID
WHERE ps.EnrollDate > '2025-05-21';

-- Q4 Show each pet’s name and the year it was born.
SELECT PetName, year(DateOfBirth) 'BirthYear'
FROM dbo.Pet

-- Q5 List all pets whose owners have an email address that ends in 'example.ca'. 
--Show columns: Pet Name, Owner FullName and Email.

SELECT p.PetName, o.FullName, o.Email
FROM dbo.Pet AS p JOIN dbo.Owner AS o ON p.OwnerID = o.OwnerID
WHERE o.Email LIKE '%example.ca';

-- Q6 Show how many pet services were enrolled in 2025.
SELECT COUNT(*) AS ServiceCount
FROM PetService
WHERE YEAR(EnrollDate) = 2025;

-- Q7 Show how many Service Assessment Due Dates happened in each month (May, June, etc.) Display month name and count.

SELECT 
    DATENAME(MONTH, sa.DueDate ) AS MonthName, 
    COUNT(*) AS AssessmentCount
FROM ServiceAssessment sa
GROUP BY DATENAME(MONTH, sa.DueDate)
order by DATENAME(MONTH, sa.DueDate)

-- Q8 Show the average base fee for each department.
SELECT s.Department, AVG(s.BaseFee) AS AverageBaseFee
FROM Service s
GROUP BY s.Department ;

/* Q9 
 * Create one list that shows: 1. All pets without a microchip, and 2. All pets without an owner. Use a union.
Show the names of owners who have at least one pet with a microchip.
Use a subquery in the WHERE clause.
 */

SELECT  p.PetName
FROM dbo.Pet AS p LEFT JOIN dbo.Microchip AS m ON p.PetID = m.PetID
WHERE m.PetID IS NULL
union
SELECT p.PetName
FROM dbo.Pet AS p
LEFT JOIN dbo.Owner AS o ON p.OwnerID = o.OwnerID
WHERE o.OwnerID IS NULL;

/* Q10) Subqueries — 
 * Show the names of owners who have at least one pet with a microchip.
Use a subquery in the WHERE clause.
Show column: FullName. */

SELECT FullName
FROM dbo.Owner
WHERE OwnerID IN (
    SELECT p.OwnerID
    FROM dbo.Pet AS p JOIN dbo.Microchip AS m ON p.PetID = m.PetID
);

/* Q11) Show the names of pets that have never been enrolled in a service.
Use a subquery in the WHERE clause.*/
SELECT p.PetName AS PetName
FROM dbo.Pet p
WHERE p.PetID NOT IN (
    SELECT ps.PetID
    FROM dbo.PetService ps
);
/*
 * 
Show the names of pets that have never been enrolled in a service.
Use a subquery in the WHERE clause.
Create a view named vwPetOwners that shows each pet’s name and its owner’s full name.
Then select all rows from the view.
*/
CREATE VIEW dbo.vwPetOwners
AS
SELECT
    p.PetName AS PetName,
    o.FullName AS OwnerName
FROM dbo.Pet p
JOIN dbo.Owner o ON o.OwnerID = p.OwnerID;

-- Query the view
SELECT *
FROM dbo.vwPetOwners;

