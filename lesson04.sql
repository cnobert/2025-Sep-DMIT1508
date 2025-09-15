--proper one-to-many design

IF OBJECT_ID('dbo.Phone','U') IS NOT NULL
  DROP TABLE dbo.Phone;
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

CREATE TABLE dbo.Phone
(
    PhoneID     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StudentID   INT               NOT NULL,
    PhoneNumber NVARCHAR(20)      NOT NULL,
    CONSTRAINT FK_Phone_Student FOREIGN KEY (StudentID)
        REFERENCES dbo.Student(StudentID)
);
GO

INSERT INTO dbo.Student (FirstName, LastName, DateOfBirth, Email) VALUES
  ('Maria','Lopez','2004-03-22','maria.lopez@example.ca'),
  ('Jason','Wong','2003-11-14','jason.wong@example.ca'),
  ('Aisha','Khan','2005-07-08','aisha.khan@example.ca'),
  ('Liam','Nguyen','2004-01-30','liam.nguyen@example.ca'),
  ('William','Smith','2006-02-19','william.smith@example.ca'),
  ('Sophia','Brown','2005-05-12','sophia.brown@example.ca');

INSERT INTO dbo.Phone (StudentID, PhoneNumber) VALUES
  (1, '780-555-1234'),
  (1, '780-555-5678'),
  (2, '780-555-2345'),
  (3, '780-555-3456'),
  (4, '780-555-4567'),
  (4, '780-555-6789');
GO

select * from student
select * from phone
-- show students with their phone numbers
select s.FirstName + ' ' + s.LastName as 'Student Name', p.PhoneNumber
from student s join phone p on s.StudentID = p.StudentID

--By default, a "join" is an "inner join".
--An "inner join" only returns the records where there are values on both sides.

--A "left join" returns records where there are values on both sides AND
--all records for the leftmost table
select s.FirstName + ' ' + s.LastName as 'Student Name', p.PhoneNumber
from student s left join phone p on s.StudentID = p.StudentID

--A "right join" returns records where there are values on both sides AND
--ALL records for the rightmost table
select s.FirstName + ' ' + s.LastName as 'Student Name', p.PhoneNumber
from student s right join phone p on s.StudentID = p.StudentID

--return the FirstName and LastName of all students who don't have phones, order by last name
select s.FirstName + ' ' + s.LastName as 'Students Without Phones'
from student s left join phone p on s.studentID = p.studentID
where p.StudentID is null
order by s.LastName

--return the First and LastName of all students who have phones, without any duplicates
select distinct s.FirstName + ' ' + s.LastName
from student s inner join phone p on s.studentID = p.StudentID
