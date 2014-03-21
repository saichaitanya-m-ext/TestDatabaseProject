/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_TaskType_Select_DD  
Description   : This procedure is used to get the list of all TaskTypes for the Dropdown
Created By    : Aditya
Created Date  : 22-Apr-2010  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
19-Aug-2010 NagaBabu Added ORDER BY to the select statement
23-Sep-10 Pramod Corrected the query to fetch care team specific data and included @i_Careteamid
12-Oct-10 Pramod Modified the SP to replace exists with NOT exists
16-Oct-10 Pramod Included new parameter @b_IsAdmin and moidified according to that
23-Nov-12 Rathnam added ScheduledDays column
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_TaskType_Select_DD]
(
	@i_AppUserId KEYID,
	@i_UserId KEYID = NULL,
	@i_CareTeamId KEYID = NULL,
	@b_IsAdmin BIT = 1
)
AS
BEGIN TRY
    SET NOCOUNT ON   
 -- Check if valid Application User ID is passed  
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
    BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
    END
-------------------------------------------------------- 
	IF @b_isadmin = 1 
	  SELECT
          TaskTypeId,
		  TaskTypeName,
		  ScheduledDays    
      FROM
          TaskType
      WHERE
          StatusCode = 'A'
	  EXCEPT
      SELECT
          TaskTypeId,
		  TaskTypeName,
		  ScheduledDays    
      FROM
          TaskType
      WHERE
          StatusCode = 'A'
	    AND EXISTS
			( SELECT 1 
				FROM CareTeamTaskRights 
			   WHERE CareTeamTaskRights.CareTeamId = @i_CareTeamId 
			     AND CareTeamTaskRights.ProviderID = @i_UserId
			     AND CareTeamTaskRights.TaskTypeId = TaskType.TaskTypeId
			     --AND CareTeamTaskRights.StatusCode = 'A'
			)
		    
	ELSE
      SELECT
          TaskTypeId,
		  TaskTypeName,
		  ScheduledDays    
      FROM
          TaskType
      WHERE
          StatusCode = 'A'
	    AND EXISTS
			( SELECT 1 
				FROM CareTeamTaskRights 
			   WHERE CareTeamTaskRights.CareTeamId = @i_CareTeamId 
			     AND CareTeamTaskRights.ProviderID = @i_AppUserId
			     AND CareTeamTaskRights.TaskTypeId = TaskType.TaskTypeId
			     AND CareTeamTaskRights.StatusCode = 'A'
			)
	  EXCEPT
	        SELECT
          TaskTypeId,
		  TaskTypeName,
		  ScheduledDays    
      FROM
          TaskType
      WHERE
          StatusCode = 'A'
	    AND EXISTS
			( SELECT 1 
				FROM CareTeamTaskRights 
			   WHERE CareTeamTaskRights.CareTeamId = @i_CareTeamId 
			     AND CareTeamTaskRights.ProviderID = @i_UserId
			     AND CareTeamTaskRights.TaskTypeId = TaskType.TaskTypeId
			     --AND CareTeamTaskRights.StatusCode = 'A'
			)

END TRY  
--------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskType_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

