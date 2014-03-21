
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PatientCarePlan_Select] 1,2       
Description   : This procedure is used for PatientCareplan select
       
Created By    : Rathnam       
Created Date  :         
------------------------------------------------------------------------------        
Log History   :        
DD-MM-YYYY  BY   DESCRIPTION   
8/6/2013:Santosh added 'OnceEvery' string to the result set frequency
09/30/2013	Modified code to check if due date is in future or mast (GS130930)
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PatientCarePlan_Select] (
	@i_AppUserId KeyId
	,@i_PatientId KEYID
	)
AS
BEGIN TRY
	SET NOCOUNT ON
	
	DECLARE @dt_TodayDate DATETIME = GETDATE()

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

	;WITH procCTE
	AS (
		SELECT cg.CodeGroupingID
			,cg.CodeGroupingName
			,'Once Every ' + CONVERT(VARCHAR(10), ptb.FrequencyNumber) + CASE 
				WHEN ptb.Frequency = 'D'
					THEN ' Day(s)'
				WHEN ptb.Frequency = 'M'
					THEN ' Month(s)'
				WHEN ptb.Frequency = 'W'
					THEN ' Week(s)'
				WHEN ptb.Frequency = 'Y'
					THEN ' Year(s)'
				END Frequency
			,CONVERT(DATE, (
					SELECT MIN(EnrollmentStartDate)
					FROM PatientProgram pp WITH (NOLOCK)
					WHERE pp.PatientID = ppt.PatientUserID
						AND pp.ProgramID = ptb.ProgramID
						AND pp.StatusCode = 'A'
					)) EnrollmentStartDate
			,ptb.ProgramID
			,CASE 
				WHEN ptb.Frequency = 'D'
					THEN ptb.FrequencyNumber * 1
				WHEN ptb.Frequency = 'W'
					THEN ptb.FrequencyNumber * 7
				WHEN ptb.Frequency = 'M'
					THEN ptb.FrequencyNumber * 30
				WHEN ptb.Frequency = 'Y'
					THEN ptb.FrequencyNumber * 365
				END FrequencyDays
		FROM ProgramPatientTaskConflict ppt WITH (NOLOCK)
		INNER JOIN ProgramTaskBundle ptb WITH (NOLOCK)
			ON ppt.ProgramTaskBundleId = ptb.ProgramTaskBundleID
		INNER JOIN CodeGrouping cg WITH (NOLOCK)
			ON cg.CodeGroupingID = ptb.GeneralizedID
		WHERE PatientUserID = @i_PatientId
			AND ppt.StatusCode = 'A'
			AND ptb.StatusCode = 'A'
			AND ptb.TaskType = 'P'
		
		UNION
		
		SELECT cg.CodeGroupingID
			,cg.CodeGroupingName
			,'Once Every ' + CONVERT(VARCHAR(10), FrequencyNumber) + CASE 
				WHEN ppgf.Frequency = 'D'
					THEN ' Day(s)'
				WHEN ppgf.Frequency = 'M'
					THEN ' Month(s)'
				WHEN ppgf.Frequency = 'W'
					THEN ' Week(s)'
				WHEN ppgf.Frequency = 'Y'
					THEN ' Year(s)'
				END
			,CONVERT(DATE, EffectiveStartDate) EnrollmentStartDate
			,ManagedPopulationID ProgramID
			,CASE 
				WHEN ppgf.Frequency = 'D'
					THEN ppgf.FrequencyNumber * 1
				WHEN ppgf.Frequency = 'W'
					THEN ppgf.FrequencyNumber * 7
				WHEN ppgf.Frequency = 'M'
					THEN ppgf.FrequencyNumber * 30
				WHEN ppgf.Frequency = 'Y'
					THEN ppgf.FrequencyNumber * 365
				END FrequencyDays
		FROM PatientProcedureGroupFrequency ppgf WITH (NOLOCK)
		INNER JOIN CodeGrouping cg WITH (NOLOCK)
			ON cg.CodeGroupingID = ppgf.CodeGroupingID
		WHERE ppgf.PatientId = @i_PatientId
		)
	SELECT CodeGroupingID
		,CodeGroupingName
		,Frequency
		,EnrollmentStartDate
		,ProgramID
		,CASE 
			WHEN (
					SELECT TOP 1 upc.DueDate
					FROM PatientProcedureGroupTask upc WITH (NOLOCK)
					WHERE upc.CodeGroupingID = ptb.CodeGroupingID
						AND ManagedPopulationID = ptb.ProgramID
						AND upc.PatientID = @i_PatientId
					ORDER BY upc.PatientProcedureGroupTaskID DESC
					) IS NOT NULL
--GS130930
				AND (
					SELECT TOP 1 upc.DueDate
					FROM PatientProcedureGroupTask upc WITH (NOLOCK)
					WHERE upc.CodeGroupingID = ptb.CodeGroupingID
						AND ManagedPopulationID = ptb.ProgramID
						AND upc.PatientID = @i_PatientId
					ORDER BY upc.PatientProcedureGroupTaskID DESC
					) < @dt_TodayDate+30
--GS130930
				THEN DATEADD(DD, FrequencyDays, (
							SELECT TOP 1 upc.DueDate
							FROM PatientProcedureGroupTask upc WITH (NOLOCK)
							WHERE upc.CodeGroupingID = ptb.CodeGroupingID
								AND ManagedPopulationID = ptb.ProgramID
								AND upc.PatientID = @i_PatientId
							ORDER BY upc.PatientProcedureGroupTaskID DESC
							))
			WHEN (
					SELECT DATEDIFF(DD, MAX(DateOfService), @dt_TodayDate)
					FROM PatientProcedureCode ppc
					INNER JOIN PatientProcedureCodeGroup ppcg
						ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
					WHERE ppcg.CodeGroupingID = ptb.CodeGroupingID
						AND ppc.PatientID = @i_PatientId
					) <= FrequencyDays
				THEN DATEADD(DD, FrequencyDays, (
							SELECT MAX(DateOfService)
							FROM PatientProcedureCode ppc
							INNER JOIN PatientProcedureCodeGroup ppcg
								ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
							WHERE ppcg.CodeGroupingID = ptb.CodeGroupingID
								AND ppc.PatientID = @i_PatientId
							))
			ELSE @dt_TodayDate
			END Duedate
	FROM procCTE ptb

	SELECT DISTINCT Program.ProgramId
		,Program.ProgramName
	FROM PatientProgram WITH (NOLOCK)
	INNER JOIN Program WITH (NOLOCK)
		ON PatientProgram.ProgramId = Program.ProgramId
	WHERE PatientID = @i_PatientID;;

	WITH cteQ
	AS (
		SELECT DISTINCT cg.QuestionaireId
			,cg.QuestionaireName
			,'Once Every ' + CONVERT(VARCHAR(10), ptb.FrequencyNumber) + CASE 
				WHEN ptb.Frequency = 'D'
					THEN ' Day(s)'
				WHEN ptb.Frequency = 'M'
					THEN ' Month(s)'
				WHEN ptb.Frequency = 'W'
					THEN ' Week(s)'
				WHEN ptb.Frequency = 'Y'
					THEN ' Year(s)'
				END Frequency
			,LastDate.LastDateTaken
			,LastDate.TotalScore
			,ISNULL((
					SELECT TOP 1 RangeName
					FROM QuestionnaireScoring WITH (NOLOCK)
					WHERE LastDate.TotalScore BETWEEN RangeStartScore
							AND RangeEndScore
						AND QuestionnaireScoring.QuestionaireId = cg.QuestionaireId
					), '') AS 'Range'
			,CASE 
				WHEN ptb.Frequency = 'D'
					THEN ptb.FrequencyNumber * 1
				WHEN ptb.Frequency = 'W'
					THEN ptb.FrequencyNumber * 7
				WHEN ptb.Frequency = 'M'
					THEN ptb.FrequencyNumber * 30
				WHEN ptb.Frequency = 'Y'
					THEN ptb.FrequencyNumber * 365
				END FrequencyDays
			,(
				SELECT MAX(PQ.DateDue) DueDate
				FROM PatientQuestionaire pq
				WHERE pq.PatientId = @i_PatientId
					AND pq.ProgramId = ptb.ProgramID
					AND pq.QuestionaireId = cg.QuestionaireId
				) DueDate
			,(
				SELECT MAX(EnrollmentStartDate)
				FROM PatientProgram pp
				WHERE pp.PatientID = @i_PatientId
					AND pp.ProgramID = ptb.ProgramID
					AND pp.StatusCode = 'A'
				) EnrollmentStartDate
		FROM ProgramPatientTaskConflict ppt WITH (NOLOCK)
		INNER JOIN ProgramTaskBundle ptb WITH (NOLOCK)
			ON ppt.ProgramTaskBundleId = ptb.ProgramTaskBundleID
		INNER JOIN Questionaire cg WITH (NOLOCK)
			ON cg.QuestionaireId = ptb.GeneralizedID
		INNER JOIN PatientProgram pg WITH (NOLOCK)
			ON pg.ProgramID = ptb.ProgramID
		LEFT JOIN (
			SELECT score.QuestionaireId
				,score.LastDateTaken
				,pq.PatientQuestionaireId
				,pq.TotalScore
			FROM PatientQuestionaire pq WITH (NOLOCK)
			INNER JOIN (
				SELECT QuestionaireId
					,MAX(DateTaken) LastDateTaken
					,PatientId
				FROM PatientQuestionaire WITH (NOLOCK)
				WHERE PatientId = @i_PatientId
				GROUP BY PatientId
					,QuestionaireId
				) score
				ON score.LastDateTaken = pq.DateTaken
					AND score.QuestionaireId = pq.QuestionaireId
					AND score.PatientId = pq.PatientId
			) LastDate
			ON LastDate.QuestionaireId = cg.QuestionaireId
		WHERE PatientUserID = @i_PatientId
			AND ppt.StatusCode = 'A'
			AND ptb.StatusCode = 'A'
			AND ptb.TaskType = 'Q'
			AND cg.StatusCode = 'A'
		)
	SELECT QuestionaireId
		,QuestionaireName
		,LastDateTaken DateTaken
		--,DueDate DateDue
		,DATEADD(DD, FrequencyDays, ISNULL(DueDate, EnrollmentStartDate)) DateDue
		,TotalScore + CASE 
			WHEN [Range] = ''
				THEN ''
			ELSE '/' + [Range]
			END 'Score/Range'
		,Frequency
	FROM cteQ

	/*
	;WITH cteQ
	AS (
		SELECT tblUQ.UserQuestionaireId
			,tblUQ.UserId
			,tblUQ.QuestionaireId
			,QuestionaireName
			,DateTaken
			,tblUQ.CreatedDate
			,tblUQ.CreatedByUserId
			,tblUQ.Comments
			,DateDue
			,DateAssigned
			--,Name DiseaseName  
			,tblUQ.IsPreventive
			,ISNULL(CAST(TotalScore AS VARCHAR(10)), '') Score
			,ISNULL((
					SELECT TOP 1 RangeName
					FROM QuestionnaireScoring WITH (NOLOCK)
					WHERE TotalScore BETWEEN RangeStartScore
							AND RangeEndScore
						AND QuestionnaireScoring.QuestionaireId = tblUQ.QuestionaireId
					), '') AS 'Range'
			,tblUQ.ProgramId
			,ProgramName
			,IsMedicationTitration
			,QuestionnaireFrequency.QuestionnaireFrequencyID
			,'Once every ' + CAST(QuestionnaireFrequency.FrequencyNumber AS VARCHAR(10)) + CASE 
				WHEN QuestionnaireFrequency.Frequency = 'D'
					THEN ' days'
				WHEN QuestionnaireFrequency.Frequency = 'W'
					THEN ' weeks'
				WHEN QuestionnaireFrequency.Frequency = 'M'
					THEN ' months'
				WHEN QuestionnaireFrequency.Frequency = 'Y'
					THEN ' years'
				END AS Patientgoal
			--,Task.IsCareGap  
			,0 AS IsCareGap
			,CASE 
				WHEN DateDue < @dt_TodayDate
					THEN 0
				ELSE 1
				END IsEdit
		FROM (
			SELECT PatientQuestionaire.PatientQuestionaireId UserQuestionaireId
				,PatientQuestionaire.PatientId UserId
				,PatientQuestionaire.QuestionaireId
				,Questionaire.QuestionaireName
				,PatientQuestionaire.DateTaken
				,PatientQuestionaire.CreatedDate
				,PatientQuestionaire.CreatedByUserId
				,PatientQuestionaire.Comments
				,PatientQuestionaire.DateDue
				,PatientQuestionaire.DateAssigned
				,PatientQuestionaire.PreviousPatientQuestionaireId
				--,Disease.Name  
				,ISNULL(PatientQuestionaire.IsPreventive, 0) AS IsPreventive
				,PatientQuestionaire.TotalScore
				,Program.ProgramId
				,Program.ProgramName
				,CASE 
					WHEN QuestionaireType.QuestionaireTypeName = 'Medication Titration'
						THEN 'TRUE'
					ELSE 'FALSE'
					END AS IsMedicationTitration
			FROM PatientQuestionaire WITH (NOLOCK)
			INNER JOIN Questionaire WITH (NOLOCK)
				ON Questionaire.QuestionaireId = PatientQuestionaire.QuestionaireId
					AND PatientQuestionaire.StatusCode <> 'I'
					AND Questionaire.StatusCode = 'A'
			LEFT JOIN QuestionaireType QuestionaireType WITH (NOLOCK)
				ON Questionaire.QuestionaireTypeId = QuestionaireType.QuestionaireTypeId
			--LEFT OUTER JOIN Disease WITH(NOLOCK)  
			-- ON PatientQuestionaire.DiseaseId = Disease.DiseaseId  
			LEFT OUTER JOIN Program WITH (NOLOCK)
				ON Program.ProgramId = PatientQuestionaire.ProgramId
			WHERE PatientQuestionaire.PatientId = @i_PatientID
			) tblUQ
		LEFT JOIN QuestionnaireFrequency WITH (NOLOCK)
			ON tblUQ.UserId = QuestionnaireFrequency.PatientId
				AND tblUQ.QuestionaireId = QuestionnaireFrequency.QuestionaireId
		LEFT JOIN Task WITH (NOLOCK)
			ON Task.PatientTaskID = tblUQ.UserQuestionaireId
			AND Task.TypeID = tblUQ.QuestionaireId
		)
	SELECT UserQuestionaireId
		,UserId
		,QuestionaireId
		,QuestionaireName
		,DateTaken
		,CreatedDate
		,CreatedByUserId
		,Comments
		,DateDue
		,DateAssigned
		--,Name DiseaseName  
		,IsPreventive
		,Score + CASE 
			WHEN [Range] = ''
				THEN ''
			ELSE '/' + [Range]
			END 'Score/Range'
		,ProgramId
		,ProgramName
		,IsMedicationTitration
		,QuestionnaireFrequencyID
		,Patientgoal
		--,Task.IsCareGap  
		,IsCareGap
		,IsEdit
	FROM cteQ
	*/
	---------------------------------------------------------------------------------------------------  
	SELECT DISTINCT 0 AS SelectedPatientGoalId
		,PatientGoal.PatientGoalId
		,PatientGoal.PatientId UserId
		,LifeStyleGoal AS Description
		,SUBSTRING(PatientGoal.Description, 0, 50) AS ShortDescription
		,CASE PatientGoal.DurationUnits
			WHEN 'D'
				THEN 'Days'
			WHEN 'W'
				THEN 'Weeks'
			WHEN 'M'
				THEN 'Months'
			WHEN 'Q'
				THEN 'Quarters'
			WHEN 'Y'
				THEN 'Years'
			ELSE ''
			END DurationUnits
		,PatientGoal.DurationTimeline
		,CASE PatientGoal.DurationUnits
			WHEN 'D'
				THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Days'
			WHEN 'W'
				THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Weeks'
			WHEN 'M'
				THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Months'
			WHEN 'Q'
				THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Quarters'
			WHEN 'Y'
				THEN CAST(PatientGoal.DurationTimeline AS VARCHAR) + '' + ' Years'
			ELSE ''
			END Duration
		,CASE PatientGoal.ContactFrequencyUnits
			WHEN 'D'
				THEN 'Days'
			WHEN 'W'
				THEN 'Weeks'
			WHEN 'M'
				THEN 'Months'
			WHEN 'Q'
				THEN 'Quarters'
			WHEN 'Y'
				THEN 'Years'
			ELSE ''
			END ContactFrequencyUnits
		,PatientGoal.ContactFrequency
		,CASE PatientGoal.ContactFrequencyUnits
			WHEN 'D'
				THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Days'
			WHEN 'W'
				THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Weeks'
			WHEN 'M'
				THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Months'
			WHEN 'Q'
				THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Quarters'
			WHEN 'Y'
				THEN CAST(PatientGoal.ContactFrequency AS VARCHAR) + '' + ' Years'
			ELSE ''
			END ContactFrequencyDuration
		--,PatientGoal.CommunicationTypeId  
		--,CommunicationType.CommunicationType AS CommunicationTypeName  
		--,PatientGoal.CancellationReason  
		,PatientGoal.Comments
		,CASE PatientGoal.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			END AS StatusDescription
		,PatientGoal.StartDate
		,PatientGoal.LifeStyleGoalId
		,LifeStyleGoals.LifeStyleGoal
		,PatientGoal.GoalCompletedDate
		,PatientGoal.ProgramId
		,CASE PatientGoal.GoalStatus
			WHEN 'C'
				THEN 'Complete'
			WHEN 'D'
				THEN 'Discontinue'
			WHEN 'I'
				THEN 'In-progress'
			END AS GoalStatus
		,PatientGoal.CreatedByUserId
		,PatientGoal.CreatedDate
		,PatientGoal.LastModifiedByUserId
		,PatientGoal.LastModifiedDate
		,Dbo.ufn_GetUserNameByID(PatientGoal.AssignedCareProviderId) AS AssignedTo
		,(
			SELECT TOP 1 PatientGoalprogresslog.FollowUpDate
			FROM PatientGoalprogresslog WITH (NOLOCK)
			WHERE PatientGoalId = PatientGoal.PatientGoalId
			ORDER BY PatientGoalProgressLogId DESC
			) AS FollowUpDate
		,PatientGoal.ProgramId
	FROM PatientGoal WITH (NOLOCK)
	INNER JOIN LifeStyleGoals WITH (NOLOCK)
		ON LifeStyleGoals.LifeStyleGoalId = PatientGoal.LifeStyleGoalId
	WHERE PatientGoal.PatientId = @i_PatientID
		AND PatientGoal.StatusCode = 'A'
		AND LifeStyleGoals.StatusCode = 'A'
	ORDER BY PatientGoal.StartDate DESC
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
    ON OBJECT::[dbo].[usp_PatientCarePlan_Select] TO [FE_rohit.r-ext]
    AS [dbo];

