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
















