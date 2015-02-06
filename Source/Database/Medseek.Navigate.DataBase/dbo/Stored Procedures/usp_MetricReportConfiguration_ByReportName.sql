
--SELECT * FROM POPULATIONMETRICSREPORTS  
/*    
---------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_MetricReportConfiguration_ByReportName]   23,'BCBS'
Description   : This procedure is used for getting the DR's and Metrics  
Created By    : Rathnam    
Created Date  : 14-Aug-2013  
----------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY  DESCRIPTION    
----------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_ByReportName] ---1,'HEDIS'  
	(
	@i_AppUserId KEYID
	,@i_ReportName VARCHAR(500)
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

	DECLARE @t_Dr TABLE (
		ID INT IDENTITY(1, 1)
		,DrID INT
		,DrName VARCHAR(2000)
		,DefinitionType VARCHAR(1)
		,ParentID INT
		,StandardID INT
		,StandardName VARCHAR(30)
		)

	IF @i_ReportName IN (
			--'Comorbidity'  
			'Condition Prevalence'
			)
		INSERT INTO @t_Dr
		SELECT DISTINCT Dr.PopulationDefinitionID DrID
			,Dr.PopulationDefinitionName DrName
			,Dr.DefinitionType
			,0
			,s.StandardID
			,s.NAME
		FROM Metric m WITH (NOLOCK)
		INNER JOIN PopulationDefinition dr WITH (NOLOCK)
			ON dr.PopulationDefinitionID = m.DenominatorID
		INNER JOIN Standard s
			ON s.StandardID = dr.StandardsId
		WHERE s.NAME IN ('CCS')
			AND m.StatusCode = 'A'
			AND dr.StatusCode = 'A'
			AND dr.DefinitionType IN ('C')
	ELSE
		IF @i_ReportName = 'HEDIS'
			INSERT INTO @t_Dr
			SELECT DISTINCT Dr.PopulationDefinitionID DrID
				,Dr.PopulationDefinitionName DrName
				,Dr.DefinitionType
				,0
				,s.StandardID
				,s.NAME
			FROM Metric m WITH (NOLOCK)
			INNER JOIN PopulationDefinition dr WITH (NOLOCK)
				ON dr.PopulationDefinitionID = m.DenominatorID
			INNER JOIN Standard s
				ON s.StandardID = dr.StandardsId
			WHERE s.NAME IN (
					'HEDIS'
					,'HEDIS-L'
					--,'Internal'
					)
				AND m.StatusCode = 'A'
				AND dr.StatusCode = 'A'
		ELSE
			IF @i_ReportName IN (
					'HMOI'
					,'BCBS'
					,'P4P'
					)
				INSERT INTO @t_Dr
				SELECT DISTINCT Dr.PopulationDefinitionID DrID
					,Dr.PopulationDefinitionName DrName
					,Dr.DefinitionType
					,0
					,s.StandardID
					,s.NAME
				FROM Metric m WITH (NOLOCK)
				INNER JOIN PopulationDefinition dr WITH (NOLOCK)
					ON dr.PopulationDefinitionID = m.DenominatorID
				INNER JOIN Standard s
					ON s.StandardID = dr.StandardsId
				WHERE --s.Name IN ('CCS','HEDIS','HEDIS-L','Internal','HMOI')  
					m.StatusCode = 'A'
					AND dr.StatusCode = 'A'
			ELSE
				IF @i_ReportName IN ('Care Management Metric')
					INSERT INTO @t_Dr
					SELECT DISTINCT Dr.ProgramID DrID
						,Dr.ProgramName DrName
						,m.DenominatorType DefinitionType
						,0
						,s.StandardID
						,s.NAME
					FROM Metric m WITH (NOLOCK)
					INNER JOIN Program dr WITH (NOLOCK)
						ON dr.ProgramID = m.ManagedPopulationID
					INNER JOIN PopulationDefinition pd
						ON pd.PopulationDefinitionID = dr.PopulationDefinitionID
							AND pd.PopulationDefinitionID = m.DenominatorID
					INNER JOIN Standard s
						ON s.StandardID = pd.StandardsID
					WHERE m.StatusCode = 'A'
						AND dr.StatusCode = 'A'
				ELSE
					IF @i_ReportName IN ('Comorbidity')
						INSERT INTO @t_Dr
						SELECT DISTINCT Dr.PopulationDefinitionID DrID
							,Dr.PopulationDefinitionName DrName
							,Dr.DefinitionType
							,0
							,s.StandardID
							,s.NAME
						FROM PopulationDefinition dr WITH (NOLOCK)
						INNER JOIN Standard s
							ON s.StandardID = dr.StandardsID
						WHERE s.NAME IN ('CCS')
							AND dr.StatusCode = 'A'
							AND dr.DefinitionType IN ('C')
					ELSE
						IF @i_ReportName IN ('TotalPatient Vs Total Cost')
							INSERT INTO @t_Dr
							SELECT DISTINCT Dr.PopulationDefinitionID DrID
								,Dr.PopulationDefinitionName DrName
								,Dr.DefinitionType
								,0
								,s.StandardID
								,s.NAME
							FROM PopulationDefinition dr WITH (NOLOCK)
							INNER JOIN Standard s
								ON s.StandardID = dr.StandardsID
							WHERE dr.StatusCode = 'A'
								AND dr.DefinitionType IN ('C')
						ELSE
							IF @i_ReportName IN ('Financial Report')
								INSERT INTO @t_Dr
								SELECT DISTINCT Dr.PopulationDefinitionID DrID
									,Dr.PopulationDefinitionName DrName
									,Dr.DefinitionType
									,0
									,s.StandardID
									,s.NAME
								FROM Metric m WITH (NOLOCK)
								INNER JOIN PopulationDefinition dr WITH (NOLOCK)
									ON dr.PopulationDefinitionID = m.DenominatorID
								INNER JOIN Standard s
									ON s.StandardID = dr.StandardsId
								WHERE m.StatusCode = 'A'
									AND dr.StatusCode = 'A'

	INSERT INTO @t_Dr
	SELECT DISTINCT 0
		,StandardName
		,NULL
		,NULL
		,NULL
		,StandardName
	FROM @t_Dr

	SELECT t.ID
		,t.DrID
		,t.DrName
		,t.DefinitionType
		,CASE 
			WHEN t.DrID > 0
				THEN (
						SELECT ID
						FROM @t_Dr t1
						WHERE t1.StandardName = t.StandardName
							AND DrID = 0
						)
			ELSE NULL
			END ParentID
		,StandardID
	FROM @t_Dr t
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
    ON OBJECT::[dbo].[usp_MetricReportConfiguration_ByReportName] TO [FE_rohit.r-ext]
    AS [dbo];

