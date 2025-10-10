-- return student name and the number of 
-- courses that they have completed

--using an aggregate function, and group by
select s.FirstName + ' ' + s.LastName as FullName, count(*) NumCoursesCompleted
from Student s join Enrollment e on s.StudentID = e.StudentID
where e.Status = 'Completed'
group by s.FirstName + ' ' + s.LastName

--using subqueries
select s.FirstName + ' ' + s.LastName as FullName, 
	(
		select count(*)
		from Enrollment e
		where e.StudentID = s.StudentID and e.Status = 'Completed'
	
	)
from Student s

--students with no phones
select s.StudentID, s.FirstName + ' ' + s.LastName as 'Students with no phones'
from Student s
where s.StudentID not in  
	(
		--subquery that returns all studentIds in phone table
		select p.StudentId
		from Phone p
	)

--compare student averages to overall average
-- more specifically, return all students with a higher than average score
select e.EnrollmentID, e.StudentID , e.FinalGradePercent 
from Enrollment e
where e.FinalGradePercent is not null
and e.FinalGradePercent > --in, not in can be used on subqueries that return many records
	(
		--query that returns the average grade
		--give the Enrollment table the name e2
		--must return one value
		select avg(e2.FinalGradePercent)
		from Enrollment e2 
		where e2.FinalGradePercent is not null
	)
	
--List students who are enrolled in any course with Term = 'F2025' (use IN).
--The subquery should return all student IDs that are in Term 'F2025'

--by adding "Not" before "in", we get all the students that are not in 'F2025'
select s.StudentID, s.FirstName + ' ' + s.LastName as 'Students in F2025'
from Student s
where s.StudentID not in 
	(
		select e.StudentId
		from Enrollment e join Course c on c.CourseID = e.CourseID 
		where c.Term = 'W2026'
	)

	select * from course

--Show LockerNumber for lockers assigned to students who are in any club 

select l.LockerNumber 'Students with lockers who are in at least one club'
from Locker l join Student s on l.StudentID = s.StudentID 
where s.StudentID in 
	(
		select sc.StudentID 
		from StudentClub sc 
	)

--Find ClubName for clubs that have no members. Use a subquery

select c.ClubName 
from Club c 
where c.ClubID not in
	(
		select sc.ClubId
		from StudentClub sc
	)



