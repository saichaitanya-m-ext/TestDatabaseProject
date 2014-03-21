
/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_EncounterType_Select_DD]
Description	  : This procedure is used to select all the active EncounterTypes for  
				the EncounterType dropdown.
Created By    :	Aditya 
Created Date  : 22-Apr-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
05-May-2011 Rathnam added IsEncounterdateMandatory one more column to the select statement.
----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_EncounterType_Select_DD] (@i_AppUserId KEYID)
AS
BEGIN TRY
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

	---------------- All the Active Encounter Type are retrieved --------
	SELECT EncounterTypeId
		,NAME
		,IsEncounterdateMandatory
	FROM EncounterType
	WHERE StatusCode = 'A'
	ORDER BY SortOrder
		,NAME
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_EncounterType_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

