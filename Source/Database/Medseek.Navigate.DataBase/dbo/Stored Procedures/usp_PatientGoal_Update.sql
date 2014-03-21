/*    
------------------------------------------------------------------------------    
Procedure Name: usp_PatientGoal_Update    
Description   : This procedure is used to Update record in PatientGoal table
Created By    : Aditya    
Created Date  : 29-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
28-Feb-2012 NagaBabu Added @i_LifeStyleGoalId,@dt_GoalCompletedDate,@v_GoalStatus     
13-Mar-2012 Gurumoorthy Added Parameters in update statement
02-May-2012 Gurumoorthy added Parameter @i_AssignedCareProviderId in update statement
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PatientGoal_Update]  
(  
 @i_AppUserId KeyId,  
 @i_UserId KeyID,  
 @vc_Description LongDescription = NULL ,  
 @vc_DurationUnits Unit,  
 @i_DurationTimeline smallint,  
 @vc_ContactFrequencyUnits Unit=null,  
 @i_ContactFrequency smallint=NULL,  
 @i_CommunicationTypeId KeyID = NULL,  
 @i_CancellationReason ShortDescription = NULL,  
 @vc_Comments LongDescription,   
 @vc_StatusCode StatusCode,  
 @dt_StartDate UserDate,  
 @i_LifeStyleGoalId KeyID,
 @i_ProgramId KeyID,
 @dt_GoalCompletedDate UserDate = NULL ,
 @V_GoalStatus StatusCode,
 @t_AdhocTaskSchduledAttempts TBLADHOCTASKSCHDULEDATTEMPTS READONLY,
 @i_PatientGoalId KeyID ,
 @b_IsAdhoc IsIndicator = NULL ,
 @i_AssignedCareProviderId KeyID = NULL  
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

	 UPDATE PatientGoal
	    SET	PatientId = @i_UserId, 
			Description = @vc_Description,
			DurationUnits = @vc_DurationUnits,
			DurationTimeline = @i_DurationTimeline,
			ContactFrequencyUnits = @vc_ContactFrequencyUnits, 
			ContactFrequency = @i_ContactFrequency,
			CommunicationTypeId = @i_CommunicationTypeId,
			CancellationReason = @i_CancellationReason,
			Comments = @vc_Comments,
			StatusCode = @vc_StatusCode, 
			StartDate = @dt_StartDate,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			LifeStyleGoalId = @i_LifeStyleGoalId ,
			ProgramId  = @i_ProgramId,
			GoalCompletedDate = @dt_GoalCompletedDate ,
			GoalStatus = @v_GoalStatus ,
			AssignedCareProviderId= @i_AssignedCareProviderId
	  WHERE PatientGoalId = @i_PatientGoalId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update PatientGoal'  
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
    ON OBJECT::[dbo].[usp_PatientGoal_Update] TO [FE_rohit.r-ext]
    AS [dbo];

