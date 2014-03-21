
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Assignment_Taskbundle 64
Description   : This procedure is used to get the tasks from the taskbundles  
Created By    : Rathnam  
Created Date  : 01-Oct-2012  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_Taskbundle] (
	@i_AppUserId KEYID
	,@i_ProgramID KEYID = NULL
	,@t_TaskBundleIDList ttypeKeyID READONLY
	,@b_IsScheduleLowestFrequency ISINDICATOR
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
	END;

	WITH cteBundle
	AS (
		SELECT tbqf.TaskBundleId
			,'Q' 'TaskType'
			,QuestionaireName TypeName
			,tbqf.FrequencyNumber
			,tbqf.Frequency
			,q.QuestionaireId TaskTypeGeneralizedID
			,0 AS CopyInclude
		FROM Questionaire q
		INNER JOIN TaskBundleQuestionnaireFrequency tbqf ON tbqf.QuestionaireId = q.QuestionaireId
			AND tbqf.StatusCode = 'A'
			AND QuestionaireName IS NOT NULL
		INNER JOIN @t_TaskBundleIDList tb ON tb.tKeyId = tbqf.TaskBundleId
		
		UNION ALL
		
		SELECT DISTINCT tbci.TaskBundleId
			,'Q' 'Type'
			,QuestionaireName TypeName
			,tbqf.FrequencyNumber
			,tbqf.Frequency
			,q.QuestionaireId GeneralizedID
			,1 AS IsInclude
		FROM Questionaire q
		INNER JOIN TaskBundleQuestionnaireFrequency tbqf ON tbqf.QuestionaireId = q.QuestionaireId
			AND tbqf.StatusCode = 'A'
			AND QuestionaireName IS NOT NULL
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbqf.TaskBundleId
			AND tbci.GeneralizedID = tbqf.QuestionaireId
			AND tbci.CopyInclude = 'I'
		INNER JOIN @t_TaskBundleIDList tb ON tb.tKeyId = tbci.TaskBundleId
		
		UNION ALL
		
		SELECT tbem.TaskBundleId
			,'E' 'Type'
			,em.NAME TypeName
			,NULL FrequencyNumber
			,NULL Frequency
			,em.EducationMaterialID GeneralizedID
			,0 AS IsInclude
		FROM EducationMaterial em
		INNER JOIN TaskBundleEducationMaterial tbem ON tbem.EducationMaterialID = em.EducationMaterialID
			AND tbem.StatusCode = 'A'
			AND em.NAME IS NOT NULL
		INNER JOIN @t_TaskBundleIDList tb ON tb.tKeyId = tbem.TaskBundleId
		
		UNION ALL
		
		SELECT DISTINCT tbci.TaskBundleId
			,'E' 'Type'
			,em.NAME TypeName
			,NULL FrequencyNumber
			,NULL Frequency
			,em.EducationMaterialID GeneralizedID
			,1 AS IsInclude
		FROM EducationMaterial em
		INNER JOIN TaskBundleEducationMaterial tbem ON tbem.EducationMaterialID = em.EducationMaterialID
			AND tbem.StatusCode = 'A'
			AND em.NAME IS NOT NULL
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbem.TaskBundleId
			AND tbci.GeneralizedID = tbem.EducationMaterialID
			AND tbci.CopyInclude = 'I'
		INNER JOIN @t_TaskBundleIDList tb ON tb.tKeyId = tbci.TaskBundleId
		
		UNION ALL
		
		SELECT tbpf.TaskBundleId
			,'P' 'Type'
			,csp.ProcedureName TypeName
			,tbpf.FrequencyNumber
			,tbpf.Frequency
			,csp.ProcedureCodeID GeneralizedID
			,0 AS IsInclude
		FROM CodeSetProcedure csp
		INNER JOIN TaskBundleProcedureFrequency tbpf ON tbpf.CodeGroupingId = csp.ProcedureCodeID
		INNER JOIN @t_TaskBundleIDList tb ON tb.tKeyId = tbpf.TaskBundleId
		WHERE tbpf.FrequencyCondition = 'None'
			AND tbpf.StatusCode = 'A'
			AND FrequencyNumber IS NOT NULL
			AND Frequency IS NOT NULL
			AND csp.ProcedureName IS NOT NULL
		
		UNION ALL
		
		SELECT DISTINCT tbci.TaskBundleId
			,'P' 'Type'
			,csp.ProcedureName TypeName
			,tbpf.FrequencyNumber
			,tbpf.Frequency
			,csp.ProcedureCodeID GeneralizedID
			,1 AS IsInclude
		FROM CodeSetProcedure csp
		INNER JOIN TaskBundleProcedureFrequency tbpf ON tbpf.CodeGroupingId = csp.ProcedureCodeID
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbpf.TaskBundleId
			AND tbci.GeneralizedID = tbpf.CodeGroupingId
			AND tbci.CopyInclude = 'I'
		INNER JOIN @t_TaskBundleIDList tb ON tb.tKeyId = tbci.TaskBundleId
		WHERE tbpf.FrequencyCondition = 'None'
			AND tbpf.StatusCode = 'A'
			AND tbpf.FrequencyNumber IS NOT NULL
			AND tbpf.Frequency IS NOT NULL
			AND csp.ProcedureName IS NOT NULL
		
		UNION ALL
		
		SELECT tbaf.TaskBundleId
			,'O' 'TYPE'
			,at.NAME TypeName
			,tbaf.FrequencyNumber
			,tbaf.Frequency
			,at.AdhocTaskID GeneralizedID
			,0 AS IsInclude
		FROM TaskBundleAdhocFrequency tbaf
		INNER JOIN AdhocTask at ON at.AdhocTaskID = tbaf.AdhocTaskID
		INNER JOIN @t_TaskBundleIDList tb1 ON tb1.tKeyId = tbaf.TaskBundleId
		WHERE tbaf.StatusCode = 'A'
			AND at.NAME IS NOT NULL
		
		UNION ALL
		
		SELECT DISTINCT tbci.TaskBundleId
			,'O' 'TYPE'
			,at.NAME TypeName
			,tbaf.FrequencyNumber
			,tbaf.Frequency
			,at.AdhocTaskID GeneralizedID
			,1 AS IsInclude
		FROM TaskBundleAdhocFrequency tbaf
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbaf.TaskBundleId
			AND tbci.GeneralizedID = tbaf.AdhocTaskID
			AND tbci.CopyInclude = 'I'
		INNER JOIN AdhocTask at ON at.AdhocTaskID = tbaf.AdhocTaskID
		INNER JOIN @t_TaskBundleIDList tb ON tb.tKeyId = tbci.TaskBundleId
		WHERE tbaf.StatusCode = 'A'
			AND at.NAME IS NOT NULL
		)
	SELECT TaskBundle.TaskBundleId
		,TaskBundle.TaskBundleName
		,TaskType
		,TypeName
		,FrequencyNumber
		,Frequency
		,TaskTypeGeneralizedID
		,CopyInclude
		,ROW_NUMBER() OVER (
			PARTITION BY TaskTypeGeneralizedID
			,Tasktype ORDER BY CASE 
					WHEN Frequency = 'D'
						THEN frequencynumber * 1
					WHEN Frequency = 'W'
						THEN frequencynumber * 7
					WHEN Frequency = 'M'
						THEN frequencynumber * 30
					WHEN Frequency = 'Y'
						THEN frequencynumber * 365
					END 
			) FrequencyOrder
		,ROW_NUMBER() OVER (
			ORDER BY TaskBundle.TaskBundleID
			) AS UniqueID
	INTO #cteBundle
	FROM cteBundle
	INNER JOIN TaskBundle ON cteBundle.TaskBundleId = TaskBundle.TaskBundleId

	IF @b_IsScheduleLowestFrequency = 0
	BEGIN
		

		;WITH CTEBundleSort
		AS (
			SELECT 0 ID
				,TaskBundleId
				,TaskBundleName
				,TaskType
				,TypeName
				,FrequencyNumber
				,Frequency
				,TaskTypeGeneralizedID
				,CopyInclude
				,FrequencyOrder
				,UniqueID
				,CASE 
					WHEN Tasktype = 'E'
						THEN ''
					ELSE 'Once Every ' + CONVERT(VARCHAR, #cteBundle.FrequencyNumber) + CASE 
							WHEN #cteBundle.Frequency = 'W'
								THEN ' Week(s)'
							WHEN #cteBundle.Frequency = 'D'
								THEN ' Day(s)'
							WHEN #cteBundle.Frequency = 'M'
								THEN ' Month(s)'
							WHEN #cteBundle.Frequency = 'Y'
								THEN ' Year(s)'
							END
					END FrequencyTitration
				,0 IsConflict
				,NULL TypeID
			FROM #cteBundle
			WHERE NOT EXISTS (
					SELECT 1
					FROM #cteBundle c
					WHERE c.TaskType = #cteBundle.TaskType
						AND c.TaskTypeGeneralizedID = #cteBundle.TaskTypeGeneralizedID
					GROUP BY c.TaskType
						,c.TaskTypeGeneralizedID
					HAVING COUNT(*) > 1
					)
			
			UNION ALL
			
			SELECT 1 ID
				,TaskBundleId
				,TaskBundleName
				,TaskType
				,TypeName
				,FrequencyNumber
				,Frequency
				,TaskTypeGeneralizedID
				,CopyInclude
				,FrequencyOrder
				,UniqueID
				,CASE 
					WHEN Tasktype = 'E'
						THEN ''
					ELSE 'Once Every ' + CONVERT(VARCHAR, #cteBundle.FrequencyNumber) + CASE 
							WHEN #cteBundle.Frequency = 'W'
								THEN ' Week(s)'
							WHEN #cteBundle.Frequency = 'D'
								THEN ' Day(s)'
							WHEN #cteBundle.Frequency = 'M'
								THEN ' Month(s)'
							WHEN #cteBundle.Frequency = 'Y'
								THEN ' Year(s)'
							END
					END FrequencyTitration
				,0 IsConflict
				,NULL TypeID
			FROM #cteBundle
			WHERE EXISTS (
					SELECT 1
					FROM #cteBundle c
					WHERE c.TaskType = #cteBundle.TaskType
						AND c.TaskTypeGeneralizedID = #cteBundle.TaskTypeGeneralizedID
					GROUP BY c.TaskType
						,c.TaskTypeGeneralizedID
					HAVING COUNT(*) > 1
					)
			)
		SELECT *
		FROM CTEBundleSort
		ORDER BY TypeName
	END

	IF @b_IsScheduleLowestFrequency = 1
	BEGIN
		DECLARE @l_TranStarted BIT = 0

		IF (@@TRANCOUNT = 0)
		BEGIN
			BEGIN TRANSACTION

			SET @l_TranStarted = 1 -- Indicator for start of transactions
		END
		ELSE
		BEGIN
			SET @l_TranStarted = 0
		END

		SELECT DISTINCT TypeName
		FROM #cteBundle
		WHERE FrequencyOrder > 1

		UPDATE ProgramTaskBundle
		SET StatusCode = 'A'
			,FrequencyNumber = #cteBundle.FrequencyNumber
			,Frequency = #cteBundle.Frequency
		FROM #cteBundle
		WHERE ProgramTaskBundle.TaskBundleID = #cteBundle.TaskBundleId
			AND ProgramTaskBundle.TaskType = #cteBundle.TaskType
			AND ProgramTaskBundle.GeneralizedID = #cteBundle.TaskTypeGeneralizedID
			AND ProgramTaskBundle.IsInclude = #cteBundle.CopyInclude
			AND ProgramTaskBundle.ProgramID = @i_ProgramID
			AND FrequencyOrder = 1

		UPDATE ProgramTaskBundle
		SET StatusCode = 'I'
		WHERE NOT EXISTS (
				SELECT 1
				FROM #cteBundle
				WHERE ProgramTaskBundle.TaskBundleID = #cteBundle.TaskBundleId
					AND ProgramTaskBundle.TaskType = #cteBundle.TaskType
					AND ProgramTaskBundle.GeneralizedID = #cteBundle.TaskTypeGeneralizedID
					AND ProgramTaskBundle.IsInclude = #cteBundle.CopyInclude
					AND FrequencyOrder = 1
				)
			AND ProgramTaskBundle.ProgramID = @i_ProgramID

		INSERT INTO ProgramTaskBundle (
			ProgramID
			,TaskBundleID
			,TaskType
			,GeneralizedID
			,CreatedByUserId
			,IsInclude
			,FrequencyNumber
			,Frequency
			)
		SELECT @i_ProgramID
			,TaskBundleId
			,TaskType
			,TaskTypeGeneralizedID
			,@i_AppUserId
			,CONVERT(BIT, CopyInclude)
			,FrequencyNumber
			,Frequency
		FROM #cteBundle
		WHERE FrequencyOrder = 1
			AND NOT EXISTS (
				SELECT 1
				FROM ProgramTaskBundle ptb
				WHERE ptb.ProgramID = @i_ProgramID
					AND ptb.TaskBundleID = #cteBundle.TaskBundleId
					AND ptb.TaskType = #cteBundle.TaskType
					AND ptb.GeneralizedID = #cteBundle.TaskTypeGeneralizedID
					AND ptb.IsInclude = #cteBundle.CopyInclude
				)

		INSERT INTO ProgramPatientTaskConflict (
			ProgramTaskBundleId
			,PatientUserID
			,CreatedByUserId
			)
		SELECT DISTINCT ProgramTaskBundle.ProgramTaskBundleID
			,PatientProgram.PatientID
			,@i_AppUserId
		FROM PatientProgram
		INNER JOIN ProgramTaskBundle ON ProgramTaskBundle.ProgramID = PatientProgram.ProgramID
		WHERE PatientProgram.ProgramID = @i_ProgramID
			AND PatientProgram.StatusCode = 'A'
			AND ProgramTaskBundle.StatusCode = 'A'
			AND PatientProgram.PatientID IS NOT NULL
			AND PatientProgram.EnrollmentEndDate IS NULL --> NEWLY ADDED
			AND NOT EXISTS (
				SELECT 1
				FROM ProgramPatientTaskConflict pptc
				WHERE pptc.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
					AND pptc.PatientUserID = PatientProgram.PatientID
				)

		UPDATE ProgramPatientTaskConflict
		SET StatusCode = 'I'
		FROM ProgramTaskBundle
		WHERE ProgramTaskBundle.ProgramTaskBundleID = ProgramPatientTaskConflict.ProgramTaskBundleId
			AND ProgramID = @i_ProgramID
			AND ProgramTaskBundle.StatusCode = 'I'

		
		IF (@l_TranStarted = 1) -- If transactions are there, then commit
		BEGIN
			SET @l_TranStarted = 0

			COMMIT TRANSACTION
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Assignment_Taskbundle] TO [FE_rohit.r-ext]
    AS [dbo];

