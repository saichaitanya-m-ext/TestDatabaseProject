
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_TaskBundle_SelectByBundleID  64,106,'CPT'
Description   : This procedure is used to get the task bundle information related to cohorts , subcohorts, measures & Diseases information  
Created By    : Rathnam  
Created Date  : 22-Dec-2011  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
28-AUG-2012 P.V.P.MOHAN Added Alias StatusCode for ColumnName
12/19/2013 prathyusha added lastmodified date column to the result set
01/06/2014 santosh added the condition @v_Type = 'ADT'
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_TaskBundle_SelectByBundleID] --64,106,'CPT'
	(
	@i_AppUserId KEYID
	,@i_TaskBundleID KEYID
	,@v_Type VARCHAR(10) = NULL -- CPT--> Procedure, QUE --> Questionaire, PEM, Adhoc
	)
AS
BEGIN
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

		DECLARE @v_TaskBundleName VARCHAR(500)

		SELECT @v_TaskBundleName = TaskBundleName
		FROM TaskBundle
		WHERE TaskBundleId = @i_TaskBundleID
		
		
		
		IF @v_Type = 'PEM'
		BEGIN
			SELECT tbpem.TaskBundleId
				,tbpem.TaskBundleEducationMaterialId
				,tbpem.EducationMaterialID
				,pem.NAME
				,CASE 
					WHEN tbpem.StatusCode = 'A'
						THEN 'Active'
					ELSE 'InActive'
					END AS StatusCode
				,STUFF((
						SELECT ',' + l.NAME
						FROM Library l
						INNER JOIN EducationMaterialLibrary eml ON l.LibraryId = eml.LibraryId
						WHERE eml.EducationMaterialID = pem.EducationMaterialID
							AND eml.TaskBundleID = tbpem.TaskBundleId
						FOR XML PATH('')
						), 1, 1, '') AS LibraryNamesList
				,@v_TaskBundleName TaskBundleName
				,tbpem.LastModifiedDate
			FROM TaskBundleEducationMaterial tbpem WITH (NOLOCK)
			INNER JOIN EducationMaterial pem WITH (NOLOCK) ON pem.EducationMaterialID = tbpem.EducationMaterialID
			WHERE
				tbpem.TaskBundleId = @i_TaskBundleID
			
			UNION ALL
			
			SELECT DISTINCT tbem.TaskBundleId
				,tbem.TaskBundleEducationMaterialId
				,e.EducationMaterialID
				,e.NAME
				,CASE 
					WHEN tbem.StatusCode = 'A'
						THEN 'Active'
					ELSE 'InActive'
					END AS StatusCode
				,STUFF((
						SELECT ',' + l.NAME
						FROM Library l
						INNER JOIN EducationMaterialLibrary eml ON l.LibraryId = eml.LibraryId
						WHERE eml.EducationMaterialID = e.EducationMaterialID
							AND eml.TaskBundleID = tbem.TaskBundleId
						FOR XML PATH('')
						), 1, 1, '') AS LibraryNamesList
				,tb.TaskBundleName
				,tbem.LastModifiedDate
			FROM TaskBundleEducationMaterial tbem WITH (NOLOCK)
			INNER JOIN EducationMaterial e WITH (NOLOCK) ON E.EducationMaterialID = tbem.EducationMaterialID
			INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbem.TaskBundleId
				AND tbci.GeneralizedID = tbem.EducationMaterialID
			INNER JOIN TaskBundle tb WITH (NOLOCK) ON tb.TaskBundleId = tbci.ParentTaskBundleId
			WHERE tbci.TaskBundleId = @i_TaskBundleID
				AND tbci.TaskType = 'E'
				AND tbci.CopyInclude = 'I'
		END
		ELSE
		BEGIN
			IF @v_Type = 'CPT'
			BEGIN
				SELECT tbPF.TaskBundleId
					,tbPF.TaskBundleProcedureFrequencyId
					,tbPF.CodeGroupingID
					,csp.CodeGroupingName
					,CONVERT(VARCHAR, tbPF.FrequencyNumber) + ' ' + CASE 
						WHEN tbPF.Frequency = 'D'
							THEN 'Day(s)'
						WHEN tbPF.Frequency = 'M'
							THEN 'Month(s)'
						WHEN tbPF.Frequency = 'W'
							THEN 'Week(s)'
						WHEN tbPF.Frequency = 'Y'
							THEN 'Year(s)'
						END Frequency
					,CASE 
						WHEN tbPF.StatusCode = 'A'
							THEN 'Active'
						ELSE 'InActive'
						END AS StatusCode
					,@v_TaskBundleName TaskBundleName
					,tbPF.LastModifiedDate
					, CASE WHEN tbPF.RecurrenceType ='O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
				FROM TaskBundleProcedureFrequency tbPF WITH (NOLOCK)
				INNER JOIN CodeGrouping csp WITH (NOLOCK) ON csp.CodeGroupingID = tbPF.CodeGroupingID
				WHERE
					tbPF.TaskBundleId = @i_TaskBundleID
				
				UNION ALL
				
				SELECT DISTINCT tbpf.TaskBundleId
					,tbpf.TaskBundleProcedureFrequencyId
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
						WHEN tbPF.StatusCode = 'A'
							THEN 'Active'
						ELSE 'InActive'
						END AS StatusCode
					,tb.TaskBundleName
					,tbPF.LastModifiedDate
					,CASE WHEN tbpf.RecurrenceType ='O' THEN 'One Time' ELSE 'Recuring' END RecurrenceType
				FROM TaskBundleProcedureFrequency tbpf WITH (NOLOCK)
				INNER JOIN CodeGrouping csp WITH (NOLOCK) ON csp.CodeGroupingID = tbpf.CodeGroupingID
				INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbpf.TaskBundleId
					AND tbci.GeneralizedID = tbpf.CodeGroupingID
				INNER JOIN TaskBundle tb WITH (NOLOCK) ON tb.TaskBundleId = tbci.ParentTaskBundleId
				WHERE tbci.TaskBundleId = @i_TaskBundleID
					AND tbci.TaskType = 'P'
					AND tbpf.FrequencyCondition = 'None'
					AND tbci.CopyInclude = 'I'
			END
			ELSE
			BEGIN
				IF @v_Type = 'QUE'
				BEGIN
					SELECT tbq.TaskBundleId
						,tbq.TaskBundleQuestionnaireFrequencyID
						,tbq.QuestionaireId
						,q.QuestionaireName
						,CONVERT(VARCHAR, tbq.FrequencyNumber) + ' ' + CASE 
							WHEN tbq.Frequency = 'D'
								THEN 'Day(s)'
							WHEN tbq.Frequency = 'M'
								THEN 'Month(s)'
							WHEN tbq.Frequency = 'W'
								THEN 'Week(s)'
							WHEN tbq.Frequency = 'Y'
								THEN 'Year(s)'
							END Frequency
						,CASE 
							WHEN tbq.StatusCode = 'A'
								THEN 'Active'
							ELSE 'InActive'
							END AS StatusCode
						,tbq.Frequency AS CurrentFrequency
						,tbq.FrequencyNumber
						,tbq.IsPreventive
						,tbq.DiseaseID
						,@v_TaskBundleName TaskBundleName
						,tbq.LastModifiedDate
						,CASE WHEN tbq.RecurrenceType ='O' THEN 'One Time' ELSE 'Recuring' END RecurrenceType
					FROM TaskBundleQuestionnaireFrequency tbq WITH (NOLOCK)
					INNER JOIN Questionaire q WITH (NOLOCK) ON tbq.QuestionaireId = q.QuestionaireId
					WHERE tbq.TaskBundleId = @i_TaskBundleID
					
					UNION ALL
					
					SELECT DISTINCT tbqf.TaskBundleId
						,tbqf.TaskBundleQuestionnaireFrequencyID
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
							WHEN tbqf.StatusCode = 'A'
								THEN 'Active'
							ELSE 'InActive'
							END AS StatusCode
						,tbqf.Frequency AS CurrentFrequency
						,tbqf.FrequencyNumber
						,tbqf.IsPreventive
						,tbqf.DiseaseID
						,tb.TaskBundleName
						,tbqf.LastModifiedDate
						,CASE WHEN tbqf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
					FROM TaskBundleQuestionnaireFrequency tbqf WITH (NOLOCK)
					INNER JOIN Questionaire Q WITH (NOLOCK) ON Q.QuestionaireId = tbqf.QuestionaireId
					INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbqf.TaskBundleId
						AND tbci.GeneralizedID = tbqf.QuestionaireId
					INNER JOIN TaskBundle tb WITH (NOLOCK) ON tb.TaskBundleId = tbci.ParentTaskBundleId
					WHERE tbci.TaskBundleId = @i_TaskBundleID
						AND tbci.TaskType = 'Q'
						AND tbci.CopyInclude = 'I'
				END
				ELSE
				BEGIN
					IF @v_Type = 'ADH'
					BEGIN
						SELECT tbaf.TaskBundleID
							,tbaf.TaskBundleAdhocFrequencyID
							,at.NAME
							,CONVERT(VARCHAR, tbaf.FrequencyNumber) + ' ' + CASE 
								WHEN tbaf.Frequency = 'D'
									THEN 'Day(s)'
								WHEN tbaf.Frequency = 'M'
									THEN 'Month(s)'
								WHEN tbaf.Frequency = 'W'
									THEN 'Week(s)'
								WHEN tbaf.Frequency = 'Y'
									THEN 'Year(s)'
								END Frequency
							,CASE 
								WHEN tbaf.StatusCode = 'A'
									THEN 'Active'
								ELSE 'InActive'
								END AS StatusCode
							,tbaf.Frequency AS CurrentFrequency
							,tbaf.FrequencyNumber
							,tbaf.Comments
							,@v_TaskBundleName TaskBundleName
							,tbaf.LastModifiedDate
							,CASE WHEN tbaf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
						FROM TaskBundleAdhocFrequency tbaf WITH (NOLOCK)
						INNER JOIN AdhocTask at WITH (NOLOCK) ON at.AdhocTaskID = tbaf.AdhocTaskID
						WHERE tbaf.TasKBundleID = @i_TaskBundleID
						
						UNION ALL
						
						SELECT DISTINCT tbaf.TaskBundleId
							,tbaf.TaskBundleAdhocFrequencyID
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
								WHEN tbaf.StatusCode = 'A'
									THEN 'Active'
								ELSE 'InActive'
								END AS StatusCode
							,tbaf.Frequency AS CurrentFrequency
							,tbaf.FrequencyNumber
							,tbaf.Comments
							,tb.TaskBundleName
							,tbaf.LastModifiedDate
							,CASE WHEN tbaf.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
						FROM TaskBundleAdhocFrequency tbaf WITH (NOLOCK)
						INNER JOIN TaskBundleCopyInclude tbci WITH (NOLOCK) ON tbci.ParentTaskBundleId = tbaf.TaskBundleId
							AND tbci.GeneralizedID = tbaf.AdhocTaskID
						INNER JOIN AdhocTask at WITH (NOLOCK) ON at.AdhocTaskID = tbaf.AdhocTaskID
						INNER JOIN TaskBundle tb WITH (NOLOCK) ON tb.TaskBundleId = tbci.ParentTaskBundleId
						WHERE tbci.TaskBundleId = @i_TaskBundleID
							AND tbci.CopyInclude = 'I'
							AND tbci.TaskType = 'O'
					END
				END
						
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
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskBundle_SelectByBundleID] TO [FE_rohit.r-ext]
    AS [dbo];

