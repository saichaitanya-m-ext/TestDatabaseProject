
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_DrPatientsByInternalWrapper]  
Description   : This proc is used to extract the data from standard hedis or hedis like procedures
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_DrPatientsByInternalWrapper] --1,20121231
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8)
	,@i_DrId KEYID = NULL
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
		,@i_Identity BIGINT

	CREATE TABLE #Drs (
		DrId INT
		,IsCompleted BIT
		)

	INSERT INTO #Drs
	SELECT DISTINCT pdc.DrId
		,0
	FROM PopulationDefinitionConfiguration pdc
	WHERE pdc.MetricID IS NULL
		AND pdc.DrProcName IS NULL
		AND (
			pdc.CodeGroupingID IS NOT NULL
			OR pdc.ConditionIdList IS NOT NULL
			)
		AND (
			pdc.DrID = @i_DrId
			OR @i_DrId IS NULL
			)

	INSERT INTO BatchStatus (
		BatchType
		,BatchStatus
		,NoofTotalCodes
		,StartDate
		,EndDate
		,NoOfProcessed
		)
	SELECT 'Denominator'
		,'Populating Standard Denominators with usp_Batch_DrWrapper'
		,NULL
		,GETDATE()
		,NULL
		,NULL

	SET @i_Identity = SCOPE_IDENTITY()

	IF NOT EXISTS (
			SELECT 1
			FROM PopulationDefinitionConfiguration pdc
			WHERE ISNULL(IsConflictParameter, 0) = 1
			)
	BEGIN
		DECLARE CurDR CURSOR
		FOR
		SELECT DISTINCT pdc.DrId
			,'usp_Batch_DrPatientsByInternal'
		FROM PopulationDefinitionConfiguration pdc
		WHERE pdc.MetricID IS NULL
			AND pdc.DrProcName IS NULL
			AND (
				pdc.CodeGroupingID IS NOT NULL
				OR pdc.ConditionIdList IS NOT NULL
				)
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
			UPDATE BatchStatus
			SET NoofTotalCodes = (
					SELECT COUNT(DISTINCT DrId)
					FROM #Drs
					)
			WHERE BatchStatusId = @i_Identity
			
			SELECT @vc_SQL = ' EXEC ' + '[' + @vc_SPName + ']' + ' ' + '@i_AppUserId = ' + CAST(@i_AppUserId AS VARCHAR(10)) + ',' + '@v_DateKey = ' + CAST(@v_DateKey AS VARCHAR(10)) + ',' + '@i_DrId= ' + CAST(@i_DrId1 AS VARCHAR(10))
			
				UPDATE BatchStatus
				SET BatchStatus = @vc_SQL
				WHERE BatchStatusId = @i_Identity
				
			BEGIN TRY
				RAISERROR (
						@vc_SQL
						,0
						,1
						)
				WITH NOWAIT

				

				EXEC SP_EXECUTESQL @vc_SQL

				UPDATE #Drs
				SET IsCompleted = 1
				WHERE DrId = @i_DrId1
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

		UPDATE BatchStatus
		SET BatchStatus = 'Completed'
			,NoOfProcessed = (
				SELECT COUNT(1)
				FROM #Drs
				WHERE IsCompleted = 1
				)
			,EndDate = GETDATE()
		WHERE BatchStatusId = @i_Identity
		DROP TABLE #Drs
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
    ON OBJECT::[dbo].[usp_Batch_DrPatientsByInternalWrapper] TO [FE_rohit.r-ext]
    AS [dbo];

