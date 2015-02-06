
/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_MetricDocument_Select]1,1  
Description   : This Procedure used to Get the Documents based on MetricDocument
Created By    : Gurumoorthy
Created Date  : 13-Dec-2012  
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION   
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_MetricDocument_Select] (
	@i_AppUserId KEYID
	,@i_MetricId KEYID
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
	SELECT MetricId
		,FileName
		,eDocument
		,MimeType
	FROM MetricDocument
	WHERE MetricId = @i_MetricId
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
    ON OBJECT::[dbo].[usp_MetricDocument_Select] TO [FE_rohit.r-ext]
    AS [dbo];

