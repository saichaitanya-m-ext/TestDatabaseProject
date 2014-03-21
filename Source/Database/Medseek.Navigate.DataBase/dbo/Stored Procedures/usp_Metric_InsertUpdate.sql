
/*    
-------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_Metrics_InsertUpdate]    
Description   : This procedure is used to insert and Update records into Metrics table and   
  
Created By    : P.V.P.Mohan   
Created Date  : 15-Nov-2012    
-------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
24-Nov-2012 Rathnam restructured the metric table.  
05-Dec-2012 Mohan Added parameters the metric table. 
25-July-2013 NagaBabu Removed Extra BEGIN ,END statements
30-Oct-2013 Mohan Removed Update Code because ISPrimary Col is nolonger Available.
-------------------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Metric_InsertUpdate] (
	@i_AppUserId KEYID
	,@v_Name VARCHAR(100)
	,@v_Description VARCHAR(500)
	,@i_StandardId KEYID = NULL
	,@i_StandardOrganizationID KEYID = NULL
	,@i_IOMCategoryID KEYID = NULL
	,@i_InsuranceGroupID KEYID = NULL
	,@v_DenominatorType VARCHAR(1)
	,@i_DenominatorID KEYID
	,@v_StatusCode STATUSCODE
	,@i_IsPrimary BIT = 0
	,@i_NumeratorID KEYID
	,@i_MeasureID KEYID
	,@i_ValueAttributeID INT = NULL
	,@i_MetricId KEYID = NULL
	,@o_MetricId INT = NULL OUTPUT
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

	------------------insert operation into Metrics table-----     
	DECLARE @l_TranStarted BIT = 0

	IF (@@TRANCOUNT = 0)
	BEGIN
		BEGIN TRANSACTION

		SET @l_TranStarted = 1 -- Indicator for start of transactions
	END
	ELSE
	BEGIN
		SET @l_TranStarted = 0
	END

	DECLARE @v_NumeratorType VARCHAR(2)
	DECLARE @v_NewMetricID INT

	SELECT @v_NumeratorType = NumeratorType
	FROM PopulationDefinition
	WHERE PopulationDefinitionID = @i_NumeratorID

	IF @i_MetricId IS NULL
		OR @i_MetricId = 0
	BEGIN
		
		    INSERT INTO Metric (
				NAME
				,Description
				,StandardId
				,StandardOrganizationID
				,IOMCategoryID
				,DenominatorType
				,DenominatorID
				,StatusCode
				,NumeratorID
				,ValueAttributeID
				,CreatedByUserId
				,CreatedDate
				,ManagedPopulationID
				)
			VALUES (
				@v_Name
				,@v_Description
				,@i_StandardId
				,@i_StandardOrganizationID
				,@i_IOMCategoryID
				,@v_DenominatorType
				,CASE WHEN @v_DenominatorType = 'M' 
				THEN (SELECT PopulationDefinitionid FROM Program WHERE ProgramId= @i_DenominatorID) ELSE @i_DenominatorID END
				,@v_StatusCode
				,@i_NumeratorID
				,@i_ValueAttributeID
				,@i_AppUserId
				,GETDATE()
				,CASE WHEN @v_DenominatorType = 'M' THEN @i_DenominatorID ELSE NULL END
				)

			SET @o_MetricId = SCOPE_IDENTITY();

			WITH metCTE
			AS (
				SELECT 1 Sno
					,@o_MetricId MetricId
					,@i_AppUserId AppUserId
					,GETDATE() Dt
					,'GD' Label
				
				UNION
				
				SELECT 2
					,@o_MetricId
					,@i_AppUserId
					,GETDATE()
					,'FR'
				
				UNION
				
				SELECT 3
					,@o_MetricId
					,@i_AppUserId
					,GETDATE()
					,'PR'
				
				UNION
				
				SELECT 4
					,@o_MetricId
					,@i_AppUserId
					,GETDATE()
					,'NC'
				
				UNION
				
				SELECT 5
					,@o_MetricId
					,@i_AppUserId
					,GETDATE()
					,'NT'
				)
			INSERT INTO MetricnumeratorFrequency (
				MetricID
				,CreatedByUserId
				,CreatedDate
				,Label
				)
			SELECT MetricId
				,AppUserId
				,Dt
				,Label
			FROM metCTE
			ORDER BY Sno

			--IF @i_IsPrimary = 1
			--BEGIN
			--	UPDATE Metric
			--	SET IsPrimary = 0
			--	WHERE DenominatorID = @i_DenominatorID
			--		AND DenominatorType = @v_DenominatorType
			--		AND MetricId <> @o_MetricId
			--END
		
	END
	ELSE
	BEGIN
		UPDATE Metric
		SET NAME = @v_Name
			,Description = @v_Description
			,StandardId = @i_StandardId
			,StandardOrganizationID = @i_StandardOrganizationID
			,IOMCategoryID = @i_IOMCategoryID
			,DenominatorType = @v_DenominatorType
			,DenominatorID = CASE WHEN @v_DenominatorType = 'M' THEN (SELECT PopulationDefinitionid FROM Program WHERE ProgramId= @i_DenominatorID) ELSE @i_DenominatorID END
			,StatusCode = @v_StatusCode
			,NumeratorID = @i_NumeratorID
			,ValueAttributeID = @i_ValueAttributeID
			,LastModifiedByUserId = @i_AppUserId
			,LastModifiedDate = GETDATE()
			,ManagedPopulationID = CASE WHEN @v_DenominatorType = 'M' THEN @i_DenominatorID ELSE NULL END
		WHERE MetricId = @i_MetricId

		IF NOT EXISTS (
				SELECT 1
				FROM MetricnumeratorFrequency
				WHERE Label IS NOT NULL
					AND MetricId = @i_MetricId
				)
		BEGIN
			DELETE
			FROM MetricnumeratorFrequency
			WHERE MetricId = @i_MetricId;

			WITH metCTE
			AS (
				SELECT 1 Sno
					,@i_MetricId MetricId
					,@i_AppUserId AppUserId
					,GETDATE() Dt
					,'GD' Label
				
				UNION
				
				SELECT 2
					,@i_MetricId
					,@i_AppUserId
					,GETDATE()
					,'FR'
				
				UNION
				
				SELECT 3
					,@i_MetricId
					,@i_AppUserId
					,GETDATE()
					,'PR'
				
				UNION
				
				SELECT 4
					,@i_MetricId
					,@i_AppUserId
					,GETDATE()
					,'NC'
				
				UNION
				
				SELECT 5
					,@i_MetricId
					,@i_AppUserId
					,GETDATE()
					,'NT'
				)
			INSERT INTO MetricnumeratorFrequency (
				MetricID
				,CreatedByUserId
				,CreatedDate
				,Label
				)
			SELECT MetricId
				,AppUserId
				,Dt
				,Label
			FROM metCTE
			ORDER BY Sno
		END
				
	END

	IF (@l_TranStarted = 1) -- If transactions are there, then commit
	BEGIN
		SET @l_TranStarted = 0

		COMMIT TRANSACTION
	END
END TRY

------------------------------------------------------------------------------------------------------------------------------  
BEGIN CATCH
	-- Handle exception    
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Metric_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

