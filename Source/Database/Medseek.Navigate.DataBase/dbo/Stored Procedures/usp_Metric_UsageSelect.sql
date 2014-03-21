
/*       
------------------------------------------------------------------------------        
Procedure Name: [usp_Metric_UsageSelect] 23,1      
Description   : This procedure is used to get the list of all Metrics details      
    for a particular MetricsId or get complete list when passed NULL      
Created By    : P.V.P.Mohan        
Created Date  : 26-Nov-2012       
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION     
19-Nov-2012 P.V.P.Mohan Modified columns , numeratorType and DenominatorType    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Metric_UsageSelect] (
	@i_AppUserId KeyID
	,@i_MetricId KeyID = NULL
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

	SELECT Metric.NAME
		,Metric.Version AS [Version]
		,CONVERT(VARCHAR(10), Metric.CreatedDate, 101) [ReportingUsageDate]
		,PopulationDefinition.PopulationDefinitionName + ' / ' + ISNULL(CONVERT(VARCHAR(20), Metric.LastModifiedDate, 101), CONVERT(VARCHAR(20), Metric.CreatedDate, 101)) [MappednumeratorDateofMapping]
		,CASE 
			WHEN Metric.DenominatorType = 'P'
				THEN (
						SELECT PopulationDefinitionName
						FROM PopulationDefinition
						WHERE PopulationDefinitionID = Metric.DenominatorID
							AND DefinitionType = 'P'
						)
			WHEN Metric.DenominatorType = 'C'
				THEN (
						SELECT PopulationDefinitionName
						FROM PopulationDefinition
						WHERE PopulationDefinitionID = Metric.DenominatorID
							AND DefinitionType = 'C'
						)
			WHEN Metric.DenominatorType = 'M'
				THEN (
						SELECT ProgramName
						FROM Program
						WHERE ProgramId = Metric.managedpopulationID
						)
			END + ' / ' + ISNULL(CONVERT(VARCHAR(20), Metric.LastModifiedDate, 101), CONVERT(VARCHAR(20), Metric.CreatedDate, 101)) [MappedDenominatorDateofMapping]
		,CASE 
			WHEN Metric.DenominatorType = 'P'
				THEN 'PopulationDefinition'
			WHEN Metric.DenominatorType = 'M'
				THEN 'ManagedPopulation'
			WHEN Metric.DenominatorType = 'C'
				THEN 'ConditionDefinition'
			ELSE ''
			END AS [MappedDenominatorType]
	FROM Metric
	LEFT JOIN PopulationDefinition ON PopulationDefinition.PopulationDefinitionID = Metric.NumeratorID
	WHERE (
			MetricId = @i_MetricId
			OR @i_MetricId IS NULL
			)
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
    ON OBJECT::[dbo].[usp_Metric_UsageSelect] TO [FE_rohit.r-ext]
    AS [dbo];

