
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReportConfiguration_Validation]  
Description   : This procedure is used add the records for the report to the ReportFrequency config table
Created By    : Rathnam  
Created Date  : 14-Aug-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_Validation] --1,1,'20131002',NULL 
	(
	@i_AppUserId KEYID
	,@i_ReportID KEYID
	,@i_AdhocAnchorDate KEYID = NULL
	,@b_IsSchedule BIT = 0
	,@i_ReportFrequencyID INT = NULL
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
			FROM ReportFrequency rf
			INNER JOIN ReportFrequencyDate rfd
				ON rf.ReportFrequencyId = rfd.ReportFrequencyId
			WHERE rf.ReportID = @i_ReportID
				AND LEFT(rfd.AnchorDate, 4) = LEFT(@i_AdhocAnchorDate, 4)
				AND CONVERT(VARCHAR(2), SUBSTRING(CONVERT(VARCHAR(10), rfd.AnchorDate), 5, 2)) = CONVERT(VARCHAR(2), SUBSTRING(CONVERT(VARCHAR(10), @i_AdhocAnchorDate), 5, 2))
				AND rf.FrequencyEndDate > = GETDATE()
				AND ((@i_ReportFrequencyID IS NOT NULL AND rf.ReportFrequencyId <> @i_ReportFrequencyID) OR @i_ReportFrequencyID IS NULL)
			)
	BEGIN
		SET @i_ValidateID = 1 --> Dont Insert the record
	END
	ELSE
	BEGIN
		SET @i_ValidateID = 0
	END
			--IF @b_IsSchedule = 0
			--BEGIN
			--	IF EXISTS (
			--			SELECT 1
			--			FROM ReportFrequency rf WITH(NOLOCK)
			--			WHERE rf.ReportID = @i_ReportID
			--				AND LEFT(DateKey, 4) = LEFT(@i_AdhocAnchorDate, 4)
			--				AND CONVERT(VARCHAR(2), SUBSTRING(CONVERT(VARCHAR(10), DateKey), 5, 2)) = CONVERT(VARCHAR(2), SUBSTRING(CONVERT(VARCHAR(10), @i_AdhocAnchorDate), 5, 2))
			--				AND ((@i_ReportFrequencyID IS NOT NULL AND rf.ReportFrequencyId <> @i_ReportFrequencyID) OR @i_ReportFrequencyID IS NULL)
			--			)
			--	BEGIN
			--		SET @i_ValidateID = 1  --> Dont Insert the record
			--	END
			--	ELSE
			--	BEGIN
			--		SET @i_ValidateID = 0
			--	END
			--END
			--ELSE
			--	IF @b_IsSchedule = 1
			--	BEGIN
			--		IF EXISTS (
			--				SELECT 1
			--				FROM ReportFrequency rf WITH(NOLOCK)
			--				WHERE rf.ReportID = @i_ReportID
			--					AND FrequencyEndDate >= GETDATE()
			--					AND ((@i_ReportFrequencyID IS NOT NULL AND rf.ReportFrequencyId <> @i_ReportFrequencyID) OR @i_ReportFrequencyID IS NULL)
			--				)
			--		BEGIN
			--			SET @i_ValidateID = 1 --> Dont Insert the record
			--		END
			--		ELSE
			--		BEGIN
			--			SET @i_ValidateID = 0
			--		END
			--	E
			
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
    ON OBJECT::[dbo].[usp_MetricReportConfiguration_Validation] TO [FE_rohit.r-ext]
    AS [dbo];

