
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_TaskBundleAdhocFrequency_InsertUpdate]        
Description   : This procedure is used to map the adhoc tasks to the taskbundle   
Created By    : Rathnam       
Created Date  : 22-Dec-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
27-Aug-2012 P.V.P.MOHAN ALTERED the DataType  AdhocTaskName column.  
04-APR-2013 P.V.P.MOHAN modified UserProgram Table to PatientProgram in Trigger .  
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_TaskBundleAdhocFrequency_InsertUpdate] --64,1,'dddd','A',2,'d','ffff',null,null
	(
	@i_AppUserId KEYID
	,@i_TaskBundleID KEYID
	,@vc_AdhocTaskName VARCHAR(250)
	,@vc_StatusCode STATUSCODE
	,@i_FrequencyNumber INT = NULL
	,@v_Frequency VARCHAR(1)= NULL
	,@v_Comments VARCHAR(500)
	,@i_TaskBundleAdhocFrequencyID KEYID = NULL
	,@vc_RecurrenceType CHAR(1)
	,@o_TaskBundleAdhocFrequencyID KEYID OUTPUT
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @l_numberOfRecordsInserted INT
			,@i_numberOfRecordsUpdated INT

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

		IF @i_TaskBundleAdhocFrequencyID IS NULL
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM AdhocTask
					WHERE NAME = @vc_AdhocTaskName
					)
			BEGIN
				INSERT INTO AdhocTask (
					NAME
					,StatusCode
					,CreatedByUserId
					)
				VALUES (
					@vc_AdhocTaskName
					,'A'
					,@i_AppUserId
					)
			END

			INSERT INTO TaskBundleAdhocFrequency (
				TaskBundleID
				,AdhocTaskId
				,FrequencyNumber
				,Frequency
				,Comments
				,RecurrenceType
				,StatusCode
				,CreatedByUserId
				,CreatedDate
				)
			SELECT @i_TaskBundleID
				,AdhocTaskId
				,@i_FrequencyNumber
				,@v_Frequency
				,@v_Comments
				,@vc_RecurrenceType
				,@vc_StatusCode
				,@i_AppUserId
				,GETDATE()
			FROM AdhocTask
			WHERE AdhocTask.NAME = @vc_AdhocTaskName

			SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
				,@o_TaskBundleAdhocFrequencyID = SCOPE_IDENTITY()

			IF @l_numberOfRecordsInserted <> 1
			BEGIN
				RAISERROR (
						N'Invalid row count %d in insert TaskBundleAdhocFrequency Table'
						,17
						,1
						,@l_numberOfRecordsInserted
						)
			END
		END
		ELSE
		BEGIN
			IF NOT EXISTS (
					SELECT 1
					FROM AdhocTask
					WHERE NAME = @vc_AdhocTaskName
					)
			BEGIN
				INSERT INTO AdhocTask (
					NAME
					,StatusCode
					,CreatedByUserId
					)
				VALUES (
					@vc_AdhocTaskName
					,'A'
					,@i_AppUserId
					)
			END

			DECLARE @i_AdhocTaskID INT

			SELECT @i_AdhocTaskID = AdhocTaskID
			FROM AdhocTask
			WHERE NAME = @vc_AdhocTaskName

			UPDATE TaskBundleAdhocFrequency
			SET TaskBundleId = @i_TaskBundleID
				,AdhocTaskID = @i_AdhocTaskID
				,FrequencyNumber = @i_FrequencyNumber
				,Frequency = @v_Frequency
				,RecurrenceType = @vc_RecurrenceType
				,StatusCode = @vc_StatusCode
				,LastModifiedDate = GETDATE()
				,LastModifiedByUserId = @i_AppUserId
				,Comments = @v_Comments
				,IsSelfTask = 1
			WHERE TaskBundleAdhocFrequencyID = @i_TaskBundleAdhocFrequencyID

			SET @i_numberOfRecordsUpdated = @@ROWCOUNT

			IF @i_numberOfRecordsUpdated <> 1
			BEGIN
				RAISERROR (
						N'Update of TaskBundleAdhocFrequency table experienced invalid row count of %d'
						,17
						,1
						,@i_numberOfRecordsUpdated
						)
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
    ON OBJECT::[dbo].[usp_TaskBundleAdhocFrequency_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

