
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserPrograms_Insert    
Description   : This procedure is used to insert record into UserPrograms table
Created By    : Aditya    
Created Date  : 15-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY          DESCRIPTION    
25-May-2010 NagaBabu   A perametr @dt_DueDate UserDate, is added to this procedure 
14-Mar-2011 NagaBabu ProgramExcludeID Field and as well as perameter   
18-Mar-2011 NagaBabu Added NULL to @i_ProgramExcludeID Bydefault  
25-Mar-2011 NagaBabu Added NULL to @dt_DueDate,@dt_EnrollmentStartDate,@dt_EnrollmentEndDate,@dt_DeclinedDate Bydefault   \
03-feb-2012 Sivakrishna Added @b_IsAdhoc parameter to maintain the adhoc task Records in UserPrograms
12-Oct-2012 Rathnam added insert statement for ProgramPatientTaskConflict
------------------------------------------------------------------------------    
exec [usp_UserPrograms_Insert] 2,11,247,null,null,null,null,'3/25/2013','A'
*/
CREATE PROCEDURE [dbo].[usp_UserPrograms_Insert] (
	@i_AppUserId KEYID
	,@i_UserId KEYID
	,@i_ProgramId KEYID
	,@dt_DueDate USERDATE = NULL
	,@dt_EnrollmentStartDate USERDATE = NULL
	,@dt_EnrollmentEndDate USERDATE = NULL
	,@i_IsPatientDeclinedEnrollment ISINDICATOR = null
	,@dt_DeclinedDate DATETIME = NULL
	,@vc_StatusCode STATUSCODE
	,@i_ProgramExcludeID KEYID = NULL
	,@o_UserProgramId KEYID OUTPUT
	,@b_IsAdhoc BIT = 0
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT

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
			FROM PatientProgram
			WHERE ProgramID = @i_ProgramId
				AND PatientID = @i_UserId
				AND EnrollmentEndDate IS NULL
			)
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

		DECLARE @i_ProviderID INT

		SELECT TOP 1 @i_ProviderID = ctm.ProviderID
		FROM ProgramCareTeam pct
		INNER JOIN CareTeamMembers ctm
			ON ctm.CareTeamId = pct.CareTeamId
		WHERE pct.ProgramId = @i_ProgramId
			AND ctm.StatusCode = 'A'

		INSERT INTO PatientProgram (
			PatientID
			,ProgramId
			,DueDate
			,EnrollmentStartDate
			,EnrollmentEndDate
			,IsPatientDeclinedEnrollment
			,DeclinedDate
			,StatusCode
			,CreatedByUserId
			,ProgramExcludeID
			,IsAdhoc
			,IsAutoEnrollment
			,IdentificationDate
			,ProviderID
			)
		VALUES (
			@i_UserId
			,@i_ProgramId
			,@dt_DueDate
			,ISNULL(@dt_EnrollmentStartDate, GETDATE())
			,NULL
			,@i_IsPatientDeclinedEnrollment
			,@dt_DeclinedDate
			,@vc_StatusCode
			,@i_AppUserId
			,@i_ProgramExcludeID
			,@b_IsAdhoc
			,0
			,GETDATE()
			,@i_ProviderID
			)

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
			,@o_UserProgramId = SCOPE_IDENTITY()

		IF EXISTS (
				SELECT 1
				FROM ProgramTaskBundle
				WHERE ProgramID = @i_ProgramId
					AND StatusCode = 'A'
				)
		BEGIN
			INSERT INTO ProgramPatientTaskConflict (
				ProgramTaskBundleId
				,PatientUserID
				,CreatedByUserId
				)
			SELECT DISTINCT ProgramTaskBundle.ProgramTaskBundleID
				,@i_UserId
				,@i_AppUserId
			FROM ProgramTaskBundle
			WHERE ProgramTaskBundle.ProgramID = @i_ProgramID
				AND ProgramTaskBundle.StatusCode = 'A'
				AND NOT EXISTS (
					SELECT 1
					FROM ProgramPatientTaskConflict pptc
					WHERE pptc.ProgramTaskBundleId = ProgramTaskBundle.ProgramTaskBundleID
						AND pptc.PatientUserID = @i_UserId
					)
		END

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
    ON OBJECT::[dbo].[usp_UserPrograms_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

