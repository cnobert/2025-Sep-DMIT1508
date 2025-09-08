-- Drop the Locker table if it already exists
IF OBJECT_ID('dbo.Locker', 'U') IS NOT NULL
    DROP TABLE dbo.Locker;
GO

-- Create the Locker table
CREATE TABLE dbo.Locker
(
    LockerID INT IDENTITY(1,1) PRIMARY KEY,
    LockerNumber NVARCHAR(50) NOT NULL, --NOT NULL forces there to be a value
    Building NVARCHAR(100) NOT NULL,
    Floor INT NOT NULL,
    IsAvailable BIT NOT NULL
);
GO
--NULL = "Null is allowed. So, this field may be left blank."
--NOT NULL = "Null is not allowed. So, this field MUST have a value."

INSERT INTO dbo.Locker (LockerNumber, Building, Floor, IsAvailable)
VALUES
('101A', 'Main', 1, 1),
('102B', 'Main', 1, 0),
('201',  'Main', 2, 1),
('305C', 'Science', 3, 1),
('310',  'Science', 3, 0),
('401',  'Engineering', 4, 1),
('402D', 'Engineering', 4, 1),
('501',  'Library', 5, 0),
('601',  'Gym', 6, 1),
('602',  'Gym', 6, 0);

select * from Locker