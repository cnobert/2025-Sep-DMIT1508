
IF OBJECT_ID('dbo.EmergencyContact','U') IS NOT NULL
  DROP TABLE dbo.EmergencyContact;
IF OBJECT_ID('dbo.Student','U') IS NOT NULL
  DROP TABLE dbo.Student;
GO

CREATE TABLE dbo.Student
(
    StudentID   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FirstName   NVARCHAR(50)      NOT NULL,
    LastName    NVARCHAR(50)      NOT NULL,
    DateOfBirth DATE              NULL,
    Email       NVARCHAR(255)     NULL UNIQUE
);
GO

CREATE TABLE dbo.EmergencyContact
(
    ContactID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StudentID     INT               NOT NULL,
    ContactName   NVARCHAR(100)     NOT NULL,
    Relationship  NVARCHAR(30)      NOT NULL,
    Phone         NVARCHAR(20)      NOT NULL,
    Email         NVARCHAR(255)     NULL,
    CONSTRAINT FK_EC_Student FOREIGN KEY (StudentID)
        REFERENCES dbo.Student(StudentID)
);
GO

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

INSERT INTO dbo.EmergencyContact (StudentID, ContactName, Relationship, Phone, Email) VALUES
  (1,'Elena Lopez','Parent','780-555-1001','elena.lopez@example.ca'),
  (1,'Carlos Lopez','Parent','780-555-1002','carlos.lopez@example.ca'),
  (2,'Derek Wong','Guardian','587-555-2001','derek.wong@example.ca'),
  (3,'Sana Khan','Parent','825-555-3001','sana.khan@example.ca'),
  (3,'Imran Khan','Parent','825-555-3002',NULL),
  (5,'Paula Brown','Parent','780-555-5001','paula.brown@example.ca'),
  (6,'Renee Martin','Other','780-555-6001','renee.martin@example.ca'),
  (7,'Harper Clark','Sibling','587-555-7001',NULL),
  (10,'Marcos Garcia','Guardian','780-555-1003','marcos.garcia@example.ca');
-- Students 4 and 9 have no contacts
GO

select s.StudentId, s.Firstname, s.LastName, e.ContactName, e.Relationship, e.Phone
from student s join EmergencyContact e on s.studentID = e.studentID

select *
from student s left join EmergencyContact e on s.studentID = e.studentID