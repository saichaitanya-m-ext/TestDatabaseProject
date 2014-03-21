
/*    
-------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_Metricdocument_InsertUpdate]    
Description   : This procedure is used to insert and Update records into Metricdocument table    
  
Created By    : P.V.P.Mohan   
Created Date  : 05-DEC-2012    
-------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
-------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Metricdocument_InsertUpdate] (
	@i_AppUserId KEYID
	,@i_MetricsId KEYID = NULL
	,@v_FileName VARCHAR(500)
	,@i_eDocument VARBINARY(MAX)
	,@vc_MimeType VARCHAR(20)
	)
AS
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

	------------------insert operation into Metrics table-----     
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
	FROM MetricDocument
	WHERE MetricId = @i_MetricsId

	INSERT INTO MetricDocument (
		MetricId
		,FileName
		,eDocument
		,MimeType
		,CreatedByUserId
		)
	VALUES (
		@i_MetricsId
		,@v_FileName
		,@i_eDocument
		,@vc_MimeType
		,@i_AppUserId
		)

	
	IF (@l_TranStarted = 1) -- If transactions are there, then commit
	BEGIN
		SET @l_TranStarted = 0

		COMMIT TRANSACTION
	END
END TRY

------------------------------------------------------------------------------------------------------------------------------  
BEGIN CATCH
	-- Handle exception    
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Metricdocument_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

