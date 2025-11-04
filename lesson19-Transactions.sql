/************ TRANSACTIONS ************/
/*
    We use transactions when we need more than one database command
    to work. If any one command fails, we need to reverse all changes.
*/
go
create or alter procedure DeleteStudent 
    @StudentID int 
as
    BEGIN
        if exists (select 1 from Student where StudentID = @StudentID)
            BEGIN
                begin transaction;

                delete from Phone
                where StudentId = @StudentID;
                if @@error <> 0
                    BEGIN
                        raiserror('DeleteStudent failed.', 16, 1)
                        rollback transaction;
                    END
                ELSE
                    BEGIN
                        delete from Locker 
                        where StudentID = @StudentID 
                        if @@error <> 0
                            BEGIN
                                raiserror('DeleteStudent failed.', 16, 1)
                                rollback transaction;
                            END
                        else
                            begin
                                delete from StudentClub
                                where StudentId = @StudentID
                                if @@error <> 0
                                    BEGIN
                                        raiserror('DeleteStudent failed.', 16, 1)
                                        rollback transaction;
                                    END
                                else
                                    begin
                                        delete from Enrollment
                                        where StudentId = @StudentID

                                        if @@error <> 0
                                            BEGIN
                                                raiserror('DeleteStudent failed.', 16, 1)
                                                rollback transaction;
                                            END
                                        ELSE
                                            begin
                                                
                                                delete from Student
                                                where StudentId = @StudentID
                                                if @@error <> 0
                                                    BEGIN
                                                        raiserror('DeleteStudent failed.', 16, 1)
                                                        rollback transaction;
                                                    END
                                                else --since @@error is equal to zero, the deletion was a success
                                                    BEGIN
                                                        select 'Delete Student was successful'
                                                        commit transaction;
                                                    END
                                            END        
                                    END
                            END
                    END
            END
        ELSE --student does not exist
            BEGIN
                raiserror('DeleteStudent failed - StudentID not found.', 16, 1);
            END
    END

select * from Locker
exec DeleteStudent 2
select * from student
--EnrollStudentInCourse
go
create or alter procedure EnrollStudentInCourse
    @StudentID int,
    @CourseID int,
    @EnrollDate date 
AS
BEGIN
    begin transaction;

    INSERT INTO Enrollment (StudentID, CourseID, EnrollDate, Status, FinalGradePercent)
    VALUES (@StudentID, @CourseID, @EnrollDate, 'Active', NULL);

    if @@error <> 0
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Enrollment failed', 16, 1);
        END
    ELSE
        BEGIN
            INSERT INTO Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate)
            VALUES (@@IDENTITY, 'Orientation Check', 'Quizz', 10.00, NULL, @EnrollDate);
        END
        if @@error <> 0
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('Adding an assessment failed, rolling back transaction.', 16, 1);
            END
        else
            BEGIN
                commit TRANSACTION;
            END
END

select * from student
select * from enrollment
select * from assessment
exec EnrollStudentInCourse 3, 2, '2026-01-04'

/*
Create a stored procedure named AssignLockerToStudent that accepts @LockerNumber, @Building, @Floor, and @StudentID.

The procedure should begin a transaction that:
    Inserts a new locker record with the provided details and assigns it to the student.
    If the student does not have a phone, roll back the transaction and raise the error 'Student must have a phone before locker assignment.'.
        Checks whether the student has at least one phone number on file.

If all conditions are met, commit the transaction.
*/
go
CREATE OR ALTER PROCEDURE AssignLockerToStudent
    @LockerNumber NVARCHAR(20),
    @Building     NVARCHAR(50),
    @Floor        INT,
    @StudentID    INT
AS
BEGIN
    begin TRANSACTION;
    /* 1) Assign the locker to the student (insert a new locker row) */
    INSERT INTO Locker (LockerNumber, Building, Floor, StudentID)
    VALUES (@LockerNumber, @Building, @Floor, @StudentID);
    IF @@ERROR != 0
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Locker assignment failed.', 16, 1);
        END
    ELSE
        BEGIN
        /* 2) Between-step check: student must have at least one phone on file */
        if not exists(select 1 from Phone where StudentID = @StudentID)
            begin
                ROLLBACK TRANSACTION;
                RAISERROR('Student must have a phone before locker assignment. Transaction rolled back.', 16, 1);
            end
        ELSE
            begin
                commit TRANSACTION;
            END
        END
END
select * from student
select * from Phone
select * from Locker
exec AssignLockerToStudent 'M1-103', 'Main', 1, 10

INSERT INTO dbo.Phone (StudentID, PhoneNumber) VALUES
  (10, '101-010-1010')