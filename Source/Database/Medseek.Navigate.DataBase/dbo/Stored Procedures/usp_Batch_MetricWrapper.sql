/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_MetricWrapper]  
Description   : This proc is used to extract the data from CodeGroupers OR Hedis tables 
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_MetricWrapper] --1,20121130
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8) = NULL
	,@i_MetricID KEYID = NULL
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

	IF NOT EXISTS (
			SELECT 1
			FROM PopulationDefinitionConfiguration pdc
			WHERE ISNULL(IsConflictParameter, 0) = 1
			)
	BEGIN
		DECLARE @i_MetricID1 Keyid
			,@v_DateKey1 VARCHAR(8)
			,@b_IsStandard BIT
		DECLARE @t_Metric TABLE (
			ID INT IDENTITY(1, 1)
			,MetricID INT
			,AnchorDate INT
			,IsStandard BIT
			)

		IF @v_DateKey IS NULL
		BEGIN -- This is for Automated metrics
			INSERT INTO @t_Metric
			SELECT DISTINCT m.MetricId
				,t.AnchorDate
				,CASE 
					WHEN pdc.NrProcName IS NOT NULL
						THEN 1
					ELSE 0
					END IsStandard
			FROM ReportFrequencyConfiguration rfc
			INNER JOIN (
				SELECT rf.ReportFrequencyId
					,rfd.AnchorDate AnchorDate
				FROM ReportFrequency rf WITH (NOLOCK)
				INNER JOIN ReportFrequencyDate rfd WITH (NOLOCK)
					ON rfd.ReportFrequencyId = rf.ReportFrequencyId
				INNER JOIN Report r WITH (NOLOCK)
					ON r.ReportId = rf.ReportID
				WHERE ISNULL(IsReadyForETL, 0) = 1
					AND CONVERT(DATE, rf.FrequencyEndDate) > = CONVERT(DATE, GETDATE())
					AND convert(DATE, LEFT(CONVERT(VARCHAR(8), rfd.AnchorDate), 4) + SUBSTRING(CONVERT(VARCHAR(8), rfd.AnchorDate), 5, 2) + RIGHT(CONVERT(VARCHAR(8), rfd.AnchorDate), 2)) <= (GETDATE())
					AND ISNULL(rfd.IsETLCompleted, 0) = 0
				) t
				ON t.ReportFrequencyId = rfc.ReportFrequencyId
			INNER JOIN PopulationDefinitionConfiguration pdc
				ON pdc.MetricID = rfc.MetricId
			INNER JOIN Metric m
				ON m.MetricId = pdc.MetricID
			WHERE m.StatusCode = 'A'
				AND m.NAME <> 'No Metric Available'
				
				AND rfc.StatusCode = 'A' 
				--AND t.AnchorDate = @v_DateKey
				AND (
					m.MetricId = @i_MetricID
					OR @i_MetricID IS NULL
					)
					ORDER BY t.AnchorDate, m.MetricId
			
		END
		ELSE
		BEGIN -- This is for Manual metrics
			INSERT INTO @t_Metric
			SELECT DISTINCT m.MetricId
				,t.AnchorDate
				,CASE 
					WHEN pdc.NrProcName IS NOT NULL
						THEN 1
					ELSE 0
					END IsStandard
			FROM ReportFrequencyConfiguration rfc
			INNER JOIN (
				SELECT rf.ReportFrequencyId
					,MIN(rfd.AnchorDate) AnchorDate
				FROM ReportFrequency rf WITH (NOLOCK)
				INNER JOIN ReportFrequencyDate rfd WITH (NOLOCK)
					ON rfd.ReportFrequencyId = rf.ReportFrequencyId
				INNER JOIN Report r WITH (NOLOCK)
					ON r.ReportId = rf.ReportID
				WHERE ISNULL(IsReadyForETL, 0) = 1
					AND rfd.AnchorDate = @v_DateKey
				--AND ISNULL(rfd.IsETLCompleted,0) = 0
				GROUP BY rf.ReportFrequencyId
				) t
				ON t.ReportFrequencyId = rfc.ReportFrequencyId
			INNER JOIN PopulationDefinitionConfiguration pdc
				ON pdc.MetricID = rfc.MetricId
			INNER JOIN Metric m
				ON m.MetricId = pdc.MetricID
			WHERE m.StatusCode = 'A'
				AND m.NAME <> 'No Metric Available'
				AND t.AnchorDate = @v_DateKey
				AND rfc.StatusCode = 'A'
				AND (
					m.MetricId = @i_MetricID
					OR @i_MetricID IS NULL
					)
		END

		DECLARE @i_Min INT

		SELECT @i_Min = MIN(ID)
		FROM @t_Metric

		WHILE (
				@i_Min <= (
					SELECT MAX(ID)
					FROM @t_Metric
					)
				)
		BEGIN
			SELECT @i_MetricID1 = MetricID
				,@v_DateKey1 = AnchorDate
				,@b_IsStandard = IsStandard
			FROM @t_Metric
			WHERE ID = @i_Min

			IF @b_IsStandard = 1
			BEGIN
				EXEC usp_Batch_MetricPatientsByStandard @i_AppUserId = @i_AppUserId
					,@v_DateKey = @v_DateKey1
					,@i_MetricID = @i_MetricID1
			END
			ELSE
			BEGIN
				EXEC usp_Batch_MetricPatientsByInternalWrapper @i_AppUserId = @i_AppUserId
					,@v_DateKey = @v_DateKey1
					,@i_MetricID = @i_MetricID1
			END
			
			EXEC [usp_Batch_MetricFrequencyUpdateforPOPReport] 
			@i_AppUserId = @i_AppUserId
			,@v_DateKey = @v_DateKey1
			,@i_MetricID = @i_MetricID1
			
			SET @i_Min = @i_Min + 1
		END
	END
			/*
	EXEC usp_Batch_MetricPatientsByInternalWrapper
	@i_AppUserId = @i_AppUserId,
	@v_DateKey = @v_DateKey,
	@i_MetricID = @i_MetricID
	
	EXEC usp_Batch_MetricPatientsByStandard
	@i_AppUserId = @i_AppUserId,
	@v_DateKey = @v_DateKey,
	@i_MetricID = @i_MetricID
	*/
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_MetricWrapper] TO [FE_rohit.r-ext]
    AS [dbo];

