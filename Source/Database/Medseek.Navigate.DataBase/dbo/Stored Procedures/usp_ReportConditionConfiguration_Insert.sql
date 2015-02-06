
/*      
---------------------------------------------------------------------------------------      
Procedure Name: [usp_ReportConditionConfiguration_Insert]   
Description   : This procedure is used to Insert the ReportCondition Configuration data.  
Created By    : Sivakrishna    
Created Date  : 04-dec-2012     
---------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
  
---------------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_ReportConditionConfiguration_Insert] (
	@i_AppUserId KeyID
	,@i_ReportId KeyId
	,@b_IsSchedule BIT
	,@t_ConditionId ttypekeyId READONLY
	,@i_AnchorDate keyid
	,@v_Frequency VARCHAR(1) = NULL
	,@v_ETLStatus VARCHAR(20) = NULL
	,@d_EndDate DATETIME = NULL
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

	IF @b_IsSchedule = 0
		AND @i_AnchorDate IS NOT NULL
	BEGIN
		--- First Time record does not exists
		INSERT INTO AnchorDate (
			DateKey
			)
		SELECT @i_AnchorDate
		WHERE NOT EXISTS (
				SELECT 1
				FROM AnchorDate
				WHERE DateKey = @i_AnchorDate
				)

		--- Second or more than one Time record does exists and status is for ready for etl
		--IF @v_ETLStatus = 'Ready for ETL'
		--BEGIN
		--	UPDATE AnchorDate
		--	SET ETLStatus = @v_ETLStatus
		--	WHERE DateKey = @i_AnchorDate
		--END

		MERGE ReportConditionConfiguration AS t1
		USING (
			SELECT tKeyID ConditionID
				,@i_AnchorDate DateKey
				,@i_ReportId ReportId
			FROM @t_ConditionId
			) AS S
			ON t1.ConditionID = s.ConditionID
				AND t1.ReportID = s.ReportID
				AND t1.DateKey = s.DateKey
		WHEN MATCHED --Row exists and data is different
			THEN
				UPDATE
				SET t1.StatusCode = 'A'
		WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
			THEN
				INSERT (
					ReportId
					,ConditionId
					,DateKey
					,CreatedByUserId
					)
				VALUES (
					s.ReportId
					,s.ConditionID
					,s.DateKey
					,@i_AppUserId
					)
		WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
			AND EXISTS (
				SELECT 1
				FROM @t_ConditionId c
				WHERE t1.DateKey = @i_AnchorDate
					AND t1.ReportID = @i_ReportID
					AND c.tKeyID <> t1.ConditionID
				)
			THEN
				UPDATE
				SET t1.StatusCode = 'I';
	END
	ELSE
		IF @b_IsSchedule = 1
			AND @i_AnchorDate IS NULL
			AND @v_Frequency IS NOT NULL
		BEGIN
			--UPDATE PopulationMetricsReports
			--SET Frequency = @v_Frequency
			--	,FrequencyEndDate = @d_EndDate
			--WHERE PopulationMetricsReportsId = @i_ReportID

			MERGE ReportConditionConfiguration AS t1
			USING (
				SELECT tKeyID ConditionID
					,@i_AnchorDate DateKey
					,@i_ReportId ReportId
				FROM @t_ConditionId
				) AS S
				ON t1.ConditionID = s.ConditionID
					AND t1.ReportID = s.ReportID
					AND t1.DateKey IS NULL
			WHEN MATCHED --Row exists and data is different
				THEN
					UPDATE
					SET t1.StatusCode = 'A'
			WHEN NOT MATCHED BY TARGET --Row exists in source but not in target
				THEN
					INSERT (
						ReportId
						,ConditionId
						,DateKey
						,CreatedByUserId
						)
					VALUES (
						s.ReportId
						,s.ConditionID
						,s.DateKey
						,@i_AppUserId
						)
			WHEN NOT MATCHED BY SOURCE --Row exists in target but not in source
				AND EXISTS (
					SELECT 1
					FROM @t_ConditionId c
					WHERE t1.DateKey IS NULL
						AND t1.ReportID = @i_ReportID
						AND c.tKeyID <> t1.ConditionID
					)
				THEN
					UPDATE
					SET t1.StatusCode = 'I';
		END
END TRY

-------------------------------------------------------------------------------------------------------------------       
BEGIN CATCH
	-- Handle exception      
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ReportConditionConfiguration_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

