﻿
/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_StandardOrganization_DD]1,1  
Description   : This Procedure used to Get the standards based on Standardorganzaiton id  
Created By    : Rathnam  
Created Date  : 30-Nov-2012  
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION   
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_StandardOrganization_DD] (
	@i_AppUserId KEYID
	,@i_StandardOrganziationID KEYID
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

	--------------------------------------------------------------------  
	SELECT StandardId
		,NAME
		,StandardOrganizationId
	FROM Standard
	WHERE Standard.StatusCode = 'A'
		AND Standard.StandardOrganizationId = @i_StandardOrganziationID
	ORDER BY NAME
END TRY

---------------------------------------------------------------------     
BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_StandardOrganization_DD] TO [FE_rohit.r-ext]
    AS [dbo];

