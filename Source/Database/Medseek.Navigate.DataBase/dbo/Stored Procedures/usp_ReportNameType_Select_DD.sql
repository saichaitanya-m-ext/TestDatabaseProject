



/*          
------------------------------------------------------------------------------------------          
Procedure Name: [usp_ReportNameType_Select_DD] 23 ,3 ,262   
Description   : This procedure is Drop Downs for reportname and reporttype,Metric,Denominator,Numerator,CodegroupersName,CodegroupingName
Created By    : Santosh          
Created Date  : 12-August-2013
------------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION
08/16/2013 Santosh added the params @tbl_Report,@tbl_Metric and the result sets Denominators and Numerators
-------------------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_ReportNameType_Select_DD](
	@i_AppUserId KEYID
	,@i_ReportID KeyID = NULL
	,@i_MetricID KeyID = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_numberOfRecordsSelected INT

	----- Check if valid Application User ID is passed--------------          
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

	SELECT 'NC' MetricCode
		,'Quality (Process Metric)' NAME
	
	UNION ALL
	
	SELECT 'NV'
		,'Quality (Outcome Metric)'
	
	UNION ALL
	
	SELECT 'UC'
		,'Utilization (Process Metric)'
	
	UNION ALL
	
	SELECT 'UV'
		,'Utilization (Outcome Metric)'

	SELECT ReportId
		,AliasName AS ReportName
	FROM Report
	WHERE StatusCode = 'A'
	ORDER BY AliasName

	IF @i_ReportID IS NULL
		AND @i_MetricID IS NULL
	BEGIN
		SELECT DISTINCT Metric.StandardId
			,Standard.NAME AS StandardName
		FROM Metric
		INNER JOIN Standard ON Standard.StandardId = Metric.StandardId
		ORDER BY Standard.Name

		SELECT DISTINCT Metric.StandardOrganizationId
			,StandardOrganization.NAME AS StandardOrganizationName
		FROM Metric
		INNER JOIN StandardOrganization ON StandardOrganization.StandardOrganizationId = Metric.StandardOrganizationId
		order by StandardOrganization.Name
	END

	SELECT DISTINCT Metric.MetricId
		,Metric.[Description]
	FROM Metric
	INNER JOIN reportfrequencyconfiguration 
	  ON reportfrequencyconfiguration.MetricId = Metric.MetricId
	INNER JOIN  ReportFrequency
	  ON ReportFrequency.ReportFrequencyId = ReportFrequencyConfiguration.ReportFrequencyId
	WHERE ReportID = @i_ReportID
		OR @i_ReportID IS NULL
	GROUP BY Metric.MetricId
		,Metric.[Description]
	ORDER BY Metric.[Description] 

	SELECT MAX(AnchorDate) AS Datekey
		,SUBSTRING(DATENAME(MONTH, CAST(CAST(AnchorDate AS VARCHAR) AS DATE)), 1, 3) + ' ' + CAST(SUBSTRING(CAST(AnchorDate AS VARCHAR), 1, 4) AS VARCHAR) AS DateKeyname
	FROM reportfrequencyconfiguration
	INNER JOIN  ReportFrequency
	  ON ReportFrequency.ReportFrequencyId = ReportFrequencyConfiguration.ReportFrequencyId
	 INNER JOIN reportfrequencydate
	  ON reportfrequencyconfiguration.ReportFrequencyId = reportfrequencydate.ReportFrequencyId
	WHERE 
	(
			ReportID = @i_ReportID
			OR @i_ReportID IS NULL
			)
		AND
		 (DateKey) IS NOT NULL
		 AND Frequency IS NULL
	GROUP BY SUBSTRING(DATENAME(MONTH, CAST(CAST(AnchorDate AS VARCHAR) AS DATE)), 1, 3) + ' ' + CAST(SUBSTRING(CAST(AnchorDate AS VARCHAR), 1, 4) AS VARCHAR)
	ORDER BY MAX(AnchorDate) DESC
	
	DECLARE @vc_ReportName VARCHAR(100) = NULL

	IF @i_ReportID IS NOT NULL
		SELECT @vc_ReportName = ReportName
		FROM Report
		WHERE ReportId = @i_ReportID

	IF @vc_ReportName <> 'Care Management Metric'
		AND @vc_ReportName <> 'Comorbidity'
		AND @vc_ReportName IS NOT NULL
	BEGIN
		SELECT DISTINCT (CAST((PopulationDefinitionID) AS VARCHAR) + '-' + Metric.DenominatorType) AS DenominatorID
			,PopulationDefinitionName AS DenominatorName
			,Metric.DenominatorType
		FROM PopulationDefinition
		INNER JOIN Metric 
		  ON Metric.DenominatorID = PopulationDefinition.PopulationDefinitionID
		INNER JOIN reportfrequencyconfiguration
		  ON reportfrequencyconfiguration.DrID = PopulationDefinition.PopulationDefinitionID
		INNER JOIN ReportFrequency
		  ON ReportFrequency.ReportFrequencyId =  reportfrequencyconfiguration.ReportFrequencyId
		WHERE (
				ReportFrequency.ReportID = @i_ReportID
				OR @i_ReportID IS NULL
				)
			AND (
				Metric.MetricId = @i_MetricID
				OR @i_MetricID IS NULL
				)
		ORDER BY PopulationDefinitionName
	END
	ELSE
		IF @vc_ReportName = 'Care Management Metric'
			AND @vc_ReportName IS NOT NULL
		BEGIN
			SELECT DISTINCT (CAST((ProgramId) AS VARCHAR) + '-' + Metric.DenominatorType) AS DenominatorID
				,Program.ProgramName AS DenominatorName
				,Metric.DenominatorType
			FROM Program
			INNER JOIN Metric ON Metric.ManagedPopulationID = Program.ProgramId
			INNER JOIN reportfrequencyconfiguration ON reportfrequencyconfiguration.MetricId = Metric.MetricId
			INNER JOIN ReportFrequency ON ReportFrequency.ReportFrequencyId = reportfrequencyconfiguration.ReportFrequencyId
			WHERE (
					ReportFrequency.ReportID = @i_ReportID
					OR @i_ReportID IS NULL
					)
				AND (
					Metric.MetricId = @i_MetricID
					OR @i_MetricID IS NULL
					)
			ORDER BY Program.ProgramName
		END
		ELSE
			IF @vc_ReportName = 'Comorbidity'
				AND @vc_ReportName IS NOT NULL
			BEGIN
				SELECT DISTINCT (CAST((PopulationDefinitionID) AS VARCHAR) + '-' + Metric.DenominatorType) AS DenominatorID
					,PopulationDefinitionName AS DenominatorName
					,Metric.DenominatorType
				FROM PopulationDefinition
				INNER JOIN reportfrequencyconfiguration ON reportfrequencyconfiguration.DrID = PopulationDefinition.PopulationDefinitionID
				INNER JOIN ReportFrequency ON ReportFrequency.ReportFrequencyId = ReportFrequencyConfiguration.ReportFrequencyId
				INNER JOIN Metric ON Metric.MetricId = ReportFrequencyConfiguration.MetricId
				WHERE (
						ReportFrequency .ReportID = @i_ReportID
						OR @i_ReportID IS NULL
						)
					AND Metric.MetricId IS NULL
				ORDER BY PopulationDefinitionName
			END
			ELSE
			BEGIN
			
				--SELECT DISTINCT (CAST((PopulationDefinitionID) AS VARCHAR) + '-' + Metric.DenominatorType) AS DenominatorID
				--	,PopulationDefinitionName AS DenominatorName
				--	,Metric.DenominatorType
				--FROM PopulationDefinition
				--INNER JOIN Metric ON Metric.DenominatorID = PopulationDefinition.PopulationDefinitionID
				--INNER JOIN  ReportFrequencyConfiguration ON ReportFrequencyConfiguration.DrID = PopulationDefinition.PopulationDefinitionID
				
				SELECT DISTINCT (CAST((PopulationDefinitionID) AS VARCHAR) + '-' + PopulationDefinition.DefinitionType) AS DenominatorID
					,PopulationDefinitionName AS DenominatorName
					,PopulationDefinition.DefinitionType
				FROM PopulationDefinition
				INNER JOIN Metric ON Metric.DenominatorID = PopulationDefinition.PopulationDefinitionID
				INNER JOIN  ReportFrequencyConfiguration ON ReportFrequencyConfiguration.DrID = PopulationDefinition.PopulationDefinitionID
				
				UNION
				
				SELECT DISTINCT (CAST((ProgramId) AS VARCHAR) + '-' + Metric.DenominatorType) AS DenominatorID
					,Program.ProgramName AS DenominatorName
					,Metric.DenominatorType
				FROM Program
				INNER JOIN Metric ON Metric.ManagedPopulationID = Program.ProgramId
				INNER JOIN ReportFrequencyConfiguration ON ReportFrequencyConfiguration.MetricId = Metric.MetricId
				
				UNION
				
				SELECT DISTINCT (CAST((PopulationDefinitionID) AS VARCHAR) + '-' + Metric.DenominatorType) AS DenominatorID
					,PopulationDefinitionName AS DenominatorName
					,Metric.DenominatorType
				FROM PopulationDefinition
				INNER JOIN ReportFrequencyConfiguration ON ReportFrequencyConfiguration.DrID = PopulationDefinition.PopulationDefinitionID
				INNER JOIN Metric ON Metric.Metricid = ReportFrequencyConfiguration.metricid
				WHERE ReportFrequencyConfiguration.MetricId IS NULL
				ORDER BY DenominatorName
			END

	SELECT DISTINCT PopulationDefinitionID AS NumeratorID
		,PopulationDefinitionName AS NumeratorName
	FROM PopulationDefinition
	INNER JOIN Metric ON Metric.NumeratorID = PopulationDefinition.PopulationDefinitionID
	INNER JOIN ReportFrequencyConfiguration ON ReportFrequencyConfiguration.MetricId = Metric.MetricId
	INNER JOIN ReportFrequency ON ReportFrequency.ReportFrequencyId = ReportFrequencyConfiguration.ReportFrequencyId
	WHERE DefinitionType IN (
			'N'
			,'U'
			)
		AND (
			ReportFrequency.ReportID = @i_ReportID
			OR @i_ReportID IS NULL
			)
		AND (
			Metric.MetricId = @i_MetricID
			OR @i_MetricID IS NULL
			)
	ORDER BY PopulationDefinitionName
END TRY

--------------------------------------------------------           
BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT
	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
	--PRINT ERROR_MESSAGE()
		RETURN @i_ReturnedErrorID
END CATCH




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ReportNameType_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

