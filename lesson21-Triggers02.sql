--------------------REVIEW-----------------------
create or alter trigger trg_AfterInsert_Locker
on Locker --associate with a table
for insert --associate with a DML command (insert, update, delete)
as 
begin 
    --in here we can access the pseudotables "inserted" or "deleted"
    --every trigger automatically creates a transaction
    select *
    from inserted
    ROLLBACK TRANSACTION;
end 

INSERT INTO Locker (LockerNumber, Building, Floor, StudentID) VALUES
  ('M1-921', 'Main',   1, 8);

-------------------------- TRIGGER LOGIC ----------------------
/*
Write an INSERT trigger on Phone that prevents inserting a phone number that already exists in the table.
*/
go 
create or alter trigger trg_Phone_PreventDuplicateNumber
on Phone 
for insert 
as 
begin 
    set nocount on; -- makes debugging triggers easier because it suppresses some messages
    -- select *
    -- from phone p join inserted i on p.PhoneNumber = i.PhoneNumber
    -- where p.PhoneID != i.PhoneID
    if EXISTS
        (
            select 1
            from phone p join inserted i on p.PhoneNumber = i.PhoneNumber
            where p.PhoneID != i.PhoneID
        )
        begin
            RAISERROR('Phone number already exists. Insert blocked.', 16, 1);
            rollback TRANSACTION;
        end
end 

select * 
from phone
where phone.PhoneNumber = '789-554-1111'


insert into Phone (StudentID, PhoneNumber)
values (1, '780-554-3422')

-- Should succeed
INSERT INTO dbo.Phone (StudentID, PhoneNumber)
VALUES (1, '7805551234');

-- Should fail
INSERT INTO dbo.Phone (StudentID, PhoneNumber)
VALUES (2, '7805551234');

/*
In-class exercise 
Write an INSERT trigger on Student that enforces this rule:
 
Business rule: No two students can share the same email address.
 
If any row in inserted has an Email that already exists in Student for a different StudentID, the trigger must raise an error and roll back the transaction.
 
Use a join between inserted and Student to check for duplicates.
 
*/
go
create or alter trigger trg_Student_PreventDuplicateEmails
on Student 
for insert 
as 
begin 
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.Student AS s
            ON s.Email = i.Email
           AND s.StudentID <> i.StudentID
    )
    BEGIN
        RAISERROR('Email address already exists for another student.', 16, 1);
        ROLLBACK TRANSACTION;
    END
end

select * from Student
INSERT INTO dbo.Student (FirstName, LastName, DateOfBirth, Email) VALUES
  ('John','Brown','2004-03-22','brown.john@example.ca');