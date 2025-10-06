--aggregate functions
select count(StudentId) TotalStudents
from Student;

--count all lockers
select count(*) 
from Locker

-- Earliest and latest student birthdates
select MIN(DateOfBirth), MAX(DateOfBirth)
from Student

--Average floor number of lockers
select avg(Floor)
from Locker

--every column in the select must either be in the "group by" or 
--in an aggregate function
select building, count(*)
from Locker
group by building

--return how many lockers are on each floor
select Locker.Floor, count(*) 'Lockers per floor'
from Locker
group by Floor

--how many phone numbers for each student ID
select StudentID, count(*) 'Phones per student'
from Phone 
group by StudentId

--let's make the above query more user friendly
--how many phones for each Student name
select s.FirstName, s.LastName, count(p.PhoneNumber) 'Number of Phones'
from Phone p join Student s on p.StudentID = s.StudentID
group by s.FirstName, s.LastName  

--how many students are there in each club, remember to include clubs that have no students
select c.ClubName, count(sc.StudentID) 'Number of Student Members'
from Club c left join StudentClub sc on c.ClubID = sc.ClubID
group by c.ClubName

--"having" is the "where" for "group by"
--so, "having" can only filter by aggregate function or column names that in "group by"


--how many students per club, only club names that begin with "C"
select c.ClubName, count(sc.StudentID) 'Number of Student Members'
from Club c left join StudentClub sc on c.ClubID = sc.ClubID
group by c.ClubName
having c.ClubName like 'C%'

--review: all of the query clauses that we've learned:
/*
 * select
 * from
 * where
 * group by
 * having 
 * order by
 */

-- show the buildings that have more than one locker
select l.Building, count(*) LockerCount
from Locker l
group by l.Building 
having count(*) > 1

--List club names where exactly one student is a member.
select c.ClubName, count(sc.StudentID )
from club c left join StudentClub sc on c.ClubID = sc.ClubID 
group by c.ClubName
having count(sc.StudentID) = 1






