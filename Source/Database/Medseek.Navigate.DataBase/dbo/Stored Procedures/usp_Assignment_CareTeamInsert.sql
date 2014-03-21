
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Assignment_CareTeamInsert
Description   : This procedure is used to map the careteams to the assignment
Created By    : Rathnam  
Created Date  : 15-Oct-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
19-Mar-2013 P.V.P.Moahn Modified  PatientProgamID to  UserProgramId parameter and 
			Modified table userProgram to PatientProgram,UserCareTeam to PatientCareTeam
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_CareTeamInsert] --64,107
	(
	@i_AppUserId KEYID
	,@i_ProgramID KEYID
	,@tblCareTeamList TTYPEKEYID READONLY
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

		DELETE
		FROM ProgramCareTeam
		WHERE ProgramId = @i_ProgramID

		INSERT INTO ProgramCareTeam (
			ProgramId
			,CareTeamId
			,CreatedByUserId
			,CreatedDate
			)
		SELECT @i_ProgramID
			,t.tKeyId
			,@i_AppUserId
			,GETDATE()
		FROM @tblCareTeamList t

		IF EXISTS (
				SELECT 1
				FROM PatientProgram
				WHERE ProgramId = @i_ProgramID
					AND ProviderID IS NULL
				)
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM ProgramCareTeam
					WHERE ProgramId = @i_ProgramID
					)
			BEGIN
				CREATE TABLE #Prov (UserID INT)

				INSERT INTO #Prov
				SELECT DISTINCT ProviderID
				FROM CareTeamMembers ctm
				INNER JOIN CareTeam ct ON ctm.CareTeamId = ct.CareTeamId
				INNER JOIN ProgramCareTeam pct ON pct.CareTeamId = ct.CareTeamId
				WHERE pct.ProgramId = @i_ProgramID
					AND ctm.StatusCode = 'A'
					AND ct.StatusCode = 'A'

				DECLARE @i_ProgramCnt INT
					,@i_ProviderCnt INT

				SELECT @i_ProgramCnt = COUNT(1)
				FROM PatientProgram
				WHERE ProgramId = @i_ProgramID
					AND ProviderID IS NULL

				SELECT @i_ProviderCnt = COUNT(*)
				FROM #Prov

				DECLARE @i_min INT

				SELECT @i_min = ISNULL(MIN(UserId), 0)
				FROM #Prov

				IF @i_ProviderCnt > 0
				BEGIN
					DECLARE @i_cnt INT

					SELECT @i_cnt = CEILING(CONVERT(DECIMAL(10, 2), @i_ProgramCnt) / CONVERT(DECIMAL(10, 2), @i_ProviderCnt))

					WHILE (@i_min) > 0
					BEGIN
						UPDATE PatientProgram
						SET ProviderID = @i_min
						FROM (
							SELECT TOP (@i_cnt) PatientProgramID UserProgramId
							FROM PatientProgram
							WHERE ProviderID IS NULL
								AND ProgramId = @i_ProgramID
							) x
						WHERE x.UserProgramId = PatientProgram.PatientProgramID
							AND ProviderID IS NULL

						DELETE
						FROM #Prov
						WHERE UserId = @i_min

						SELECT @i_min = isnull(MIN(UserId), 0)
						FROM #Prov
					END
				END
			END
		END

		INSERT INTO PatientCareTeam (
			PatientID
			,CareTeamID
			,ProgramID
			,StatusCode
			,CreatedByUserId
			)
		SELECT DISTINCT ups.PatientID UserId
			,pc.CareTeamId
			,pc.ProgramId
			,'A'
			,@i_AppUserId
		FROM PatientProgram ups
		INNER JOIN ProgramCareTeam pc ON ups.ProgramId = pc.ProgramId
		WHERE ups.ProgramId = @i_ProgramID
			AND NOT EXISTS (
				SELECT 1
				FROM PatientCareTeam uct
				WHERE uct.PatientID = ups.PatientID
					AND uct.CareTeamID = pc.CareTeamId
					AND uct.ProgramID = pc.ProgramId
				)

		UPDATE PatientCareTeam
		SET StatusCode = 'I'
		WHERE NOT EXISTS (
				SELECT 1
				FROM ProgramCareTeam pc
				WHERE pc.CareTeamId = PatientCareTeam.CareTeamID
					AND pc.ProgramId = PatientCareTeam.ProgramID
				)
			AND ProgramID = @i_ProgramID

		IF (@l_TranStarted = 1) -- If transactions are there, then commit
		BEGIN
			SET @l_TranStarted = 0

			COMMIT TRANSACTION
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
    ON OBJECT::[dbo].[usp_Assignment_CareTeamInsert] TO [FE_rohit.r-ext]
    AS [dbo];

