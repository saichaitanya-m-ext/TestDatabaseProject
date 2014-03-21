
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CodeGroupingDetailIntrenal_Delete]  2,2 
Description   : This procedure is used for drop down from CodeGroupingDetailIntrenal table      
       
Created By    : Gurumoorthy v 
Created Date  : 27-May-2013
------------------------------------------------------------------------------        
Log History   :        
DD-MM-YYYY  BY   DESCRIPTION   
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CodeGroupingDetailIntrenal_Delete] (
	@i_AppUserId KEYID
	,@i_CodeGroupingDetailInternallID KEYID = NULL
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

	DELETE
	FROM CodeGroupingDetailInternalHistory
	WHERE CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternallID

	DELETE
	FROM CodeGroupingDetailInternal
	WHERE CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternallID
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
    ON OBJECT::[dbo].[usp_CodeGroupingDetailIntrenal_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

