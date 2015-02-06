
--SELECT * FROM PopulationMetricsReports

/*            
------------------------------------------------------------------------------------------            
Procedure Name: [usp_ReportSummary_Select] @i_AppUserId = 23 ,@IsLanding=1,@i_reportName = 1
Description   : This procedure is used to populate reports based on the given selection  
Created By    : Santosh            
Created Date  : 12-August-2013  
------------------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION    
    
   
EXEC usp_ReportSummary_Select @i_AppUserId = 23,@i_numeratorID=80,@IsLanding=0 @i_reportPeriod = 20121130, @vc_reporttype = 'NC'  
@i_reportName = 9,@i_standardid = NULL,@i_standardorgid = NULL,@i_MetricID = NULL,@i_DenominatorID = NULL,@i_numeratorID = 83  
  
EXEC usp_ReportSummary_Select @i_AppUserId = 23,@i_reportPeriod = 20121231  
Modifications:  
 - Chaitanya made the following changes  
  a.Modified @i_DenominatorID as VARCHAR(10)   
  b.Denominator Type is retrieved from MetricReportConfiguration instead of Metric  
  c.Modified DenominatorStandardName,DenominatorStandardOrgName values to NULL  
  d.Added a new parameter @IsLanding  
-------------------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_ReportSummary_Select_Test] (
	@i_AppUserId KEYID
	,@i_standardid KEYID = NULL
	,@i_standardorgid KEYID = NULL
	,@i_reportName KEYID = NULL
	,@i_MetricID KEYID = NULL
	,@i_DenominatorID VARCHAR(10) = NULL
	,@i_numeratorID KEYID = NULL
	,@i_reportPeriod KEYID = NULL
	,@vc_reporttype VARCHAR(2) = NULL
	,@i_isPrimary isindicator = NULL
	,@i_isIndicator isindicator = NULL
	,@i_statusCode VARCHAR(1) = NULL
	,@IsLanding BIT = 1
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

	IF @i_reportPeriod IS NULL
		AND @IsLanding = 1
	BEGIN
		SELECT @i_reportPeriod = MAX(Datekey)
		FROM MetricReportConfiguration
	END

	IF ((
			SELECT ReportName
			FROM PopulationMetricsReports
			WHERE PopulationMetricsReportsId = @i_reportName
			) <> 'Comorbidity' OR @i_reportName IS NULL)
	BEGIN

			;

		WITH CTE
		AS (
			SELECT DISTINCT MRC.ReportID
				,pmr.AliasName AS ReportName
				,CONVERT(VARCHAR(10), CAST(CAST((Datekey) AS VARCHAR(10)) AS DATE), 101) [MeasurementDate]
				,M.MetricId
				,CASE 
					WHEN MRC.StatusCode = 'A'
						THEN 'Active'
					ELSE 'Inactive'
					END StatusCode
				,MRC.IsPrimary IsPrimary
				,M.NAME AS MetricName
				,M.Description
				,(
					SELECT NAME
					FROM STANDARD
					WHERE StandardId = M.StandardId
					) AS StandardName
				,(
					SELECT NAME
					FROM StandardOrganization ST
					WHERE StandardOrganizationId = M.StandardOrganizationId
					) AS StandardOrgName
				,CASE 
					WHEN PD.NumeratorType = 'C'
						AND PD.DefinitionType = 'N'
						THEN 'Quality' + ' (Process Metric)'
					WHEN PD.NumeratorType = 'V'
						AND PD.DefinitionType = 'N'
						THEN 'Quality' + ' (Outcome Metric)'
					WHEN PD.NumeratorType = 'C'
						AND PD.DefinitionType = 'U'
						THEN 'Utilization' + ' (Process Metric)'
					WHEN PD.NumeratorType = 'V'
						AND PD.DefinitionType = 'U'
						THEN 'Utilization' + ' (Outcome Metric)'
					END AS MetricType
				,PD.PopulationDefinitionID AS NumeratorID
				,(
					CASE 
						WHEN pmr.ReportName = 'Comorbidity'
							THEN NULL
						ELSE PD.IsIndicator
						END
					) AS IsIndicator
				,PD.PopulationDefinitionName AS NumeratorName
				,PD.PopulationDefinitionDescription AS NumeratorDescription
				,(
					SELECT NAME
					FROM STANDARD S
					WHERE S.StandardId = PD.StandardsId
					) AS NumeratorStandardName
				,(
					SELECT NAME
					FROM StandardOrganization ST
					WHERE ST.StandardOrganizationID = PD.StandardOrganizationID
					) AS NumeratorStandardOrgName
				,CASE 
					WHEN PD.NumeratorType = 'C'
						THEN 'Count'
					WHEN PD.NumeratorType = 'V'
						THEN 'Value'
					END AS NumeratorType
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN M.managedpopulationid
					ELSE P.PopulationDefinitionID
					END AS DenominatorID
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN (
								SELECT ProgramName
								FROM Program
								WHERE ProgramId = M.managedpopulationid
								)
					ELSE P.PopulationDefinitionName
					END AS DenominatorName
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN (
								SELECT Description
								FROM Program
								WHERE ProgramId = M.managedpopulationid
								)
					ELSE P.PopulationDefinitionDescription
					END AS DenominatorDescription
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN NULL
					ELSE (
							SELECT NAME
							FROM STANDARD S
							WHERE S.StandardId = P.StandardsId
							)
					END AS DenominatorStandardName
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN NULL
					ELSE (
							SELECT NAME
							FROM StandardOrganization ST
							WHERE ST.StandardOrganizationID = P.StandardOrganizationID
							)
					END AS DenominatorStandardOrgName
				,CASE 
					WHEN MRC.DrType = 'C'
						THEN 'Condition'
					WHEN MRC.DrType = 'P'
						THEN 'Preventive'
					WHEN MRC.DrType = 'M'
						THEN 'ManagedPopulation'
					END AS DenominatorType
			FROM MetricReportConfiguration MRC
			LEFT JOIN Metric M
				ON MRC.MetricId = M.MetricId
			LEFT JOIN PopulationDefinition P
				ON P.PopulationDefinitionID = MRC.DrID
			LEFT JOIN PopulationDefinition PD
				ON M.NumeratorID = PD.PopulationDefinitionID
			LEFT JOIN PopulationMetricsReports pmr
				ON pmr.PopulationMetricsReportsId = MRC.ReportID
			LEFT JOIN Program PG
				ON PG.ProgramId = M.ManagedPopulationID
			WHERE 1 = 1
			    AND pmr.ReportName <> 'HMOI'
				AND (
					MRC.Datekey = @i_reportPeriod
					OR @i_reportPeriod IS NULL
					)
				AND (
					M.StandardId = @i_standardid
					OR @i_standardid IS NULL
					)
				AND (
					M.StandardOrganizationID = @i_standardorgid
					OR @i_standardorgid IS NULL
					)
				AND (
					MRC.ReportID = @i_reportName
					OR @i_reportName IS NULL
					)
				AND (
					PD.DefinitionType + PD.NumeratorType = @vc_reporttype
					OR @vc_reporttype IS NULL
					)
				AND (
					M.MetricId = @i_MetricID
					OR @i_MetricID IS NULL
					)
				AND (
					@i_DenominatorID = (
						CASE 
							WHEN RIGHT(@i_DenominatorID, 1) = 'C'
								THEN (CAST((P.PopulationDefinitionID) AS VARCHAR) + '-' + P.DefinitionType)
							WHEN RIGHT(@i_DenominatorID, 1) = 'P'
								THEN (CAST((P.PopulationDefinitionID) AS VARCHAR) + '-' + P.DefinitionType)
							WHEN RIGHT(@i_DenominatorID, 1) = 'M'
								THEN (CAST((PG.ProgramId) AS VARCHAR) + '-' + MRC.DrType)
							END
						)
					OR @i_DenominatorID IS NULL
					)
				AND (
					PD.PopulationDefinitionID = @i_numeratorID
					OR @i_numeratorID IS NULL
					)
				--AND pmr.StatusCode = 'A'
				AND (
					MRC.StatusCode = @i_statusCode
					OR @i_statusCode IS NULL
					)
				AND (
					PD.IsIndicator = @i_isIndicator
					OR @i_isIndicator IS NULL
					)
				AND (
					MRC.IsPrimary = @i_isPrimary
					OR @i_isPrimary IS NULL
					)
			)
		SELECT *
		FROM CTE
		ORDER BY CAST(MeasurementDate AS DATE) DESC
	END
	ELSE
	BEGIN
	
			;

		WITH NCTE
		AS (
			SELECT DISTINCT MRC.ReportID
				,pmr.AliasName AS ReportName
				,CONVERT(VARCHAR(10), CAST(CAST((Datekey) AS VARCHAR(10)) AS DATE), 101) [MeasurementDate]
				,M.MetricId
				,CASE 
					WHEN MRC.StatusCode = 'A'
						THEN 'Active'
					ELSE 'Inactive'
					END StatusCode
				,(
					CASE 
						WHEN pmr.ReportName = 'Comorbidity'
							THEN 'false'
						ELSE MRC.IsPrimary
						END
					) AS IsPrimary
				,M.NAME AS MetricName
				,M.Description
				,(
					SELECT NAME
					FROM STANDARD
					WHERE StandardId = M.StandardId
					) AS StandardName
				,(
					SELECT NAME
					FROM StandardOrganization ST
					WHERE StandardOrganizationId = M.StandardOrganizationId
					) AS StandardOrgName
				,CASE 
					WHEN PD.NumeratorType = 'C'
						AND PD.DefinitionType = 'N'
						THEN 'Quality' + ' (Process Metric)'
					WHEN PD.NumeratorType = 'V'
						AND PD.DefinitionType = 'N'
						THEN 'Quality' + ' (Outcome Metric)'
					WHEN PD.NumeratorType = 'C'
						AND PD.DefinitionType = 'U'
						THEN 'Utilization' + ' (Process Metric)'
					WHEN PD.NumeratorType = 'V'
						AND PD.DefinitionType = 'U'
						THEN 'Utilization' + ' (Outcome Metric)'
					END AS MetricType
				,PD.PopulationDefinitionID AS NumeratorID
				,(
					CASE 
						WHEN pmr.ReportName = 'Comorbidity'
							THEN NULL
						ELSE PD.IsIndicator
						END
					) AS IsIndicator
				,PD.PopulationDefinitionName AS NumeratorName
				,PD.PopulationDefinitionDescription AS NumeratorDescription
				,(
					SELECT NAME
					FROM STANDARD S
					WHERE S.StandardId = PD.StandardsId
					) AS NumeratorStandardName
				,(
					SELECT NAME
					FROM StandardOrganization ST
					WHERE ST.StandardOrganizationID = PD.StandardOrganizationID
					) AS NumeratorStandardOrgName
				,CASE 
					WHEN PD.NumeratorType = 'C'
						THEN 'Count'
					WHEN PD.NumeratorType = 'V'
						THEN 'Value'
					END AS NumeratorType
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN M.managedpopulationid
					ELSE P.PopulationDefinitionID
					END AS DenominatorID
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN (
								SELECT ProgramName
								FROM Program
								WHERE ProgramId = M.managedpopulationid
								)
					ELSE P.PopulationDefinitionName
					END AS DenominatorName
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN (
								SELECT Description
								FROM Program
								WHERE ProgramId = M.managedpopulationid
								)
					ELSE P.PopulationDefinitionDescription
					END AS DenominatorDescription
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN NULL
					ELSE (
							SELECT NAME
							FROM STANDARD S
							WHERE S.StandardId = P.StandardsId
							)
					END AS DenominatorStandardName
				,CASE 
					WHEN M.DenominatorType = 'M'
						THEN NULL
					ELSE (
							SELECT NAME
							FROM StandardOrganization ST
							WHERE ST.StandardOrganizationID = P.StandardOrganizationID
							)
					END AS DenominatorStandardOrgName
				,CASE 
					WHEN MRC.DrType = 'C'
						THEN 'Condition'
					WHEN MRC.DrType = 'P'
						THEN 'Preventive'
					WHEN MRC.DrType = 'M'
						THEN 'ManagedPopulation'
					END AS DenominatorType
			FROM MetricReportConfiguration MRC
			LEFT JOIN Metric M
				ON MRC.MetricId = M.MetricId
			LEFT JOIN PopulationDefinition P
				ON P.PopulationDefinitionID = MRC.DrID
			INNER JOIN CodeGrouping cg
				ON cg.CodeGroupingID = p.CodeGroupingID
			INNER JOIN CodeTypeGroupers ct
				ON ct.CodeTypeGroupersID = cg.CodeTypeGroupersID
			LEFT JOIN PopulationDefinition PD
				ON M.NumeratorID = PD.PopulationDefinitionID
			LEFT JOIN PopulationMetricsReports pmr
				ON pmr.PopulationMetricsReportsId = MRC.ReportID
			LEFT JOIN Program PG
				ON PG.ProgramId = M.ManagedPopulationID
			WHERE 1 = 1
				AND (
					MRC.Datekey = @i_reportPeriod
					OR @i_reportPeriod IS NULL
					)
				AND (
					M.StandardId = @i_standardid
					OR @i_standardid IS NULL
					)
				AND (
					M.StandardOrganizationID = @i_standardorgid
					OR @i_standardorgid IS NULL
					)
				AND (
					MRC.ReportID = @i_reportName
					OR @i_reportName IS NULL
					)
				AND (
					PD.DefinitionType + PD.NumeratorType = @vc_reporttype
					OR @vc_reporttype IS NULL
					)
				AND (
					M.MetricId = @i_MetricID
					OR @i_MetricID IS NULL
					)
				AND (
					@i_DenominatorID = (
						CASE 
							WHEN RIGHT(@i_DenominatorID, 1) = 'C'
								THEN (CAST((P.PopulationDefinitionID) AS VARCHAR) + '-' + P.DefinitionType)
							WHEN RIGHT(@i_DenominatorID, 1) = 'P'
								THEN (CAST((P.PopulationDefinitionID) AS VARCHAR) + '-' + P.DefinitionType)
							WHEN RIGHT(@i_DenominatorID, 1) = 'M'
								THEN (CAST((PG.ProgramId) AS VARCHAR) + '-' + MRC.DrType)
							END
						)
					OR @i_DenominatorID IS NULL
					)
				AND (
					PD.PopulationDefinitionID = @i_numeratorID
					OR @i_numeratorID IS NULL
					)
				AND pmr.StatusCode = 'A'
				AND ct.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group'
				AND (
					MRC.StatusCode = @i_statusCode
					OR @i_statusCode IS NULL
					)
				AND (
					PD.IsIndicator = @i_isIndicator
					OR @i_isIndicator IS NULL
					)
				AND (
					MRC.IsPrimary = @i_isPrimary
					OR @i_isPrimary IS NULL
					)
			)
		SELECT *
		FROM NCTE
		ORDER BY CAST(MeasurementDate AS DATE) DESC
	END

	------------------------------DateKey-------------  
	SELECT MAX(Datekey) AS Datekey
		,SUBSTRING(DATENAME(MONTH, CAST(CAST(DateKey AS VARCHAR) AS DATE)), 1, 3) + ' ' + CAST(SUBSTRING(CAST(DateKey AS VARCHAR), 1, 4) AS VARCHAR) AS DateKeyname
	FROM MetricReportConfiguration
	GROUP BY SUBSTRING(DATENAME(MONTH, CAST(CAST(DateKey AS VARCHAR) AS DATE)), 1, 3) + ' ' + CAST(SUBSTRING(CAST(DateKey AS VARCHAR), 1, 4) AS VARCHAR)
END TRY

--------------------------------------------------------             
BEGIN CATCH
	-- Handle exception            
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ReportSummary_Select_Test] TO [FE_rohit.r-ext]
    AS [dbo];

