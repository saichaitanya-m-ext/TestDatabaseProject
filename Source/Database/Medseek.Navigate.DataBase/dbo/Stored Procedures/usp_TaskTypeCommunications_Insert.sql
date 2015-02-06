
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_TaskTypeCommunications_Insert          
Description   : This procedure is used to insert record into TaskTypeCommunications table      
Created By    : Aditya          
Created Date  : 23-Apr-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
27-July-2010 NagaBabu Added CommunicationTemplateID,TaskTypeGeneralizedID Fields   
                            And TaskTypeCommunicationID AS OUTPUT perameter 
02-Aug-2010  NagaBabu Added StatusCode to the insert statement                                      
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_TaskTypeCommunications_Insert] (
	@i_AppUserId KEYID
	,@i_TaskTypeID KeyID
	,@i_CommunicationTypeID KeyID
	,@i_CommunicationSequence INT
	,@i_CommunicationAttemptDays INT
	,@i_NoOfDaysBeforeTaskClosedIncomplete INT
	,@i_CommunicationTemplateID INT
	,@i_TaskTypeGeneralizedID INT
	,@o_TaskTypeCommunicationID KeyID OUTPUT
	,@v_StatusCode StatusCode
	,@v_RemainderState VARCHAR(1)
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

	------------------insert operation into TaskTypeCommunications table-----        
	INSERT INTO TaskTypeCommunications (
		TaskTypeID
		,CommunicationTypeID
		,CommunicationSequence
		,CommunicationAttemptDays
		,NoOfDaysBeforeTaskClosedIncomplete
		,CommunicationTemplateID
		,TaskTypeGeneralizedID
		,CreatedByUserId
		,StatusCode
		,RemainderState
		)
	VALUES (
		@i_TaskTypeID
		,@i_CommunicationTypeID
		,@i_CommunicationSequence
		,@i_CommunicationAttemptDays
		,@i_NoOfDaysBeforeTaskClosedIncomplete
		,@i_CommunicationTemplateID
		,@i_TaskTypeGeneralizedID
		,@i_AppUserId
		,@v_StatusCode
		,@v_RemainderState
		)

	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		,@o_TaskTypeCommunicationID = SCOPE_IDENTITY()

	IF @l_numberOfRecordsInserted <> 1
	BEGIN
		RAISERROR (
				N'Invalid row count %d in insert TaskTypeCommunications'
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
    ON OBJECT::[dbo].[usp_TaskTypeCommunications_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

