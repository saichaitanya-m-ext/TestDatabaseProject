
/*  
------------------------------------------------------------------------------  
Procedure Name:   [Usp_CodeGroupingClone_DrawFromLibrary]
Description   : This procedure is used to Insert the details into CodeGroupingDetailIntrenal table
Created By    : Gurumoorthy V  
Created Date  : 22-May-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[Usp_CodeGroupingClone_DrawFromLibrary] (
	@i_AppUserId KEYID
	,@i_OldCodeGroupingID KEYID
	,@i_NewCodeGroupingID KEYID
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
				,24
				,@i_AppUserId
				)
	END

	INSERT INTO CodeGroupingDetailInternal (
		CodeGroupingID
		,CodeGroupingCodeTypeID
		,CodeGroupingCodeID
		,CreatedByUserId
		,CreatedDate
		)
	SELECT DISTINCT @i_NewCodeGroupingID
		,CodeGroupingCodeTypeID
		,CodeGroupingCodeID
		,@i_AppUserId
		,GETDATE()
	FROM CodeGroupingDetailInternal
	WHERE CodeGroupingID = @i_OldCodeGroupingID
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
    ON OBJECT::[dbo].[Usp_CodeGroupingClone_DrawFromLibrary] TO [FE_rohit.r-ext]
    AS [dbo];

