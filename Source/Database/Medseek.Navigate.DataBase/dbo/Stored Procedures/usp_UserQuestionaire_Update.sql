/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserQuestionaire_Update      
Description   : This procedure is used to update record in UserQuestionaire table  
Created By    : Aditya      
Created Date  : 26-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION
09-Jun-2011 Rathnam added @i_DiseaseId  , @b_IsPreventive parameters
03-Oct-2011 Rathnam added TotalScore to the update statement
09-Nov-2011 NagaBabu Added @i_ProgramId as input parameter
03-APR-2013 Mohan Commented  DiseaseId column.   
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserQuestionaire_Update]    
(    
 @i_AppUserId KeyID,    
 @i_UserId KeyID,  
 @i_QuestionaireId KeyID,  
 @dt_DateTaken UserDate = NULL,  
 @dt_DateDue UserDate = NULL,  
 @dt_DateAssigned UserDate = NULL,  
 @vc_Comments VARCHAR(4000) = NULL,  
 @i_UserQuestionaireId KeyID,
 @i_DiseaseId KeyID = NULL,
 @b_IsPreventive IsIndicator = 0,
 @i_ProgramId KeyID = NULL,
 @i_AssignedCareProviderId keyid = NULL 
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
	  
	  UPDATE PatientQuestionaire  
		 SET QuestionaireId = @i_QuestionaireId,
			 PatientId = @i_UserId,
			 DateTaken = @dt_DateTaken ,
			 DateDue = ISNULL( @dt_DateDue, DateDue),
			 DateAssigned = ISNULL( @dt_DateAssigned, DateAssigned),
			 Comments = ISNULL( @vc_Comments , Comments),
			 LastModifiedByUserId = @i_AppUserId,
			 LastModifiedDate = GETDATE(),
			 --DiseaseId = @i_DiseaseId ,
	         IsPreventive  = @b_IsPreventive,
	         TotalScore = (SELECT dbo.GetMaxScoreByUserQuestionaireID (@i_userquestionaireid)), 
	         ProgramId = @i_ProgramId ,
	         AssignedCareProviderId=@i_AssignedCareProviderId
	   WHERE PatientQuestionaireId = @i_userquestionaireid  
	  
		SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
	        
	 IF @l_numberOfRecordsUpdated <> 1  
	  BEGIN        
		   RAISERROR    
		   (  N'Invalid Row count %d passed to update UserQuestionaire Details'    
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
    ON OBJECT::[dbo].[usp_UserQuestionaire_Update] TO [FE_rohit.r-ext]
    AS [dbo];

