/************** REVIEW SUBQUERIES ****************/ 
--Many places in our select statements, we put a full query 
--inside of ()

--Students with no phone (FirstName, LastName)
--use a subquery

select s.StudentId, s.FirstName + ' ' + s.LastName as 'Students with no phone'
from Student s 
where s.StudentID not in (select p.Studentid from phone p)

--Students with no locker (FirstName, LastName)
--use a subquery
select *
from Student s
where s.StudentID not in 
	(
		select l.studentID 
		from Locker l
		where l.StudentID is not null
	)

--Students with any completed course (FirstName, LastName)
--use a subquery
select s.FirstName, s.LastName
from Student s
where s.StudentID in	
	(
		select e.StudentID
		from Enrollment e
		where e.Status = 'Completed'
	);

/************** REVIEW HAVING ****************/
--Aggregate functions are sum, average, max, min, count
--"group by" puts little "piles" of data together base on a commonality
--"having" is the "where clause" for a "group by"

--return student ids and the count of how many phones each has
--filter out students who only have one phone
select p.StudentID, count(*)
from Phone p
group by p.StudentID 
having count(*) > 1

--the above count, but with student first and last name
select s.FirstName, s.LastName, count(*)
from Phone p join Student s on p.StudentID = s.StudentID 
group by s.FirstName, s.LastName
having count(*) > 1

--count how many erollments per year, limiting to 2025 and before
select year(EnrollDate), count(*)
from Enrollment e 
group by year(EnrollDate)
having year(EnrollDate) <= 2025

--count how many erollments per month
select month(EnrollDate), count(*)
from Enrollment e 
group by month(EnrollDate)


/************** VIEWS ****************/
/* 
 * A View is a stored "select".
 * A view:
 * 		stores "select" logic in the database behind a stable name
 * 		can make complex queries easy to use
 * 		can make all queries secure to access
 */

--example: create a view that displays student names for term F2025

create view vw_F2025Students
as
select distinct s.FirstName, s.LastName
from Student s join Enrollment e on s.StudentID = e.StudentID 
join Course c on e.CourseID = c.CourseID
where c.Term = 'F2025'

select FirstName from vw_F2025Students

-- Base join we use a lot
create view vw_StudentClubs
as
SELECT
    s.StudentID,
    s.FirstName,
    s.LastName,
    c.ClubName
FROM Student s
JOIN StudentClub sc ON s.StudentID = sc.StudentID
JOIN Club c ON sc.ClubID = c.ClubID;

select * from vw_StudentClubs



