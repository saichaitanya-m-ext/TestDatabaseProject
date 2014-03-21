
/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_usercommunication_ByUserCommunicationId] 2,1
Description	  : This procedure is used to get the details of usercommunication .
Created By    :	Gurumoorthy.V 
Created Date  : 16-Mar-2012
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_usercommunication_ByUserCommunicationId] (
	@i_AppUserId KEYID
	,@i_UserCommunicationId KEYID
	)
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

	----------- Select all the usercommunication details ---------------
	SELECT communicationtext
	FROM PatientCommunication
	WHERE PatientCommunicationId = @i_UserCommunicationId
END TRY

---------------------------------------------------------------------------------------------------------------
BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_usercommunication_ByUserCommunicationId] TO [FE_rohit.r-ext]
    AS [dbo];

