
/*
------------------------------------------------------------------------------
Procedure Name: [dbo].[Usp_CommunicationType_Select_All]
Description	  : This procedure is used to select the communication type data.
Created By    :	Aditya 
Created Date  : 07-Jan-2010
------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

-------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_CommunicationType_Select_All] @i_AppUserId KEYID
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

	---------------- All the Active communication types are retrieved --------
	SELECT CommunicationTypeId
		,CommunicationType
		,Description
		,SortOrder
		,CreatedByUserId
		,CreatedDate
		,LastModifiedByUserId
		,LastModifiedDate
		,StatusCode
	FROM CommunicationType
	ORDER BY SortOrder
		,CommunicationType
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CommunicationType_Select_All] TO [FE_rohit.r-ext]
    AS [dbo];

