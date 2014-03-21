
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_TaskBundleEducationMaterial_InsertUpdate]        
Description   : This procedure is used to map the Drugs to a taskbundle    
Created By    : Rathnam       
Created Date  : 22-Dec-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
18-Jan-2012 NagaBabu Added IF (SELECT COUNT(*) FROM @tblCommunication) >= 1  
21-Jan-2012 NagaBabu Added @i_TaskBundleCommunicationScheduleID as input parameter
4-APR-2013 Mohan modified UserProgram table to PatientProgram in Trigger    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_TaskBundlePatientEducationMaterial_InsertUpdate] --64,5,'Asthma','A',null,null
	(
	@i_AppUserId KEYID
	,@i_TaskBundleID KEYID
	,@v_PEMName VARCHAR(250)
	,@v_Comments VARCHAR(1000)
	,@tblLibraryID TTYPEKEYID READONLY
	,@vc_StatusCode STATUSCODE
	,@i_TaskBundleEducationMaterialID KEYID = NULL
	,@o_TaskBundleEducationMaterialID KEYID OUTPUT
	,@i_EducationMaterialID INT = NULL
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @l_numberOfRecordsInserted INT
			,@i_numberOfRecordsUpdated INT
			,@o_EducationMaterialID INT

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

		IF @i_TaskBundleEducationMaterialID IS NULL
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM EducationMaterial
					WHERE NAME = @v_PEMName
					)
			BEGIN
				INSERT INTO EducationMaterial (
					NAME
					,StatusCode
					,CreatedByUserId
					)
				VALUES (
					@v_PEMName
					,@vc_StatusCode
					,@i_AppUserId
					)
			END

			INSERT INTO EducationMaterialLibrary (
				EducationMaterialID
				,LibraryId
				,CreatedByUserId
				,TaskBundleID
				)
			SELECT (
					SELECT EducationMaterialID
					FROM EducationMaterial
					WHERE NAME = @v_PEMName
					)
				,tKeyId
				,@i_AppUserId
				,@i_TaskBundleID
			FROM @tblLibraryID

			INSERT INTO TaskBundleEducationMaterial (
				TaskBundleId
				,EducationMaterialId
				,StatusCode
				,CreatedByUserId
				,Comments
				)
			VALUES (
				@i_TaskBundleID
				,(
					SELECT EducationMaterialID
					FROM EducationMaterial
					WHERE NAME = @v_PEMName
					)
				,@vc_StatusCode
				,@i_AppUserId
				,@v_Comments
				)
		END
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM EducationMaterial
					WHERE NAME = @v_PEMName
					)
			BEGIN
				INSERT INTO EducationMaterial (
					NAME
					,StatusCode
					,CreatedByUserId
					)
				VALUES (
					@v_PEMName
					,@vc_StatusCode
					,@i_AppUserId
					)
			END
			ELSE
			BEGIN
				UPDATE EducationMaterial
				SET StatusCode = @vc_StatusCode
					,LastModifiedByUserId = @i_AppUserId
					,LastModifiedDate = GETDATE()
				WHERE EducationMaterialID = (
						SELECT EducationMaterialID
						FROM EducationMaterial
						WHERE NAME = @v_PEMName
						)
			END

			DELETE
			FROM EducationMaterialLibrary
			WHERE EducationMaterialID = (
					SELECT EducationMaterialID
					FROM EducationMaterial
					WHERE NAME = @v_PEMName
					)
				AND LibraryId NOT IN (
					SELECT tKeyId
					FROM @tblLibraryID
					)
				AND TaskBundleID = @i_TaskBundleID

			DECLARE @i_NewEducationMaterialID INT

			SELECT @i_NewEducationMaterialID = EducationMaterialID
			FROM EducationMaterial
			WHERE NAME = @v_PEMName

			INSERT INTO EducationMaterialLibrary (
				EducationMaterialID
				,LibraryId
				,CreatedByUserId
				,TaskBundleID
				)
			SELECT @i_NewEducationMaterialID
				,tKeyId
				,@i_AppUserId
				,@i_TaskBundleID
			FROM @tblLibraryID
			WHERE NOT EXISTS (
					SELECT 1
					FROM EducationMaterialLibrary
					WHERE EducationMaterialLibrary.LibraryId = tKeyId
						AND EducationMaterialID = @i_NewEducationMaterialID
						AND TaskBundleID = @i_TaskBundleID
					)

			UPDATE TaskBundleEducationMaterial
			SET EducationMaterialID = @i_NewEducationMaterialID
				,StatusCode = @vc_StatusCode
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
				,Comments = @v_Comments
				,IsSelfTask = 1
			WHERE TaskBundleEducationMaterialID = @i_TaskBundleEducationMaterialID
		END

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
    ON OBJECT::[dbo].[usp_TaskBundlePatientEducationMaterial_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

