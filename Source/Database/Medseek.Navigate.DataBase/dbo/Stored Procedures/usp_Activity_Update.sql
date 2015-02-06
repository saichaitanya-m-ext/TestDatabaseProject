/*
-----------------------------------------------------------------------------------------------
Procedure Name: [dbo].[Usp_Activity_Update]
Description	  : This procedure is used to update the data from Library based on the ActivityId 
Created By    :	Pramod
Created Date  : 22-Mar-2010
------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
17-Sep-10 Pramod Corrected issue with @i_numberOfRecordsUpdated > 1 
23-Feb-11 Rathnam changed the length of @vc_Description from 500 to 1500
------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Activity_Update]
(
	 @i_AppUserId        KeyID
	,@i_ActivityId       KeyID
	,@i_ParentActivityId KeyID
	,@vc_Name			 ShortDescription 
	,@vc_Description	 VARCHAR(1500)      
	,@vc_StatusCode 	 StatusCode
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
			
	UPDATE Activity
	   SET Name = @vc_Name
		  ,Description = @vc_Description
		  ,ParentActivityId = @i_ParentActivityId
		  ,LastModifiedByUserId = @i_AppUserId
		  ,LastModifiedDate	= GETDATE()
		  ,StatusCode = @vc_StatusCode  
	 WHERE 
		ActivityId = @i_ActivityId
		  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <> 1 
		RAISERROR
		(	 N'Update of Activity table experienced invalid row count of %d'
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
    ON OBJECT::[dbo].[usp_Activity_Update] TO [FE_rohit.r-ext]
    AS [dbo];

