
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_TaskBundle_Summary]1,19
Description   : This proc is used to fetch the summary information of a TaskBundle
Created By    : Rathnam
Created Date  : 18-Sep-2012

--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  12/19/2013 prathyusha added lastmodified date column to the result set
  01/06/2013 Santosh added the last result set for TaskADT
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_TaskBundle_Summary] (
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
		
		

		SELECT DISTINCT TaskBundleAdhocFrequencyID
			,TaskBundleId
			,at.AdhocTaskID AS TypeID
			,at.NAME TypeName
			,CONVERT(VARCHAR, FrequencyNumber) + CASE 
				WHEN Frequency = 'W'
					THEN ' Week(s)'
				WHEN Frequency = 'M'
					THEN ' Month(s)'
				WHEN Frequency = 'Y'
					THEN ' Years(s)'
				WHEN Frequency = 'D'
					THEN ' Day(s)'
				END Frequency
			,CASE 
				WHEN (
						taf.ParentTaskBundleID = taf.TaskBundleId
						OR taf.ParentTaskBundleID IS NULL
						)
					THEN 'Individual'
				ELSE 'Copy'
				END ReferenceType
			,ISNULL(taf.IsConflictResolution, 0) AS IsConflict
			,taf.LastModifiedDate
			,CASE WHEN taf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
		FROM TaskBundleAdhocFrequency taf
		INNER JOIN AdhocTask at ON taf.AdhocTaskID = at.AdhocTaskID
		WHERE TaskBundleId = @i_TaskBundleID
			AND taf.StatusCode = 'A'
		
		UNION
		
		SELECT DISTINCT tbaf.TaskBundleAdhocFrequencyID
			,tbaf.TaskBundleId
			,at.AdhocTaskID AS TypeID
			,at.NAME
			,CONVERT(VARCHAR, tbaf.FrequencyNumber) + CASE 
				WHEN tbaf.Frequency = 'W'
					THEN ' Week(s)'
				WHEN tbaf.Frequency = 'M'
					THEN ' Month(s)'
				WHEN tbaf.Frequency = 'Y'
					THEN ' Years(s)'
				WHEN tbaf.Frequency = 'D'
					THEN ' Day(s)'
				END Frequency
			,CASE 
				WHEN tbci.CopyInclude = 'I'
					THEN 'Include'
				END ReferenceType
			,ISNULL(tbci.IsConflictResolution, 0) AS IsConflict
			,tbaf.LastModifiedDate
			,CASE WHEN tbaf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
		FROM TaskBundleAdhocFrequency tbaf
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbaf.TaskBundleId
			AND tbci.GeneralizedID = tbaf.AdhocTaskID
		INNER JOIN AdhocTask at ON at.AdhocTaskID = tbaf.AdhocTaskID
		WHERE tbci.TaskBundleId = @i_TaskBundleID
			AND tbci.CopyInclude = 'I'
			AND tbci.TaskType = 'O'
			AND tbaf.StatusCode = 'A'

		SELECT DISTINCT tbqf.TaskBundleQuestionnaireFrequencyID
			,tbqf.TaskBundleId
			,Q.QuestionaireId
			,Q.QuestionaireName
			,CONVERT(VARCHAR(10), tbqf.FrequencyNumber) + CASE 
				WHEN tbqf.Frequency = 'W'
					THEN ' Week(s)'
				WHEN tbqf.Frequency = 'M'
					THEN ' Month(s)'
				WHEN tbqf.Frequency = 'Y'
					THEN ' Years(s)'
				WHEN tbqf.Frequency = 'D'
					THEN ' Day(s)'
				END Frequency
			,CASE 
				WHEN (
						tbqf.ParentTaskBundleID = tbqf.TaskBundleId
						OR tbqf.ParentTaskBundleID IS NULL
						)
					THEN 'Individual'
				ELSE 'Copy'
				END ReferenceType
			,ISNULL(tbqf.IsConflictResolution, 0) AS IsConflict
			,tbqf.LastModifiedDate
			,CASE WHEN tbqf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
		FROM TaskBundleQuestionnaireFrequency tbqf
		INNER JOIN Questionaire Q ON Q.QuestionaireId = tbqf.QuestionaireId
		WHERE tbqf.TaskBundleId = @i_TaskBundleID
			AND tbqf.StatusCode = 'A'
		
		UNION
		
		SELECT DISTINCT tbqf.TaskBundleQuestionnaireFrequencyID
			,tbqf.TaskBundleId
			,Q.QuestionaireId
			,Q.QuestionaireName
			,CONVERT(VARCHAR(10), tbqf.FrequencyNumber) + CASE 
				WHEN tbqf.Frequency = 'W'
					THEN ' Week(s)'
				WHEN tbqf.Frequency = 'M'
					THEN ' Month(s)'
				WHEN tbqf.Frequency = 'Y'
					THEN ' Years(s)'
				WHEN tbqf.Frequency = 'D'
					THEN ' Day(s)'
				END Frequency
			,CASE 
				WHEN tbci.CopyInclude = 'I'
					THEN 'Include'
				ELSE 'Copy'
				END ReferenceType
			,ISNULL(tbci.IsConflictResolution, 0) AS IsConflict
			,tbqf.LastModifiedDate
			,CASE WHEN tbqf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
		FROM TaskBundleQuestionnaireFrequency tbqf
		INNER JOIN Questionaire Q ON Q.QuestionaireId = tbqf.QuestionaireId
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbqf.TaskBundleId
			AND tbci.GeneralizedID = tbqf.QuestionaireId
		WHERE tbci.TaskBundleId = @i_TaskBundleID
			AND tbqf.StatusCode = 'A'
			AND tbci.TaskType = 'Q'
			AND tbci.CopyInclude = 'I'

		SELECT DISTINCT tbem.TaskBundleEducationMaterialId
			,tbem.TaskBundleId
			,e.EducationMaterialID
			,e.NAME
			,NULL AS Frequency
			,CASE 
				WHEN (
						tbem.ParentTaskBundleID = tbem.TaskBundleId
						OR tbem.ParentTaskBundleID IS NULL
						)
					THEN 'Individual'
				ELSE 'Copy'
				END ReferenceType
			,ISNULL(tbem.IsConflictResolution, 0) AS IsConflict
			,tbem.LastModifiedDate
		FROM TaskBundleEducationMaterial tbem
		INNER JOIN EducationMaterial e ON e.EducationMaterialID = tbem.EducationMaterialID
		WHERE tbem.TaskBundleId = @i_TaskBundleID
			AND tbem.StatusCode = 'A'
		
		UNION
		
		SELECT DISTINCT tbem.TaskBundleEducationMaterialId
			,tbem.TaskBundleId
			,e.EducationMaterialID
			,e.NAME
			,NULL AS Frequency
			,CASE 
				WHEN tbci.CopyInclude = 'I'
					THEN 'Include'
				ELSE 'Copy'
				END ReferenceType
			,ISNULL(tbci.IsConflictResolution, 0) AS IsConflict
			,tbem.LastModifiedDate
		FROM TaskBundleEducationMaterial tbem
		INNER JOIN EducationMaterial e ON E.EducationMaterialID = tbem.EducationMaterialID
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbem.TaskBundleId
			AND tbci.GeneralizedID = tbem.EducationMaterialID
		WHERE tbci.TaskBundleId = @i_TaskBundleID
			AND tbem.StatusCode = 'A'
			AND tbci.TaskType = 'E'
			AND tbci.CopyInclude = 'I'

		SELECT DISTINCT tbpf.TaskBundleProcedureFrequencyId
			,tbpf.TaskBundleId
			,csp.CodeGroupingID
			,csp.CodeGroupingName
			,CONVERT(VARCHAR(10), tbpf.FrequencyNumber) + CASE 
				WHEN tbpf.Frequency = 'W'
					THEN ' Week(s)'
				WHEN tbpf.Frequency = 'M'
					THEN ' Month(s)'
				WHEN tbpf.Frequency = 'Y'
					THEN ' Years(s)'
				WHEN tbpf.Frequency = 'D'
					THEN ' Day(s)'
				END Frequency
			,CASE 
				WHEN (
						tbpf.ParentTaskBundleID = tbpf.TaskBundleId
						OR tbpf.ParentTaskBundleID IS NULL
						)
					THEN 'Individual'
				ELSE 'Copy'
				END ReferenceType
			,ISNULL(tbpf.IsConflictResolution, 0) AS IsConflict
			,tbpf.LastModifiedDate
			,CASE WHEN tbpf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
		FROM TaskBundleProcedureFrequency tbpf
		INNER JOIN CodeGrouping csp ON csp.CodeGroupingID = tbpf.CodeGroupingID
		WHERE tbpf.TaskBundleId = @i_TaskBundleID
			AND tbpf.StatusCode = 'A'
			AND tbpf.FrequencyCondition = 'None'
		
		UNION
		
		SELECT DISTINCT tbpf.TaskBundleProcedureFrequencyId
			,tbpf.TaskBundleId
			,csp.CodeGroupingID
			,csp.CodeGroupingName
			,CONVERT(VARCHAR(10), tbpf.FrequencyNumber) + CASE 
				WHEN tbpf.Frequency = 'W'
					THEN ' Week(s)'
				WHEN tbpf.Frequency = 'M'
					THEN ' Month(s)'
				WHEN tbpf.Frequency = 'Y'
					THEN ' Years(s)'
				WHEN tbpf.Frequency = 'D'
					THEN ' Day(s)'
				END Frequency
			,CASE 
				WHEN tbci.CopyInclude = 'I'
					THEN 'Include'
				ELSE 'Copy'
				END ReferenceType
			,ISNULL(tbci.IsConflictResolution, 0) AS IsConflict
			,tbpf.LastModifiedDate
			,CASE WHEN tbpf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
		FROM TaskBundleProcedureFrequency tbpf
		INNER JOIN CodeGrouping csp ON csp.CodeGroupingID = tbpf.CodeGroupingID
		INNER JOIN TaskBundleCopyInclude tbci ON tbci.ParentTaskBundleId = tbpf.TaskBundleId
			AND tbci.GeneralizedID = tbpf.CodeGroupingID
		WHERE tbci.TaskBundleId = @i_TaskBundleID
			AND tbpf.StatusCode = 'A'
			AND tbci.TaskType = 'P'
			AND tbpf.FrequencyCondition = 'None'
			AND tbci.CopyInclude = 'I'
		
		UNION
		
		SELECT DISTINCT tbpf.TaskBundleProcedureFrequencyId
			,tbpf.TaskBundleId
			,csp.CodeGroupingID
			,csp.CodeGroupingName
			,CONVERT(VARCHAR(10), tbpcf.Frequency) + CASE 
				WHEN tbpcf.FrequencyUOM = 'W'
					THEN ' Week(s)'
				WHEN tbpcf.FrequencyUOM = 'M'
					THEN ' Month(s)'
				WHEN tbpcf.FrequencyUOM = 'Y'
					THEN ' Years(s)'
				WHEN tbpcf.FrequencyUOM = 'D'
					THEN ' Day(s)'
				END Frequency
			,'Individual' ReferenceType
			,ISNULL(tbpf.IsConflictResolution, 0) AS IsConflict
			,tbpf.LastModifiedDate
			,CASE WHEN tbpf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
		FROM TaskBundleProcedureFrequency tbpf
		INNER JOIN CodeGrouping csp ON csp.CodeGroupingID = tbpf.CodeGroupingID
		INNER JOIN TaskBundleProcedureConditionalFrequency tbpcf ON tbpcf.TaskBundleProcedureFrequencyId = tbpf.TaskBundleProcedureFrequencyId
		WHERE tbpf.TaskBundleId = @i_TaskBundleID
			AND tbpf.StatusCode = 'A'
			AND tbpf.FrequencyCondition <> 'None'

		

		
		SELECT DISTINCT TaskBundle.TaskBundleName
			,CONVERT(VARCHAR(10), TaskBundle.CreatedDate, 101) CreatedDate
		FROM TaskBundleCopyInclude
		INNER JOIN TaskBundle ON TaskBundle.TaskBundleId = TaskBundleCopyInclude.ParentTaskBundleId
		WHERE TaskBundleCopyInclude.TaskBundleID = @i_TaskbundleId
			AND TaskBundleCopyInclude.CopyInclude = 'I'
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
    ON OBJECT::[dbo].[usp_TaskBundle_Summary] TO [FE_rohit.r-ext]
    AS [dbo];

