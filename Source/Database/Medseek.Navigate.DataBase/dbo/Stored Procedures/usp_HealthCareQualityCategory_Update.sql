/*
-----------------------------------------------------------------------------------------------
Procedure Name: [dbo].[Usp_HealthCareQualityCategory_Update]
Description	  : This procedure is used to update the data into HealthCareQualityCategory
Created By    :	NagaBabu
Created Date  : 11-Oct-2010
------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityCategory_Update]
(
   @i_AppUserId KeyID ,
   @vc_HealthCareQualityCategoryName ShortDescription ,
   @i_HealthCareQualityCategoryID KeyID
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
			
	UPDATE HealthCareQualityCategory
	   SET HealthCareQualityCategoryName = @vc_HealthCareQualityCategoryName
	 WHERE
		   HealthCareQualityCategoryID = @i_HealthCareQualityCategoryID
		  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <> 1 
		RAISERROR
		(	 N'Update of HealthCareQualityCategory table experienced invalid row count of %d'
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
    ON OBJECT::[dbo].[usp_HealthCareQualityCategory_Update] TO [FE_rohit.r-ext]
    AS [dbo];

