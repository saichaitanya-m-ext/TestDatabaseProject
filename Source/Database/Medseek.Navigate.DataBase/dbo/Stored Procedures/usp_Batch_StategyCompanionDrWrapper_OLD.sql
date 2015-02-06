
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_StategyCompanionDrWrapper]  
Description   : This proc is used to extract the data from CodeGroupers OR Hedis tables 
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_StategyCompanionDrWrapper_OLD] --1,20121130
	(
	 @i_AppUserId KEYID
	,@v_DateKey VARCHAR(8) = NULL
	,@i_DrID KEYID = NULL
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

	DECLARE @i_DrId1 INT
		,@vc_SPName VARCHAR(100)
		,@vc_SQL NVARCHAR(MAX)
		
	DECLARE @t_AnchorDate TABLE (AanchorDate INT)

	INSERT INTO @t_AnchorDate (AanchorDate)
	SELECT DISTINCT rfd.AnchorDate 
	FROM ReportFrequency rf WITH (NOLOCK)
	INNER JOIN ReportFrequencyDate rfd WITH (NOLOCK)
		ON rfd.ReportFrequencyId = rf.ReportFrequencyId
	INNER JOIN AnchorDate ad
		ON ad.DateKey = rfd.AnchorDate
	INNER JOIN Report r WITH (NOLOCK)
		ON r.ReportId = rf.ReportID
	WHERE ISNULL(IsReadyForETL, 0) = 1
		AND CONVERT(DATE, rf.FrequencyEndDate) > = CONVERT(DATE, GETDATE())
		AND AD.AnchorDate <= GETDATE()
		AND ISNULL(rfd.IsETLCompleted, 0) = 0
		AND (ad.DateKey = @v_DateKey OR @v_DateKey IS NULL)

	DECLARE @i_Min INT

	SELECT @i_Min = MIN(AanchorDate)
	FROM @t_AnchorDate

	WHILE (
			@i_Min <= (
				SELECT MAX(AanchorDate)
				FROM @t_AnchorDate
				)
			)
	BEGIN
		DECLARE CurDR CURSOR
		FOR
		SELECT DISTINCT pdc.DrId
			,'usp_Batch_StategyCompanionDrPatient'
		FROM PopulationDefinitionConfiguration pdc
		WHERE pdc.MetricID IS NULL
			AND pdc.DrProcName IS NULL
			AND pdc.CodeGroupingID IS NOT NULL
			AND (
				pdc.DrID = @i_DrId
				OR @i_DrId IS NULL
				)

		OPEN CurDR

		FETCH NEXT
		FROM CurDR
		INTO @i_DrId1
			,@vc_SPName

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @vc_SQL = ' EXEC ' + '[' + @vc_SPName + ']' + ' ' + 
								'@i_AppUserId = ' + CAST(@i_AppUserId AS VARCHAR(10)) + ',' + 
								'@v_DateKey = ' + CAST(@i_Min AS VARCHAR(10)) + ',' + 
								'@i_DrId= ' + CAST(@i_DrId1 AS VARCHAR(10))

			BEGIN TRY
				RAISERROR (
						@vc_SQL
						,0
						,1
						)
				WITH NOWAIT

				EXEC SP_EXECUTESQL @vc_SQL
			END TRY

			BEGIN CATCH
				IF @@ERROR <> 0
				BEGIN
					INSERT INTO ETLReportErrorlog (
						DenominatorId
						,MetricId
						,ErrorQuerry
						,ErrorMessage
						,DateKey
						)
					SELECT @i_DrId1
						,NULL
						,@vc_SQL
						,ERROR_MESSAGE()
						,@v_DateKey
				END
			END CATCH

			FETCH NEXT
			FROM CurDR
			INTO @i_DrId1
				,@vc_SPName
		END

		CLOSE CurDR

		DEALLOCATE CurDR

		DELETE
		FROM @t_AnchorDate
		WHERE AanchorDate = @i_Min

		SELECT @i_Min = MIN(AanchorDate)
		FROM @t_AnchorDate
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
    ON OBJECT::[dbo].[usp_Batch_StategyCompanionDrWrapper_OLD] TO [FE_rohit.r-ext]
    AS [dbo];

