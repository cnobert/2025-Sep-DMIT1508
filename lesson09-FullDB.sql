-- Drop child tables first (those with foreign keys), then parent tables.
-- Order is important to avoid foreign key constraint errors.

-- PRE-DROP for new tables so the original block can run cleanly
IF OBJECT_ID('dbo.Assessment','U') IS NOT NULL
  DROP TABLE dbo.Assessment;    -- depends on Enrollment

IF OBJECT_ID('dbo.Enrollment','U') IS NOT NULL
  DROP TABLE dbo.Enrollment;    -- depends on Student and Course

IF OBJECT_ID('dbo.Course','U') IS NOT NULL
  DROP TABLE dbo.Course;        -- parent of Enrollment (safe to drop now)
 
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

INSERT INTO dbo.Locker (LockerNumber, Building, Floor, StudentID) VALUES
  ('M1-101', 'Main',   1, 1),   -- Maria Lopez
  ('M1-102', 'Main',   1, NULL), -- Unassigned
  ('T0-015', 'Tech',   0, NULL), -- Unassigned
  ('T1-045', 'Tech',   1, 2),   -- Jason Wong
  ('N3-301', 'North',  3, 4),   -- Liam Nguyen
  ('S2-220', 'South',  2, 3),   -- Aisha Khan
  ('E1-110', 'East',   1, 5),   -- Sophia Brown
  ('W0-005', 'West',   0, NULL), -- Unassigned
  ('G4-410', 'Gym',    4, 6),   -- Ethan Martin
  ('N1-115', 'North',  1, 7);   -- Olivia Clark

INSERT INTO dbo.Club (ClubName, Room, MeetingDay) VALUES
  ('Robotics Club','D201','Tuesday'),
  ('Chess Club','C118','Thursday'),
  ('Drama Society','A303','Wednesday'),
  ('Coding Circle','B122','Monday'),
  ('Basketball','Gym','Friday'),
  ('Photography','E210','Tuesday'),
  ('Debate Team','B204','Thursday');

-- Many-to-many example: some students belong to multiple clubs, some to none, 
-- and one club has no members
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
  
/* =========================================================
   Extension: Course, Enrollment, Assessment  (simple inserts)
   - Raw INSERT ... VALUES only
   - Uses IDENTITY_INSERT to set stable IDs for teaching
   ========================================================= */


-- Parent: Course
CREATE TABLE dbo.Course
(
    CourseID   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CourseCode NVARCHAR(12)      NOT NULL UNIQUE,  -- e.g., DMIT1508
    Title      NVARCHAR(120)     NOT NULL,
    Department NVARCHAR(50)      NULL,
    Credits    TINYINT           NOT NULL
        CONSTRAINT CK_Course_Credits CHECK (Credits BETWEEN 1 AND 10),
    Term       NVARCHAR(10)      NULL             -- e.g., F2025, W2026
);

-- Simple inserts with fixed IDs
SET IDENTITY_INSERT dbo.Course ON;
INSERT INTO dbo.Course (CourseID, CourseCode, Title, Department, Credits, Term) VALUES
  (1,'DMIT1508','Database Fundamentals with SQL','Digital Media',3,'F2025'),
  (2,'GMPR1512','Unity 2D Game Dev','Game Programming',3,'F2025'),
  (3,'GMPR2512','Game Dev Tools and Scripting','Game Programming',3,'W2026'),
  (4,'GMPR2514','Game Programming Fundamentals','Game Programming',4,'W2026'),
  (5,'COMM1101','Business Communications','General Studies',3,'F2025'),
  (6,'MATH1201','Applied Math for Tech','Mathematics',3,'F2025');
SET IDENTITY_INSERT dbo.Course OFF;

-- Bridge: Enrollment
CREATE TABLE dbo.Enrollment
(
    EnrollmentID       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StudentID          INT               NOT NULL,
    CourseID           INT               NOT NULL,
    EnrollDate         DATE              NOT NULL,
    Status             NVARCHAR(12)      NOT NULL
        CONSTRAINT CK_Enrollment_Status CHECK (Status IN ('Active','Dropped','Completed')),
    FinalGradePercent  DECIMAL(5,2)      NULL
        CONSTRAINT CK_Enrollment_Grade CHECK (
            FinalGradePercent IS NULL OR (FinalGradePercent >= 0 AND FinalGradePercent <= 100)
        ),

    CONSTRAINT FK_Enrollment_Student FOREIGN KEY (StudentID)
        REFERENCES dbo.Student(StudentID),

    CONSTRAINT FK_Enrollment_Course FOREIGN KEY (CourseID)
        REFERENCES dbo.Course(CourseID),

    CONSTRAINT UX_Enrollment_Student_Course UNIQUE (StudentID, CourseID)
);

-- Fixed EnrollmentIDs for clarity
SET IDENTITY_INSERT dbo.Enrollment ON;

-- 1: Maria Lopez (1)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (1, 1, 1, '2025-09-01', 'Active',    NULL),
 (2, 1, 2, '2025-09-01', 'Active',    NULL),
 (3, 1, 5, '2025-09-01', 'Completed', 88.50);

-- 2: Jason Wong (2)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (4, 2, 1, '2025-09-01', 'Active',    NULL),
 (5, 2, 3, '2026-01-08', 'Dropped',   NULL),
 (6, 2, 6, '2025-09-01', 'Completed', 79.00);

-- 3: Aisha Khan (3)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (7, 3, 1, '2025-09-01', 'Active',    NULL),
 (8, 3, 2, '2025-09-01', 'Active',    NULL),
 (9, 3, 6, '2025-09-01', 'Completed', 91.00);

-- 4: Liam Nguyen (4)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (10, 4, 2, '2025-09-01', 'Active',   NULL),
 (11, 4, 3, '2026-01-08', 'Active',   NULL),
 (12, 4, 4, '2026-01-08', 'Active',   NULL);

-- 5: Sophia Brown (5)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (13, 5, 1, '2025-09-01', 'Completed',95.25),
 (14, 5, 2, '2025-09-01', 'Completed',92.00),
 (15, 5, 5, '2025-09-01', 'Active',    NULL);

-- 6: Ethan Martin (6)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (16, 6, 1, '2025-09-01', 'Completed',72.00),
 (17, 6, 2, '2025-09-01', 'Completed',76.50),
 (18, 6, 3, '2026-01-08', 'Active',   NULL);

-- 7: Olivia Clark (7)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (19, 7, 1, '2025-09-01', 'Active',   NULL),
 (20, 7, 2, '2025-09-01', 'Active',   NULL);

-- 8: Noah Wilson (8)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (21, 8, 1, '2025-09-01', 'Completed',84.00),
 (22, 8, 6, '2025-09-01', 'Completed',80.00);

-- 9: Mia Patel (9)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (23, 9, 2, '2025-09-01', 'Active',   NULL),
 (24, 9, 5, '2025-09-01', 'Dropped',  NULL);

-- 10: Lucas Garcia (10)
INSERT INTO dbo.Enrollment (EnrollmentID, StudentID, CourseID, EnrollDate, Status, FinalGradePercent) VALUES
 (25,10, 1, '2025-09-01', 'Completed',68.00),
 (26,10, 2, '2025-09-01', 'Active',   NULL),
 (27,10, 3, '2026-01-08', 'Active',   NULL);

SET IDENTITY_INSERT dbo.Enrollment OFF;

-- Child: Assessment
CREATE TABLE dbo.Assessment
(
    AssessmentID   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EnrollmentID   INT               NOT NULL,
    Title          NVARCHAR(100)     NOT NULL,
    Category       NVARCHAR(20)      NOT NULL,
    PointsPossible DECIMAL(6,2)      NOT NULL,
    PointsEarned   DECIMAL(6,2)      NULL,
    DueDate        DATE              NULL,

    CONSTRAINT CK_Assessment_Category
        CHECK (Category IN ('Quiz','Lab','Project','Exam','Other')),

    CONSTRAINT CK_Assessment_Possitive
        CHECK (PointsPossible > 0),

    CONSTRAINT CK_Assessment_NotOver
        CHECK (PointsEarned IS NULL OR (PointsEarned >= 0 AND PointsEarned <= PointsPossible)),

    CONSTRAINT FK_Assessment_Enrollment
        FOREIGN KEY (EnrollmentID)
        REFERENCES dbo.Enrollment(EnrollmentID)
        ON DELETE CASCADE
);

-- Assessments - raw inserts only

-- DMIT1508 - EnrollmentIDs: 1,4,7,13,16,19,21,25
INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (1,  'Quiz 1',     'Quiz',    10.00,  9.00, '2025-09-15'),
 (1,  'Lab 1',      'Lab',     20.00, 18.00, '2025-09-22'),
 (1,  'Project 1',  'Project', 40.00, 35.50, '2025-10-10'),
 (1,  'Midterm',    'Exam',    30.00, 27.00, '2025-10-20'),

 (4,  'Quiz 1',     'Quiz',    10.00,  8.00, '2025-09-15'),
 (4,  'Lab 1',      'Lab',     20.00, 17.00, '2025-09-22'),

 (7,  'Quiz 1',     'Quiz',    10.00,  9.00, '2025-09-15'),
 (7,  'Lab 1',      'Lab',     20.00, 19.00, '2025-09-22'),

 (13, 'Quiz 1',     'Quiz',    10.00, 10.00, '2025-09-15'),
 (13, 'Lab 1',      'Lab',     20.00, 20.00, '2025-09-22'),
 (13, 'Project 1',  'Project', 40.00, 38.00, '2025-10-10'),
 (13, 'Midterm',    'Exam',    30.00, 27.25, '2025-10-20'),

 (16, 'Quiz 1',     'Quiz',    10.00,  7.00, '2025-09-15'),
 (16, 'Lab 1',      'Lab',     20.00, 15.00, '2025-09-22'),

 (19, 'Quiz 1',     'Quiz',    10.00,  9.00, '2025-09-15'),

 (21, 'Quiz 1',     'Quiz',    10.00,  9.00, '2025-09-15'),
 (21, 'Lab 1',      'Lab',     20.00, 17.50, '2025-09-22'),
 (21, 'Project 1',  'Project', 40.00, 34.00, '2025-10-10'),
 (21, 'Midterm',    'Exam',    30.00, 23.50, '2025-10-20'),

 (25, 'Quiz 1',     'Quiz',    10.00,  6.50, '2025-09-15'),
 (25, 'Lab 1',      'Lab',     20.00, 13.00, '2025-09-22');

-- DMIT1508 - in progress for Active enrollments: 1,4,7,19
INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (1,  'Quiz 2', 'Quiz', 10.00, NULL, '2025-11-05'),
 (1,  'Lab 2',  'Lab',  25.00, NULL, '2025-11-15'),
 (4,  'Quiz 2', 'Quiz', 10.00, NULL, '2025-11-05'),
 (7,  'Quiz 2', 'Quiz', 10.00, NULL, '2025-11-05'),
 (19, 'Lab 2',  'Lab',  25.00, NULL, '2025-11-15');

-- GMPR1512 - EnrollmentIDs: 2,8,10,14,17,20,23,26
INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (2,  'Prototype Checkpoint', 'Project', 30.00, 27.00, '2025-10-01'),
 (2,  'Quiz: Input Systems',  'Quiz',    10.00,  8.00, '2025-10-08'),
 (8,  'Prototype Checkpoint', 'Project', 30.00, 26.00, '2025-10-01'),
 (10, 'Lab: Physics',         'Lab',     20.00, 18.00, '2025-10-12'),
 (14, 'Final Build',          'Exam',    40.00, 38.00, '2025-12-01'),
 (17, 'Quiz: Input Systems',  'Quiz',    10.00,  9.00, '2025-10-08'),
 (20, 'Lab: Physics',         'Lab',     20.00, 19.00, '2025-10-12'),
 (23, 'Prototype Checkpoint', 'Project', 30.00, NULL,  '2025-10-01'),
 (26, 'Final Build',          'Exam',    40.00, NULL,  '2025-12-01');

-- GMPR2512 - EnrollmentIDs: 5 (Dropped), 11, 18, 27
INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (11, 'Tooling Setup',     'Lab',    15.00, NULL, '2026-01-15'),
 (11, 'Scripting Quiz 1',  'Quiz',   15.00, NULL, '2026-01-22'),
 (18, 'Mini Project 1',    'Project',30.00, NULL, '2026-02-05'),
 (27, 'Midterm Practical', 'Exam',   40.00, NULL, '2026-02-20');

-- GMPR2514 - EnrollmentID: 12
INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (12, 'C# Review Quiz', 'Quiz',   20.00, NULL, '2026-01-20'),
 (12, 'OOP Lab 1',      'Lab',    20.00, NULL, '2026-01-27'),
 (12, 'Project Setup',  'Project',30.00, NULL, '2026-02-03'),
 (12, 'Midterm',        'Exam',   30.00, NULL, '2026-02-17');

-- COMM1101 - EnrollmentIDs: 3 (Completed), 15 (Active), 24 (Dropped)
INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (3,  'Report Draft', 'Project', 25.00, 22.00, '2025-10-05'),
 (3,  'Peer Review',  'Lab',     10.00,  9.00, '2025-10-12'),
 (3,  'Quiz 1',       'Quiz',    10.00,  9.00, '2025-10-18'),
 (3,  'Final Exam',   'Exam',    55.00, 48.00, '2025-12-10'),
 (15, 'Report Draft', 'Project', 25.00, NULL,  '2025-10-05');

-- MATH1201 - EnrollmentIDs: 6, 9, 22
INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (6,  'Quiz: Algebra',     'Quiz',    15.00, 12.00, '2025-10-03'),
 (6,  'Lab: Functions',    'Lab',     20.00, 16.00, '2025-10-10'),
 (9,  'Project: Modeling', 'Project', 25.00, 21.00, '2025-10-25'),
 (22, 'Final Exam',        'Exam',    40.00, 31.00, '2025-12-12');