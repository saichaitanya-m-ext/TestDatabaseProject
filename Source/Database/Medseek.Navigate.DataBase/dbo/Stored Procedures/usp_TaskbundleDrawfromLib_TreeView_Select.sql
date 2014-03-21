
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_TaskbundleDrawfromLib_TreeView_Select]12,NULL,NULL,19
Description   : This procedure is used to get data from Taskbundle tables
Created By    : Balla Kalyan
Created Date  : Sept-12-2012
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/---[usp_TaskbundleDrawfromLib_TreeView_Select] 12,NULL,NULL,103
CREATE PROCEDURE [dbo].[usp_TaskbundleDrawfromLib_TreeView_Select] (
	@i_AppUserId INT
	,@v_TaskBundleName SOURCENAME = NULL
	,@v_Description SHORTDESCRIPTION = NULL
	,@i_TaskBundleID KEYID = NULL
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

	-------------------------------------------------------- 
	CREATE TABLE #Child_Temp (
		TaskBundleId INT IDENTITY(5000, 1)
		,ParentTaskBundleID INT
		,TaskType VARCHAR(1)
		,TaskTypeID INT
		,NAME VARCHAR(1050)
		,FrequencyNumber INT
		,Frequency VARCHAR(10)
		,StatusCode VARCHAR(2)
		,ParentID INT
		,GeneralizedID INT
		)

	INSERT #Child_Temp (
		ParentTaskBundleID
		,TaskType
		,TaskTypeID
		,NAME
		,FrequencyNumber
		,Frequency
		,StatusCode
		,ParentID
		,GeneralizedID
		)
	SELECT TB.TaskBundleId
		,'Q' 'TYPE'
		,TBQF.TaskBundleQuestionnaireFrequencyID ID
		,'Questionaire - ' + TBQF.QuestionaireName NAME
		,TBQF.FrequencyNumber
		,TBQF.Frequency
		,'0' AS 'Status'
		,TBQF.TaskBundleId AS ParentID
		,GeneralizedID
	FROM TaskBundle TB
	INNER JOIN (
		SELECT TaskBundleId
			,TBQF.TaskBundleQuestionnaireFrequencyID
			,QuestionaireName
			,FrequencyNumber
			,Frequency
			,QT.QuestionaireId GeneralizedID
		FROM Questionaire QT WITH (NOLOCK)
		INNER JOIN TaskBundleQuestionnaireFrequency TBQF WITH (NOLOCK) ON TBQF.QuestionaireId = QT.QuestionaireId
			AND TBQF.StatusCode = 'A'
			AND QuestionaireName IS NOT NULL
		) TBQF ON TBQF.TaskBundleId = TB.TaskBundleId
	WHERE tb.StatusCode = 'A'
		AND tb.ProductionStatus = 'F'
	
	
	UNION
	
	SELECT TBEM.TaskBundleId
		,'E' 'TYPE'
		,TBEM.TaskBundleEducationMaterialId ID
		,'PEM - ' + TBEM.NAME NAME
		,NULL FrequencyNumber
		,NULL Frequency
		,'1' AS 'Status'
		,TB.TaskBundleId AS ParentID
		,GeneralizedID
	FROM TaskBundle TB WITH (NOLOCK)
	INNER JOIN (
		SELECT TBEM.TaskBundleId
			,TBEM.TaskBundleEducationMaterialId
			,EM.NAME
			,EM.EducationMaterialID GeneralizedID
		FROM EducationMaterial EM WITH (NOLOCK)
		INNER JOIN TaskBundleEducationMaterial TBEM WITH (NOLOCK) ON TBEM.EducationMaterialID = EM.EducationMaterialID
			AND TBEM.StatusCode = 'A'
			AND EM.NAME IS NOT NULL
		) TBEM ON TBEM.TaskBundleId = TB.TaskBundleId
	WHERE TB.StatusCode = 'A'
		AND tb.ProductionStatus = 'F'
	      
	
	UNION
	
	SELECT TB.TaskBundleId
		,'P' 'TYPE'
		,TBPF.TaskBundleProcedureFrequencyId ID
		,'Procedure - ' + TBPF.NAME
		,TBPF.FrequencyNumber
		,TBPF.Frequency
		,'0' AS 'Status'
		,TB.TaskBundleId AS ParentID
		,GeneralizedID
	FROM TaskBundle TB WITH (NOLOCK)
	INNER JOIN (
		SELECT TaskBundleId
			,TaskBundleProcedureFrequencyId
			,CSP.CodeGroupingName NAME
			,FrequencyNumber
			,Frequency
			,CSP.CodeGroupingID GeneralizedID
		FROM CodeGrouping CSP WITH (NOLOCK)
		INNER JOIN TaskBundleProcedureFrequency TBPF WITH (NOLOCK) ON TBPF.CodeGroupingID = CSP.CodeGroupingID
		WHERE TBPF.FrequencyCondition = 'None'
			AND TBPF.StatusCode = 'A'
			AND FrequencyNumber IS NOT NULL
			AND Frequency IS NOT NULL
		) TBPF ON TBPF.TaskBundleId = TB.TaskBundleId
	WHERE tb.StatusCode = 'A'
		AND tb.ProductionStatus = 'F'
	
	
	UNION
	
	SELECT TB.TaskBundleId
		,'O' 'TYPE'
		,TBAF.TaskBundleAdhocFrequencyID ID
		,'OtherTask - ' + at.NAME
		,TBAF.FrequencyNumber
		,TBAF.Frequency
		,'0' AS 'Status'
		,TB.TaskBundleId AS ParentID
		,at.AdhocTaskid GeneralizedID
	FROM TaskBundle TB WITH (NOLOCK)
	INNER JOIN TaskBundleAdhocFrequency TBAF WITH (NOLOCK) ON TBAF.TaskBundleId = TB.TaskBundleId
	INNER JOIN AdhocTask at WITH (NOLOCK) ON at.AdhocTaskid = TBAF.AdhocTaskid
	WHERE tb.StatusCode = 'A'
		AND tb.ProductionStatus = 'F'
		AND TBAF.StatusCode = 'A'
		AND at.NAME IS NOT NULL

 



	;WITH cteTask
	AS (
		SELECT TaskBundleId
			,TaskBundleName NAME
			,NULL FrequencyNumber
			,NULL Frequency
			,NULL AS 'Status'
			,NULL AS ParentID
			,NULL ParentTaskBundleID
			,NULL TaskType
			,NULL TaskTypeID
			,CASE 
				WHEN IsEdit = '1'
					THEN 'Yes'
				ELSE 'No'
				END IsEdit
			,NULL GeneralizedID
		FROM TaskBundle
		WHERE StatusCode = 'A'
			AND (
				TaskBundleName LIKE '%' + @v_TaskBundleName + '%'
				OR @v_TaskBundleName IS NULL
				)
			AND (
				Description LIKE '%' + @v_Description + '%'
				OR @v_Description IS NULL
				)
		UNION
		
		SELECT CTEMP.TaskBundleId
			,NAME
			,FrequencyNumber
			,Frequency
			,CTEMP.StatusCode
			,ParentID
			,ParentTaskBundleID
			,TaskType
			,TaskTypeID
			,NULL IsEdit
			,GeneralizedID
		FROM #Child_Temp CTEMP
		INNER JOIN TaskBundle WITH (NOLOCK) ON TaskBundle.TaskBundleId = CTEMP.ParentID
		WHERE (
				NAME <> ''
				OR NAME IS NOT NULL
				)
			AND (
				TaskBundleName LIKE '%' + @v_TaskBundleName + '%'
				OR @v_TaskBundleName IS NULL
				)
			AND (
				Description LIKE '%' + @v_Description + '%'
				OR @v_Description IS NULL
				)
		)
	SELECT *
	FROM cteTask
	WHERE TaskBundleId IN (
			SELECT ParentID
			FROM cteTask
			)
		AND (
			TaskBundleId <> @i_TaskBundleID
			OR @i_TaskBundleID IS NULL
			)
	
	UNION ALL
	
	SELECT *
	FROM cteTask
	WHERE ParentID IS NOT NULL
		AND (
			ParentID <> @i_TaskBundleID
			OR @i_TaskBundleID IS NULL
			)
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
    ON OBJECT::[dbo].[usp_TaskbundleDrawfromLib_TreeView_Select] TO [FE_rohit.r-ext]
    AS [dbo];

