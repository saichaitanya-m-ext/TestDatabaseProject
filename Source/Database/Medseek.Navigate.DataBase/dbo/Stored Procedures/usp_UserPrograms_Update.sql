
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserPrograms_Update    
Description   : This procedure is used to update record in UserPrograms table
Created By    : Aditya    
Created Date  : 23-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY         DESCRIPTION    
25-May-2010 NagaBabu   A perameter @dt_DueDate UserDate, is added to this
14-Mar-2011 NagaBabu ProgramExcludeID Field and as well as perameter  
18-Mar-2011 NagaBabu Added NULL to @i_ProgramExcludeID Bydefault
21-Jan-2014 Mohan Changed PatientProgam name to  PatientProgram 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UserPrograms_Update] (
	@i_AppUserId KeyID
	,@i_UserId KeyID
	,@i_ProgramId KeyID
	--,@dt_DueDate UserDate
	,@dt_EnrollmentStartDate UserDate
	/*
	,@dt_EnrollmentEndDate UserDate
	,@i_IsPatientDeclinedEnrollment IsIndicator
	,@dt_DeclinedDate DATETIME
	,@vc_StatusCode StatusCode
	,@i_UserProgramId KeyId
	,@i_ProgramExcludeID KeyID = NULL
	*/
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsUpdated INT

	-- Check if valid Application User ID is passed    
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	UPDATE PatientProgram
	SET 
		 EnrollmentEndDate = GETDATE()
		,IsPatientDeclinedEnrollment = 1
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
	WHERE 
		ProgramId = @i_ProgramId
		AND PatientID = @i_UserId
		AND CONVERT(DATE,EnrollmentStartDate) = @dt_EnrollmentStartDate
		AND  EnrollmentEndDate IS NULL
		
	SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
	
	IF @l_numberOfRecordsUpdated >= 1
	BEGIN
	UPDATE ProgramPatientTaskConflict
	SET StatusCode = 'I'
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
	FROM ProgramTaskBundle
	WHERE ProgramTaskBundle.ProgramTaskBundleID = ProgramPatientTaskConflict.ProgramTaskBundleId
		AND ProgramTaskBundle.ProgramID = @i_ProgramId
		AND ProgramPatientTaskConflict.PatientUserID = @i_UserId
		
	
	UPDATE
        PatientQuestionaire
    SET
        StatusCode = 'I'
       ,LastModifiedDate = GETDATE()
       ,LastModifiedByUserId = @i_AppUserId
    WHERE PatientQuestionaire.ProgramID = @i_ProgramId
    AND PatientQuestionaire.PatientId = @i_UserId
    AND PatientQuestionaire.StatusCode = 'A'    
       
    	
	UPDATE
        PatientProcedureGroupTask
    SET
        StatusCode = 'I'
       ,LastModifiedDate = GETDATE()
       ,LastModifiedByUserId = @i_AppUserId
    WHERE PatientProcedureGroupTask.PatientID = @i_UserId
    AND PatientProcedureGroupTask.ManagedPopulationID = @i_ProgramId
    AND PatientProcedureGroupTask.StatusCode = 'A'
    
    
     UPDATE
        PatientOtherTask
	 SET
        StatusCode = 'I'
       ,LastModifiedDate = GETDATE()
       ,LastModifiedByUserId = @i_AppUserId   
       WHERE PatientOtherTask.PatientID = @i_UserId
    AND PatientOtherTask.ProgramId = @i_ProgramId
    AND PatientOtherTask.StatusCode = 'A' 	
		
	UPDATE PatientEducationMaterial
	SET
	   
	    StatusCode = 'I',
	    LastModifiedByUserId = @i_AppUserId,
	    LastModifiedDate = GETDATE()
	 WHERE    PatientID = @i_UserId
	 AND ProgramID = @i_ProgramId
	 AND StatusCode = 'A' 
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
    ON OBJECT::[dbo].[usp_UserPrograms_Update] TO [FE_rohit.r-ext]
    AS [dbo];

