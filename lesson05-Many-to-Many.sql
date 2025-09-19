
  IF OBJECT_ID('dbo.StudentClub','U') IS NOT NULL DROP TABLE dbo.StudentClub;
IF OBJECT_ID('dbo.Club','U')        IS NOT NULL DROP TABLE dbo.Club;
IF OBJECT_ID('dbo.Student','U')     IS NOT NULL DROP TABLE dbo.Student;
GO

CREATE TABLE dbo.Student
(
    StudentID  INT IDENTITY(1,1) PRIMARY KEY,
    FirstName  NVARCHAR(50)  NOT NULL,
    LastName   NVARCHAR(50)  NOT NULL,
    Email      NVARCHAR(255) NOT NULL UNIQUE
);

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
GO

-- Sample data
INSERT INTO dbo.Student (FirstName, LastName, Email) VALUES
  ('Maria','Lopez','maria.lopez@example.ca'),
  ('Jason','Wong','jason.wong@example.ca'),
  ('Aisha','Khan','aisha.khan@example.ca'),
  ('Liam','Nguyen','liam.nguyen@example.ca'),
  ('Sophia','Brown','sophia.brown@example.ca'),
  ('Ethan','Martin','ethan.martin@example.ca'),
  ('Olivia','Clark','olivia.clark@example.ca'),
  ('Noah','Wilson','noah.wilson@example.ca'),
  ('Chloe','Patel','chloe.patel@example.ca'),
  ('Mason','Hall','mason.hall@example.ca');

INSERT INTO dbo.Club (ClubName, Room, MeetingDay) VALUES
  ('Robotics Club','D201','Tuesday'),
  ('Chess Club','C118','Thursday'),
  ('Drama Society','A303','Wednesday'),
  ('Coding Circle','B122','Monday'),
  ('Basketball','Gym','Friday'),
  ('Photography','E210','Tuesday'),
  ('Debate Team','B204','Thursday');

-- Some students in multiple clubs, some students in none, one club with no members
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

  insert into StudentClub(StudentID, ClubID) values 
  (12,1);

  select * from student

  --a) Show ClubName, FirstName, LastName for every club and every student who is in a club
  -- order by ClubName
  select c.ClubName, s.FirstName, s.LastName
  from Student s join StudentClub sc on s.StudentID = sc.StudentID
  join Club c on sc.ClubId = c.ClubID
  order by c.ClubName

--All clubs for StudentID = 2
select c.ClubName
from StudentClub sc join Club c on sc.ClubId = c.ClubId 
where sc.StudentID = 2

-- All club names for Sophia Brown
select c.ClubName
from Student s join StudentClub sc on s.StudentID = sc.StudentID
join Club c on sc.ClubId = c.ClubID
--where s.FirstName = 'Sophia' and s.LastName = 'Brown'
where s.FirstName + ' ' + s.LastName = 'Sophia Brown'

--All students for the 'Coding Circle' club
select s.FirstName + ' ' + s.LastName as 'Coding Club Members'
from Student s join StudentClub sc on s.StudentID = sc.StudentID
join Club c on sc.ClubId = c.ClubID
where c.ClubName = 'Coding Circle'