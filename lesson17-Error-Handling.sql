/************ REVIEW ************/
INSERT INTO Club (ClubName, Room)
VALUES ('Karaoke', 'W309');

--this puts a null value in the MeetingDay column
INSERT INTO Club (ClubName, Room)
VALUES ('Karate', 'W322');

/*
 * INSERT INTO dbo.Assessment (EnrollmentID, Title, Category, PointsPossible, PointsEarned, DueDate) VALUES
 (1,  'Quiz 1',     'Quiz',    10.00,  9.00, '2025-09-15'),
 */

select * from Assessment 
where EnrollmentID = 1 and AssessmentID = 1

Update Assessment
set PointsEarned = 9.50
where EnrollmentID = 1 and AssessmentID = 1

delete from Assessment 
where EnrollmentID = 1 and AssessmentID = 1

/************ DML in a stored procedure ************/
--in other words, insert/update/delete in a stored procedure
go
create or alter procedure DeleteStudent @StudentID int 
as
	begin
		delete from Phone
		where StudentId = @StudentID;
		
		if @@error <> 0 --if @@error is not zero, there was an error
			begin
				raiserror('Delete Phone failed.', 16, 1)
			end
		else --there was no error deleting from Phone
			begin
                delete from Locker 
                where StudentID = @StudentID 

                if @@error <> 0
                   begin
						raiserror('Delete Locker failed.', 16, 1)
					end
				else --there was no error deleting from Locker
                    begin
                        delete from StudentClub
                        where StudentId = @StudentID
                        if @@error <> 0
                            begin
                                raiserror('Delete StudentClub failed.', 16, 1)
                            end
                        else -- no error deleting from StudentClub
                           begin
                                delete from Enrollment
                                where StudentId = @StudentID
                                
                                if @@error <> 0
                                    begin
                                        raiserror('Delete Student failed on Enrollment.', 16, 1)
                                    end
                                else --no error on Enrollment
                                    begin
                                        delete from Student
                                        where StudentId = @StudentID
                                        
                                        if @@error <> 0
                                            begin
                                                raiserror('Delete Student failed.', 16, 1)
                                            end
                                        else
                                            begin
                                                select 'Delete Student was successful'
                                            end	
                                    end
                            end
                    end
			end
	end
exec DeleteStudent 3

select * from Phone where StudentID = 2 
go



create or alter procedure InsertClub
    @ClubName NVARCHAR(100),
    @Room NVARCHAR(20),
    @MeetingDay NVARCHAR(15)
as
    BEGIN
        insert into Club (ClubName, Room, MeetingDay)
        values (@ClubName, @Room, @MeetingDay)

        if @@error <> 0
            BEGIN
                RAISERROR('Insert failed - please check club details.', 16, 1)
            END
        ELSE --insert succeeded
            BEGIN
                select 'Insert successful! Club ID is ' + CAST(@@IDENTITY as nvarchar(10));
            END
    END
go

exec InsertClub 'Nintendo', 'W309A', 'Tuesday'


select * from Club









