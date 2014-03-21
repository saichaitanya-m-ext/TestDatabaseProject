/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_MetricPatientsByStandard]  
Description   : This proc is used to extract the data from standard hedis or hedis like procedures
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
--[usp_Batch_MetricPatientsByStandard] 1,'20130131',4,'S'
CREATE PROCEDURE [dbo].[usp_Batch_MetricPatientsByStandard] --1,20121231,62,'S'
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8)
	,@i_MetricID KEYID
	,@v_@ReportType CHAR(1) = 'P'
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_BatchStatusId INT

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

	SELECT @i_BatchStatusId = MAx(BatchStatusId)
	FROM BatchStatus

	IF NOT EXISTS (
			SELECT 1
			FROM PopulationDefinitionConfiguration pdc
			WHERE ISNULL(IsConflictParameter, 0) = 1
			)
	BEGIN
		DECLARE @i_AnchorDate_Year INT = SUBSTRING(CAST(@v_DateKey AS VARCHAR(10)), 1, 4)
			,@i_AnchorDate_Month VARCHAR(5) = SUBSTRING(CAST(@v_DateKey AS VARCHAR(10)), 5, 2)
			,@i_AnchorDate_Day VARCHAR(5) = SUBSTRING(CAST(@v_DateKey AS VARCHAR(10)), 7, 2)
		DECLARE @i_DrId INT
			,@vc_SPName VARCHAR(1000)
			,@vc_SQL NVARCHAR(MAX)

		SELECT DISTINCT @i_DrId = m.DenominatorID
			,@vc_SPName = pdc.NrProcName
		FROM PopulationDefinitionConfiguration pdc
		INNER JOIN Metric m ON m.MetricId = pdc.MetricID
		WHERE pdc.NrProcName IS NOT NULL
			AND pdc.MetricId = @i_MetricID

		SELECT @vc_SQL = ' EXEC ' + '[' + @vc_SPName + ']' + ' ' + '@PopulationDefinitionID = ' + 
		CAST(@i_DrId AS VARCHAR(10)) + ',' + '@MetricID = ' + 
		CAST(@i_MetricID AS VARCHAR(10)) + ',' + '@AnchorDate_Year = ' + 
		CAST(@i_AnchorDate_Year AS VARCHAR(10)) + ',' + '@AnchorDate_Month = ''' + 
		CAST(@i_AnchorDate_Month AS VARCHAR(10)) + ''',' + '@AnchorDate_Day = ''' + 
		CAST(@i_AnchorDate_Day AS VARCHAR(10)) + ''''

		/*
		SET @vc_SQL = @vc_SQL + ' , ' + '@Num_Months_Prior = 1 ' --+ ' , ' + '@ReportType = ''S'''
		
		IF @v_@ReportType = 'S'
		BEGIN
			SET @vc_SQL = @vc_SQL + ' , ' + '@Num_Months_Prior = 1 ' + ' , ' + '@ReportType = ''S'''
		END
		*/

		BEGIN TRY
			RAISERROR (
					@vc_SQL
					,0
					,1
					)
			WITH NOWAIT

			UPDATE BatchStatus
			SET BatchStatus = @vc_SQL
			WHERE BatchStatusId = @i_BatchStatusId

			EXEC SP_EXECUTESQL @vc_SQL
			-- Updating the MetricNumerator Frquency ID . It is mandatory for the population reports
			EXEC [usp_Batch_MetricFrequencyUpdateforPOPReport] 
			 @i_AppUserId = @i_AppUserId
			,@v_DateKey = @v_DateKey
			,@i_MetricID = @i_MetricID
			/*
			IF @v_@ReportType = 'P'
			BEGIN
			EXEC [usp_Batch_MetricFrequencyUpdateforPOPReport] 
			 @i_AppUserId = @i_AppUserId
			,@v_DateKey = @v_DateKey
			,@i_MetricID = @i_MetricID
			END
			ELSE IF @v_@ReportType = 'S'
			BEGIN
			EXEC [usp_Batch_MetricFrequencyUpdate] 
			 @i_AppUserId = @i_AppUserId
			,@v_DateKey = @v_DateKey
			,@i_MetricID = @i_MetricID
			END
			*/
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
				SELECT @i_DrId
					,@i_MetricID
					,@vc_SQL
					,ERROR_MESSAGE()
					,@v_DateKey
			END
		END CATCH
	END
			/*
	DECLARE CurNR CURSOR
	FOR
	SELECT DISTINCT pdc.DrId
		,NrProcName
		,pdc.MetricId
	FROM PopulationDefinitionConfiguration pdc
	INNER JOIN MetricReportConfiguration mrc
		ON MRC.MetricId = pdc.MetricId
	WHERE mrc.Datekey = @v_DateKey
		AND NrProcName IS NOT NULL
		AND MRC.MetricId = pdc.MetricId
		AND (mrc.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		

	OPEN CurNR

	FETCH NEXT
	FROM CurNR
	INTO @i_DrId
		,@vc_SPName
		,@i_MetricID1

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @vc_SQL = ' EXEC ' + '['+ @vc_SPName + ']'+ ' ' + '@PopulationDefinitionID = ' + CAST(@i_DrId AS VARCHAR(10)) + ',' + 
		'@MetricID = ' + CAST(@i_MetricID1 AS VARCHAR(10)) + ',' + 
		'@AnchorDate_Year = ' + CAST(@i_AnchorDate_Year AS VARCHAR(10)) + ',' + 
		'@AnchorDate_Month = ''' + CAST(@i_AnchorDate_Month AS VARCHAR(10)) + ''',' + 
		'@AnchorDate_Day = ''' + CAST(@i_AnchorDate_Day AS VARCHAR(10)) + ''''

		BEGIN TRY
			RAISERROR (@vc_SQL, 0, 1) WITH NOWAIT  
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
					)
				SELECT @i_DrId
					,@i_MetricID1
					,@vc_SQL
					,ERROR_MESSAGE()
			END
		END CATCH

		FETCH NEXT
		FROM CurNR
		INTO @i_DrId
			,@vc_SPName
			,@i_MetricID1
	END

	CLOSE CurNR
	DEALLOCATE CurNR
	
	*/
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_MetricPatientsByStandard] TO [FE_rohit.r-ext]
    AS [dbo];

