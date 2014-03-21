/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TaskBundleProcedureFrequency_Update      
Description   : This procedure is used to update mapped procedures & related information for a taskbundle  
Created By    : Rathnam      
Created Date  : 23-Dec-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION    
01-Feb-2012 Rathnam added two column LeadDays & ScheduleDays to the  TaskBundleProcedureFrequency    
07-feb-2012 Sivakrishna Assigned parameter(@i_TaskBundleId) to inner sp
			[usp_TaskBundleCommunicationSchedule_Insert]	
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_TaskBundleProcedureFrequency_Update]    
(    
 @i_AppUserId KEYID,  
 @i_TaskBundleProcedureFrequencyId KEYID,  
 @i_CodeGroupingId KEYID,  
 @vc_StatusCode STATUSCODE,  
 @i_FrequencyNumber KEYID = NULL,  
 @vc_Frequency VARCHAR(1) = NULL,
 @b_NeverSchedule BIT,
 @vc_ExclusionReason ShortDescription,
 @b_IsPreventive IsIndicator = NULL ,
 @v_FrequencyCondition SourceName ,
 @vc_RecurrenceType CHAR,
 @i_TaskBundleProcedureConditionalFrequencyID INT = NULL
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
	  
	  UPDATE TaskBundleProcedureFrequency  
		 SET CodeGroupingId = @i_CodeGroupingId,
		     FrequencyNumber = @i_FrequencyNumber ,
			 Frequency = @vc_Frequency,  
			 StatusCode = @vc_StatusCode,  
			 LastModifiedByUserId = @i_AppUserId,  
			 LastModifiedDate = GETDATE(),
			 NeverSchedule =  @b_NeverSchedule,
			 ExclusionReason = @vc_ExclusionReason,
             IsPreventive = @b_IsPreventive ,
             FrequencyCondition = @v_FrequencyCondition,
             IsSelfTask = 1,
             RecurrenceType = @vc_RecurrenceType
	   WHERE TaskBundleProcedureFrequencyID = @i_TaskBundleProcedureFrequencyId  
	   
	   IF @i_TaskBundleProcedureConditionalFrequencyID IS NOT NULL
	   BEGIN
	   DELETE FROM TaskBundleProcedureConditionalFrequency WHERE TaskBundleProcedureConditionalFrequencyID  = @i_TaskBundleProcedureConditionalFrequencyID
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
    ON OBJECT::[dbo].[usp_TaskBundleProcedureFrequency_Update] TO [FE_rohit.r-ext]
    AS [dbo];

