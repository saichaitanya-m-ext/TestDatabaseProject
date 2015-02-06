
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_TaskBundleQuestionnaireFrequency_InsertUpdate  2,3,114,10,'W','A',Null,0,null,null      
Description   : This procedure is used to map the questionnaire to a taskbundle    
Created By    : Rathnam       
Created Date  : 22-Dec-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
18-Jan-2012 NagaBabu Added IF (SELECT COUNT(*) FROM @tblCommunication) >= 1  
21-Jan-2012 NagaBabu Added @i_TaskBundleCommunicationScheduleID as input parameter             
07-feb-2012 Sivakrishna Assigned parameter(@i_TaskBundleId) to inner sp
			[usp_TaskBundleCommunicationSchedule_Insert]	
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_TaskBundleQuestionnaireFrequency_InsertUpdate] (
	@i_AppUserId KEYID
	,@i_TaskBundleID KEYID
	,@i_QuestionaireId KEYID
	,@i_FrequencyNumber INT = NULL
	,@vc_Frequency VARCHAR(1) = NULL
	,@vc_StatusCode STATUSCODE
	,@i_DiseaseID KEYID
	,@b_IsPreventive ISINDICATOR = NULL
	,@i_TaskBundleQuestionnaireFrequencyID KEYID = NULL
	,@vc_RecurrenceType CHAR
	,@o_TaskBundleQuestionnaireFrequencyID KEYID OUTPUT
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT
		,@i_numberOfRecordsUpdated INT

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

	IF @i_TaskBundleQuestionnaireFrequencyID IS NULL
	BEGIN
		INSERT INTO TaskBundleQuestionnaireFrequency (
			TaskBundleId
			,QuestionaireId
			,FrequencyNumber
			,Frequency
			,StatusCode
			,IsPreventive
			,DiseaseID
			,RecurrenceType
			,CreatedByUserId
			,IsSelfTask
			)
		VALUES (
			@i_TaskBundleID
			,@i_QuestionaireId
			,@i_FrequencyNumber
			,@vc_Frequency
			,@vc_StatusCode
			,@b_IsPreventive
			,@i_DiseaseID
			,@vc_RecurrenceType
			,@i_AppUserId
			,1
			)

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
			,@o_TaskBundleQuestionnaireFrequencyID = SCOPE_IDENTITY()

		IF @l_numberOfRecordsInserted <> 1
		BEGIN
			RAISERROR (
					N'Invalid row count %d in insert TaskBundleQuestionnaireFrequency Table'
					,17
					,1
					,@l_numberOfRecordsInserted
					)
		END
	END
	ELSE
	BEGIN
		UPDATE TaskBundleQuestionnaireFrequency
		SET TaskBundleId = @i_TaskBundleID
			,FrequencyNumber = @i_FrequencyNumber
			,Frequency = @vc_Frequency
			,QuestionaireId = @i_QuestionaireId
			,StatusCode = @vc_StatusCode
			,LastModifiedDate = GETDATE()
			,LastModifiedByUserId = @i_AppUserId
			,DiseaseID = @i_DiseaseID
			,IsPreventive = @b_IsPreventive
			,RecurrenceType = @vc_RecurrenceType
			,IsSelfTask = 1
		WHERE TaskBundleQuestionnaireFrequencyID = @i_TaskBundleQuestionnaireFrequencyID

		SET @i_numberOfRecordsUpdated = @@ROWCOUNT

		IF @i_numberOfRecordsUpdated <> 1
		BEGIN
			RAISERROR (
					N'Update of TaskBundleQuestionnaireFrequency table experienced invalid row count of %d'
					,17
					,1
					,@i_numberOfRecordsUpdated
					)
		END
	END
END TRY

--------------------------------------------------------         
BEGIN CATCH
	-- Handle exception        
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

SELECT *
FROM ErrorLog
ORDER BY 1 DESC

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskBundleQuestionnaireFrequency_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

