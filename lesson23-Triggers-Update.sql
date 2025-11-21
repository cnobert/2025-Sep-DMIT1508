----------------REVIEW----------------
/*
Create an INSERT trigger on Student that updates the newly inserted rows so that the email is stored
as all capital letters.
*/
go
create or alter trigger trg_Student_CapitalizeEmail
on student 
for insert 
AS
begin
    UPDATE s
    SET s.Email = upper(s.email)
    from Student s join inserted i on s.StudentID = i.StudentID
END

INSERT INTO Student (FirstName, LastName, DateOfBirth, Email) VALUES
  ('Harper','Sinclair','2004-10-18','hharper.sinclair@example.ca');

select * from student where firstname = 'Harper'

---------------- UPDATE TRIGGERS ----------------
/*
Clear a student’s final grade when they drop a course.
Create an UPDATE trigger on Enrollment that:
	•	Detects when Status changes from anything else to 'Dropped'.
	•	Sets FinalGradePercent to NULL.
*/
go
create or alter trigger trg_Enrollment_ClearGradeOnDrop
on enrollment
for update 
as 
BEGIN
    set nocount on;
    update e 
    set e.FinalGradePercent = null
    from Enrollment e join inserted i on e.EnrollmentID = i.EnrollmentID
    join deleted d on i.EnrollmentID = d.EnrollmentID
    where i.Status = 'Dropped' and d.Status != 'Dropped' --only update the ones that have changed in this way
END

select * from enrollment where EnrollmentID = 1

UPDATE Enrollment
SET Status = 'Dropped'
WHERE EnrollmentID = 1

/*
    Create an UPDATE trigger on Enrollment that enforces this rule:
	•	FinalGradePercent cannot be increased by more than 20 percentage points in a single update.

    Requirements:
        •	Use both the inserted and deleted pseudo-tables.
        •	If any updated row tries to increase FinalGradePercent by more than 20 points compared to its previous value, the trigger must raise an error and roll back the transaction.
        •	If FinalGradePercent was NULL before the update (no grade yet), the trigger should allow the update.
*/
go
create or alter trigger trg_Enrollment_PreventLargeGradeIncreases
on enrollment
for update 
as 
BEGIN
    set nocount on;

    if exists 
    (
                select *
                from inserted i join deleted d on i.EnrollmentID = d.EnrollmentID
                where i.FinalGradePercent > (d.FinalGradePercent + 20)
    )
    BEGIN
        RAISERROR('FinalGradePercent cannot be increased by more than 20 percentage points in a single update.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END

SELECT * FROM Enrollment WHERE EnrollmentID = 13;
UPDATE Enrollment SET FinalGradePercent = 90 WHERE EnrollmentID = 13;


/* 
QUESTION:

Create a new table AssessmentGradeLog with these columns:
- LogID (INT IDENTITY, primary key)
- AssessmentID (INT, not null)
- OldPointsEarned (DECIMAL(6,2), nullable)
- NewPointsEarned (DECIMAL(6,2), nullable)
- ChangedAt (DATETIME2, not null)

Then create an UPDATE trigger on Assessment that:
- Inserts a row into AssessmentGradeLog whenever PointsEarned changes.
- Handles multi-row updates correctly (one log row per changed assessment).
*/
go
CREATE TABLE AssessmentGradeLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    AssessmentID INT NOT NULL,
    OldPointsEarned DECIMAL(6,2) NULL,
    NewPointsEarned DECIMAL(6,2) NULL,
    ChangedAt DATETIME2 NOT NULL
);
select * from AssessmentGradeLog
/*
 create an UPDATE trigger on Assessment that:
- Inserts a row into AssessmentGradeLog whenever PointsEarned changes.
- Handles multi-row updates correctly (one log row per changed assessment).
*/
go
create or alter trigger trg_Assessment_LogGradeChanges
on Assessment
for update 
as 
begin 
    set nocount on;
    INSERT INTO AssessmentGradeLog (AssessmentID, OldPointsEarned, NewPointsEarned, ChangedAt) 
    select d.AssessmentID, d.PointsEarned, i.PointsEarned, GetDate()
    from inserted i join deleted d on i.AssessmentID = d.AssessmentID
    where i.PointsEarned != d.PointsEarned
end

INSERT INTO AssessmentGradeLog (AssessmentID, OldPointsEarned, NewPointsEarned, ChangedAt) 
VALUES (101, 85.50, 90.00, '2025-11-21 11:20:00.0000000');

DELETE from AssessmentGradeLog

select * from AssessmentGradeLog

select * from Assessment where EnrollmentID = 1 and AssessmentID = 2

update Assessment
set PointsEarned = 19
where EnrollmentID = 1 and AssessmentID = 2