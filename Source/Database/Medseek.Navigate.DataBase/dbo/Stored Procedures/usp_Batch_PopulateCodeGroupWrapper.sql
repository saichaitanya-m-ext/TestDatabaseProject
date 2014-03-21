/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_PopulateCodeGroupWrapper]  
Description   : This proc is used to extract the data from standard hedis or hedis like procedures
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
12-12-2013   Siva krishna :Added Automation process by updating Batchstatus Table.
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_PopulateCodeGroupWrapper] --1,20121231
	(
	@i_AppUserId KEYID
	,@i_CodeGroupingID KEYID = NULL
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

	DECLARE @i_CodeGroupingID1 INT
		,@vc_SPName VARCHAR(100)
		,@vc_SQL NVARCHAR(MAX)
		,@i_Identity BIGINT

	INSERT INTO BatchStatus (
		 BatchType
		,BatchStatus
		,NoofTotalCodes
		,StartDate
		,EndDate
		,NoOfProcessed
		)
	SELECT 'CodeGroup'
		,'Populating Codes with usp_Batch_PopulateCode'
		,NULL
		,GETDATE()
		,NULL
		,NULL

	SET @i_Identity = SCOPE_IDENTITY()
	
	TRUNCATE TABLE ETLReportErrorlog

	EXEC usp_Batch_PopulateCode 1

	CREATE TABLE #CodeGroup (CodeGroupingID INT,IsCompleted BIT)

	INSERT INTO #CodeGroup
	 (CodeGroupingID,IsCompleted)
	SELECT DISTINCT pdc.CodeGroupingID,0
	FROM PopulationDefinitionConfiguration pdc
	WHERE pdc.CodeGroupingID IS NOT NULL
	
	UNION
	
	SELECT cg.CodeGroupingID,0
	FROM CodeGrouping cg
	INNER JOIN CodeTypeGroupers ctg ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	WHERE ctg.CodeTypeGroupersName IN (
			'Encounter Types(Internal)'
			,'Utilization Type (Internal)'
			,'Encounter Type (Internal) by Code Type'
			,'CCS ICD Procedure 4Classes'
			,'CCS Chronic Diagnosis Group'
			,'CCS Diagnosis Group'
			)
	
	UNION
	
	SELECT CodeGroupingID,0
	FROM CodeGrouping
	WHERE CodeGroupingName IN (
			'A1C'
			,'LDL'
			)

	UPDATE BatchStatus 
	   SET NoofTotalCodes =(SELECT 
								COUNT(DISTINCT CodeGroupingID)
							FROM 
							   #CodeGroup )
	WHERE BatchStatusId = @i_Identity

	

	DECLARE CurDR CURSOR
	FOR
	SELECT DISTINCT cg.CodeGroupingID
		,'usp_Batch_PopulateCodeGroup'
	FROM CodeGrouping cg
	INNER JOIN CodeGroupingDetailInternal cgdi ON cg.CodeGroupingID = cgdi.CodeGroupingID
	INNER JOIN #CodeGroup cg1 ON cg.CodeGroupingID = cg1.CodeGroupingID
	WHERE (
			cg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)
	
	UNION ALL
	
	SELECT DISTINCT cg.CodeGroupingID
		,'usp_Batch_PopulateCodeGroupForHedis'
	FROM CodeGrouping cg
	INNER JOIN CodeGroupingECTTable cgdi ON cg.CodeGroupingID = cgdi.CodeGroupingID
	INNER JOIN #CodeGroup cg1 ON cg.CodeGroupingID = cg1.CodeGroupingID
	WHERE (
			cg.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)

	OPEN CurDR

	FETCH NEXT
	FROM CurDR
	INTO @i_CodeGroupingID1
		,@vc_SPName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT @vc_SQL = ' EXEC ' + '[' + @vc_SPName + ']' + ' ' + '@i_AppUserId = ' + CAST(@i_AppUserId AS VARCHAR(10)) + ',' + '@i_CodeGroupingID = ' + CAST(@i_CodeGroupingID1 AS VARCHAR(10))

		BEGIN TRY
			RAISERROR (
					@vc_SQL
					,0
					,1
					)
			WITH NOWAIT
			
			UPDATE BatchStatus 
			  SET BatchStatus = @vc_SQL
			WHERE  BatchStatusId = @i_Identity
			  
			EXEC SP_EXECUTESQL @vc_SQL
				--PRINT @vc_SQL
			UPDATE #CodeGroup 
			  SET IsCompleted =1 
			WHERE CodeGroupingID = @i_CodeGroupingID1
			
			
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
				SELECT @i_CodeGroupingID1
					,NULL
					,@vc_SQL
					,ERROR_MESSAGE()
			END
		END CATCH

		FETCH NEXT
		FROM CurDR
		INTO @i_CodeGroupingID1
			,@vc_SPName
	END

	CLOSE CurDR

	DEALLOCATE CurDR
	
	UPDATE BatchStatus 
	   SET BatchStatus = 'Utilization Other Groupers processing'
	WHERE BatchStatusId = @i_Identity
	-- Utilization Other Group
	CREATE TABLE #otherCTE (ClaimInfoId INT)

	INSERT INTO #otherCTE
	SELECT DISTINCT ppc.ClaimInfoId
	FROM PatientProcedureCode ppc
	INNER JOIN PatientProcedureCodeGroup ppcg ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
	INNER JOIN CodeGrouping cg ON cg.CodeGroupingID = ppcg.CodeGroupingID
	INNER JOIN CodeTypeGroupers ctg ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN CodeGroupingType cgt ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	WHERE ppc.StatusCode = 'A'
		AND ppcg.StatusCode = 'A'
		AND cgt.CodeGroupType = 'Utilization Groupers'
		AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'
	
	UNION
	
	SELECT DISTINCT ppc.ClaimInfoId
	FROM PatientOtherCode ppc
	INNER JOIN PatientOtherCodeGroup ppcg ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
	INNER JOIN CodeGrouping cg ON cg.CodeGroupingID = ppcg.CodeGroupingID
	INNER JOIN CodeTypeGroupers ctg ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN CodeGroupingType cgt ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	WHERE ppc.StatusCode = 'A'
		AND ppcg.StatusCode = 'A'
		AND cgt.CodeGroupType = 'Utilization Groupers'
		AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'

	UPDATE ClaimInfo
	SET IsOtherUtilizationGroup = 1
	WHERE NOT EXISTS (
			SELECT 1
			FROM #otherCTE c
			WHERE c.ClaimInfoId = ClaimInfo.ClaimInfoID
			)
			
	UPDATE BatchStatus
	  SET BatchStatus = 'Completed',
	      NoOfProcessed =( SELECT 
	                          COUNT(1)
	                       FROM #CodeGroup WHERE IsCompleted = 1
	                      ),
	      EndDate = GETDATE()   

	

END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_PopulateCodeGroupWrapper] TO [FE_rohit.r-ext]
    AS [dbo];

