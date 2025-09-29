--Many to Many review:
--students who are in clubs, list all columns
select * 
from student s join studentclub sc on s.studentid = sc.studentid
join club c on sc.clubid = c.clubid

--students who are in clubs, student names and club names
select s.FirstName + ' ' + s.LastName as 'Student', c.ClubName
from student s join studentclub sc on s.studentid = sc.studentid
join club c on sc.clubid = c.clubid

--The "Like" keyword
--used to match patterns in strings
--matched with the "%" character a lot
--% is a wildcard that means “any sequence of characters (including none).”
--"_" is a wildcard that means "any character, but only one"

--return students whose name begins with 'W'
select *
from student
where LastName like 'W%'

select *
from student
where LastName like 'W' --if there is no wildcard character, "like" is the same as "="

--return students whose name begins with 'W' and is four characters long
select *
from student 
where LastName like 'W___'

--return students with the email address '@example.ca'
select *
from student 
where email like '%example.ca'

--lockers with numbers that end in '15' and are 6 characters long
select *
from locker
where LockerNumber like '____15'

--students with 'o' anywhere in their last name
select *
from student
where lastname like '%o%'

--students with 'a' as the second letter of their first name
select *
from student
where FirstName like '_a%'

--STRING FUNCTIONS
--can be used in the "select" or the "where" clauses

--Len() LENGTH
select LastName, len(LastName) as 'Number of characters in last name'
from Student

--all students with names less than 5 characters long
select *
from Student 
where len(LastName) < 5

--Left and Right 
--First letter of every student's first name, along with all of their last name
select left(firstname, 1) as 'First Initial', LastName
from Student

--last 3 characters of locker numbers 
select LockerNumber, right(LockerNumber, 3) as 'Last digits' --GIVE ME 3 CHARACTERS, BEGINNING FROM THE RIGHT SIDE OF THE STRING
from Locker

--substring - returns part of a string, starting at a given point, and going for a given number of characters
--extract characters 2-4 from the locker number
select LockerNumber, substring(LockerNumber, 2, 3)
from Locker

--upper, lower CONVERTS ALL CHARACTERS IN A STRING TO UPPER OR LOWER CASE
select *
from student
where upper(lastName) = 'BROWN'

select *
from student
where lower(lastName) = 'brown'

select upper(FirstName), lower(LastName)
from student

--date functions
--getdate() returns today's date
select getdate()

select left(getdate(), 11) as "Today's date"

--what month are we in? returnst the current month as a number
select month(getdate()) as 'The current month'

select datename(mm, getdate()) as 'The current month'

-- Extract year of birth for each student
select FirstName, LastName, year(DateOfBirth) as 'BirthYear'
from student

--return students born in 2003
select *
from Student
where year(DateOfBirth) = 2003

--return student ages
select firstname, lastname, DATEDIFF(yy, DateOfBirth, getdate()) as 'Age'
from student