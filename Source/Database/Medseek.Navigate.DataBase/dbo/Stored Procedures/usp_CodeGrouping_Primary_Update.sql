
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_CodeGrouping_Primary_Update
Description   : This procedure is used to Update  Primary
Created By    : RATHNAM      
Created Date  : 26-jun-2013
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION   
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_CodeGrouping_Primary_Update] (
	@i_AppUserId KEYID
	,@i_CodeGroupingID KEYID
	,@b_IsPrimary BIT
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

	UPDATE CodeGrouping
	SET IsPrimary = @b_IsPrimary
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
	WHERE CodeGroupingID = @i_CodeGroupingID
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
    ON OBJECT::[dbo].[usp_CodeGrouping_Primary_Update] TO [FE_rohit.r-ext]
    AS [dbo];

