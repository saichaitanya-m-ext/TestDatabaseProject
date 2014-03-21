
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_CodeGroupingDetailIntrenal_Insert        
Description   : This procedure is used to insert record into CodeGroupingDetailIntrenal table    
Created By    : P.V.P.Mohan
Created Date  : 27-May-2013
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CodeGroupingDetailIntrenal_Insert] (
	@i_AppUserId KEYID
	,@i_CodeGroupingID KEYID
	,@i_CodeGroupingCodeTypeID KEYID
	,@t_CodeGroupingCodeID TTYPEKEYID READONLY
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

	---------insert operation into CodeGroupingDetailIntrenal table-----       
	INSERT INTO CodeGroupingDetailInternal (
		CodeGroupingID
		,CodeGroupingCodeTypeID
		,CodeGroupingCodeID
		,StatusCode
		,CreatedByUserId
		,CreatedDate
		)
	SELECT @i_CodeGroupingID
		,@i_CodeGroupingCodeTypeID
		,CodeGroup.tKeyId
		,'A'
		,@i_AppUserId
		,GETDATE()
	FROM @t_CodeGroupingCodeID CodeGroup
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
    ON OBJECT::[dbo].[usp_CodeGroupingDetailIntrenal_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

