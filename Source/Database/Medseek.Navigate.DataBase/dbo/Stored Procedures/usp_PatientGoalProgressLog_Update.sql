/*    
------------------------------------------------------------------------------    
Procedure Name: usp_PatientGoalProgressLog_Update    
Description   : This procedure is used to update record in PatientGoalProgressLog table
Created By    : Aditya    
Created Date  : 30-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PatientGoalProgressLog_Update]  
(  
	@i_AppUserId  KeyID,
	@i_PatientGoalProgressLogId	KeyID,
	@i_PatientGoalId KeyID,
	@i_PatientActivityId KeyID,
	@i_ProgressPercentage smallint,
	@dt_FollowUpDate UserDate = NULL,
	@dt_FollowUpCompleteDate UserDate,
	@dt_AttemptedContactDate UserDate ,
	@dt_ActivityCompletedDate UserDate,
	@vc_Comments LongDescription,
	@vc_StatusCode StatusCode
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

	 UPDATE PatientGoalProgressLog
	    SET	PatientGoalId = @i_PatientGoalId,
			PatientActivityId = @i_PatientActivityId, 
			ProgressPercentage = @i_ProgressPercentage,
			FollowUpDate = @dt_FollowUpDate, 
			FollowUpCompleteDate = @dt_FollowUpCompleteDate, 
			Comments = @vc_Comments,
			AttemptedContactDate = @dt_AttemptedContactDate,
			ActivityCompletedDate = @dt_ActivityCompletedDate, 
			StatusCode = @vc_StatusCode,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE()
	  WHERE PatientGoalProgressLogId = @i_PatientGoalProgressLogId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update PatientGoalProgressLog'  
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
    ON OBJECT::[dbo].[usp_PatientGoalProgressLog_Update] TO [FE_rohit.r-ext]
    AS [dbo];

