/************** PARAMETER VALIDATION AND RAISERROR ****************/ 
drop procedure GetStudentByID
go
create procedure GetStudentByID
	@StudentID int 
as
if @studentID is null 
	begin
		raiserror('StudentID cannot be null.', 16, 1);
	end
--will return false if the studentID isn't in the database
if not exists(select 1 from Student where StudentID = @studentID)
	begin
		raiserror('hey silly, StudentID not found.', 16, 1);
	end
else
	begin
		select s.StudentID, s.FirstName, s.LastName, s.Email
		from Student s
		where s.StudentID = @StudentID
	end


exec GetStudentByID 23423423