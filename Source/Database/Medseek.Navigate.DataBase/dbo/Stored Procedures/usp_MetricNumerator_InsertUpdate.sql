
/*    
---------------------------------------------------------------------------------------    
Procedure Name: usp_Numerator_InsertUpdate  
Description   : This procedure is used to create Numerator record
Created By    : P.V.P.Mohan
Created Date  : 22-Nov-2012
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    

---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_MetricNumerator_InsertUpdate] --23,3,65,'=>',2,'>',3,4,'A',4,null
	(
	@i_AppUserId KEYID
	,@i_MetricsID KEYID
	,@v_FromOperator VARCHAR(20)
	,@i_FromFrequency VARCHAR(6)
	,@v_ToOperator VARCHAR(20)
	,@i_ToFrequency VARCHAR(6)
	,@i_MetricNumeratorId KEYID
	,@o_MetricNumeratorId KEYID OUTPUT
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

	DECLARE @l_numberOfRecordsInserted INT
		,@l_numberOfRecordsUpdated INT

	IF @i_MetricNumeratorId IS NULL
	BEGIN
		INSERT INTO MetricnumeratorFrequency (
			MetricID
			,FromOperator
			,FromFrequency
			,ToOperator
			,ToFrequency
			,CreatedByUserId
			,CreatedDate
			)
		VALUES (
			@i_MetricsID
			,@v_FromOperator
			,@i_FromFrequency
			,@v_ToOperator
			,@i_ToFrequency
			,@i_AppUserId
			,GETDATE()
			)

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
			,@o_MetricNumeratorId = SCOPE_IDENTITY()
	END

	IF @l_numberOfRecordsInserted <> 1
	BEGIN
		RAISERROR (
				N'Invalid row count %d in insert TaskBundle'
				,17
				,1
				,@l_numberOfRecordsInserted
				)
	END
	ELSE
	BEGIN
		IF @i_MetricNumeratorId IS NOT NULL
		BEGIN
			UPDATE MetricNumeratorFrequency
			SET MetricID = @i_MetricsID
				,FromOperator = @v_FromOperator
				,FromFrequency = @i_FromFrequency
				,ToOperator = @v_ToOperator
				,ToFrequency = @i_ToFrequency
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			WHERE MetricNumeratorFrequencyId = @i_MetricNumeratorId

			SET @l_numberOfRecordsUpdated = @@ROWCOUNT

			IF @l_numberOfRecordsUpdated <> 1
				
			BEGIN
				RAISERROR (
						N'Invalid row count %d in Update TaskBundle'
						,17
						,1
						,@l_numberOfRecordsUpdated
						)
			END
		END
	END
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
    ON OBJECT::[dbo].[usp_MetricNumerator_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

