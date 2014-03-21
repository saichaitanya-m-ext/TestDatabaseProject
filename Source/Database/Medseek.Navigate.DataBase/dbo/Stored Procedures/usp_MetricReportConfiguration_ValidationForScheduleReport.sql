
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReportConfiguration_ValidationForScheduleReport]  
Description   : This procedure is used add the records for the report to the ReportFrequency config table
Created By    : Rathnam  
Created Date  : 14-Aug-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_ValidationForScheduleReport] --1,1,'20131002',NULL 
	(
	@i_AppUserId KEYID
	,@i_ReportID KEYID
	,@v_Frequency VARCHAR(1)
	,@d_EndDate DATETIME
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

	DECLARE @i_Month INT = MONTH(GETDATE())
		,@d_StartDate DATETIME

	SELECT @d_StartDate = CASE 
			WHEN @v_Frequency = 'Q'
				THEN CASE 
						WHEN @i_Month BETWEEN 1
								AND 3
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '03' + '01'))
						WHEN @i_Month BETWEEN 4
								AND 6
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '06' + '01'))
						WHEN @i_Month BETWEEN 7
								AND 9
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '09' + '01'))
						WHEN @i_Month BETWEEN 10
								AND 12
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '12' + '01'))
						END
			WHEN @v_Frequency = 'H'
				THEN CASE 
						WHEN @i_Month BETWEEN 1
								AND 6
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '06' + '01'))
						WHEN @i_Month BETWEEN 7
								AND 12
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '12' + '01'))
						END
			WHEN @v_Frequency = 'Y'
				THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '12' + '01'))
			WHEN @v_Frequency = 'M'
				THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('00'+ CAST(MONTH(GETDATE()) AS VARCHAR(4)),2) + '01'))
			END

	IF EXISTS (
			SELECT 1
			FROM ReportFrequency rf WITH(NOLOCK)
			INNER JOIN ReportFrequencyDate rfd WITH(NOLOCK)
				ON rfd.ReportFrequencyId = rf.ReportFrequencyId
			WHERE rfd.AnchorDate IN (
					SELECT t.DateKey
					FROM [dbo].[udf_GetDateKeys](@d_StartDate, @d_EndDate, @v_Frequency) t
					)
				AND rf.ReportID = @i_ReportID
				AND rf.FrequencyEndDate > = GETDATE()
			)
	BEGIN
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
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
    ON OBJECT::[dbo].[usp_MetricReportConfiguration_ValidationForScheduleReport] TO [FE_rohit.r-ext]
    AS [dbo];

