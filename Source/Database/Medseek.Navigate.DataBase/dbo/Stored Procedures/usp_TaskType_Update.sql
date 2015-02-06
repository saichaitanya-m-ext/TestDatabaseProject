
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TaskType_Update      
Description   : This procedure is used to Update records in TaskType table  
Created By    : Aditya      
Created Date  : 22-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
16-June-2010 NagaBabu  Added DestinationPage field   
02-Aug-2010 NagaBabu Added AllowSpecificSchedules field to Update Statement 
29-Sep-2010 NagaBabu Deleted DestinationPage in update statement         
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_TaskType_Update] (
	@i_AppUserId KeyID
	,@vc_TaskTypeName SourceName
	,@vc_Description ShortDescription
	,@vc_StatusCode StatusCode
	,@i_ScheduledDays INT
	,@i_TaskTypeId KeyID
	,@vc_DestinationPage VARCHAR(200) = NULL
	,@i_AllowSpecificSchedules IsIndicator
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsUpdated INT

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

	UPDATE TaskType
	SET
		ScheduledDays = @i_ScheduledDays
		,StatusCode = @vc_StatusCode
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
		,AllowSpecificSchedules = @i_AllowSpecificSchedules
	WHERE TaskTypeId = @i_TaskTypeId

	SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT

	IF @l_numberOfRecordsUpdated <> 1
	BEGIN
		RAISERROR (
				N'Invalid Row count %d passed to update TaskType'
				,17
				,1
				,@l_numberOfRecordsUpdated
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
    ON OBJECT::[dbo].[usp_TaskType_Update] TO [FE_rohit.r-ext]
    AS [dbo];

