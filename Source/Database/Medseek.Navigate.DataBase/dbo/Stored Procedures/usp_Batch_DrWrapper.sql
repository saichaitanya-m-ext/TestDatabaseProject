
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_DrWrapper]  
Description   : This proc is used to extract the data from CodeGroupers OR Hedis tables 
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_DrWrapper] --1,20121130
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

	IF NOT EXISTS (
			SELECT 1
			FROM PopulationDefinitionConfiguration pdc
			WHERE pdc.MetricID IS NULL
				AND pdc.IsConflictParameter = 1
			)
	BEGIN
		UPDATE Report
		SET IsProcessing = 1

		IF @v_DateKey IS NULL
		BEGIN
			DECLARE @t_AnchorDate TABLE (AanchorDate INT)

			INSERT INTO @t_AnchorDate (AanchorDate)
			SELECT DISTINCT rfd.AnchorDate AnchorDate
			FROM ReportFrequency rf WITH (NOLOCK)
			INNER JOIN ReportFrequencyDate rfd WITH (NOLOCK)
				ON rfd.ReportFrequencyId = rf.ReportFrequencyId
			INNER JOIN Report r WITH (NOLOCK)
				ON r.ReportId = rf.ReportID
			WHERE ISNULL(IsReadyForETL, 0) = 1
				AND CONVERT(DATE, rf.FrequencyEndDate) > = CONVERT(DATE, GETDATE())
				AND convert(DATE, LEFT(CONVERT(VARCHAR(8), rfd.AnchorDate), 4) + SUBSTRING(CONVERT(VARCHAR(8), rfd.AnchorDate), 5, 2) + RIGHT(CONVERT(VARCHAR(8), rfd.AnchorDate), 2)) <= (GETDATE())
				AND r.ReportName <> 'Care Management Metric'
				AND ISNULL(rfd.IsETLCompleted, 0) = 0

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
				EXEC usp_Batch_DrPatientsByInternalWrapper @i_AppUserId = @i_AppUserId
					,@v_DateKey = @i_Min
					,@i_DrID = @i_DrID

				EXEC usp_Batch_DrPatientsByStandard @i_AppUserId = @i_AppUserId
					,@v_DateKey = @i_Min
					,@i_DrID = @i_DrID

				DELETE
				FROM @t_AnchorDate
				WHERE AanchorDate = @i_Min

				SELECT @i_Min = MIN(AanchorDate)
				FROM @t_AnchorDate
			END
		END
		ELSE
		BEGIN
			EXEC usp_Batch_DrPatientsByInternalWrapper @i_AppUserId = @i_AppUserId
				,@v_DateKey = @v_DateKey
				,@i_DrID = @i_DrID

			EXEC usp_Batch_DrPatientsByStandard @i_AppUserId = @i_AppUserId
				,@v_DateKey = @v_DateKey
				,@i_DrID = @i_DrID
		END
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
    ON OBJECT::[dbo].[usp_Batch_DrWrapper] TO [FE_rohit.r-ext]
    AS [dbo];

