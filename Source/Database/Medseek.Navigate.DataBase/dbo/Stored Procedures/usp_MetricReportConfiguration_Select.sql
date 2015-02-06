
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReportConfiguration_Select]  1,3
Description   : This procedure is used fetch the records for the report from the MetricReport config table
Created By    : Rathnam  
Created Date  : 19-Aug-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_Select] --1,3
	(
	@i_AppUserId KEYID
	,@i_ReportFrequencyID KEYID
	,@b_IsClone BIT = 0
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

	IF @b_IsClone = 0
	BEGIN
		SELECT r.ReportId
			,r.ReportName
			,CASE 
				WHEN Frequency IS NULL
					AND DateKey IS NOT NULL
					THEN 'Adhoc'
				WHEN Frequency IS NOT NULL
					AND DateKey IS NULL
					THEN 'Scheduled'
				END AS ReportType
			,rf.Frequency
			,FrequencyEndDate
			,DateKey
			,rf.IsReadyForETL
			,CASE 
				WHEN DATEDIFF(dd, getdate(), rf.FrequencyEndDate) < 0
					THEN 0
				ELSE 1
				END STATUS
		FROM ReportFrequency rf WITH (NOLOCK)
		INNER JOIN Report r WITH (NOLOCK)
			ON r.ReportId = rf.ReportID
		WHERE rf.ReportFrequencyId = @i_ReportFrequencyID
	END
	ELSE
	BEGIN
		SELECT r.ReportId
			,r.ReportName
		FROM ReportFrequency rf WITH (NOLOCK)
		INNER JOIN Report r WITH (NOLOCK)
			ON r.ReportId = rf.ReportID
		WHERE rf.ReportFrequencyId = @i_ReportFrequencyID
	END

	DECLARE @v_ReportName VARCHAR(50)

	SELECT @v_ReportName = r.ReportName
	FROM ReportFrequency rf WITH (NOLOCK)
	INNER JOIN Report r WITH (NOLOCK)
		ON r.ReportId = rf.ReportID
	WHERE rf.ReportFrequencyId = @i_ReportFrequencyID

	DECLARE @t_Metric TABLE (
		Id INT IDENTITY(1, 1)
		,ParentID INT
		,DrID INT
		,MetricID INT
		,MetricName VARCHAR(1000)
		,IsPrimary BIT
		,DrType VARCHAR(1)
		)

	IF @v_ReportName = 'Care Management Metric'
	BEGIN
		INSERT INTO @t_Metric (
			ParentID
			,DrID
			,MetricName
			,DrType
			,MetricID
			)
		SELECT DISTINCT NULL
			,dr.ProgramID PopulationDefinitionID
			,dr.ProgramName PopulationDefinitionName
			,'M'
			,0 -- Means Getting Drs for building the parent tree
		FROM ReportFrequencyConfiguration mrc WITH (NOLOCK)
		INNER JOIN Metric m WITH (NOLOCK)
			ON m.MetricId = mrc.MetricId
				AND m.StatusCode = 'A'
		INNER JOIN Program dr WITH (NOLOCK)
			ON dr.Programid = mrc.DrID
				AND m.ManagedPopulationID = dr.ProgramId
		WHERE mrc.ReportFrequencyId = @i_ReportFrequencyId
			AND mrc.StatusCode = 'A'
			AND dr.StatusCode = 'A'
			AND m.DenominatorType = 'M'
	END
	ELSE
	BEGIN
		INSERT INTO @t_Metric (
			ParentID
			,DrID
			,MetricName
			,DrType
			,MetricID
			)
		SELECT DISTINCT NULL
			,dr.PopulationDefinitionID
			,dr.PopulationDefinitionName
			,m.DenominatorType
			,0 -- Means Getting Drs for building the parent tree
		FROM ReportFrequencyConfiguration mrc WITH (NOLOCK)
		LEFT JOIN Metric m WITH (NOLOCK)
			ON m.MetricId = mrc.MetricId
				AND m.StatusCode = 'A'
		INNER JOIN PopulationDefinition dr WITH (NOLOCK)
			ON dr.PopulationDefinitionID = mrc.DrID
		WHERE mrc.ReportFrequencyId = @i_ReportFrequencyId
			AND mrc.StatusCode = 'A'
			AND dr.StatusCode = 'A'
	END

	INSERT INTO @t_Metric (
		ParentID
		,MetricID
		,MetricName
		,IsPrimary
		,DrID
		,DrType
		)
	SELECT (
			SELECT ID
			FROM @t_Metric t
			WHERE t.DrID = mrc.DrID
				AND t.ParentID IS NULL
			)
		,ISNULL(m.MetricID, 0)
		,CASE 
			WHEN m.NAME IS NOT NULL
				THEN m.NAME + ISNULL(CASE 
							WHEN nr.DefinitionType + nr.NumeratorType = 'NC'
								THEN ' (Process Metric)'
							WHEN nr.DefinitionType + nr.NumeratorType = 'NV'
								THEN ' (Outcome Metric)'
							WHEN nr.DefinitionType + nr.NumeratorType = 'UC'
								THEN ' (Utilization)'
							END, '') + CASE 
						WHEN ISNULL(mrc.IsPrimary, 0) = 1
							THEN ' Is Primary'
						ELSE ''
						END
			ELSE 'No Metric Avilable'
			END
		,mrc.IsPrimary
		,mrc.DrID
		,m.DenominatorType
	FROM ReportFrequencyConfiguration mrc WITH (NOLOCK)
	LEFT JOIN Metric m WITH (NOLOCK)
		ON m.MetricId = mrc.MetricId
			AND m.StatusCode = 'A'
	LEFT JOIN PopulationDefinition nr
		ON nr.PopulationDefinitionID = m.NumeratorID
			AND nr.StatusCode = 'A'
	WHERE mrc.ReportFrequencyId = @i_ReportFrequencyId
		AND mrc.StatusCode = 'A'

	EXEC [usp_MetricReportConfiguration_ByReportName] @i_AppUserId
		,@v_ReportName

	SELECT *
	FROM @t_Metric
		--IF @i_AdhocAnchorDate IS NOT NULL
		--BEGIN
		--	IF (
		--			SELECT ETLStatus
		--			FROM ReportStatus ad WITH (NOLOCK)
		--			WHERE ad.DateKey = @i_AdhocAnchorDate
		--				AND RePortID = @i_ReportID
		--			) IN (
		--			'Completed'
		--			,'Ready For ETL'
		--			)
		--	BEGIN
		--		SELECT 1
		--	END
		--	ELSE
		--	BEGIN
		--		SELECT 0
		--	END
		--END
		--ELSE
		--BEGIN
		--	SELECT Frequency
		--		,FrequencyEndDate
		--	FROM PopulationMetricsReportFrequency
		--	WHERE PopulationMetricsReportFrequencyId = (
		--			SELECT MAX(PopulationMetricsReportFrequencyId)
		--			FROM PopulationMetricsReportFrequency pmr
		--			WHERE ReportID = @i_ReportID
		--			)
		--END
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
    ON OBJECT::[dbo].[usp_MetricReportConfiguration_Select] TO [FE_rohit.r-ext]
    AS [dbo];

