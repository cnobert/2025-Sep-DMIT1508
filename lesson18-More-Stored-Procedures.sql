/************ REVIEW ************/
/* 
    Global Variables:
    @@error - will be "not zero" if there was an error in the db system
    @@identity - will contain the id of the most recently inserted record
    @@row - will contain the number of rows that were affected by the most recent action
*/
go
create or alter procedure DeleteStudent 
    @StudentID int 
as
    BEGIN
        if exists (select 1 from Student where StudentID = @StudentID)
            BEGIN
                delete from Phone
                where StudentId = @StudentID;

                delete from Locker 
                where StudentID = @StudentID 

                delete from Enrollment
                where StudentId = @StudentID

                delete from StudentClub
                where StudentId = @StudentID

                delete from Student
                where StudentId = @StudentID

                if @@error <> 0
                    BEGIN
                        raiserror('DeleteStudent failed.', 16, 1)
                    END
                else --since @@error is equal to zero, the deletion was a success
                    BEGIN
                        select 'Delete Student was successful'
                    END
            END
        ELSE --student does not exist
            BEGIN
                raiserror('DeleteStudent failed - StudentID not found.', 16, 1);
            END
    END

exec DeleteStudent 4

select * from Student
go
create or alter procedure InsertClub
    @ClubName NVARCHAR(100),
    @Room NVARCHAR(20),
    @MeetingDay NVARCHAR(15)
as 
BEGIN
    if exists(select 1 from Club where ClubName = @ClubName)
        BEGIN
            RAISERROR('InsertClub failed - club name already exists.', 16, 1)
        END
    ELSE -- @clubname is not in the Club table, proceed
        BEGIN
            insert into Club (ClubName, Room, MeetingDay)
            values (@ClubName, @Room, @MeetingDay)

            if @@error <> 0
                BEGIN
                    RAISERROR('Insert failed - please check club details.', 16, 1)
                END
            ELSE
                BEGIN
                    select 'Insert succeeded! Club ID is ' + cast(@@identity as NVARCHAR(10))
                END
        END
END

select * from Club

exec InsertClub 'Nintendo', 'W309A', 'Friday'

/*
Exercise:
 
Create a stored procedure called DeleteClub to delete by ClubID. 

If the club does not exist, raise an error. 

If any memberships exist in StudentClub, raise an error and do not delete.
*/
go
create or alter PROCEDURE DeleteClub @ClubID int 
AS
BEGIN
    if not exists(select 1 from Club where ClubID = @ClubID)
        BEGIN
            raiserror('DeleteClub failed - ClubID not found.', 16, 1);
        END
    ELSE --the given Club exists
        BEGIN
            if exists(select 1 from StudentClub where ClubID = @ClubID)
                BEGIN
                    raiserror('DeleteClub failed - club has members. Remove memberships first.', 16, 1);
                END
            ELSE -- we're good to delete the club!
                BEGIN
                    delete from Club
                    where ClubID = @ClubId

                    if @@error <> 0
                    begin
                        raiserror('DeleteClub delete failed.', 16, 1);
                    end
                END
        END
END

/*
Exercise:
 
Create a procedure called UpdateClub to update ClubName, Room, and MeetingDay by ClubID.
 
If the ClubID does not exist, raise an error.
 
*/
go
create or alter procedure UpdateClub 
    @ClubId int,
    @ClubName NVARCHAR(100),
    @Room NVARCHAR(20),
    @MeetingDay NVARCHAR(15)
AS
BEGIN
    if not exists(select 1 from Club where ClubID = @ClubID)
        BEGIN
           raiserror('UpdateClub failed - ClubID not found.', 16, 1); 
        END
    ELSE -- we're good to update
        BEGIN
            update Club
            set ClubName = @ClubName, Room = @Room, MeetingDay = @MeetingDay
            where ClubID = @ClubID

            if @@error <> 0
                begin
                    raiserror('UpdateClub update failed.', 16, 1);
                end
        END
END

select * from club

exec UpdateClub 1, 'RoboFun Club', 'D202', 'Monday'