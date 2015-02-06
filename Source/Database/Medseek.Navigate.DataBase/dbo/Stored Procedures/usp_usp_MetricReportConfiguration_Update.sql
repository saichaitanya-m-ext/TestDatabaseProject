
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_usp_MetricReportConfiguration_Update]  
Description   : This procedure is used add the records for the report to the ReportFrequency config table
Created By    : Rathnam  
Created Date  : 14-Aug-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_usp_MetricReportConfiguration_Update] 
	(
	@i_AppUserId KEYID
	,@i_ReportFrequencyId INT = NULL
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

	UPDATE ReportFrequency
	SET IsReadyForETL = 1
	WHERE ReportFrequencyId = @i_ReportFrequencyId
END TRY

-------------------------------------------------------------------------------------------------
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_usp_MetricReportConfiguration_Update] TO [FE_rohit.r-ext]
    AS [dbo];

