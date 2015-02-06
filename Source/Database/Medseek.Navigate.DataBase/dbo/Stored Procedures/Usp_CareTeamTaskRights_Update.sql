/*
-----------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_CareTeamTaskRights_Update]
Description	  : This procedure is used to update the records in CareTeamTaskRights table
Created By    :	Aditya
Created Date  : 22-Apr-2010
------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
17-Sep-10 Pramod Corrected the recordcount condition for raise error
16-Oct-10 Pramod modified to remove tasktypeid from update as it is not going to be used
------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[Usp_CareTeamTaskRights_Update]
(
	@i_AppUserId KEYID ,
	@i_UserId KEYID ,
	@i_TaskTypeId KEYID = NULL,
	@i_CareTeamId KEYID ,
	@vc_StatusCode StatusCode,
	@i_CareTeamTaskRightsId KEYID 
)

AS
BEGIN TRY 

	SET NOCOUNT ON	
	-- Check if valid Application User ID is passed
	DECLARE @i_numberOfRecordsUpdated INT
	IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR
		(	 N'Invalid Application User ID %d passed.'
			,17
			,1
			,@i_AppUserId
		)
	END
------------    Updation operation takes place   --------------------------
			
	UPDATE CareTeamTaskRights
	   SET  ProviderID = @i_UserId
		  --,TaskTypeId = @i_TaskTypeId
		  ,CareTeamId = @i_CareTeamId
		  ,LastModifiedByUserId = @i_AppUserId
		  ,LastModifiedDate	= GETDATE()
		  ,StatusCode = @vc_StatusCode  
	 WHERE 
		CareTeamTaskRightsId = @i_CareTeamTaskRightsId
		  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <> 1  
		RAISERROR
		(	 N'Update of CareTeamTaskRights table experienced invalid row count of %d'
			,17
			,1
			,@i_numberOfRecordsUpdated         
	    )        
			
	RETURN 0
	
END TRY 
------------ Exception Handling --------------------------------
BEGIN CATCH
    DECLARE @i_ReturnedErrorID	INT
    
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
				@i_UserId = @i_AppUserId
                        
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Usp_CareTeamTaskRights_Update] TO [FE_rohit.r-ext]
    AS [dbo];

