
/*      
-----------------------------------------------------------------------------------------------      
Procedure Name: [dbo].[usp_TaskTypeCommunications_UpdateStatusCode]      
Description   : This procedure is used to update the Status code in TaskTypeCommunications table based on       
    TaskTypeID and generalizedid
Created By    : Pramod
Created Date  : 9-Aug-2010      
------------------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION   
27-Sep-2010 NagaBabu Modified @i_numberOfRecordsUpdated = 0 by  < 1   
------------------------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_TaskTypeCommunications_UpdateStatusCode] (
	@i_AppUserId KeyID
	,@i_TaskTypeID KeyID
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
	SET StatusCode = @v_StatusCode
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
	WHERE TaskTypeID = @i_TaskTypeID
		AND TaskTypeGeneralizedID = @i_TaskTypeGeneralizedID

	SET @i_numberOfRecordsUpdated = @@ROWCOUNT

	IF @i_numberOfRecordsUpdated < 1
	BEGIN
		RAISERROR (
				N'Update of TaskTypeCommunications table Status field experienced invalid row count of %d'
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
    ON OBJECT::[dbo].[usp_TaskTypeCommunications_UpdateStatusCode] TO [FE_rohit.r-ext]
    AS [dbo];

