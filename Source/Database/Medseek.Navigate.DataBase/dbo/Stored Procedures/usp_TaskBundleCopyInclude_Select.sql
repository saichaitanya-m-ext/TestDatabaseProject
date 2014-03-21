
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_TaskBundleCopyInclude_Select 1,42      
Description   : This procedure is used to get the Taskbundle details of dependencies
    table.        
Created By    : Rathnam      
Created Date  : 21-Sep-2012          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
             
------------------------------------------------------------------------------          
*/---[usp_TaskBundleCopyInclude_Select] 64,103
CREATE PROCEDURE [dbo].[usp_TaskBundleCopyInclude_Select] (
	@i_AppUserId KEYID
	,@i_TaskBundleID KEYID
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

	DECLARE @b_IsEdit BIT

	SELECT @b_IsEdit = IsEdit
	FROM TaskBundle
	WHERE TaskBundleId = @i_TaskBundleID

	CREATE TABLE #Child_Temp (
		Id INT IDENTITY(5000, 1)
		,TaskBundleId INT
		,TaskType VARCHAR(1)
		,TaskTypeID INT
		,NAME VARCHAR(1050)
		,FrequencyNumber INT
		,Frequency VARCHAR(10)
		,STATUS VARCHAR(2)
		,ParentID INT
		,GeneralizedID INT
		,CopyInclude VARCHAR(20)
		)

	INSERT #Child_Temp (
		TaskBundleId
		,TaskType
		,TaskTypeID
		,NAME
		,FrequencyNumber
		,Frequency
		,STATUS
		,ParentID
		,GeneralizedID
		,CopyInclude
		)
	SELECT tbqf.TaskBundleId
		,'Q' 'Type'
		,tbqf.TaskBundleQuestionnaireFrequencyID TypeID
		,'Questionaire - ' + QuestionaireName TypeName
		,tbqf.FrequencyNumber
		,tbqf.Frequency
		,'0' AS 'Status'
		,ISNULL(tbqf.ParentTaskBundleID, tbqf.TaskBundleId)
		,q.QuestionaireId GeneralizedID
		,CASE 
			WHEN (
					tbqf.ParentTaskBundleID = tbqf.TaskBundleId
					OR tbqf.ParentTaskBundleID IS NULL
					)
				THEN ''
			ELSE 'Copy'
			END CopyInclude
	FROM Questionaire q WITH (NOLOCK)
	INNER JOIN TaskBundleQuestionnaireFrequency tbqf WITH (NOLOCK) ON tbqf.QuestionaireId = q.QuestionaireId
		AND tbqf.StatusCode = 'A'
		AND QuestionaireName IS NOT NULL
	WHERE TaskBundleId = @i_TaskBundleID
	
	UNION ALL
	
	SELECT tbci.TaskBundleId
		,'Q' 'Type'
		,tbqf.TaskBundleQuestionnaireFrequencyID TypeID
		,'Questionaire - ' + QuestionaireName TypeName
		,tbqf.FrequencyNumber
		,tbqf.Frequency
		,'0' AS 'Status'
		,tbci.ParentTaskBundleID
		,q.QuestionaireId GeneralizedID
		,'Include' CopyInclude
	FROM Questionaire q WITH (NOLOCK)
	INNER JOIN TaskBundleQuestionnaireFrequency tbqf WITH (NOLOCK) ON tbqf.QuestionaireId = q.QuestionaireId
		AND tbqf.StatusCode = 'A'
		AND QuestionaireName IS NOT NULL
	INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbqf.TaskBundleId
		AND tbci.GeneralizedID = tbqf.QuestionaireId
		AND tbci.CopyInclude = 'I'
	WHERE tbci.TaskBundleId = @i_TaskBundleID
	
	UNION ALL
	
	SELECT tbem.TaskBundleId
		,'E' 'Type'
		,tbem.TaskBundleEducationMaterialId
		,'PEM - ' + em.NAME
		,NULL FrequencyNumber
		,NULL Frequency
		,'1' AS 'Status'
		,ISNULL(tbem.ParentTaskBundleID, tbem.TaskBundleId)
		,em.EducationMaterialID GeneralizedID
		,CASE 
			WHEN (
					tbem.ParentTaskBundleID = tbem.TaskBundleId
					OR tbem.ParentTaskBundleID IS NULL
					)
				THEN ''
			ELSE 'Copy'
			END CopyInclude
	FROM EducationMaterial em WITH (NOLOCK)
	INNER JOIN TaskBundleEducationMaterial tbem WITH (NOLOCK) ON tbem.EducationMaterialID = em.EducationMaterialID
		AND tbem.StatusCode = 'A'
		AND em.NAME IS NOT NULL
	WHERE tbem.TaskBundleId = @i_TaskBundleID
	
	UNION ALL
	
	SELECT tbci.TaskBundleId
		,'E' 'Type'
		,tbem.TaskBundleEducationMaterialId
		,'PEM - ' + em.NAME
		,NULL FrequencyNumber
		,NULL Frequency
		,'1' AS 'Status'
		,tbci.ParentTaskBundleID
		,em.EducationMaterialID GeneralizedID
		,'Include' CopyInclude
	FROM EducationMaterial em WITH (NOLOCK)
	INNER JOIN TaskBundleEducationMaterial tbem WITH (NOLOCK) ON tbem.EducationMaterialID = em.EducationMaterialID
		AND tbem.StatusCode = 'A'
		AND em.NAME IS NOT NULL
	INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbem.TaskBundleId
		AND tbci.GeneralizedID = tbem.EducationMaterialID
		AND tbci.CopyInclude = 'I'
	WHERE tbci.TaskBundleId = @i_TaskBundleID
	
	UNION ALL
	
	SELECT tbpf.TaskBundleId
		,'P' 'Type'
		,tbpf.TaskBundleProcedureFrequencyId
		,'Procedure - ' + csp.CodeGroupingName NAME
		,tbpf.FrequencyNumber
		,tbpf.Frequency
		,'0' AS 'Status'
		,ISNULL(tbpf.ParentTaskBundleID, tbpf.TaskBundleId)
		,csp.CodeGroupingId GeneralizedID
		,CASE 
			WHEN (
					tbpf.ParentTaskBundleID = tbpf.TaskBundleId
					OR tbpf.ParentTaskBundleID IS NULL
					)
				THEN ''
			ELSE 'Copy'
			END CopyInclude
	FROM CodeGrouping csp WITH (NOLOCK)
	INNER JOIN TaskBundleProcedureFrequency tbpf WITH (NOLOCK) ON tbpf.CodeGroupingId = csp.CodeGroupingId
	WHERE tbpf.FrequencyCondition = 'None'
		AND tbpf.StatusCode = 'A'
		AND FrequencyNumber IS NOT NULL
		AND Frequency IS NOT NULL
		AND tbpf.TaskBundleId = @i_TaskBundleID
	
	UNION ALL
	
	SELECT tbci.TaskBundleId
		,'P' 'Type'
		,tbpf.TaskBundleProcedureFrequencyId
		,'Procedure - ' + csp.CodeGroupingName NAME
		,tbpf.FrequencyNumber
		,tbpf.Frequency
		,'0' AS 'Status'
		,tbci.ParentTaskBundleID
		,csp.CodeGroupingId GeneralizedID
		,'Include' CopyInclude
	FROM CodeGrouping csp WITH (NOLOCK)
	INNER JOIN TaskBundleProcedureFrequency tbpf WITH (NOLOCK) ON tbpf.CodeGroupingId = csp.CodeGroupingId
	INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbpf.TaskBundleId
		AND tbci.GeneralizedID = tbpf.CodeGroupingId
		AND tbci.CopyInclude = 'I'
	WHERE tbpf.FrequencyCondition = 'None'
		AND tbpf.StatusCode = 'A'
		AND tbpf.FrequencyNumber IS NOT NULL
		AND tbpf.Frequency IS NOT NULL
		AND tbci.TaskBundleId = @i_TaskBundleID
	
	
		
     UNION ALL
	
	SELECT tb.TaskBundleId
		,'O' 'TYPE'
		,tbaf.TaskBundleAdhocFrequencyID ID
		,'OtherTask - ' + at.NAME
		,tbaf.FrequencyNumber
		,tbaf.Frequency
		,'0' AS 'Status'
		,ISNULL(tbaf.ParentTaskBundleID, tbaf.TaskBundleId)
		,at.AdhocTaskID GeneralizedID
		,CASE 
			WHEN (
					tbaf.ParentTaskBundleID = tbaf.TaskBundleId
					OR tbaf.ParentTaskBundleID IS NULL
					)
				THEN ''
			ELSE 'Copy'
			END CopyInclude
	FROM TaskBundle tb WITH (NOLOCK)
	INNER JOIN TaskBundleAdhocFrequency tbaf WITH (NOLOCK) ON tbaf.TaskBundleId = tb.TaskBundleId
	INNER JOIN AdhocTask at WITH (NOLOCK) ON at.AdhocTaskID = tbaf.AdhocTaskID
	WHERE tb.StatusCode = 'A'
		AND tbaf.StatusCode = 'A'
		AND at.NAME IS NOT NULL
		AND tbaf.TaskBundleId = @i_TaskBundleID
	
	UNION ALL
	
	SELECT tbci.TaskBundleId
		,'O' 'TYPE'
		,tbaf.TaskBundleAdhocFrequencyID ID
		,'OtherTask - ' + at.NAME
		,tbaf.FrequencyNumber
		,tbaf.Frequency
		,'0' AS 'Status'
		,tbci.ParentTaskBundleID AS ParentID
		,at.AdhocTaskID GeneralizedID
		,'Include' CopyInclude
	FROM TaskBundle tb WITH (NOLOCK)
	INNER JOIN TaskBundleAdhocFrequency tbaf WITH (NOLOCK) ON tbaf.TaskBundleId = tb.TaskBundleId
	INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbaf.TaskBundleId
		AND tbci.GeneralizedID = tbaf.AdhocTaskID
		AND tbci.CopyInclude = 'I'
	INNER JOIN AdhocTask at WITH (NOLOCK) ON at.AdhocTaskID = tbaf.AdhocTaskID
	WHERE tb.StatusCode = 'A'
		AND tbaf.StatusCode = 'A'
		AND at.NAME IS NOT NULL
		AND tbci.TaskBundleId = @i_TaskBundleID;

	WITH cteBundle
	AS (
		SELECT ID AS TaskBundleID
			,TaskBundleId BundleID
			,TaskType
			,TaskTypeID
			,NAME
			,FrequencyNumber
			,Frequency
			,STATUS
			,ParentID
			,ParentID ParentTaskBundleID
			,GeneralizedID
			,CopyInclude
			,CASE 
				WHEN ISNULL(@b_IsEdit, 0) = 0
					THEN 'No'
				ELSE 'Yes'
				END IsEdit
		FROM #Child_Temp
		
		UNION
		
		SELECT TaskBundle.TaskBundleId
			,TaskBundle.TaskBundleId BundleID
			,NULL
			,NULL
			,TaskBundle.TaskBundleName
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,CASE 
				WHEN TaskBundleCopyInclude.CopyInclude = 'C'
					THEN 'Copy'
				WHEN TaskBundleCopyInclude.CopyInclude = 'I'
					THEN 'Include'
				ELSE ''
				END
			,CASE 
				WHEN ISNULL(@b_IsEdit, 0) = 0
					THEN 'No'
				ELSE 'Yes'
				END IsEdit
		FROM TaskBundle WITH (NOLOCK)
		INNER JOIN #Child_Temp ON #Child_Temp.ParentID = TaskBundle.TaskBundleId
		INNER JOIN TaskBundleCopyInclude WITH (NOLOCK) ON TaskBundleCopyInclude.ParentTaskBundleId = TaskBundle.TaskBundleId
		WHERE TaskBundleCopyInclude.TaskBundleID = @i_TaskBundleID
		
		UNION
		
		SELECT TaskBundle.TaskBundleId
			,TaskBundle.TaskBundleId
			,NULL
			,NULL
			,TaskBundle.TaskBundleName
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,''
			,CASE 
				WHEN ISNULL(@b_IsEdit, 0) = 0
					THEN 'No'
				ELSE 'Yes'
				END IsEdit
		FROM TaskBundle
		WHERE TaskBundleId = @i_TaskBundleID
		)
	SELECT DISTINCT *
	FROM cteBundle
	ORDER BY GeneralizedID
END TRY

BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskBundleCopyInclude_Select] TO [FE_rohit.r-ext]
    AS [dbo];

