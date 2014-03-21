/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserPhoneCallLog_Insert    
Description   : This procedure is used to insert record into UserPhoneCallLog table
Created By    : Aditya    
Created Date  : 05-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
03-feb-2012 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  UserPhoneCallLog table  
20-Mar-2013 P.V.P.Mohan modified UserPhoneCallLog to PatientPhoneCallLog
			and modified columns.
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserPhoneCallLog_Insert]  
(  
	@i_AppUserId KEYID,  
	@i_UserId KeyID,
	@dt_CallDate UserDate,
	@v_StatusCode StatusCode,
	@vc_Comments VARCHAR(200),
	@i_CareProviderUserId KeyID,
	@d_DueDate DATETIME,
	@o_UserPhoneCallId KeyID OUTPUT,
	@b_IsAdhoc  BIT = 0
)  
AS  
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  

	INSERT INTO PatientPhoneCallLog
	   ( 
			PatientId,
			CallDate,
			StatusCode,
			Comments,
			CareProviderUserId,
			CreatedByUserId,
			DueDate ,
			IsAdhoc
	   )
	VALUES
		(  
			@i_UserId ,
			@dt_CallDate ,
			@v_StatusCode ,
			@vc_Comments,
			@i_CareProviderUserId,
			@i_AppUserId,
			@d_DueDate ,
			@b_IsAdhoc
		)
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
		   @o_UserPhoneCallId = SCOPE_IDENTITY()
        
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert UserPhoneCallLog Table'      
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
    ON OBJECT::[dbo].[usp_UserPhoneCallLog_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

