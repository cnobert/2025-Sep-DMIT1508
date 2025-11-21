----------------REVIEW----------------
--write a trigger that prevents the insertion duplicate emails int the student table
create or alter trigger trg_Student_PreventDuplicateEmails
on Student 
for insert 
as 
begin 
    if exists --the email being inserted is already in the db
    (
        select *
        from inserted i join student s on s.email = i.email
        where s.studentID != i.studentID
    )
    BEGIN
        RAISERROR('Email address already exists for another student. Insert failed.', 16, 1);
        rollback TRANSACTION;
    END
end

/*
    The query below returns no records if the email being inserted is unique
    select *
    from inserted i join student s on s.email = i.email
    where s.studentID != i.studentID
*/
select * from student

INSERT INTO Student (FirstName, LastName, DateOfBirth, Email) VALUES
  ('Conrad','Nobert','2004-03-22','con@example.ca');

  --trigger: limit a student to 3 enrollments with status = 'active'
go
create or alter trigger trg_Enrollment_LimitToThreeCourses
on Enrollment 
for insert 
as 
begin
    set nocount on;
    if
    (
        select count(*)
        from Enrollment e join inserted i on e.studentId = i.studentID
        where e.Status = 'Active'
    ) > 3
    BEGIN
        RAISERROR('Students may not be enrolled in more than three courses. Insert failed.', 16, 1);
        rollback TRANSACTION;
    END
end

select * from Enrollment where studentid = 7

INSERT INTO dbo.Enrollment (StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (7, 4, '2025-09-01', 'Active',   NULL);

 INSERT INTO dbo.Enrollment (StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (7, 5, '2025-09-01', 'Completed',   NULL);

 --trigger: Block course enrollment for students who do not have a phone.
go
create or alter trigger trg_Enrollment_StudentMustHavePhone
on Enrollment 
for insert 
as 
begin
    set nocount on;
    if not exists
    (
        select *
        from phone p join inserted i on p.studentID = i.studentID
    )
    BEGIN
        -- select *
        -- from phone p join inserted i on p.studentID = i.studentID
        RAISERROR('Students may not be enrolled if they do not have a phone. Insert failed.', 16, 1);
        rollback TRANSACTION;
    END
end

select * from phone 
select * from enrollment

--has no phone
INSERT INTO dbo.Enrollment (StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (10, 4, '2025-09-01', 'Completed',   NULL);
--has phone
INSERT INTO dbo.Enrollment (StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
(4, 5, '2025-09-01', 'Completed',   NULL);

/*
Create an INSERT trigger on Student that updates the newly inserted rows so that both FirstName and LastName are stored with the first letter uppercase and the rest lowercase.
For example:
‘cHaRLeS’ → ‘Charles’
‘mcDONALD’ → ‘Mcdonald’
‘jACOBsON’ → ‘Jacobson’
*/
GO
create or alter trigger trg_Student_CapitalizeNames
on student
for insert 
as 
BEGIN
    set nocount on;
    update s
    SET s.FirstName = UPPER(LEFT(s.FirstName, 1)) + LOWER(SUBSTRING(s.FirstName, 2, LEN(s.FirstName))),
    s.LastName  = UPPER(LEFT(s.LastName, 1))  + LOWER(SUBSTRING(s.LastName, 2, LEN(s.LastName)))
    from Student s join inserted i on s.studentID = i.studentID
END

INSERT INTO Student (FirstName, LastName, DateOfBirth, Email) VALUES
  ('conrad','nobert','2005-10-11','keira.ddddfdundfield@example.ca');

select * from student