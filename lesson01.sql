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
('Brian', 'Smith', '1999-08-22', 'brian.smith@example.com'),
('Catherine', 'Lee', '2001-01-10', 'catherine.lee@example.com'),
('Daniel', 'Martinez', '1998-11-30', 'daniel.martinez@example.com'),
('Ella', 'Nguyen', '2000-07-05', 'ella.nguyen@example.com'),
('Frank', 'O''Connor', '1997-03-18', 'frank.oconnor@example.com'),
('Grace', 'Kim', '2001-09-27', 'grace.kim@example.com'),
('Henry', 'Brown', '1999-12-12', 'henry.brown@example.com'),
('Isabella', 'Wilson', '2000-02-25', 'isabella.wilson@example.com'),
('Jack', 'Davis', '1998-06-09', 'jack.davis@example.com');

select * from Student;

select FirstName from Student;

select FirstName, Lastname from Student;

select FirstName + ' ' + LastName as FullName
from Student;

select *
from Student
where StudentID = 1;

select *
from Student
where StudentID between 3 and 7;