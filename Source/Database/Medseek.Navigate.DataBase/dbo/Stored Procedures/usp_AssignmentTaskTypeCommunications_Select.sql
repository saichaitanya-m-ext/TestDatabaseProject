
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_AssignmentTaskTypeCommunications_Select]   23,470 
Description   : This procedure is used to get the records from the ProgramTaskTypeCommunication  
				table  
Created By    : Mohan    
Created Date  : 18-Oct-2012    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
29-Oct-2012 NagaBabu Replaced INNER JOIN with LEFT JOIN with CommunicationTemplate while it is not a mandatory field 
19-Dec-2012 P.V.P.Mohan modified Communication DataType from NOT NULL to NULL
19-Dec-2012 P.V.P.Mohan modified JOIN Statement in Select Condition
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_AssignmentTaskTypeCommunications_Select] (
	@i_AppUserId KEYID
	,@i_ProgramTaskBundleID KEYID
	)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	
	IF NOT EXISTS (
			SELECT 1
			FROM ProgramTaskTypeCommunication
			WHERE ProgramTaskBundleID = @i_ProgramTaskBundleID
			)
	BEGIN
		INSERT INTO ProgramTaskTypeCommunication (
			ProgramTaskBundleID
			,ProgramID
			,TaskTypeID
			,GeneralizedID
			,CommunicationSequence
			,CommunicationTypeID
			,CommunicationAttemptDays
			,NoOfDaysBeforeTaskClosedIncomplete
			,CommunicationTemplateID
			,StatusCode
			,CreatedByUserId
			,CreatedDate
			,RemainderState
			)
		SELECT DISTINCT ptb.ProgramTaskBundleID
			,ptb.ProgramID
			,ttc.TaskTypeID
			,ptb.GeneralizedID
			,ttc.CommunicationSequence
			,ttc.CommunicationTypeID
			,ttc.CommunicationAttemptDays
			,ttc.NoOfDaysBeforeTaskClosedIncomplete
			,ttc.CommunicationTemplateID
			,'A'
			,@i_AppUserId
			,Getdate()
			,ttc.RemainderState
		FROM TaskTypeCommunications ttc WITH (NOLOCK)
		INNER JOIN ProgramTaskBundle ptb WITH (NOLOCK) ON ttc.TaskTypeID = CASE 
				WHEN ptb.TaskType = 'O'
					THEN (
							SELECT TaskTypeID
							FROM TaskType
							WHERE TaskTypeName = 'Other Tasks'
							)
				WHEN ptb.TaskType = 'P'
					THEN (
							SELECT TaskTypeID
							FROM TaskType
							WHERE TaskTypeName = 'Schedule Procedure'
							)
				WHEN ptb.TaskType = 'Q'
					THEN (
							SELECT TaskTypeID
							FROM TaskType
							WHERE TaskTypeName = 'Questionnaire'
							)
				WHEN ptb.TaskType = 'E'
					THEN (
							SELECT TaskTypeID
							FROM TaskType
							WHERE TaskTypeName = 'Patient Education Material'
							)
				END
		WHERE ptb.ProgramTaskBundleID = @i_ProgramTaskBundleID
			AND ttc.TaskTypeGeneralizedID IS NOT NULL
			AND ttc.TaskTypeGeneralizedID = ptb.GeneralizedID
			AND ttc.StatusCode = 'A'
			AND NOT EXISTS (
				SELECT 1
				FROM ProgramTaskTypeCommunication ptc
				WHERE ptc.ProgramID = ptb.ProgramID
					AND ptc.GeneralizedID = ptb.GeneralizedID
					AND ptc.TaskTypeID = ttc.TaskTypeID
				)
		ORDER BY ttc.CommunicationSequence
	END
	
	SELECT DISTINCT ProgramTaskTypeCommunication.ProgramTaskTypeCommunicationID
		,ProgramTaskTypeCommunication.ProgramTaskBundleID
		,ProgramTaskTypeCommunication.GeneralizedID
		,CommunicationSequence
		,CommunicationType.CommunicationTypeID
		,CommunicationType.CommunicationType
		,CommunicationAttemptDays
		,NoOfDaysBeforeTaskClosedIncomplete
		,CommunicationTemplate.CommunicationTemplateID
		,CommunicationTemplate.TemplateName
		,CASE ProgramTaskTypeCommunication.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS StatusDescription
		,ProgramTaskTypeCommunication.RemainderState
		,CASE 
			WHEN ProgramTaskTypeCommunication.RemainderState = 'B'
				THEN ProgramTaskTypeCommunication.CommunicationAttemptDays
			END DaysBeforeDueDate
		,CASE 
			WHEN ProgramTaskTypeCommunication.RemainderState = 'A'
				THEN ProgramTaskTypeCommunication.CommunicationAttemptDays
			END DaysAfterDueDate
		,ProgramTaskTypeCommunication.StatusCode
		,ProgramTaskTypeCommunication.LastModifiedDate
	FROM ProgramTaskTypeCommunication WITH (NOLOCK)
	LEFT JOIN CommunicationType WITH (NOLOCK)
		ON CommunicationType.CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeID
	LEFT JOIN CommunicationTemplate WITH (NOLOCK)
		ON CommunicationTemplate.CommunicationTemplateId = ProgramTaskTypeCommunication.CommunicationTemplateID
	WHERE (
			ProgramTaskTypeCommunication.ProgramTaskBundleID = @i_ProgramTaskBundleID
			OR @i_ProgramTaskBundleID IS NULL
			)
		AND ProgramTaskTypeCommunication.StatusCode = 'A'
	ORDER BY CommunicationSequence
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
    ON OBJECT::[dbo].[usp_AssignmentTaskTypeCommunications_Select] TO [FE_rohit.r-ext]
    AS [dbo];

