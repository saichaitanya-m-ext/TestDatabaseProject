/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserDiagnosisCodes_Insert    
Description   : This procedure is used to insert record into UserDiagnosisCodes table
Created By    : Rama   
Created Date  : 19-Jan-2011   
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
12-07-2014   Sivakrishna Added @i_DataSourceId parameter and added DataSourceId column
			 the insert and update statements.
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserDiagnosisCodes_Insert]  
(  
	@i_AppUserId KEYID,
	@i_UserId KEYID,
	@i_DiagnosisID KEYID, 
	@d_DateDiagnosed USERDATE,
	@v_Commments VARCHAR(100),
	@c_StatusCode STATUSCODE,
	@o_UserDiagnosisID KeyID OUTPUT,
	@i_DataSourceId KeyId 
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  

	INSERT INTO PatientDiagnosis
		( 
			PatientID,
			DiagnosisCodeID,
			DateDiagnosed,
			Comments,
			StatusCode,
			CreatedByUserId ,
			DataSourceID
	   )
	VALUES
	   ( 
			@i_UserId,
			@i_DiagnosisID, 
			@d_DateDiagnosed,
			@v_Commments,
			@c_StatusCode,
			@i_AppUserId,
			@i_DataSourceId
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_UserDiagnosisID = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert UserDiagnosisCodes '
				,17      
				,1      
				,@l_numberOfRecordsInserted                 
			)              
	END  

	RETURN 0 
  
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
    ON OBJECT::[dbo].[usp_UserDiagnosisCodes_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

