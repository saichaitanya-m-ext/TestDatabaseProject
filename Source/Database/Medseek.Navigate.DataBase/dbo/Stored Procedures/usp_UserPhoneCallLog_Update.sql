/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserPhoneCallLog_Update    
Description   : This procedure is used to update record in UserPhoneCallLog table
Created By    : Aditya    
Created Date  : 05-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserPhoneCallLog_Update]  
(  
	@i_AppUserId KEYID,  
	@i_UserId KeyID,
	@dt_CallDate UserDate,
	@v_StatusCode StatusCode,
	@vc_Comments VARCHAR(200),
	@i_CareProviderUserId KeyID,
	@i_UserPhoneCallId KeyID,
	@d_DueDate DATETIME
) 
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
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

	 UPDATE PatientPhoneCallLog
	    SET	PatientId = @i_UserId,
			CallDate = @dt_CallDate,
			Comments = @vc_Comments,
			CareProviderUserId = @i_CareProviderUserId ,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @v_StatusCode,
			DueDate = @d_DueDate
	  WHERE PatientPhoneCallId = @i_UserPhoneCallId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update UserPhoneCallLog Details'  
				,17  
				,1 
				,@l_numberOfRecordsUpdated            
			)          
		END  
		
    RETURN 0 
  
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserPhoneCallLog_Update] TO [FE_rohit.r-ext]
    AS [dbo];

