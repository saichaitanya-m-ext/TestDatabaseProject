
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReport_ETLStatus]  
Description   :
Created By    : Rathnam  
Created Date  : 21-Oct-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MetricReport_ETLStatus] (@i_AppUserId KEYID)
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

	IF EXISTS (
			SELECT 1
			FROM Report r
			WHERE ISNULL(r.IsProcessing, 0) = 1
			)
	BEGIN
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MetricReport_ETLStatus] TO [FE_rohit.r-ext]
    AS [dbo];

