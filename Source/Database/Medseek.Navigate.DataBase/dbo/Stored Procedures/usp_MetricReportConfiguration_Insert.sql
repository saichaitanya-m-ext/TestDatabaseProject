


/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MetricReportConfiguration_Insert]  
Description   : This procedure is used add the records for the report to the ReportFrequency config table
Created By    : Rathnam  
Created Date  : 14-Aug-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MetricReportConfiguration_Insert] (
	@i_AppUserId KEYID
	,@i_ReportID KEYID
	,@b_IsSchedule BIT
	,@i_AdhocAnchorDate KEYID = NULL
	,@v_Frequency VARCHAR(1) = NULL
	,@d_EndDate DATETIME = NULL
	,@tblMetric tMetric READONLY
	,@b_IsReadyForETL BIT = 0
	,@i_ReportFrequencyId INT = NULL
	,@i_Identity INT OUTPUT
	,@b_IsCloneFromExisting BIT = 0
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

	/*
	--DECLARE @i_Identity INT
	IF @b_IsSchedule = 0
		AND @i_AdhocAnchorDate IS NOT NULL
	BEGIN
		--- First Time record does not exists
		IF NOT EXISTS (
				SELECT 1
				FROM AnchorDate
				WHERE DateKey = @i_AdhocAnchorDate
				)
		BEGIN
			INSERT INTO AnchorDate (DateKey)
			SELECT @i_AdhocAnchorDate
		END
	END
	*/
	DECLARE @i_Month INT = MONTH(GETDATE())
		,@d_StartDate DATETIME

	SELECT @d_StartDate = CASE 
			WHEN @v_Frequency = 'Q'
				THEN CASE 
						WHEN @i_Month BETWEEN 1
								AND 3
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '03' + '01'))
						WHEN @i_Month BETWEEN 4
								AND 6
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '06' + '01'))
						WHEN @i_Month BETWEEN 7
								AND 9
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '09' + '01'))
						WHEN @i_Month BETWEEN 10
								AND 12
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '12' + '01'))
						END
			WHEN @v_Frequency = 'H'
				THEN CASE 
						WHEN @i_Month BETWEEN 1
								AND 6
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '06' + '01'))
						WHEN @i_Month BETWEEN 7
								AND 12
							THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '12' + '01'))
						END
			WHEN @v_Frequency = 'Y'
				THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + '12' + '01'))
			WHEN @v_Frequency = 'M'
				THEN DATEADD(d, - 1, DATEADD(mm, 1, CAST(YEAR(GETDATE()) AS VARCHAR(4)) + RIGHT('00'+ CAST(MONTH(GETDATE()) AS VARCHAR(4)),2) + '01'))
			WHEN @v_Frequency IS NULL
				THEN CONVERT(DATE, CONVERT(VARCHAR(4), LEFT(@i_AdhocAnchorDate, 4)) + '-' + CONVERT(VARCHAR(2), SUBSTRING(CONVERT(VARCHAR(10), @i_AdhocAnchorDate), 5, 2)) + '-' + CONVERT(VARCHAR(2), RIGHT(@i_AdhocAnchorDate, 2)))
			END

	IF @b_IsClonefromexisting = 1
	BEGIN
		---- Do Schedule reports inactive 
		DECLARE @i_ReportFrequencyId_Aactive INT

		SELECT @i_ReportFrequencyId_Aactive = ReportFrequencyId
		FROM ReportFrequency
		WHERE ReportId = @i_ReportID
			AND Frequency IS NOT NULL
			AND CONVERT(DATE, FrequencyEndDate) > = CONVERT(DATE, GETDATE()) -- Means getting the active schedule records for doing inactive

		UPDATE ReportFrequency
		SET FrequencyEndDate = ISNULL(LastETLDate, Getdate() - 1)
		WHERE ReportFrequencyId = @i_ReportFrequencyId_Aactive

		DELETE
		FROM Reportfrequencydate
		WHERE ReportFrequencyId = @i_ReportFrequencyId_Aactive
			AND ISNULL(IsETLCompleted, 0) = 0

		--- Do Adhoc Reports inacive 
		DECLARE @Reportfrequency TABLE (ReportFrequencyID INT)

		IF @v_Frequency IS NOT NULL
			AND @d_EndDate IS NOT NULL
		BEGIN
			INSERT INTO @Reportfrequency (ReportFrequencyID)
			SELECT rf.ReportFrequencyId
			FROM ReportFrequency rf WITH (NOLOCK)
			INNER JOIN ReportFrequencyDate rfd WITH (NOLOCK)
				ON rfd.ReportFrequencyId = rf.ReportFrequencyId
			WHERE rfd.AnchorDate IN (
					SELECT t.DateKey
					FROM [dbo].[udf_GetDateKeys](@d_StartDate, @d_EndDate, @v_Frequency) t
					)
				AND rf.ReportID = @i_ReportID
				AND rf.FrequencyEndDate > = GETDATE()

			UPDATE ReportFrequency
			SET FrequencyEndDate = ISNULL(LastETLDate, Getdate() - 1)
			WHERE ReportFrequencyId IN (
					SELECT *
					FROM @Reportfrequency
					)

			DELETE
			FROM Reportfrequencydate
			WHERE ReportFrequencyId IN (
					SELECT *
					FROM @Reportfrequency
					)
				AND ISNULL(IsETLCompleted, 0) = 0
		END
	END

	--- Inserting new record
	IF @i_ReportFrequencyId IS NULL
	BEGIN
		INSERT INTO ReportFrequency (
			ReportID
			,Frequency
			,FrequencyEndDate
			,StartDate
			,DateKey
			,IsReadyForETL
			,LastETLDate
			,CreatedByUserId
			,CreatedDate
			)
		VALUES (
			@i_ReportID
			,@v_Frequency
			,@d_EndDate
			,@d_StartDate
			,@i_AdhocAnchorDate
			,@b_IsReadyForETL
			,NULL
			,@i_AppUserId
			,GETDATE()
			)

		SELECT @i_Identity = SCOPE_IDENTITY()

		INSERT INTO ReportFrequencyConfiguration (
			MetricId
			,ReportFrequencyId
			,IsPrimary
			,DrID
			)
		SELECT MetricId
			,@i_Identity
			,IsPrimary
			,DrID
		FROM @tblMetric

		IF @b_IsSchedule = 0
			AND @i_AdhocAnchorDate IS NOT NULL
		BEGIN
			INSERT INTO ReportFrequencyDate (
				ReportFrequencyId
				,AnchorDate
				)
			VALUES (
				@i_Identity
				,@i_AdhocAnchorDate
				)
		END
	END
	ELSE ---- Updating the existing record 
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM ReportFrequency
				WHERE ISNULL(IsReadyForETL, 0) = 0
					AND ReportFrequencyId = @i_ReportFrequencyId
				)
		BEGIN ---- Updating the existing record which are not marked as IsReadyForETL true
			UPDATE ReportFrequency
			SET Frequency = @v_Frequency
				,FrequencyEndDate = @d_EndDate
				,DateKey = @i_AdhocAnchorDate
				,StartDate = @d_StartDate
				,IsReadyForETL = @b_IsReadyForETL
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			WHERE ReportFrequencyId = @i_ReportFrequencyId

			IF @b_IsSchedule = 0
				AND @i_AdhocAnchorDate IS NOT NULL
			BEGIN
				UPDATE ReportFrequencyDate
				SET AnchorDate = @i_AdhocAnchorDate
				WHERE ReportFrequencyId = @i_ReportFrequencyId
			END

			IF EXISTS (
					SELECT 1
					FROM @tblMetric
					WHERE MetricID IS NOT NULL
					)
			BEGIN
				MERGE ReportFrequencyConfiguration AS t1
				USING (
					SELECT MetricID
						,IsPrimary
						,DrID
						,@i_ReportFrequencyId ReportFrequencyId
					FROM @tblMetric
					WHERE MetricId IS NOT NULL
					) AS S
					ON t1.MetricID = s.MetricID
						AND t1.ReportFrequencyId = s.ReportFrequencyId
				WHEN MATCHED --Row exists and data is different
					THEN
						UPDATE
						SET t1.IsPrimary = s.IsPrimary
							,t1.StatusCode = 'A'
							,t1.DrID = s.DrID
				WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
					THEN
						INSERT (
							MetricId
							,ReportFrequencyId
							,IsPrimary
							,DrID
							)
						VALUES (
							s.MetricID
							,s.ReportFrequencyId
							,s.IsPrimary
							,s.DrID
							)
				WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
					AND EXISTS (
						SELECT 1
						FROM @tblMetric c
						WHERE t1.ReportFrequencyId = @i_ReportFrequencyId
							AND c.MetricID <> t1.MetricID
						)
					THEN
						UPDATE
						SET t1.StatusCode = 'I';
			END
			ELSE
			BEGIN
				MERGE ReportFrequencyConfiguration AS t1
				USING (
					SELECT DrID
						,@i_ReportFrequencyId ReportFrequencyId
					FROM @tblMetric
					WHERE MetricId IS NULL
					) AS S
					ON t1.DrID = s.DrID
						AND t1.ReportFrequencyId = s.ReportFrequencyId
				WHEN MATCHED --Row exists and data is different
					THEN
						UPDATE
						SET t1.StatusCode = 'A'
				WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
					THEN
						INSERT (
							ReportFrequencyId
							,DrID
							)
						VALUES (
							s.ReportFrequencyId
							,s.DrID
							)
				WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
					AND EXISTS (
						SELECT 1
						FROM @tblMetric c
						WHERE t1.ReportFrequencyId = @i_ReportFrequencyId
							AND c.DrID <> t1.DrID
						)
					THEN
						UPDATE
						SET t1.StatusCode = 'I';
			END
		END
		ELSE ---- Updating the existing record which are marked as IsReadyForETL true for allowing to change the enddate only
			IF EXISTS (
					SELECT 1
					FROM ReportFrequency
					WHERE ISNULL(IsReadyForETL, 0) = 1
						AND ReportFrequencyId = @i_ReportFrequencyId
					)
				AND @d_EndDate IS NOT NULL
			BEGIN
				UPDATE ReportFrequency
				SET FrequencyEndDate = @d_EndDate
				WHERE ReportFrequencyId = @i_ReportFrequencyId
			END

		SET @i_Identity = @i_ReportFrequencyId
	END

	------------------------- Calcluating the Datekey between  StartDate & Enddate for not to inserting the duplicate frequency's
	DECLARE @StartDate DATE
		,@EndDate DATE
		,@Period CHAR(1) --	Month(M), Quarter (Q), HalfYear(H), Year(Y)

	SELECT @StartDate = StartDate
		,@EndDate = FrequencyEndDate
		,@Period = ISNULL(Frequency, 'M') -- for Adhoc it is just for month
	FROM ReportFrequency
	WHERE ReportFrequencyId = @i_Identity

	DELETE
	FROM Reportfrequencydate
	WHERE ReportFrequencyId = @i_Identity
		AND ISNULL(IsETLCompleted, 0) = 0

	INSERT INTO Reportfrequencydate (
		ReportFrequencyId
		,AnchorDate
		,IsETLCompleted
		)
	SELECT @i_Identity
		,t.DateKey
		,0
	FROM [dbo].[udf_GetDateKeys](@StartDate, @EndDate, @Period) t
	WHERE NOT EXISTS (
			SELECT 1
			FROM Reportfrequencydate
			WHERE ReportFrequencyId = @i_Identity
				AND ISNULL(IsETLCompleted, 0) = 1
				AND AnchorDate = t.DateKey
			)

	-------------------  PopulationDefinitionConfiguration -----------------------------------------------------------
	SELECT DISTINCT DriD
		,pd.CodeGroupingID
		,PopulationDefinitionCriteriaSQL
	INTO #DR
	FROM @tblMetric t
	INNER JOIN PopulationDefinition pd
		ON pd.PopulationdefinitionID = t.DrID
	LEFT JOIN PopulationdefinitionCriteria cr
		ON cr.PopulationdefinitionID = t.DrID
			AND cr.PopulationDefPanelConfigurationID = 75
			AND cr.PopulationDefinitionCriteriaSQL LIKE 'usp_%'
	WHERE pd.DefinitionType IN (
			'C'
			,'P'
			)

	MERGE PopulationDefinitionConfiguration AS t1
	USING (
		SELECT DrID
			,CodeGroupingID
			,PopulationDefinitionCriteriaSQL
		FROM #DR
		) AS S
		ON t1.DrID = s.DrID
			AND t1.MetricId IS NULL
	WHEN MATCHED --Row exists and data is different
		THEN
			UPDATE
			SET t1.StatusCode = 'A'
				,t1.CodeGroupingID = ISNULL(s.CodeGroupingID, t1.CodeGroupingID)
				,t1.DrProcName = ISNULL(s.PopulationDefinitionCriteriaSQL, t1.DrProcName)
	WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
		THEN
			INSERT (
				DrID
				,NoOfCodes
				,StatusCode
				,CreatedDate
				,CodeGroupingID
				,DrProcName
				)
			VALUES (
				s.DrID
				,1
				,'A'
				,Getdate()
				,s.CodeGroupingID
				,s.PopulationDefinitionCriteriaSQL
				);

	SELECT DISTINCT CASE 
			WHEN DenominatorType = 'M'
				THEN ManagedPopulationID
			ELSE DenominatorID
			END DrID
		,nr.CodeGroupingID
		,PopulationDefinitionCriteriaSQL
		,m.MetricID
	INTO #NR
	FROM @tblMetric t
	INNER JOIN Metric m
		ON m.MetricID = t.MetricID
	INNER JOIN PopulationDefinition nr
		ON nr.PopulationdefinitionID = m.NumeratorID
	LEFT JOIN PopulationdefinitionCriteria cr
		ON cr.PopulationdefinitionID = nr.PopulationdefinitionID
			AND cr.PopulationDefPanelConfigurationID = 75
			AND cr.PopulationDefinitionCriteriaSQL LIKE 'usp_%'
	WHERE nr.DefinitionType IN (
			'N'
			,'U'
			)

	MERGE PopulationDefinitionConfiguration AS t1
	USING (
		SELECT DrID
			,CodeGroupingID
			,PopulationDefinitionCriteriaSQL
			,MetricID
		FROM #NR
		) AS S
		ON t1.MetricId = s.MetricID
	WHEN MATCHED --Row exists and data is different
		THEN
			UPDATE
			SET t1.StatusCode = 'A'
				,t1.CodeGroupingID = ISNULL(s.CodeGroupingID, t1.CodeGroupingID)
				,t1.NrProcName = ISNULL(s.PopulationDefinitionCriteriaSQL, t1.NrProcName)
				,t1.DrID = s.DrID
	WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
		THEN
			INSERT (
				DrID
				,NoOfCodes
				,StatusCode
				,CreatedDate
				,CodeGroupingID
				,MetricID
				,NrProcName
				,TimeInDays
				)
			VALUES (
				s.DrID
				,1
				,'A'
				,Getdate()
				,s.CodeGroupingID
				,s.MetricID
				,s.PopulationDefinitionCriteriaSQL
				,365
				);

	UPDATE PopulationDefinitionConfiguration
	SET IsConflictParameter = 1
	WHERE MetricID IS NULL
		AND (
			(
				CodeGroupingID IS NOT NULL
				AND DrProcName IS NOT NULL
				AND ConditionIdList IS NOT NULL
				)
			OR (
				CodeGroupingID IS NOT NULL
				AND DrProcName IS NOT NULL
				)
			)

	UPDATE PopulationDefinitionConfiguration
	SET IsConflictParameter = 1
	WHERE MetricID IS NOT NULL
		AND (
			CodeGroupingID IS NOT NULL
			AND NrProcName IS NOT NULL
			)
END TRY

-------------------------------------------------------------------------------------------------
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

