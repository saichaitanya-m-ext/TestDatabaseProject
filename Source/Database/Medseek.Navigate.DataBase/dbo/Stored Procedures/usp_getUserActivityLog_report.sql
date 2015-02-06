
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_getUserActivityLog_report] null,null 
Description   : This procedure is used to get UserActivityLog Records
Created By    : Chaitanya
Created Date  : 01-Oct-2013  
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_getUserActivityLog_report] (
	 @v_LoginName VARCHAR(100)=null
	,@dt_ActivityDate datetime =null	
	)
AS
BEGIN TRY
  if(@v_LoginName is not null)
    BEGIN
       SELECT '' AS SNO,
            ''  LoginTime,
            U.UserLoginName AS LoginName,
            UA.PageName as PageName,
            UA.ControlType AS ControlName,
            UA.ActivityType AS EventName,
            UA.DateTime as EventTime 
            FROM UserActivityLog UA             
            INNER JOIN UserGroup UG ON UA.UserID=UG.ProviderID  
            INNER JOIN Users U ON U.UserId=Ug.UserId  
            WHERE u.UserLoginName=@v_LoginName
            order by   EventTime,UserLoginName DESC
    END
  ELSE IF(@dt_ActivityDate is not null)
    BEGIN
    SELECT '' AS SNO,U.UserLoginName AS LoginName,
            (SELECT LastLoginDate from aspnet_Membership where UserID in(SELECT UserId FROM aspnet_Users WHERE UserName=@v_LoginName)) AS LoginTime,
            UA.PageName AS PageName,
            UA.ControlType AS ControlName,
            UA.ActivityType AS EventName,
            UA.DateTime AS EventTime FROM UserActivityLog UA join Users U ON U.UserId=UA.UserId WHERE UA.DateTime= @dt_ActivityDate 
    END
  ELSE IF(@v_LoginName is null and @dt_ActivityDate is null) 
    BEGIN
        SELECT '' AS SNO,
            ''  LoginTime,
            U.UserLoginName AS LoginName,UA.PageName as PageName,
            UA.ControlType AS ControlName,
            UA.ActivityType AS EventName,
            UA.DateTime as EventTime 
            FROM UserActivityLog UA             
            INNER JOIN UserGroup UG ON UA.UserID=UG.ProviderID  
            INNER JOIN Users U ON U.UserId=Ug.UserId           
            order by   EventTime,UserLoginName DESC    
            
    END
    
    SELECT u.UserId,UserLoginName FROM Users U

    INNER JOIN UserGroup UG ON ug.UserID=U.userid
    
END TRY

---------------------------------------------------------------------------------------------------------------------     
BEGIN CATCH

		SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage

END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_getUserActivityLog_report] TO [FE_rohit.r-ext]
    AS [dbo];

