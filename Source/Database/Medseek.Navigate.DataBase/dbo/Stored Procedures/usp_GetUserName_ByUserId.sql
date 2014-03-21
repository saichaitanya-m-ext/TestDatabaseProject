
/*  
---------------------------------------------------------------------------------  
Procedure Name:[usp_GetUserCreateBy_UserId] 2,2  
Description   : This procedure is used to get the Updated by ,Created by Username
Created By    : Gurumoorthy
Created Date  : 03-20-2013  
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_GetUserName_ByUserId] (
	@i_AppUserId KEYID
	,@i_UserId KEYID
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

	SELECT dbo.ufn_GetUserNameByID(@i_UserId) AS UserName
END TRY

BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_GetUserName_ByUserId] TO [FE_rohit.r-ext]
    AS [dbo];

