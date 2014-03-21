
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReportConfiguration_CheckByReport]  
Description   : This procedure is used to not to insert the duplicate records based on reportid
                It should has either adhoc/schedule
Created By    : Rathnam  
Created Date  : 15-Oct-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_CheckByReport] 
	(
	@i_AppUserId KEYID
	,@i_ReportID KEYID
	,@i_ValidateID KEYID OUTPUT
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

	IF EXISTS (
			SELECT 1
			FROM ReportFrequency rf WITH (NOLOCK)
			WHERE rf.ReportID = @i_ReportID
				AND FrequencyEndDate >= GETDATE()
			)
	BEGIN
		SET @i_ValidateID = 1 --> Dont Insert the record
	END
	ELSE
	BEGIN
		SET @i_ValidateID = 0
	END
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
    ON OBJECT::[dbo].[usp_MetricReportConfiguration_CheckByReport] TO [FE_rohit.r-ext]
    AS [dbo];

