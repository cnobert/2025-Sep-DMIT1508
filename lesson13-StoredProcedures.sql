/************** REVIEW VIEWS ****************/ 

--create a view that reveals the average points earned 
--divided by the average points possible for 
--assessment titles

if object_id('vw_AverageMarkPerTitle') is not null
	drop view vw_AverageMarkPerTitle

create view vw_AverageMarkPerTitle
as
select a.Title, format(round(AVG(a.PointsEarned / a.PointsPossible), 2), '#.##') as 'Mark'
from Assessment a
where a.PointsEarned is not null and a.PointsPossible is not null
group by a.Title 

select * from vw_AverageMarkPerTitle

/************** STORED PROCEDURES ****************/ 

/*
 * A stored procedure is a named block of SQL code that is stored and 
 * executed on the SQL Server itself.
 * 
 * "procedure" = "function" = "method"
 * 
 * Stored procedures can enforce business rules, improve performance,
 * and help to organize secure access to the database.
 * 
 */

--create a stored procedure that returns all students
drop procedure GetAllStudents
create procedure GetAllStudents
as
begin
	select s.StudentID, s.FirstName, s.LastName
	from Student s
end

exec GetAllStudents

--write a stored procedure that accepts a student ID and returns  
--all columns for that Student
drop procedure GetByStudentID

create procedure GetByStudentID
	@StudentID int 
as
begin
	select StudentID, FirstName, LastName, Email
	from Student 
	where StudentID = @StudentID
end

exec GetByStudentID 5







