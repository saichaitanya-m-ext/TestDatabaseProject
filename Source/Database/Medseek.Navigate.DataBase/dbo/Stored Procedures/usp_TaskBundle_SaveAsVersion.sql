
/*  select * from errorlog order by 1 desc 
select * from taskbundle
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_TaskBundle_SaveAsVersion]1,7
Description   : This proc is used to store the history information of a TaskBundle
Created By    : Rathnam
Created Date  : 13-Sep-2012
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_TaskBundle_SaveAsVersion] (
	@i_AppUserId KEYID
	,@i_TaskbundleId KEYID
	)
AS
BEGIN
	BEGIN TRY
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

		DECLARE @l_TranStarted BIT = 0

		IF (@@TRANCOUNT = 0)
		BEGIN
			BEGIN TRANSACTION

			SET @l_TranStarted = 1
		END
		ELSE
		BEGIN
			SET @l_TranStarted = 0
		END

		DECLARE @v_Version VARCHAR(5)

		SELECT @v_Version = DefinitionVersion
		FROM TaskBundle
		WHERE TaskBundleId = @i_TaskbundleId

		INSERT INTO TaskBundleHistory (
			TaskBundleId
			,TaskBundleName
			,DefinitionVersion
			,Description
			,StatusCode
			,IsEdit
			,ProductionStatus
			,ConflictType
			,CreatedByUserId
			)
		SELECT TaskBundleId
			,TaskBundleName
			,DefinitionVersion
			,Description
			,StatusCode
			,IsEdit
			,ProductionStatus
			,ConflictType
			,@i_AppUserId
		FROM TaskBundle
		WHERE TaskBundleId = @i_TaskbundleId

		INSERT INTO TaskBundleAdhocFrequencyHistory (
			TaskBundleAdhocFrequencyID
			,TaskBundleId
			,AdhocTaskID
			,DefinitionVersion
			,FrequencyNumber
			,Frequency
			,Comments
			,StatusCode
			,CreatedByUserId
			)
		SELECT TaskBundleAdhocFrequencyID
			,TaskBundleId
			,AdhocTaskID
			,@v_Version
			,FrequencyNumber
			,Frequency
			,Comments
			,StatusCode
			,@i_AppUserId
		FROM TaskBundleAdhocFrequency
		WHERE TaskBundleId = @i_TaskbundleId

		INSERT INTO TaskBundleEducationMaterialHistory (
			TaskBundleEducationMaterialId
			,TaskBundleId
			,EducationMaterialID
			,DefinitionVersion
			,StatusCode
			,CreatedByUserId
			,NAME
			,LibraryIDList
			,Comments
			)
		SELECT DISTINCT TaskBundleEducationMaterialId
			,tbem.TaskBundleId
			,tbem.EducationMaterialID
			,@v_Version
			,tbem.StatusCode
			,@i_AppUserId
			,em.NAME
			,STUFF((
					SELECT ',' + CONVERT(VARCHAR, LibraryId)
					FROM EducationMaterialLibrary
					WHERE
						EducationMaterialLibrary.EducationMaterialID = tbem.EducationMaterialID
						AND EducationMaterialLibrary.TaskBundleID = tbem.TaskBundleId
					ORDER BY LibraryId
					FOR XML PATH('')
					), 1, 1, '') AS ProgramName
			,tbem.Comments
		FROM TaskBundleEducationMaterial tbem
		INNER JOIN EducationMaterial em ON em.EducationMaterialID = tbem.EducationMaterialID
		WHERE tbem.TaskBundleId = @i_TaskbundleId

		INSERT INTO TaskBundleProcedureFrequencyHistory (
			TaskBundleProcedureFrequencyId
			,TaskBundleId
			,DefinitionVersion
			,CodeGroupingId
			,StatusCode
			,FrequencyNumber
			,Frequency
			,NeverSchedule
			,ExclusionReason
			,IsPreventive
			,FrequencyCondition
			,CreatedByUserId
			)
		SELECT TaskBundleProcedureFrequencyId
			,TaskBundleId
			,@v_Version
			,CodeGroupingId
			,StatusCode
			,FrequencyNumber
			,Frequency
			,NeverSchedule
			,ExclusionReason
			,IsPreventive
			,FrequencyCondition
			,@i_AppUserId
		FROM TaskBundleProcedureFrequency
		WHERE TaskBundleId = @i_TaskbundleId

		INSERT INTO TaskBundleProcedureConditionalFrequencyHistory (
			TaskBundleProcedureConditionalFrequencyID
			,TaskBundleProcedureFrequencyId
			,DefinitionVersion
			,MeasureID
			,FromOperatorforMeasure
			,FromValueforMeasure
			,ToOperatorforMeasure
			,ToValueforMeasure
			,FromOperatorforAge
			,FromValueforAge
			,ToOperatorforAge
			,ToValueforAge
			,FrequencyUOM
			,Frequency
			,CreatedByUserId
			)
		SELECT tbpcf.TaskBundleProcedureConditionalFrequencyID
			,tbpcf.TaskBundleProcedureFrequencyId
			,@v_Version
			,tbpcf.MeasureID
			,tbpcf.FromOperatorforMeasure
			,tbpcf.FromValueforMeasure
			,tbpcf.ToOperatorforMeasure
			,tbpcf.ToValueforMeasure
			,tbpcf.FromOperatorforAge
			,tbpcf.FromValueforAge
			,tbpcf.ToOperatorforAge
			,tbpcf.ToValueforAge
			,tbpcf.FrequencyUOM
			,tbpcf.Frequency
			,@i_AppUserId
		FROM TaskBundleProcedureConditionalFrequency tbpcf
		INNER JOIN TaskBundleProcedureFrequency tbpf ON tbpcf.TaskBundleProcedureFrequencyId = tbpf.TaskBundleProcedureFrequencyId
		WHERE tbpf.TaskBundleId = @i_TaskbundleId

		INSERT INTO TaskBundleQuestionnaireFrequencyHistory (
			TaskBundleQuestionnaireFrequencyID
			,TaskBundleId
			,DefinitionVersion
			,QuestionaireId
			,FrequencyNumber
			,Frequency
			,StatusCode
			,IsPreventive
			,DiseaseID
			,CreatedByUserId
			)
		SELECT TaskBundleQuestionnaireFrequencyID
			,TaskBundleId
			,@v_Version
			,QuestionaireId
			,FrequencyNumber
			,Frequency
			,StatusCode
			,IsPreventive
			,DiseaseID
			,@i_AppUserId
		FROM TaskBundleQuestionnaireFrequency
		WHERE TaskBundleId = @i_TaskbundleId

		UPDATE TaskBundle
		SET DefinitionVersion = DBO.ufn_GetVersionNumber(@v_Version)
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		WHERE TaskBundleId = @i_TaskbundleId

		UPDATE TaskBundleHistory
		SET ParentTaskBundleList = STUFF((
					SELECT DISTINCT '$$' + CONVERT(VARCHAR(10), c.TaskBundleID) + ' - ' + CopyInclude
					FROM TaskBundleCopyInclude c
					WHERE c.TaskBundleID <> c.ParentTaskBundleId
						AND c.ParentTaskBundleId = @i_TaskbundleId
					FOR XML PATH('')
					), 1, 0, '')
		FROM TaskBundle
		WHERE TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
			AND TaskBundleHistory.TaskBundleId = @i_TaskbundleId
			AND TaskBundleHistory.DefinitionVersion = @v_Version --CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)    

		IF @l_TranStarted = 1
		BEGIN
			SET @l_TranStarted = 0

			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
		END
	END TRY

	-----------------------------------------------------------------------------------------------------------------------------------------------      
	BEGIN CATCH
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskBundle_SaveAsVersion] TO [FE_rohit.r-ext]
    AS [dbo];

