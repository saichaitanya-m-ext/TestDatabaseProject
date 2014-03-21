
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReportConfiguration_Search] 1 , null, null,null,'i'
Description   : This procedure is used to fetch all the reports with their status
Created By    : Rathnam  
Created Date  : 03-Oct-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_Search] (
	@i_AppUserId KEYID
	,@i_ReportID KEYID = NULL
	,@b_IsSchedule BIT = NULL
	,@b_IsReadyForETL BIT = NULL
	,@v_Status VARCHAR(1) = 'A'
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

	SELECT rf.ReportFrequencyId
		,r.ReportId
		,r.AliasName AS ReportName
		,CASE 
			WHEN Frequency IS NULL
				AND DateKey IS NOT NULL
				THEN 'Adhoc'
			WHEN Frequency IS NOT NULL
				AND DateKey IS NULL
				THEN 'Scheduled'
			END AS ReportType
		,CONVERT(VARCHAR(10), rf.StartDate, 101) StartDate
		,CONVERT(VARCHAR(10), rf.FrequencyEndDate, 101) FrequencyEndDate
		,CASE 
			WHEN rf.Frequency IS NULL
				THEN CONVERT(VARCHAR(10), CONVERT(DATE, CONVERT(VARCHAR(4), LEFT(rf.DateKey, 4)) + '-' + CONVERT(VARCHAR(2), SUBSTRING(CONVERT(VARCHAR(10), rf.DateKey), 5, 2)) + '-' + CONVERT(VARCHAR(2), RIGHT(rf.DateKey, 2))), 101)
			ELSE CONVERT(VARCHAR(10), CONVERT(DATE, (
							SELECT LEFT(CONVERT(VARCHAR(8), MIN(AnchorDate)), 4) + '-' + SUBSTRING(CONVERT(VARCHAR(8), MIN(AnchorDate)), 5, 2) + '-' + RIGHT(CONVERT(VARCHAR(8), MIN(AnchorDate)), 2)
							FROM ReportFrequencyDate rfd WITH (NOLOCK)
							WHERE rfd.ReportFrequencyId = RF.ReportFrequencyId
								AND ISNULL(rfd.IsETLCompleted, 0) = 0
							)), 101)
			END AS DateKey
		,CASE 
			WHEN rf.Frequency = 'Y'
				THEN 'Annually'
			WHEN rf.Frequency = 'M'
				THEN 'Monthly'
			WHEN rf.Frequency = 'Q'
				THEN 'Quarterly'
			WHEN rf.Frequency = 'H'
				THEN 'Half-Yearly'
			END Frequency
		,CASE 
			WHEN @v_Status = 'I'
				THEN 'InActive'
			ELSE ISNULL(rf.ReportStatus, 'Active')
			END ReportStatus
		,CASE 
			WHEN rf.IsReadyForETL = 0
				THEN 'NO'
			ELSE 'YES'
			END IsReadyForETL
		,CONVERT(VARCHAR(10), CONVERT(DATE, (
					SELECT LEFT(CONVERT(VARCHAR(8), MAX(AnchorDate)), 4) + '-' + SUBSTRING(CONVERT(VARCHAR(8), MAX(AnchorDate)), 5, 2) + '-' + RIGHT(CONVERT(VARCHAR(8), MAX(AnchorDate)), 2)
					FROM ReportFrequencyDate rfd
					INNER JOIN ReportFrequency rf2 
					ON rf2.ReportFrequencyId = rfd.ReportFrequencyId
					WHERE rf2.ReportID = rf.ReportID
						AND rfd.IsETLCompleted = 1
					)), 101) LastEtlDate
		--,CONVERT(VARCHAR(10), rf.LastEtlDate, 101) LastEtlDate
		,dbo.ufn_GetProviderName(rf.CreatedByUserId) AS CreatedByUserName
		,CONVERT(VARCHAR(10), rf.CreatedDate, 101) CreatedDate
		,dbo.ufn_GetProviderName(rf.LastModifiedByUserId) AS ModifiedByUserName
		,CONVERT(VARCHAR(10), rf.LastModifiedDate, 101) LastModifiedDate
	FROM ReportFrequency rf
	INNER JOIN Report r
		ON r.ReportId = rf.ReportID
	WHERE (
			r.ReportId = @i_ReportID
			OR @i_ReportID IS NULL
			)
		AND (
			(
				rf.Frequency IS NOT NULL
				AND @b_IsSchedule = 1
				)
			OR (
				rf.Frequency IS NULL
				AND @b_IsSchedule = 0
				)
			OR @b_IsSchedule IS NULL
			)
		AND (
			rf.IsReadyForETL = @b_IsReadyForETL
			OR @b_IsReadyForETL IS NULL
			)
		AND (
			(
				DATEDIFF(dd, getdate(), rf.FrequencyEndDate) < 0
				AND @v_Status = 'I'
				AND rf.FrequencyEndDate IS NOT NULL
				)
			OR (
				@v_Status = 'A'
				AND (
					(
						DATEDIFF(dd, getdate(), rf.FrequencyEndDate) >= 0
						AND rf.FrequencyEndDate IS NOT NULL
						)
					OR rf.FrequencyEndDate IS NULL
					)
				)
			)
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
    ON OBJECT::[dbo].[usp_MetricReportConfiguration_Search] TO [FE_rohit.r-ext]
    AS [dbo];

