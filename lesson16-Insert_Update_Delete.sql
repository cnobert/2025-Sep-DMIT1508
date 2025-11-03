/************ INSERTS ************/
INSERT INTO Club (ClubName, Room)
VALUES ('Karaoke', 'W309');

--this puts a null value in the MeetingDay column
INSERT INTO Club (ClubName, Room)
VALUES ('Karate', 'W322');

--illegal insert into Phone
INSERT INTO dbo.Phone (StudentID, PhoneNumber)
VALUES (12, '780.555.2233');

--illegal insert into Course
INSERT INTO dbo.Course (CourseCode, Title, Department, Credits, Term)
VALUES ('DMIT1100', 'Intro to Nintendo Racing', 'Digital Media', 30, 'F2025');

/************ UPDATE ************/
--an update is actually two things: a delete AND an insert

select *
from Student s 
where s.LastName = 'Lopez'

--this command deletes the old record and inserts a new one
update Student 
set Email = 'maria.lopez007@example.ca'
where StudentID = 1

update Student 
set LastName = 'Bob'

--change the phone number of a student with a given locker
update Student 
set email = 'maria.l@example.ca'
where StudentID in 
(
	select l.StudentID 
	from Locker l 
	where l.LockerNumber = 'M1-101'
);


select * from locker

/************ DELETE ************/
DELETE FROM Club
WHERE ClubName = 'Karate';

DELETE FROM Club
WHERE ClubName = 'Coding Circle';

--we need to delete records in the correct order, so that they cascade properly

delete from Phone 
where StudentID = 2

delete from Locker 
where StudentID = 2

delete from StudentClub 
where StudentID = 2

delete from Enrollment 
where StudentID = 2

delete from Student 
where StudentID = 2


select * from Phone
select * from Student
select * from Club