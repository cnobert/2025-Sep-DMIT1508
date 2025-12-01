/* 
Q1 (3 marks)

Create a stored procedure named GetAllServices that selects all columns
from Service, ordered by ServiceCode.
*/
GO
create or alter Procedure GetAllServices
AS
BEGIN
    select ServiceID, ServiceCode, Title, Department, BaseFee
    from Service 
    Order By ServiceCode
END

select * from Service
exec GetAllServices


/* 
Q2 (5 marks)

Create GetPetServicesByStatus that accepts a @Status parameter.
If @Status IS NULL, RAISERROR 'Status parameter required'.
Otherwise select PetName, Title, and Status.
*/
go
create or alter procedure GetPetServicesByStatus
    @Status nvarchar(12)
AS
BEGIN
    if(@Status is null)
        begin
            RAISERROR ('Status parameter required', 16, 1);
        END
    ELSE
        BEGIN
            select p.PetName, s.Title, ps.Status
            from PetService ps join Pet p on p.PetID = ps.PetID
            join Service s on s.ServiceID = ps.ServiceID
            where ps.Status = @Status
        END
end
select * from PetService
exec GetPetServicesByStatus 'Completed'
/* 
Q3 (4 marks)

Create a stored procedure named DeleteService to delete by ServiceID.
If the service does not exist, raise an error.
If a record for the given ServiceID exists in PetService, raise an error
and do not delete.
*/
go
create or alter PROCEDURE DeleteService
    @ServiceID int
AS
BEGIN
    if not exists(select * from Service where ServiceID = @ServiceID)
        BEGIN
            RAISERROR('Service does not exist.', 16, 1);
        END
    ELSE if exists(select * from PetService where ServiceID = @ServiceID)
        BEGIN
            RAISERROR('Cannot delete service with existing pet enrollments.', 16, 1);
        END
    ELSE
        BEGIN
            delete from service 
            where ServiceID = @ServiceID
        END
end
select * from Service
exec DeleteService 8
/* 
Q4 (4 marks)

Create a stored procedure named AddService to insert a new service with
ServiceCode, Title, Department, and BaseFee.
If the ServiceCode already exists, raise an error 'Service code already exists.'
Return the new ServiceID.
*/
go
CREATE OR ALTER PROCEDURE AddService
    @ServiceCode NVARCHAR(12),
    @Title NVARCHAR(120),
    @Department NVARCHAR(50),
    @BaseFee DECIMAL(10,2)
AS
BEGIN
    if exists(select * from service where ServiceCode = @ServiceCode)
        BEGIN
            RAISERROR('Service code already exists.', 16, 1);
        END
    ELSE
        begin
            INSERT INTO Service (ServiceCode, Title, Department, BaseFee) 
            VALUES (@ServiceCode, @Title, @Department, @BaseFee);

            select @@IDENTITY as NewServiceId;
        END
end
exec AddService 'VET911', 'Emergency Surgery', 'Surgery',  495.00
/* 
Q5 (6 marks)

Create a stored procedure named EnrollPetInService that accepts
@PetID, @ServiceID, and @EnrollDate.

The procedure should begin a transaction that:
- Inserts a new record into PetService with Status = 'Active'.
- Inserts a new record into ServiceAssessment for that pet’s new service
  with Title = 'Initial Check', Category = 'Exam', and DueDate = @EnrollDate.
- If any insert fails, roll back the transaction and raise 'Enrollment failed.'.
  Otherwise, commit.
*/
go
CREATE OR ALTER PROCEDURE EnrollPetInService @PetID INT, @ServiceID INT, @EnrollDate DATE
AS
BEGIN
    begin TRANSACTION;
    INSERT INTO PetService (PetID, ServiceID, EnrollDate, Status, FinalOutcomeNotes)
    VALUES (@PetID, @ServiceID, @EnrollDate, 'Active', NULL);
    if(@@error != 0)
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Enrollment failed. Insert into PetService did not work.', 16, 1);
        END
    ELSE
        BEGIN
            INSERT INTO ServiceAssessment (PetServiceID, Title, Category, DueDate)
            VALUES (@@IDENTITY, 'Initial Check', 'Exam', @EnrollDate);

            if @@error != 0
                BEGIN
                    ROLLBACK TRANSACTION;
                    RAISERROR('Enrollment failed. Insert into ServiceAssessment did not work.', 16, 1);
                END
            ELSE
                BEGIN
                    COMMIT TRANSACTION;
                END
        END
END
EXEC EnrollPetInService 1, 2, '2025-10-01';
EXEC EnrollPetInService 999, 2, '2025-10-01';

/* 
Q6 (6 marks)

Create a stored procedure named TransferMicrochip that accepts
@OldPetID and @NewPetID.

Begin a transaction that:
- Sets PetID = NULL in Microchip for the old pet.
- Updates that same chip to use the new @NewPetID.
- If any update fails, roll back and raise 'Transfer failed.'.
  Otherwise, commit.
*/


/* 
Q7 (4 marks)

Limit active services per pet.
Create a trigger on PetService that prevents inserting rows which would
cause a pet to have more than two records where Status = 'Active'.
If an insert would exceed this limit, raise an error and roll back.
*/
go
create or alter trigger trg_PetService_MaxPetService
on PetService
for INSERT
AS
BEGIN
    set nocount on;
    if 2 < (
        select count(*)
        from inserted i join PetService ps on i.PetId = ps.Petid
        where ps.STATUS = 'Active'
    )
        BEGIN
            RAISERROR('Cannot have more than two Pet Services for a given pet with status = Active', 16, 1);
            ROLLBACK TRANSACTION;
        END
end

select * from PetService
delete from PetService
INSERT INTO PetService (PetID, ServiceID, EnrollDate, Status, FinalOutcomeNotes) VALUES
(1, 1, '2025-06-15', 'Active', 'Healthy exam, mild tartar noted');

INSERT INTO PetService (PetID, ServiceID, EnrollDate, Status, FinalOutcomeNotes) VALUES
(1, 3, '2025-06-15', 'Active', 'Vaccines up to date');

INSERT INTO PetService (PetID, ServiceID, EnrollDate, Status, FinalOutcomeNotes) VALUES
(1, 4, '2025-06-17', 'Active', 'Vaccines up to date');

/* 
Q8 (4 marks)

Prevent large service fee increases.
Create an UPDATE trigger on Service enforcing:
BaseFee cannot be increased by more than 20 percent in a single update.
If any updated row tries to increase BaseFee by more than 20 percent
compared to its previous value, raise an error and roll back.
*/
GO
CREATE OR ALTER TRIGGER trg_Service_PreventLargeFeeIncrease
ON Service
for UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS
    (
        SELECT *
        FROM inserted AS i
        JOIN deleted  AS d ON d.ServiceID = i.ServiceID
        WHERE i.BaseFee > d.BaseFee * 1.2
    )
    BEGIN
        RAISERROR('BaseFee cannot be increased by more than 20 percent in a single update.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- TESTING COMMANDS (Q8)
UPDATE Service SET BaseFee = BaseFee * 1.19 WHERE ServiceID = 1;   -- should succeed
UPDATE Service SET BaseFee = BaseFee * 1.50 WHERE ServiceID = 1;   -- should fail

/* 
Q9 (4 marks)

Block PetService enrollment for pets without owners.
Create a trigger on PetService that prevents inserting a row if the related
pet has OwnerID IS NULL in Pet.
If any inserted row references a pet with no owner, raise an error and roll back.
*/
GO
CREATE OR ALTER TRIGGER trg_PetService_BlockPetsWithoutOwners
ON PetService
for INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted AS i
        JOIN dbo.Pet AS p ON p.PetID = i.PetID
        WHERE p.OwnerID IS NULL
    )
    BEGIN
        RAISERROR('Cannot enroll a pet without an owner.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-- TESTING COMMANDS (Q9)
INSERT INTO Service (ServiceCode, Title, Department, BaseFee)
VALUES ('VET999', 'Test Enrollment Service', 'General', 10.00);

--or you can look into the database to find out what primary key was assigned
DECLARE @TestServiceID INT;
SET @TestServiceID = SCOPE_IDENTITY();

-- Success case: Pet with an owner (e.g., PetID = 1)
INSERT INTO PetService (PetID, ServiceID, EnrollDate, Status, FinalOutcomeNotes)
VALUES (1, @TestServiceID, '2025-10-01', 'Active', NULL);   -- should succeed

INSERT INTO PetService (PetID, ServiceID, EnrollDate, Status, FinalOutcomeNotes)
VALUES (9, 2, '2025-10-01', 'Active', NULL);   -- PetID 9 has NO owner → should fail
/* 
Q10 (4 marks)

Auto-format pet names.
Table: Pet
Trigger type: for INSERT
Create an AFTER INSERT trigger on Pet that updates newly inserted rows so
that PetName is stored with the first letter uppercase and the rest lowercase.
Examples: 'gUDDY' → 'Guddy', 'lUnA' → 'Luna'.
*/
GO
CREATE OR ALTER TRIGGER trg_Pet_FormatPetName
ON Pet
for INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET PetName =
        UPPER(LEFT(i.PetName, 1)) +
        LOWER(SUBSTRING(i.PetName, 2, LEN(i.PetName) - 1))
    FROM Pet AS p JOIN inserted AS i ON p.PetID = i.PetID;
END;
GO
-- TESTING COMMANDS (Q10)
INSERT INTO Pet (OwnerID, PetName, Species, Breed, DateOfBirth, Sex)
VALUES (1, 'gUDDY', 'Dog', NULL, '2024-01-01', 'M');

INSERT INTO Pet (OwnerID, PetName, Species, Breed, DateOfBirth, Sex)
VALUES (2, 'lUnA', 'Cat', NULL, '2024-02-02', 'F');

SELECT PetID, PetName FROM Pet WHERE PetName IN ('Guddy','Luna');

/* 
Q11 (6 marks)

Log changes to service fees.

Create a new table ServiceFeeLog with:
LogID INT IDENTITY PRIMARY KEY,
ServiceID INT,
OldFee DECIMAL(10,2),
NewFee DECIMAL(10,2),
ChangedAt DATETIME2.

Create an UPDATE trigger on Service that inserts a row into ServiceFeeLog
whenever BaseFee changes.
*/

GO

CREATE TABLE ServiceFeeLog
(
    LogID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ServiceID  INT               NOT NULL,
    OldFee     DECIMAL(10,2)     NOT NULL,
    NewFee     DECIMAL(10,2)     NOT NULL,
    ChangedAt  DATETIME2         NOT NULL
        CONSTRAINT DF_ServiceFeeLog_ChangedAt DEFAULT (SYSUTCDATETIME())
);
go
CREATE OR ALTER TRIGGER trg_Service_LogFeeChanges
ON Service
for UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.ServiceFeeLog (ServiceID, OldFee, NewFee, ChangedAt)
    SELECT d.ServiceID, d.BaseFee, i.BaseFee, SYSUTCDATETIME()
    FROM inserted i JOIN deleted d ON d.ServiceID = i.ServiceID
    WHERE d.BaseFee != i.BaseFee;
END;
GO

-- TESTING COMMANDS (Q11)
UPDATE Service SET BaseFee = BaseFee + 5 WHERE ServiceID = 2;   -- should log
UPDATE Service SET BaseFee = BaseFee WHERE ServiceID = 2;       -- no log (no change)