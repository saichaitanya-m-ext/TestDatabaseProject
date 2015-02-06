
/*    
-----------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_TaskTypeCommunications_Update]    
Description   : This procedure is used to update the data in TaskTypeCommunications table based on     
    TaskTypeID and CommunicationTypeID.    
Created By    : Aditya    
Created Date  : 23-Apr-2010    
------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
27-July-2010 NagaBabu Added TaskTypeID,CommunicationSequence,CommunicationTemplateID,TaskTypeGeneralizedID    
                            to the Update Statement and Modified Where clause also 
02-Aug-2010  NagaBabu Added StatusCode to the Update statement                                
------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_TaskTypeCommunications_Update] (
	@i_AppUserId KeyID
	,@i_TaskTypeCommunicationID KeyID
	,@i_TaskTypeID KeyID
	,@i_CommunicationTypeID KeyID
	,@i_CommunicationSequence INT
	,@i_CommunicationAttemptDays INT
	,@i_NoOfDaysBeforeTaskClosedIncomplete INT
	,@i_CommunicationTemplateID INT
	,@i_TaskTypeGeneralizedID INT
	,@v_StatusCode StatusCode
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed    
	DECLARE @i_numberOfRecordsUpdated INT

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

	------------    Updation operation takes place   --------------------------    
	UPDATE TaskTypeCommunications
	SET TaskTypeID = @i_TaskTypeID
		,CommunicationTypeID = @i_CommunicationTypeID
		,CommunicationSequence = @i_CommunicationSequence
		,CommunicationAttemptDays = @i_CommunicationAttemptDays
		,NoOfDaysBeforeTaskClosedIncomplete = @i_NoOfDaysBeforeTaskClosedIncomplete
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
		,CommunicationTemplateID = @i_CommunicationTemplateID
		,TaskTypeGeneralizedID = @i_TaskTypeGeneralizedID
		,StatusCode = @v_StatusCode
	WHERE
		TaskTypeCommunicationID = @i_TaskTypeCommunicationID

	SET @i_numberOfRecordsUpdated = @@ROWCOUNT

	IF @i_numberOfRecordsUpdated <> 1
	BEGIN
		RAISERROR (
				N'Update of TaskTypeCommunications table experienced invalid row count of %d'
				,17
				,1
				,@i_numberOfRecordsUpdated
				)
	END

	RETURN 0
END TRY

------------ Exception Handling --------------------------------    
BEGIN CATCH
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskTypeCommunications_Update] TO [FE_rohit.r-ext]
    AS [dbo];

