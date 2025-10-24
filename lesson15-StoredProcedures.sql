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
else if not exists(select 1 from Student where StudentID = @studentID)
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
exec GetStudentByID @studentID = null

drop procedure GetLockerForStudent
go 
create procedure GetLockerForStudent
	@studentID int 
as
if @studentID is NULL 
	begin
		RAISERROR('StudentID cannot be null.',16,1);
	end
else if not exists(select 1 from Student where StudentID = @studentID)
	begin
		raiserror('hey silly, StudentID not found.', 16, 1);
	end
else if not exists(select 1 from Locker where StudentID = @studentID)
	begin
		raiserror('No locker is assigned to this student.', 16, 1);
	end
else
	begin
		SELECT LockerID, LockerNumber, Building, Floor
		FROM dbo.Locker
		WHERE StudentID = @StudentID;
	end
	
exec GetLockerForStudent @studentID = null
exec GetLockerForStudent 234234
exec GetLockerForStudent 7
exec GetLockerForStudent 1

















