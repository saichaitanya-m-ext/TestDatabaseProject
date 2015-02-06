/*          
------------------------------------------------------------------------------          
Procedure Name: usp_CodeGrouping_VersionHistory          
Description   : This procedure is used to get the history of codegrouping
Created By    : Rathnam
Created Date  : 30-May-2013  
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_CodeGrouping_VersionHistory] (
	@i_AppUserId KEYID
	,@i_CodeGroupingID KEYID
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

	SELECT DefinitionVersion
		,dbo.ufn_GetUserNameByID(CreatedByUserId) AS ModifiedBy
		,CreatedDate ModifiedDate
		,'' ModificationDescription
	FROM CodeGroupingHistory
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
    ON OBJECT::[dbo].[usp_CodeGrouping_VersionHistory] TO [FE_rohit.r-ext]
    AS [dbo];

