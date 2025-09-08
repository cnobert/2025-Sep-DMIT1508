drop table Student;
create table Student 
(
    StudentID INT IDENTITY(1,1) not null primary key,
    FirstName NVARCHAR(50) not null,
    LastName NVARCHAR(50) not null,
    DateOfBirth date not null,
    email NVARCHAR(255) null unique
);
INSERT INTO Student (FirstName, LastName, DateOfBirth, Email) VALUES
('Alice', 'Johnson', '2000-05-14', 'alice.johnson@example.com'),
('Brian', 'Lopez', '1999-08-22', 'brian.smith@example.com'),
('Catherine', 'Lee', '2001-01-10', 'catherine.lee@example.com'),
('Daniel', 'Martinez', '1998-11-30', 'daniel.martinez@example.com'),
('Ella', 'Nguyen', '2000-07-05', 'ella.nguyen@example.com'),
('Frank', 'O''Connor', '1997-03-18', 'frank.oconnor@example.com'),
('Grace', 'Kim', '2001-09-27', 'grace.kim@example.com'),
('Henry', 'Brown', '1999-12-12', 'henry.brown@example.com'),
('Isabella', 'Lopez', '2000-02-25', 'isabella.wilson@example.com'),
('Jack', 'Davis', '1998-06-09', 'jack.davis@example.com');

select * from Student; --select all columns from all rows in Student

select FirstName from Student; --select only first name from all rows in Student

select FirstName, Lastname from Student; --select only first and last names from all rows in Student

select FirstName + ' ' + LastName as FullName
from Student;

--select all columns from only the student(s) with the StudentId of 1
select *
from Student
where StudentID = 1; --"where" filters out records

select *
from Student
where StudentID between 3 and 7;

-- Select only FirstName, LastName, and Email.
select FirstName, LastName, Email 
from Student

--Select students with the last name Lopez.
select * 
from Student
where LastName = 'Lopez'

--Select students born after January 1, 1999
select * 
from Student
where DateOfBirth > '1999-01-01'

--Select students born before January 1, 1999
select * 
from Student
where DateOfBirth <= '1999-01-01'

--Show all students ordered alphabetically by LastName.
select *
from Student
order by LastName 

--Show all students ordered alphabetically by LastName, descending
select *
from Student
order by LastName desc

--Show all students, ordered by DOB and then by LastName
select *
from Student
order by DateOfBirth desc, LastName desc

--Show all students, ordered by DOB and then by LastName
--set the DOB column equal to "Date of Birth, Descending"
select StudentID, FirstName, LastName, DateOfBirth as 'Date of Birth, Descending', email
from Student
order by DateOfBirth desc, LastName desc