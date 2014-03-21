
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_AssignmentProgramTaskTypeCommunication_Insert          
Description   : This procedure is used to insert/update record into ProgramTaskTypeCommunication table      
Created By    : Rathnam          
Created Date  : 01-Oct-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
29-Oct-2012 NagaBabu Added ProgramID field in Insert,Update Statements while as it is Mandatory field and Modified 
						@i_TaskTypeId as @vc_TaskType
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_AssignmentTaskTypeCommunications_InsertUpdate] (
	@i_AppUserId KEYID
	,@vc_TaskType CHAR(1) --DeNormalized Due to performance effect
	,@i_ProgramID KEYID --DeNormalized Due to performance effect
	,@i_GeneralizedID KEYID --DeNormalized Due to performance effect
	,@i_CommunicationTypeID KEYID
	,@i_ProgramTaskBundleID KEYID --DeNormalized Due to performance effect
	,@i_CommunicationSequence INT
	,@i_CommunicationAttemptDays INT
	,@i_NoOfDaysBeforeTaskClosedIncomplete INT
	,@i_CommunicationTemplateID INT --,@o_TaskTypeCommunicationID KEYID OUTPUT
	,@v_StatusCode STATUSCODE
	,@i_ProgramTaskTypeCommunicationID KEYID = NULL
	,@v_RemainderState VARCHAR(1)
	--,@t_tblAdhocTaskSchduledAttempts tblAdhocTaskSchduledAttempts READONLY
	)
AS
BEGIN
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

		------------------insert operation into ProgramTaskTypeCommunication table-----        
		IF @i_ProgramTaskTypeCommunicationID IS NULL
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM ProgramTaskTypeCommunication pttc
					WHERE pttc.ProgramTaskBundleID = @i_ProgramTaskBundleID
						AND pttc.NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL
					)
			BEGIN
				UPDATE ProgramTaskTypeCommunication
				SET CommunicationSequence = @i_CommunicationSequence
				WHERE ProgramTaskBundleID = @i_ProgramTaskBundleID
					AND NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL

				SET @i_CommunicationSequence = @i_CommunicationSequence - 1
			END

			INSERT INTO ProgramTaskTypeCommunication (
				ProgramTaskBundleID
				,ProgramID
				,TaskTypeID
				,CommunicationTypeID
				,CommunicationSequence
				,CommunicationAttemptDays
				,NoOfDaysBeforeTaskClosedIncomplete
				,CommunicationTemplateID
				,GeneralizedID
				,CreatedByUserId
				,StatusCode
				,RemainderState
				)
			SELECT @i_ProgramTaskBundleID
				,@i_ProgramID
				,(
					SELECT TaskTypeid
					FROM TaskType
					WHERE TaskTypeName = CASE 
							WHEN @vc_TaskType = 'E'
								THEN 'Patient Education Material'
							WHEN @vc_TaskType = 'O'
								THEN 'Other Tasks'
							WHEN @vc_TaskType = 'P'
								THEN 'Schedule Procedure'
							WHEN @vc_TaskType = 'Q'
								THEN 'Questionnaire'
							END
					)
				,@i_CommunicationTypeID
				,@i_CommunicationSequence
				,@i_CommunicationAttemptDays
				,@i_NoOfDaysBeforeTaskClosedIncomplete
				,@i_CommunicationTemplateID
				,@i_GeneralizedID
				,@i_AppUserId
				,@v_StatusCode
				,@v_RemainderState

			SELECT @l_numberOfRecordsInserted = @@ROWCOUNT

			--,@o_TaskTypeCommunicationID = SCOPE_IDENTITY()
			IF @l_numberOfRecordsInserted <> 1
			BEGIN
				RAISERROR (
						N'Invalid row count %d in insert ProgramTaskTypeCommunication'
						,17
						,1
						,@l_numberOfRecordsInserted
						)
			END
		END
		ELSE
		BEGIN
			IF @i_ProgramTaskTypeCommunicationID IS NOT NULL
			BEGIN
				DECLARE @i_numberOfRecordsUpdated INT

				UPDATE ProgramTaskTypeCommunication
				SET CommunicationTypeID = @i_CommunicationTypeID
					,CommunicationSequence = @i_CommunicationSequence
					,CommunicationAttemptDays = @i_CommunicationAttemptDays
					,NoOfDaysBeforeTaskClosedIncomplete = @i_NoOfDaysBeforeTaskClosedIncomplete
					,LastModifiedByUserId = @i_AppUserId
					,LastModifiedDate = GETDATE()
					,CommunicationTemplateID = @i_CommunicationTemplateID
					,StatusCode = @v_StatusCode
				WHERE ProgramTaskTypeCommunicationID = @i_ProgramTaskTypeCommunicationID

				SET @i_numberOfRecordsUpdated = @@ROWCOUNT

				IF @i_numberOfRecordsUpdated <> 1
				BEGIN
					RAISERROR (
							N'Update of ProgramTaskTypeCommunication table experienced invalid row count of %d'
							,17
							,1
							,@i_numberOfRecordsUpdated
							)
				END
			END
		END

		RETURN 0
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
    ON OBJECT::[dbo].[usp_AssignmentTaskTypeCommunications_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

