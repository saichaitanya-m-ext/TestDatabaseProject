/*
-----------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_UserAllergies_Update]
Description	  : This procedure is used to update the record in UserAllergies table based on 
				the UserAllergiesID 
Created By    :	Aditya
Created Date  : 23-Mar-2010
------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
27-Sep-2010 NagaBabu modified  @i_numberOfRecordsUpdated > 0 by <> 1  
12-07-2014   Sivakrishna Added @i_DataSourceId parameter and added DataSourceId column to Existing Update statement.
05-Sep-2012  P.V.P.Moahn Added @i_AllergiesID parameter and added AllergiesID Column to Existing Update Statement 
19-Mar-2013 P.V.P.Moahn Modified  UserID to PatientID parameter and Modified table userAllergies to PatientAllergies    
------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_UserAllergies_Update]
(
		@i_AppUserId KeyID,    
		@i_UserID KeyID,
		@i_AllergiesID KeyID,
		@vc_Reaction ShortDescription,
		@vc_Severity Unit,
		@vc_Comments LongDescription,
		@vc_StatusCode StatusCode,
		@dt_UserAllergiesDate DATE,
		@i_UserAllergiesID KeyID ,
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
------------ Updation operation takes place here --------------------------
			
	UPDATE PatientAllergies
	   SET  PatientID = @i_UserID,
			AllergiesID = @i_AllergiesID,
			Reaction = @vc_Reaction,
			Severity = @vc_Severity,
			Comments = @vc_Comments,
			StatusCode = @vc_StatusCode,
			UserAllergiesDate = @dt_UserAllergiesDate,
			LastModifiedByUserId = @i_AppUserId, 
			LastModifiedDate = GETDATE(),
			DataSourceID = @i_DataSourceId
	 WHERE 
		PatientAllergiesID = @i_UserAllergiesID
		  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <> 1  
		RAISERROR
		(	 N'Update of UserAllergies table experienced invalid row count of %d'
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
    ON OBJECT::[dbo].[usp_UserAllergies_Update] TO [FE_rohit.r-ext]
    AS [dbo];

