
-- Drop child tables first (those with foreign keys), then parent tables.
-- Order is important to avoid foreign key constraint errors.

IF OBJECT_ID('dbo.StudentClub','U') IS NOT NULL
  DROP TABLE dbo.StudentClub;   -- depends on Student and Club

IF OBJECT_ID('dbo.Phone','U') IS NOT NULL
  DROP TABLE dbo.Phone;         -- depends on Student

IF OBJECT_ID('dbo.Locker','U') IS NOT NULL
  DROP TABLE dbo.Locker;        -- depends on Student

IF OBJECT_ID('dbo.Club','U') IS NOT NULL
  DROP TABLE dbo.Club;          -- parent for StudentClub

IF OBJECT_ID('dbo.Student','U') IS NOT NULL
  DROP TABLE dbo.Student;       -- parent for Phone, Locker, StudentClub


-- Create parent tables first (no dependencies).
-- Then create child tables that reference them.
CREATE TABLE dbo.Student
(
    StudentID   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FirstName   NVARCHAR(50)      NOT NULL,
    LastName    NVARCHAR(50)      NOT NULL,
    DateOfBirth DATE              NULL,
    Email       NVARCHAR(255)     NULL UNIQUE
);

-- Now the child tables (these reference Student or Club).
CREATE TABLE dbo.Phone
(
    PhoneID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StudentID   INT               NOT NULL,
    PhoneNumber NVARCHAR(20)      NOT NULL,
    CONSTRAINT FK_Phone_Student FOREIGN KEY (StudentID)
        REFERENCES dbo.Student(StudentID)
);

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

/* 
 * Enforce: a student can hold at most one locker (allow many NULLs) 
 * NULLs mean unassigned lockers are allowed.
 * */
CREATE UNIQUE INDEX UX_Locker_StudentID_OnePerStudent
  ON dbo.Locker (StudentID)
  WHERE StudentID IS NOT NULL;

CREATE TABLE dbo.Club
(
    ClubID     INT IDENTITY(1,1) PRIMARY KEY,
    ClubName   NVARCHAR(100) NOT NULL,
    Room       NVARCHAR(20)  NULL,
    MeetingDay NVARCHAR(15)  NULL
);

CREATE TABLE dbo.StudentClub
(
    StudentID INT NOT NULL,
    ClubID    INT NOT NULL,
    CONSTRAINT PK_StudentClub PRIMARY KEY (StudentID, ClubID),
    CONSTRAINT FK_StudentClub_Student FOREIGN KEY (StudentID) REFERENCES dbo.Student(StudentID),
    CONSTRAINT FK_StudentClub_Club    FOREIGN KEY (ClubID)    REFERENCES dbo.Club(ClubID)
);

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

INSERT INTO dbo.Phone (StudentID, PhoneNumber) VALUES
  (1, '780-555-1234'),
  (1, '780-555-5678'),
  (2, '780-555-2345'),
  (3, '780-555-3456'),
  (4, '780-555-4567'),
  (4, '780-555-6789');

INSERT INTO dbo.Locker (LockerNumber, Building, Floor, IsAvailable, StudentID) VALUES
  ('M1-101', 'Main',   1, 0, 1),   -- Maria Lopez
  ('M1-102', 'Main',   1, 1, NULL), -- Unassigned
  ('T0-015', 'Tech',   0, 1, NULL), -- Unassigned
  ('T1-045', 'Tech',   1, 0, 2),   -- Jason Wong
  ('N3-301', 'North',  3, 0, 4),   -- Liam Nguyen
  ('S2-220', 'South',  2, 0, 3),   -- Aisha Khan
  ('E1-110', 'East',   1, 0, 5),   -- Sophia Brown
  ('W0-005', 'West',   0, 1, NULL), -- Unassigned
  ('G4-410', 'Gym',    4, 0, 6),   -- Ethan Martin
  ('N1-115', 'North',  1, 0, 7);   -- Olivia Clark

INSERT INTO dbo.Club (ClubName, Room, MeetingDay) VALUES
  ('Robotics Club','D201','Tuesday'),
  ('Chess Club','C118','Thursday'),
  ('Drama Society','A303','Wednesday'),
  ('Coding Circle','B122','Monday'),
  ('Basketball','Gym','Friday'),
  ('Photography','E210','Tuesday'),
  ('Debate Team','B204','Thursday');

-- Many-to-many example: some students belong to multiple clubs, some to none, 
--and one club has no members
INSERT INTO dbo.StudentClub (StudentID, ClubID) VALUES
  (1, 1), -- Maria in Robotics
  (1, 2), -- Maria in Chess
  (2, 2), -- Jason in Chess
  (2, 4), -- Jason in Coding
  (3, 1), -- Aisha in Robotics
  (3, 4), -- Aisha in Coding
  (4, 5), -- Liam in Basketball
  (5, 3), -- Sophia in Drama
  (5, 6), -- Sophia in Photography
  (6, 2), -- Ethan in Chess
  (7, 4), -- Olivia in Coding
  (8, 1); -- Noah in Robotics
