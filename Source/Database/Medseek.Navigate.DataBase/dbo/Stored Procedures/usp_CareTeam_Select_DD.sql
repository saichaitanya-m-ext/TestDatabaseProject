
/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_CareTeam_Select_DD]
Description	  : This procedure is used to select all the active CareTeam records for  
				careteam dropdown.
Created By    :	Aditya 
Created Date  : 14-Apr-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
09-Jan-2012 Rathnam added @v_CareTeamName parameter
----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_CareTeam_Select_DD] (
	@i_AppUserId KEYID
	,@v_CareTeamName VARCHAR(20) = NULL
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

	---------------- All the Active CareTeam records are retrieved --------
	SELECT CareTeamId
		,CareTeamName
		,Description
	FROM CareTeam
	WHERE StatusCode = 'A'
		AND (
			CareTeamName LIKE '%' + @v_CareTeamName + '%'
			OR @v_CareTeamName IS NULL
			)
	ORDER BY CareTeamName
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeam_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

