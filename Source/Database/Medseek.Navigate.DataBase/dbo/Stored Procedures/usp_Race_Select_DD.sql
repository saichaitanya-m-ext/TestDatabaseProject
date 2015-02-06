
/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Race_Select_DD]
Description	  : This procedure is used to select all the active records from the  
				Race table for the dropdown.
Created By    :	Aditya 
Created Date  : 15-Apr-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Race_Select_DD] (@i_AppUserId KEYID)
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

	---------------- All the Active Race records are retrieved --------
	SELECT RaceId
		,RaceName
		,Description
	FROM CodesetRace
	WHERE StatusCode = 'A'
	ORDER BY RaceName
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Race_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

