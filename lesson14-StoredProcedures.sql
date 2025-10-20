/************** REVIEW STORED PROCEDURES ****************/ 

--create a stored procedure called GetAllStudents that returns all students

drop procedure GetAllStudents;
go
create procedure GetAllStudents
as
begin --like "{" in c#
	select s.FirstName, s.LastName
	from Student s
end --like "}" in c#
go

exec GetAllStudents

--passing parameters to stored procedures

--Write a stored procedure called GetCourseMarks that displays the final grade percentages
--and course codes for a given course code
--it will accept a parameter called CourseCode

drop procedure GetCourseMarks 
go

create procedure GetCourseMarks
	@CourseCode nvarchar(12)
as
begin
	select c.CourseCode, e.FinalGradePercent  
	from Course c join Enrollment e on c.CourseID = e.CourseID 
	where e.FinalGradePercent is not null
	and c.CourseCode = @CourseCode
end

exec GetCourseMarks 'COMM1101'

select c.CourseCode, e.FinalGradePercent  
from Course c join Enrollment e on c.CourseID = e.CourseID 
where e.FinalGradePercent is not null
and c.CourseCode = 'COMM1101'


/************** NEW CONTENT ****************/ 
/************** VARIABLES INSIDE A STORED PROCEDURE, AND IF/ELSE ****************/ 

--we can declare variables inside a stored procedure
--write a stored procedure called StudentCount that displays a count of students

drop procedure StudentCount
go

create procedure StudentCount 
as
begin
	declare @StudentCount int;
	
	select @StudentCount = count(*)
	from Student
	
	select 'There are ' + cast(@StudentCount as nvarchar(10)) + ' in the database.'
end

exec StudentCount

--using if/else in a stored procedure

drop procedure CheckClubCount
go

--write a procedure called CheckClubCount that prints out a happy message
--if there are 5 or more clubs, and a sad message otherwise
create procedure CheckClubCount 
as
begin
	declare @ClubCount int;

	select @ClubCount = count(*) 
	from Club;
	
	if @ClubCount < 5
	begin
		select 'Low number of clubs. Get some more clubs!'
	end
	else
	begin
		select 'Club list is healthy!'
	end
end

exec CheckClubCount









