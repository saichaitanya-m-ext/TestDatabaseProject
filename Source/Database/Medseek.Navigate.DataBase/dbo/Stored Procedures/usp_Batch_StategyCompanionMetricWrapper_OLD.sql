
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_StategyCompanionMetricWrapper]  
Description   : This proc is used to extract the data from CodeGroupers OR Hedis tables 
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_StategyCompanionMetricWrapper_OLD] --1,20121130
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
			INNER JOIN AnchorDate ad
				ON ad.DateKey = rfd.AnchorDate
			INNER JOIN Report r WITH (NOLOCK)
				ON r.ReportId = rf.ReportID
			WHERE ISNULL(IsReadyForETL, 0) = 1
				AND CONVERT(DATE, rf.FrequencyEndDate) > = CONVERT(DATE, GETDATE())
				AND ad.AnchorDate <= (GETDATE())
				AND ISNULL(rfd.IsETLCompleted, 0) = 0
				AND (
					rf.DateKey = @v_DateKey
					OR @v_DateKey IS NULL
					)
			) t
			ON t.ReportFrequencyId = rfc.ReportFrequencyId
		INNER JOIN PopulationDefinitionConfiguration pdc
			ON pdc.MetricID = rfc.MetricId
		INNER JOIN Metric m
			ON m.MetricId = pdc.MetricID
		WHERE m.StatusCode = 'A'
			AND m.NAME <> 'No Metric Available'
			AND rfc.StatusCode = 'A'
			AND (
				m.MetricId = @i_MetricID
				OR @i_MetricID IS NULL
				)

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
					,@v_@ReportType = 'S'
			END
			ELSE
			BEGIN
				EXEC usp_Batch_StategyCompanionMetricPatientsByInternal @i_AppUserId = @i_AppUserId
					,@v_DateKey = @v_DateKey1
					,@i_MetricID = @i_MetricID1
			END
			/*
			EXEC usp_Batch_MetricFrequencyUpdate 1,@v_DateKey1,@i_MetricID1 
			*/
			SET @i_Min = @i_Min + 1
			
		END
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
    ON OBJECT::[dbo].[usp_Batch_StategyCompanionMetricWrapper_OLD] TO [FE_rohit.r-ext]
    AS [dbo];

