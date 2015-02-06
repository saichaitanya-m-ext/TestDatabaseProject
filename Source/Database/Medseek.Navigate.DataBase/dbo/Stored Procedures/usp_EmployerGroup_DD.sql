
/*  
------------------------------------------------------------------------------  
Procedure Name: usp_EmployerGroup_DD  
Description   : This procedure is used to get the details from EmployerGroup table
Created By    : Rathnam
Created Date  : 07-July-2012
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_EmployerGroup_DD] (@i_AppUserId KEYID)
AS
BEGIN
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

		SELECT DISTINCT TOP 100 EmployerGroupID
			,GroupNumber + '-' + GroupName GroupName
		FROM EmployerGroup
		ORDER BY 2
	END TRY

	--------------------------------------------------------   
	BEGIN CATCH
		-- Handle exception  
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_EmployerGroup_DD] TO [FE_rohit.r-ext]
    AS [dbo];

