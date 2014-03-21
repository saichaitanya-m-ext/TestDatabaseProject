
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReportConfiguration_ByDrID]  
Description   : This procedure is used for getting the  Metrics based on DRid
Created By    : Rathnam  
Created Date  : 14-Aug-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
--update Populationdefinition set numeratortype = 'V' WHERE PopulationdefinitionID = 344
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_ByDrID]-- 1,71,'c',6
	(
	@i_AppUserId KEYID
	,@i_DrID KEYID
	--,@i_StandardID KEYID
	,@v_DrType VARCHAR(1)
	,@i_ReportID INT
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

	DECLARE @t_Metric TABLE (
		ID INT identity(1, 1)
		,MetricID INT
		,MetricName VARCHAR(2000)
		,MetricType VARCHAR(10)
		,ParentID INT
		,DrID INT
		)
	DECLARE @v_ReportName VARCHAR(500)

	SELECT @v_ReportName = ReportName
	FROM Report pmr
	WHERE pmr.ReportId = @i_ReportID

	IF @v_DrType IN (
			'C'
			,'P'
			)
	BEGIN
		INSERT INTO @t_Metric (
			MetricID
			,MetricName
			,MetricType
			,ParentID
			,DrID
			)
		SELECT m.MetricID
			,m.NAME MetricName
			,nr.DefinitionType + nr.NumeratorType
			,0
			,dr.PopulationDefinitionID
		FROM Metric m WITH (NOLOCK)
		INNER JOIN PopulationDefinition nr WITH (NOLOCK)
			ON nr.PopulationDefinitionID = m.NumeratorID
		INNER JOIN PopulationDefinition dr WITH (NOLOCK)
			ON dr.PopulationDefinitionID = m.DenominatorID
		WHERE m.DenominatorID = @i_DrID
			AND m.StatusCode = 'A'
			AND nr.StatusCode = 'A'
			AND dr.StatusCode = 'A'
			AND m.DenominatorType IN ('C','P')
			AND (
				(
					@v_ReportName NOT IN ( 'Condition Prevalence','Financial Report')
					AND nr.DefinitionType <> 'U'
					)
				OR @v_ReportName IN ( 'Condition Prevalence','Financial Report')
			)
			
			
	END
	ELSE
		IF @v_DrType = 'M'
		BEGIN
			INSERT INTO @t_Metric (
				MetricID
				,MetricName
				,MetricType
				,ParentID
				,DrID
				)
			SELECT m.MetricID
				,m.NAME MetricName
				,nr.DefinitionType + nr.NumeratorType
				,0
				,dr.ProgramID
			FROM Metric m WITH (NOLOCK)
			INNER JOIN PopulationDefinition nr WITH (NOLOCK)
				ON nr.PopulationDefinitionID = m.NumeratorID
			INNER JOIN Program dr WITH (NOLOCK)
				ON dr.ProgramID = m.ManagedPopulationID
			WHERE dr.ProgramID = @i_DrID
				AND m.StatusCode = 'A'
				AND nr.StatusCode = 'A'
				AND dr.StatusCode = 'A'
				AND m.DenominatorType IN ('M')
				AND (
					(
						@v_ReportName NOT IN ( 'Condition Prevalence','Financial Report')
						AND nr.DefinitionType <> 'U'
						)
					OR @v_ReportName IN ( 'Condition Prevalence','Financial Report')
					)
		END

	--INSERT INTO @t_Metric (
	--	MetricID
	--	,MetricName
	--	,MetricType
	--	,ParentID
	--	,DrID
	--	)
	--SELECT DISTINCT 0
	--	,'No Metric Available'
	--	,MetricType
	--	,ParentID
	--	,Drid
	--FROM @t_Metric m
	--WHERE NOT EXISTS (
	--		SELECT 1
	--		FROM @t_Metric m1
	--		WHERE m.DrID = m1.DrID
	--			AND m.MetricType = m1.MetricType
	--			AND m1.MetricName = 'No Metric Available'
	--		)
	--	AND Drid IS NOT NULL

	INSERT INTO @t_Metric
	SELECT DISTINCT NULL
		,CASE 
			WHEN MetricType = 'NC'
				THEN 'Quality'
			WHEN MetricType = 'NV'
				THEN 'Quality'
			WHEN MetricType = 'UC'
				THEN 'Utilization'
			WHEN MetricType = 'UV'
				THEN 'Utilization'
			END
		,LEFT(t.MetricType, 1)
		,NULL
		,NULL
	FROM @t_Metric t

	--- This is for Process & Outcome second tree
	INSERT INTO @t_Metric
	SELECT DISTINCT NULL
		,CASE 
			WHEN MetricType = 'NC'
				THEN 'Process Metric'
			WHEN MetricType = 'NV'
				THEN 'OutCome Metric'
			WHEN MetricType = 'UC'
				THEN 'Process Metric'
			WHEN MetricType = 'UV'
				THEN 'OutCome Metric'
			END
		,MetricType
		,(
			SELECT ID
			FROM @t_Metric t1
			WHERE t1.MetricType = LEFT(t.MetricType, 1)
				AND ParentID IS NULL
			)
		,NULL
	FROM @t_Metric t
	WHERE LEN(MetricType) = 2

	SELECT ID
		,MetricID
		,MetricName
		,MetricType
		,CASE 
			WHEN ParentID = 0
				THEN (
						SELECT ID
						FROM @t_Metric t1
						WHERE t1.MetricType = m.MetricType
							AND DrID IS NULL
						)
			ELSE ParentID
			END ParentID
		,DrID
	FROM @t_Metric m
	ORDER BY DrID
		--END
		--ELSE
		--BEGIN
		--	INSERT INTO @t_Metric
		--	SELECT DISTINCT 0
		--		,CASE 
		--			WHEN MetricType = 'NC'
		--				THEN 'Process Metric'
		--			WHEN MetricType = 'NV'
		--				THEN 'OutCome Metric'
		--			WHEN MetricType = 'UC'
		--				THEN 'Process Metric'
		--			WHEN MetricType = 'UV'
		--				THEN 'OutCome Metric'
		--			END
		--		,MetricType
		--		,NULL
		--		,NULL
		--	FROM @t_Metric t
		--	SELECT ID
		--		,MetricID
		--		,MetricName
		--		,MetricType
		--		,CASE 
		--			WHEN ParentID = 0
		--				THEN (
		--						SELECT ID
		--						FROM @t_Metric t1
		--						WHERE t1.MetricType = m.MetricType
		--							AND ParentID IS NULL
		--						)
		--			ELSE NULL
		--			END ParentID
		--		,DrID
		--	FROM @t_Metric m
		--	ORDER BY DrID
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
    ON OBJECT::[dbo].[usp_MetricReportConfiguration_ByDrID] TO [FE_rohit.r-ext]
    AS [dbo];

