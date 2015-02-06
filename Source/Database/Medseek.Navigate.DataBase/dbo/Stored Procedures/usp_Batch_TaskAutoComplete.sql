
/*    
----------------------------------------------------------------------------------------------   
Procedure Name: [usp_Batch_TaskAutoComplete]
Description   : This Stored procedure used to auto complete the Pending For Claims tasks related to Procedures
Created By    : Rathnam   
Created Date  : 04-July-2013.    
----------------------------------------------------------------------------------------------
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 

-----------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Batch_TaskAutoComplete]
	 (
	 @i_AppUserId KEYID
	,@i_TaskID KEYID = NULL
	,@v_SpecialtyCode VARCHAR(5) = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	DECLARE @i_TaskStatusID INT

	SELECT @i_TaskStatusID = TaskStatusId
	FROM TaskStatus
	WHERE TaskStatusText = 'Closed Complete';

	WITH taskCTE
	AS (
		SELECT TaskId
		FROM Task t
		INNER JOIN TaskStatus ts
			ON t.TaskStatusId = ts.TaskStatusId
		INNER JOIN PatientProcedureCode ppc
			ON ppc.PatientID = t.PatientId
		INNER JOIN PatientProcedureCodeGroup ppcg
			ON ppcg.PatientProcedureCodeID = ppc.PatientProcedureCodeID
				AND ppcg.CodeGroupingID = t.TypeID
		LEFT JOIN ClaimProvider cp
			ON cp.ClaimInfoID = ppc.ClaimInfoId
		LEFT JOIN ProviderSpecialty ps
			ON ps.ProviderID = cp.ProviderID
		LEFT JOIN CodeSetCMSProviderSpecialty cscps
			ON cscps.CMSProviderSpecialtyCodeID = ps.ProviderSpecialtyID
		INNER JOIN TaskType ty
		    ON ty.TaskTypeId = t.TaskTypeId	
		WHERE TaskStatusText = 'Pending For Claims'
			AND ty.TaskTypeName = 'Schedule Procedure'
			AND (
				t.TaskId = @i_TaskID
				OR @i_TaskID IS NULL
				)
			AND (
				cscps.ProviderSpecialtyCode = @v_SpecialtyCode
				OR @v_SpecialtyCode IS NULL
				)
				
		
		UNION
		
		SELECT TaskId
		FROM Task t
		INNER JOIN TaskStatus ts
			ON t.TaskStatusId = ts.TaskStatusId
		INNER JOIN PatientDiagnosisCode ppc
			ON ppc.PatientID = t.PatientId
		INNER JOIN PatientDiagnosisCodeGroup ppcg
			ON ppcg.PatientDiagnosisCodeID = ppc.PatientDiagnosisCodeID
				AND ppcg.CodeGroupingID = t.TypeID
		LEFT JOIN ClaimProvider cp
			ON cp.ClaimInfoID = ppc.ClaimInfoId
		LEFT JOIN ProviderSpecialty ps
			ON ps.ProviderID = cp.ProviderID
		LEFT JOIN CodeSetCMSProviderSpecialty cscps
			ON cscps.CMSProviderSpecialtyCodeID = ps.ProviderSpecialtyID
		INNER JOIN TaskType ty
		    ON ty.TaskTypeId = t.TaskTypeId		
		WHERE TaskStatusText = 'Pending For Claims'
			AND ty.TaskTypeName = 'Schedule Procedure'
			AND (
				t.TaskId = @i_TaskID
				OR @i_TaskID IS NULL
				)
			AND (
				cscps.ProviderSpecialtyCode = @v_SpecialtyCode
				OR @v_SpecialtyCode IS NULL
				)
		
		UNION
		
		SELECT TaskId
		FROM Task t
		INNER JOIN TaskStatus ts
			ON t.TaskStatusId = ts.TaskStatusId
		INNER JOIN RxClaim ppc
			ON ppc.PatientID = t.PatientId
		INNER JOIN PatientMedicationCodeGroup ppcg
			ON ppcg.RxClaimId = ppc.RxClaimId
				AND ppcg.CodeGroupingID = t.TypeID
		LEFT JOIN ProviderSpecialty ps
			ON ps.ProviderID = ppc.PrescriberID
		LEFT JOIN CodeSetCMSProviderSpecialty cscps
			ON cscps.CMSProviderSpecialtyCodeID = ps.ProviderSpecialtyID
		INNER JOIN TaskType ty
		    ON ty.TaskTypeId = t.TaskTypeId			
		WHERE TaskStatusText = 'Pending For Claims'
			AND ty.TaskTypeName = 'Schedule Procedure'
			AND (
				t.TaskId = @i_TaskID
				OR @i_TaskID IS NULL
				)
			AND (
				cscps.ProviderSpecialtyCode = @v_SpecialtyCode
				OR @v_SpecialtyCode IS NULL
				)
		
		UNION
		
		SELECT TaskId
		FROM Task t
		INNER JOIN TaskStatus ts
			ON t.TaskStatusId = ts.TaskStatusId
		INNER JOIN PatientOtherCode ppc
			ON ppc.PatientID = t.PatientId
		INNER JOIN PatientOtherCodeGroup ppcg
			ON ppcg.PatientOtherCodeID = ppc.PatientOtherCodeID
				AND ppcg.CodeGroupingID = t.TypeID
		LEFT JOIN ClaimProvider cp
			ON cp.ClaimInfoID = ppc.ClaimInfoId
		LEFT JOIN ProviderSpecialty ps
			ON ps.ProviderID = cp.ProviderID
		LEFT JOIN CodeSetCMSProviderSpecialty cscps
			ON cscps.CMSProviderSpecialtyCodeID = ps.ProviderSpecialtyID
		INNER JOIN TaskType ty
		    ON ty.TaskTypeId = t.TaskTypeId			
		WHERE TaskStatusText = 'Pending For Claims'
			AND ty.TaskTypeName = 'Schedule Procedure'
			AND (
				t.TaskId = @i_TaskID
				OR @i_TaskID IS NULL
				)
			AND (
				cscps.ProviderSpecialtyCode = @v_SpecialtyCode
				OR @v_SpecialtyCode IS NULL
				)
		)
	UPDATE Task
	SET TaskStatusId = @i_TaskStatusID
	FROM taskCTE
	WHERE taskCTE.TaskId = Task.TaskId
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
    ON OBJECT::[dbo].[usp_Batch_TaskAutoComplete] TO [FE_rohit.r-ext]
    AS [dbo];

