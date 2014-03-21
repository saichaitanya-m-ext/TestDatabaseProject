
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_Metrics_Search  23,null,null,null,'hyp' ,null,null,NULL,NULL   
Description   : This procedure is used to get the details from Metrics table     
Created By    : P.V.P.Mohan      
Created Date  : 15-Nov-2012
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION  
19-Nov-2012 P.V.P.Mohan changed @i_MetricsId and IF Condition to get Result Set @i_MetricsId is Null
20-Nov-2012 P.V.P.Mohan Added  Program and CohortList tables in Join and Written Case Condition To get Denominator
22/08/2013:Santosh modified denominatorID to managedpopulationID where definitiontype is 'M'
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_Metrics_Search] (
	@i_AppUserId KEYID
	,@i_MetricId KEYID = NULL
	,@v_Name SHORTDESCRIPTION = NULL
	,@v_Description VARCHAR(250) = NULL
	,@v_DenominatorType VARCHAR(1) = NULL
	,@i_DenominatorID KEYID = NULL
	,@i_InsuranceGroupID KEYID = NULL
	,@i_StandardId KEYID = NULL
	,@i_StandardOrganizationID KEYID = NULL
	,@i_NumeratorID KEYID = NULL
	,@v_StatusCode STATUSCODE = NULL
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

	SELECT m.MetricId
		,m.NAME
		,m.Description AS MetricDescription
		,s.StandardId
		,s.NAME StandardName
		,so.StandardOrganizationID
		,so.NAME StandardOrganizationName
		,iom.IOMCategoryID
		,iom.NAME IOMCategoryName
		,ig.InsuranceGroupID
		,ig.GroupName InsuranceGroupName
		,m.DenominatorType
		--,m.MeasureId
		,CASE 
			WHEN cl.DefinitionType + cl.NumeratorType = 'NC'
				THEN 'Quality (Process Metric)'
			WHEN cl.DefinitionType + cl.NumeratorType = 'NV'
				THEN 'Quality (OutCome Metric)'
			WHEN cl.DefinitionType + cl.NumeratorType = 'UC'
				THEN 'Process (Utilization Metric)'
			WHEN cl.DefinitionType + cl.NumeratorType = 'UV'
				THEN 'OutCome (Utilization Metric)'		
			END NumeratorType
		,m.DenominatorID
		,CASE 
			WHEN m.DenominatorType = 'P'
				THEN (
						SELECT PopulationDefinitionName
						FROM PopulationDefinition
						WHERE PopulationDefinitionID = m.DenominatorID
							AND DefinitionType = 'P'
						)
			WHEN m.DenominatorType = 'C'
				THEN (
						SELECT PopulationDefinitionName
						FROM PopulationDefinition
						WHERE PopulationDefinitionID = m.DenominatorID
							AND DefinitionType = 'C'
						)
			WHEN m.DenominatorType = 'M'
				THEN (
						SELECT ProgramName
						FROM Program
						WHERE ProgramId = m.ManagedPopulationID
						)
			END DenominatorName
		,CASE m.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			END AS StatusDescription
		,Version
		,NULL IsPrimary
		,m.NumeratorID
		,cl.PopulationDefinitionName NumeratorName
		,CONVERT(VARCHAR(10), m.CreatedDate, 101) CreatedDate
		,m.ValueAttributeID
		,(
				SELECT 1  
				FROM MetricDocument md
				WHERE md.MetricId = m.MetricId
					
	     ) AS DOC
	FROM Metric m WITH (NOLOCK)
	--LEFT JOIN ReportFrequencyConfiguration RFC ON m.MetricId = RFC.MetricId
	LEFT JOIN Standard s WITH (NOLOCK) ON s.StandardID = m.StandardId
	LEFT JOIN StandardOrganization so WITH (NOLOCK) ON so.StandardOrganizationID = m.StandardOrganizationID
	LEFT JOIN IOMCategory iom WITH (NOLOCK) ON iom.IOMCategoryID = m.IOMCategoryID
	LEFT JOIN InsuranceGroup ig WITH (NOLOCK) ON ig.InsuranceGroupID = m.InsuranceGroupID
	LEFT JOIN PopulationDefinition cl WITH (NOLOCK) ON cl.PopulationDefinitionId = m.NumeratorID
	
		AND cl.DefinitionType IN ('N','U')
	WHERE (
			m.MetricId = @i_MetricId
			OR @i_MetricId IS NULL
			)
		AND (
			m.NAME LIKE '%' + @v_Name + '%'
			OR @v_Name IS NULL
			)
		AND (
			m.Description LIKE '%' + @v_Description + '%'
			OR @v_Description IS NULL
			)
		AND (
			CASE 
				WHEN @v_DenominatorType = 'P'
					AND m.DenominatorType = 'P'
					THEN (
							SELECT PopulationDefinitionID
							FROM PopulationDefinition
							WHERE PopulationDefinitionID = m.DenominatorID
								AND DefinitionType = 'P'
							)
				WHEN @v_DenominatorType = 'C'
					AND m.DenominatorType = 'C'
					THEN (
							SELECT PopulationDefinitionID
							FROM PopulationDefinition
							WHERE PopulationDefinitionID = m.DenominatorID
								AND DefinitionType = 'C'
							)
				WHEN @v_DenominatorType = 'M'
					AND m.DenominatorType = 'M'
					THEN (
							SELECT ProgramId
							FROM Program
							WHERE ProgramId = m.ManagedPopulationID
							)
				END = @i_DenominatorID
			OR @i_DenominatorID IS NULL
			)
		AND (
			m.InsuranceGroupID = @i_InsuranceGroupID
			OR @i_InsuranceGroupID IS NULL
			)
		AND (
			m.StandardId = @i_StandardId
			OR @i_StandardId IS NULL
			)
		AND (
			m.StandardOrganizationID = @i_StandardOrganizationID
			OR @i_StandardOrganizationID IS NULL
			)
		AND (
			m.NumeratorID = @i_NumeratorID
			OR @i_NumeratorID IS NULL
			)
		AND (
			m.StatusCode = @v_StatusCode
			OR @v_StatusCode IS NULL
			)
	ORDER BY NAME
		--  
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
    ON OBJECT::[dbo].[usp_Metrics_Search] TO [FE_rohit.r-ext]
    AS [dbo];

