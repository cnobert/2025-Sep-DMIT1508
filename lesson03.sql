
/* Recreate tables */
IF OBJECT_ID('dbo.Locker','U') IS NOT NULL DROP TABLE dbo.Locker;
IF OBJECT_ID('dbo.Student','U') IS NOT NULL DROP TABLE dbo.Student;
GO

CREATE TABLE dbo.Student
(
    StudentID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FirstName     NVARCHAR(50)      NOT NULL,
    LastName      NVARCHAR(50)      NOT NULL,
    DateOfBirth   DATE              NULL,
    Email         NVARCHAR(255)     NULL UNIQUE
);
GO

CREATE TABLE dbo.Locker
(
    LockerID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    LockerNumber  NVARCHAR(20)      NOT NULL UNIQUE,
    Building      NVARCHAR(50)      NOT NULL,
    Floor         INT               NOT NULL,
    IsAvailable   BIT               NOT NULL,
    StudentID     INT               NULL,
    CONSTRAINT FK_Locker_Student FOREIGN KEY (StudentID)
        REFERENCES dbo.Student(StudentID)
);
GO

/* Enforce: a student can hold at most one locker (allow many NULLs) */
CREATE UNIQUE INDEX UX_Locker_StudentID_OnePerStudent
  ON dbo.Locker (StudentID)
  WHERE StudentID IS NOT NULL;
GO

/* ===========================
   Seed data - 10 students
   =========================== */
INSERT INTO dbo.Student (FirstName, LastName, DateOfBirth, Email) VALUES
  ('Maria','Lopez','2004-03-22','maria.lopez@example.ca'),
  ('Jason','Wong','2003-11-14','jason.wong@example.ca'),
  ('Aisha','Khan','2005-07-08','aisha.khan@example.ca'),
  ('Liam','Nguyen','2004-01-30','liam.nguyen@example.ca'),
  ('Sophia','Brown','2005-05-12','sophia.brown@example.ca'),
  ('Ethan','Martin','2003-09-19','ethan.martin@example.ca'),
  ('Olivia','Clark','2004-12-03','olivia.clark@example.ca'),
  ('Noah','Wilson','2005-02-17','noah.wilson@example.ca'),
  ('Mia','Patel','2004-07-26','mia.patel@example.ca'),
  ('Lucas','Garcia','2003-03-11','lucas.garcia@example.ca');
GO

/* ===========================
   Seed data - 10 lockers
   - Assigned lockers have IsAvailable = 0
   - Unassigned lockers have IsAvailable = 1
   =========================== */
INSERT INTO dbo.Locker (LockerNumber, Building, Floor, IsAvailable, StudentID) VALUES
  ('M1-101', 'Main',   1, 0, 1),   -- Maria
  ('M1-102', 'Main',   1, 1, NULL),
  ('T0-015', 'Tech',   0, 1, NULL),
  ('T1-045', 'Tech',   1, 0, 2),   -- Jason
  ('N3-301', 'North',  3, 0, 4),   -- Liam
  ('S2-220', 'South',  2, 0, 3),   -- Aisha
  ('E1-110', 'East',   1, 0, 5),   -- Sophia
  ('W0-005', 'West',   0, 1, NULL),
  ('G4-410', 'Gym',    4, 0, 6),   -- Ethan
  ('N1-115', 'North',  1, 0, 7);   -- Olivia
GO
