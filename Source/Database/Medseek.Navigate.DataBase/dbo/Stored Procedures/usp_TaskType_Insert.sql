
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TaskType_Insert      
Description   : This procedure is used to insert record into TaskType table  
Created By    : Aditya      
Created Date  : 22-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
16-June-2010 NagaBabu  Added DestinationPage field  
28-July-2010 NagaBabu Added AllowSpecificSchedules field to Insert Statement      
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_TaskType_Insert] (
	@i_AppUserId KeyID
	,@vc_TaskTypeName SourceName
	,@vc_Description ShortDescription
	,@vc_StatusCode StatusCode
	,@i_ScheduledDays INT
	,@vc_DestinationPage VARCHAR(200) = NULL
	,@i_AllowSpecificSchedules IsIndicator
	,@o_TaskTypeId KeyID OUTPUT
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

	INSERT INTO TaskType (
		TaskTypeName
		,Description
		,ScheduledDays
		,StatusCode
		,CreatedByUserId
		,DestinationPage
		,AllowSpecificSchedules
		)
	VALUES (
		@vc_TaskTypeName
		,@vc_Description
		,@i_ScheduledDays
		,@vc_StatusCode
		,@i_AppUserId
		,@vc_DestinationPage
		,@i_AllowSpecificSchedules
		)

	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		,@o_TaskTypeId = SCOPE_IDENTITY()

	IF @l_numberOfRecordsInserted <> 1
	BEGIN
		RAISERROR (
				N'Invalid row count %d in insert TaskType'
				,17
				,1
				,@l_numberOfRecordsInserted
				)
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
    ON OBJECT::[dbo].[usp_TaskType_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

