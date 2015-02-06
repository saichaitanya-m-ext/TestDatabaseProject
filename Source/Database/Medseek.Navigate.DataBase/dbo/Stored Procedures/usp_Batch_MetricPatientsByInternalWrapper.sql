/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_MetricPatientsByInternalWrapper]  
Description   : This proc is used to extract the data from standard hedis or hedis like procedures
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_MetricPatientsByInternalWrapper] --1,20121231
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8)
	,@i_MetricID KEYID
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
	
	DECLARE
		@i_DrId INT
		,@vc_SPName VARCHAR(1000)
		,@vc_SQL NVARCHAR(MAX)
		,@i_BatchStatusId BIGINT

	SELECT 
	  @i_BatchStatusId=MAX(BatchStatusId)
	FROM 
	  BatchStatus 
	  
	SELECT @vc_SPName = CASE 
			WHEN m.DenominatorType = 'M'
				THEN 'usp_Batch_MetricPatientsByInternal_MP'
			ELSE 'usp_Batch_MetricPatientsByInternal'
			END
	FROM Metric m WITH (NOLOCK)
	WHERE m.MetricId = @i_MetricID

	SELECT @vc_SQL = ' EXEC ' + '[' + @vc_SPName + ']' + ' ' + 
	'@i_AppUserId = ' + CAST(@i_AppUserId AS VARCHAR(10)) + ',' + 
	'@v_DateKey = ' + CAST(@v_DateKey AS VARCHAR(10)) + ',' + 
	'@i_MetricID = ' + CAST(@i_MetricID AS VARCHAR(10))

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
		---- Updating the MetricNumerator Frquency ID . It is mandatory for the population reports
		--	EXEC [usp_Batch_MetricFrequencyUpdateforPOPReport] 
		--	 @i_AppUserId = @i_AppUserId
		--	,@v_DateKey = @v_DateKey
		--	,@i_MetricID = @i_MetricID
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
		/*
	DECLARE @i_MetricID1 INT, @i_DrId INT, @vc_SPName VARCHAR(1000),@vc_SQL NVARCHAR(MAX) 
	DECLARE CurNR CURSOR
	FOR
	SELECT DISTINCT pdc.DrId
		,CASE WHEN m.DenominatorType = 'M' THEN 'usp_Batch_MetricPatientsByInternal_MP'
		ELSE 'usp_Batch_MetricPatientsByInternal'
		END
		,pdc.MetricId
	FROM PopulationDefinitionConfiguration pdc
	INNER JOIN MetricReportConfiguration mrc
		ON MRC.MetricID = pdc.MetricID
	INNER JOIN Metric m 
	ON m.MetricId = mrc.MetricId	
	WHERE mrc.Datekey = @v_DateKey
		AND NrProcName IS NULL
		AND pdc.CodeGroupingID IS NOT NULL
		AND MRC.MetricId = pdc.MetricId
		AND (mrc.MetricId = @i_MetricID OR @i_MetricID IS NULL)
	UNION
	SELECT DISTINCT pdc.DrId
		,CASE WHEN m.DenominatorType = 'M' THEN 'usp_Batch_MetricPatientsByInternal_MP'
		ELSE 'usp_Batch_MetricPatientsByInternal'
		END
		,pdc.MetricId
	FROM PopulationDefinitionConfiguration pdc
	INNER JOIN MetricReportConfiguration mrc
		ON MRC.MetricID = pdc.MetricID
	INNER JOIN Metric m 
	ON m.MetricId = mrc.MetricId	
	WHERE mrc.Datekey = @v_DateKey
		AND NrProcName IS NULL
		--AND pdc.CodeGroupingID IS NOT NULL
		AND MRC.MetricId = pdc.MetricId
		AND name  = 'Unique NDC Count'
		AND (mrc.MetricId = @i_MetricID OR @i_MetricID IS NULL)	
		

	OPEN CurNR

	FETCH NEXT
	FROM CurNR
	INTO @i_DrId
		,@vc_SPName
		,@i_MetricID1

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @vc_SQL = ' EXEC ' + '['+ @vc_SPName + ']'+ ' ' + 
		'@i_AppUserId = ' + CAST(@i_AppUserId AS VARCHAR(10)) + ',' +
		'@v_DateKey = ' + CAST(@v_DateKey AS VARCHAR(10)) + ',' + 
		'@i_MetricID = ' + CAST(@i_MetricID1 AS VARCHAR(10)) 
		

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
    ON OBJECT::[dbo].[usp_Batch_MetricPatientsByInternalWrapper] TO [FE_rohit.r-ext]
    AS [dbo];

