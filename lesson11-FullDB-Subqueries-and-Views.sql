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
	






