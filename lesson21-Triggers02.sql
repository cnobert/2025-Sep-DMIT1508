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