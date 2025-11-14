--------------------review stored procedures-----------------

--write a stored procedure that returns the locker number and building for a given student
--raise an error if the procedure is passed a null value, the student doesn't exist,
--or no locker is assigned to the student
create or alter procedure GetLockerForStudent @studentID int
as 
begin
    if @studentID is null 
        BEGIN
            RAISERROR('StudentID cannot be null.',16,1);
        END
    else if not exists (select 1 from Student Where StudentID = @studentID)
        BEGIN
            RAISERROR('Student not found.',16,1);
        END
    else if not exists (select 1 from Locker where StudentID = @studentID)
        BEGIN
            RAISERROR('No locker assigned to this student.',16,1);
        END
    ELSE --we're good to go
        BEGIN
            select LockerNumber, Building
            from Locker
            where studentID = @studentID
        END
END
select * from locker
exec GetLockerForStudent 10

--write a stored procedure called EnrollStudent that enrolls a given studentID into a given courseID
--make sure the studentId and course exist, and that the student isn't already enrolled in the course
GO
create or alter procedure EnrollStudent
    @StudentID int, @courseID INT
as 
begin 
    if not exists (select 1 from dbo.Student where StudentID = @StudentID)
        begin
            raiserror('EnrollStudent failed - StudentID not found.', 16, 1);
        end
    else if not exists (select 1 from dbo.Course where CourseID = @CourseID)
        begin
            raiserror('EnrollStudent failed - CourseID not found.', 16, 1);
        end
    else if exists (select 1 from dbo.Enrollment where StudentID = @StudentID and CourseID = @CourseID)
        begin
            raiserror('EnrollStudent failed - already enrolled in this course.', 16, 1);
        end
    ELSE --passed all checks, enroll the student
        BEGIN
            insert into enrollment (StudentID, CourseID, EnrollDate, Status, FinalGradePercent)
            values(@studentID, @courseID, getdate(), 'Active', null);

            if @@error != 0 --did the last statement create an error?
                BEGIN
                    raiserror('EnrollStudent insert failed.', 16, 1);
                END
            ELSE
                BEGIN
                    select @@identity as NewEnrollmentID
                END
        END
END
exec EnrollStudent 1, 3

select * from Enrollment

----------------TRIGGERS--------------------
go
create or alter trigger trg_AfterInsert_Student
on Student --which table?
for insert --which DML command? insert, update, or delete?
AS
BEGIN
    select StudentId, FirstName, LastName, DateofBirth, Email
    from inserted;
END

INSERT INTO dbo.Student (FirstName, LastName, DateOfBirth, Email) VALUES
  ('Leannn','Amores','2001-03-22','Lean6.Amores.ca');

go
create or alter trigger trg_AfterDelete_Student
on Student 
for DELETE
AS
BEGIN
    --the deleted table contains all the records that are about to be deleted
    select StudentId, FirstName, LastName, DateofBirth, Email
    from deleted;
END

delete from Student
where StudentID = 11 or StudentID = 15

select * from Student
go
create or alter trigger trg_AfterUpdate_Student
on Student 
for update 
as 
BEGIN
    select deleted.StudentID, deleted.FirstName, deleted.LastName, deleted.DateofBirth, deleted.Email,
    inserted.StudentID, inserted.FirstName, inserted.LastName, inserted.DateofBirth, inserted.Email
    from deleted, inserted;
END


UPDATE Student
SET Email = 'triggerrrrrr.test2@example.ca'
WHERE FirstName = 'Maria' AND LastName = 'Lopez';

select * from Student