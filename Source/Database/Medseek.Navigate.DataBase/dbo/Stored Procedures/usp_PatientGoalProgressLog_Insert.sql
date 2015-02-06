
/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_PatientGoalProgressLog_Insert]
Description   : This Procedure used to insert data into PatientGoalProgressLog table
Created By    : NagaBabu
Created Date  : 29-Feb-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_PatientGoalProgressLog_Insert] (
	@i_AppUserId KEYID
	,@i_PatientGoalId KEYID
	,@t_PatientActivity PatientGoalProgress READONLY
	,@d_FollowUpDate UserDate
	,@d_FollowUpCompleteDate UserDate
	,@o_PatientGoalProgressLogId KEYID OUTPUT
	,@b_IsAdhoc BIT
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

	------------------insert operation into PatientGoalProgressLog table-----        
	DECLARE @TranStarted BIT = 0

	IF (@@TRANCOUNT = 0)
	BEGIN
		BEGIN TRANSACTION

		SET @TranStarted = 1
	END
	ELSE
		SET @TranStarted = 0

	INSERT INTO PatientGoalProgressLog (
		PatientGoalId
		,PatientActivityId
		,ProgressPercentage
		,FollowUpDate
		,FollowUpCompleteDate
		,Comments
		,StatusCode
		,CreatedByUserId
		,AttemptedContactDate
		,ActivityCompletedDate
		,IsAdhoc
		)
	SELECT @i_PatientGoalId
		,PatientActivityId
		,ProgressPercentage
		,@d_FollowUpDate
		,@d_FollowUpCompleteDate
		,NULL
		,'A'
		,@i_AppUserId
		,NULL
		,NULL
		,@b_IsAdhoc
	FROM @t_PatientActivity

	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		,@o_PatientGoalProgressLogId = SCOPE_IDENTITY()

	IF @l_numberOfRecordsInserted < 1
	BEGIN
		RAISERROR (
				N'Invalid row count %d in insert PatientGoalProgressLog'
				,17
				,1
				,@l_numberOfRecordsInserted
				)
	END

	UPDATE PatientActivity
	SET ProgressPercentage = TPA.ProgressPercentage
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
	FROM @t_PatientActivity TPA
	INNER JOIN PatientActivity ON TPA.PatientActivityId = PatientActivity.PatientActivityId
		AND PatientActivity.PatientGoalId = @i_PatientGoalId

	IF (@TranStarted = 1)
	BEGIN
		SET @TranStarted = 0

		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientGoalProgressLog_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

