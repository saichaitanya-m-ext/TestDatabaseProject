/*
-----------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_UserDisease_Update]
Description	  : This procedure is used to update the data in User Disease table based on 
				UserID.
Created By    :	Aditya
Created Date  : 05-Apr-2010
------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
27-Sep-2010 NagaBabu modified  @i_numberOfRecordsUpdated > 1 by <> 1 
------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_UserDisease_Update]
(
 @i_AppUserId KeyID,  
 @i_UserID KeyID,
 @i_DiseaseID KeyID,
 @vc_Comments LongDescription,
 @dt_DiagnosedDate UserDate, 
 @vc_StatusCode StatusCode ,
 @i_DataSourceId KeyId
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
			
	UPDATE UserDisease
	   SET Comments = @vc_Comments,
		   StatusCode = @vc_StatusCode,
		   DiagnosedDate = @dt_DiagnosedDate,
		   LastModifiedByUserId = @i_AppUserId,
		   LastModifiedDate	= GETDATE(),
		   DataSourceId = @i_DataSourceId
	 WHERE 
		  UserId = @i_UserId
		  AND DiseaseID = @i_DiseaseID
  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <> 1
		RAISERROR
		(	 N'Update of UserDisease table experienced invalid row count of %d'
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
    RETURN @i_ReturnedErrorID                    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserDisease_Update] TO [FE_rohit.r-ext]
    AS [dbo];

