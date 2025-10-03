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
select avg(LockerId)
from Locker

select building, count(*)
from Locker
group by building