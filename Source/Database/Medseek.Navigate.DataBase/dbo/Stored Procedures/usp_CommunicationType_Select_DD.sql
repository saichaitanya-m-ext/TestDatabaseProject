
/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_CommunicationType_Select_DD  
Description   : This procedure is used to get the list for the Dropdown for CommunicationType.
Created By    : Aditya
Created Date  : 06-May-2010  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
29-Sep-2010 NagaBabu Deleted SortOrder from order by clause  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CommunicationType_Select_DD] (@i_AppUserId INT)
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

	-------------------------------------------------------- 
	SELECT CommunicationTypeId
		,CommunicationType
	FROM CommunicationType
	WHERE StatusCode = 'A'
	ORDER BY CommunicationType
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
    ON OBJECT::[dbo].[usp_CommunicationType_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

