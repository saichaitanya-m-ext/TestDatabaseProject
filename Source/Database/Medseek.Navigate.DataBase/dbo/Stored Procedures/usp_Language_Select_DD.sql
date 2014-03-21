
/*
---------------------------------------------------------------------------------
Procedure Name: [usp_Language_Select_DD] 
Description	  : This procedure is used to get all the active languages for Dropdown
Created By    :	NagaBabu
Created Date  : 15-Mar-2011
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Language_Select_DD] (@i_AppUserId KEYID)
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

	---------------- All the Active Language records are retrieved --------
	SELECT LanguageID
		,LanguageName
	FROM CodeSetLanguage
	WHERE StatusCode = 'A'
	ORDER BY LanguageName
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Language_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

