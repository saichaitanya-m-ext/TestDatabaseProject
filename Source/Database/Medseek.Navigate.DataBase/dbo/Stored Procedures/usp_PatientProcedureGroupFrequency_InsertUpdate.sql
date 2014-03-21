
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_PatientProcedureGroupFrequency_InsertUpdate     
Description   : This procedure is used to insert record into PatientProcedureGroupFrequency table  
Created By    : Rathnam      
Created Date  : 25-July-2013
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_PatientProcedureGroupFrequency_InsertUpdate] (
	@i_AppUserId KeyId
	,@i_PatientId KEYID
	,@i_CodeGroupingID KEYID
	,@i_FrequencyNumber INT
	,@v_Frequency statuscode
	,@d_EffectiveStartDate DATETIME = NULL
	,@i_ManagedPopulationID INT
	,@i_AssignedCareProviderId INT
	,@v_StatusCode VARCHAR(1)
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT

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
			FROM PatientProcedureGroupFrequency f
			WHERE f.PatientId = @i_PatientId
				AND f.CodeGroupingID = @i_CodeGroupingID
			)
	BEGIN
		INSERT INTO PatientProcedureGroupFrequency (
			PatientId
			,CodeGroupingID
			,FrequencyNumber
			,Frequency
			,EffectiveStartDate
			,ManagedPopulationID
			,AssignedCareProviderId
			,StatusCode
			,CreatedByUserId
			,CreatedDate
			)
		VALUES (
			@i_PatientId
			,@i_CodeGroupingID
			,@i_FrequencyNumber
			,@v_Frequency
			,@d_EffectiveStartDate
			,@i_ManagedPopulationID
			,@i_AssignedCareProviderId
			,@v_StatusCode
			,@i_AppUserId
			,GETDATE()
			)
	END
	ELSE
	BEGIN
		UPDATE PatientProcedureGroupFrequency
		SET FrequencyNumber = @i_FrequencyNumber
			,Frequency = @v_Frequency
			,EffectiveStartDate = @d_EffectiveStartDate
			,ManagedPopulationID = @i_ManagedPopulationID
			,AssignedCareProviderId = @i_AssignedCareProviderId
			,StatusCode = @v_StatusCode
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
		WHERE CodeGroupingID = @i_CodeGroupingID
			AND PatientId = @i_PatientId
	END

	IF NOT EXISTS (
			SELECT 1
			FROM PatientProcedureGroupTask t
			WHERE t.PatientID = @i_PatientId
				AND t.CodeGroupingID = @i_CodeGroupingID
				AND t.ManagedPopulationID = @i_ManagedPopulationID
				AND t.ProcedureGroupCompletedDate IS NULL
			)
	BEGIN
		DECLARE @d_Duedate DATE

		SET @d_Duedate = DATEADD(DD, CASE 
					WHEN @v_Frequency = 'D'
						THEN @i_FrequencyNumber * 1
					WHEN @v_Frequency = 'W'
						THEN @i_FrequencyNumber * 7
					WHEN @v_Frequency = 'M'
						THEN @i_FrequencyNumber * 30
					WHEN @v_Frequency = 'Y'
						THEN @i_FrequencyNumber * 365
					END, @d_EffectiveStartDate)
	END

	INSERT INTO PatientProcedureGroupTask (
		PatientID
		,CodeGroupingID
		,DueDate
		,ManagedPopulationID
		,AssignedCareProviderId
		,StatusCode
		,CreatedByUserId
		)
	VALUES (
		@i_PatientId
		,@i_CodeGroupingID
		,@d_Duedate
		,@i_ManagedPopulationID
		,@i_AssignedCareProviderId
		,@v_StatusCode
		,@i_AppUserId
		)
END TRY

--------------------------------------------------------       
BEGIN CATCH
	-- Handle exception      
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientProcedureGroupFrequency_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

