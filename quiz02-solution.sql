/*
01) Show all reservations with CheckInDate after 2025-07-01. 
	Show: GuestID, RoomNumber, CheckInDate.
*/
select GuestID, RoomNumber, CheckInDate
from Reservation
where CheckInDate > '2025-07-01';
/*
 * 
 * */


--02) Show each guest’s full name in uppercase as UpperName.
select upper(g.FirstName + ' ' + g.LastName ) as UpperName
from guest g

--03) Show each guest's reservation check-in month name as CheckInMonth. 
--Include guest FirstName and LastName. 
select g.FirstName , g.LastName , month(r.CheckInDate) as CheckInMonth
from Guest g join Reservation r on g.GuestID = r.GuestID


--04) Show how many reservations each GuestID has 
--(even if they have zero reservations!). 
--Include columns GuestID, ReservationCount.
select g.GuestID, count(r.reservationID) as ReservationCount
from Guest g left join Reservation r on g.GuestID = r.GuestID 
group by g.GuestID 


--05) Related to Question 4, show how many reservations each GuestID has,
-- but include Guest FirstName and LastName along with the count.
select g.GuestID, g.FirstName, g.LastName, count(r.reservationID) as ReservationCount
from Guest g left join Reservation r on g.GuestID = r.GuestID 
group by g.GuestID, g.FirstName, g.LastName

--06) Show the average nightly rate for each room number. 
--Include: RoomNumber, AverageRate.
select r.RoomNumber, avg(r.NightlyRate) AverageRate
from Reservation r
group by r.RoomNumber 

--07)    Create one list showing: 
--	1) Guests whose email begins with 'a' (FirstName, LastName)
--	2) Guests who have at least one reservation (FirstName, LastName). 
--	Show them all at once using "union"
SELECT g.FirstName, g.LastName
FROM Guest g
WHERE g.Email LIKE 'a%'
union
SELECT g.FirstName, g.LastName
FROM Guest g join Reservation r on g.GuestID = r.GuestID 

--08) Show Card Codes for Key Cards that belong to guests who checked 
--out after August 15, 2025. Use a subquery.
select kc.CardCode
from KeyCard kc 
where kc.GuestID in
	(
		select r.GuestID
		from Reservation r 
		where r.CheckOutDate > '2025-08-15'
	)

--09) Show GuestIDs of guests who have made at least one reservation 
--with a nightly rate higher than the average nightly rate of all reservations. 
--Use a subquery.

select r.GuestID
from Reservation r 
where r.NightlyRate >
	(select avg(r.NightlyRate)
	from Reservation r)
	
	
--10) Create a view named vwGuestsWithCards that lists the guests who currently 
--have an active key card. Include full name and email. 
--Select guests whose name begins with 'S' from the view.
CREATE VIEW vw_GuestsWithCards
AS
SELECT g.FirstName + ' ' + g.LastName FullName, g.Email
FROM Guest g
JOIN KeyCard kc ON kc.GuestID = g.GuestID
WHERE kc.IsActive = 1;
go
SELECT * FROM vw_GuestsWithCards
WHERE FullName LIKE 'S%';






