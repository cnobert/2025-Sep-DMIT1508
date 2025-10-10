select * from course
select * from enrollment

--IN CLASS EXERCISES

--return course code and student name of students who are enrolled in a course
select s.FirstName, s.LastName, c.CourseCode 
from Student s join enrollment e on s.StudentID = e.StudentID 
join Course c on e.CourseID = c.CourseID 

--return course code and name of students who are enrolled in a course
--that is in the Game Programming Department
select s.FirstName, s.LastName, c.CourseCode 
from Student s join enrollment e on s.StudentID = e.StudentID 
join Course c on e.CourseID = c.CourseID 
where c.Department = 'Game Programming'

--return the student name, assessment title, and points earned
--for all assessments
--don't show assessments with no points earned
--order by last name and points earned, with highest points earned at the top
select s.FirstName , s.LastName, a.Title , a.PointsEarned 
from Student s join enrollment e on s.StudentID = e.StudentID
join Assessment a on e.EnrollmentID = a.EnrollmentID
where a.PointsEarned is not null
order by s.LastName , a.PointsEarned desc

--show student names and course codes of students 
--who are active in DMIT1508
select s.FirstName, s.LastName, c.CourseCode 
from Student s join enrollment e on s.StudentID = e.StudentID 
join Course c on e.CourseID = c.CourseID
where Status = 'Active' and c.CourseCode = 'DMIT1508'

--return the average final grade
select avg(FinalGradePercent)
from Enrollment

--return the course code and average final grade for each course
select c.CourseCode, avg(e.FinalGradePercent)
from Enrollment e join Course c on e.CourseID = c.CourseID 
where e.FinalGradePercent is not null
group by c.CourseCode 

--UNION
--A UNION stacks rows from compatible 
--SELECT statements into one result. Think “same columns, more rows.”
--the columns from each select MUST MATCH
--union automatically eliminates duplicates

--combine course codes offered in Fall 2025 and Winter 2026
select CourseCode, Term 
from Course
where Term = 'F2025'
union
select CourseCode, Term 
from Course
where Term = 'W2026'

--return the student ids of all students who have lockers or phones
select studentID
from locker 
where studentid is not null
union
select studentid
from phone

--return the student ids of all students who have both lockers and phones
select studentID
from locker 
where studentid is not null
intersect
select studentid
from phone

--return first and last names of all students who have both lockers and phones
select s.Firstname, s.Lastname
from locker l join Student s on l.StudentID = s.StudentID 
intersect
select s.Firstname, s.Lastname
from phone p join Student s on p.StudentID =s.StudentID 

--show studentId, courseId and status for both Active and Completed 
--enrollments.
select StudentID, CourseID, Status 
from Enrollment
where Status = 'Active'
union
select StudentID, CourseID, Status 
from Enrollment
where Status = 'Completed'






