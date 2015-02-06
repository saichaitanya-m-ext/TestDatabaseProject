
/*    
---------------------------------------------------------------------------------------    
Procedure Name: [usp_MetricGoals_InsertUpdate]
Description   : This procedure is used to create MetricsGoal record
Created By    : P.V.P.Mohan
Created Date  : 23-Nov-2012
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    

---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_MetricGoals_InsertUpdate] (
	@i_AppUserId INT
	,@i_MetricnumeratorFrequencyId KEYID
	,@v_EntityType VARCHAR(2)
	,@t_EntityTypeId TTYPEKEYID READONLY
	,@i_GoalRange INT
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

	UPDATE MetricnumeratorFrequency
	SET EntityType = @v_EntityType
		,Goal = @i_GoalRange
	WHERE MetricNumeratorFrequencyId = @i_MetricnumeratorFrequencyId

	DELETE
	FROM NumeratorGoal
	WHERE MetricnumeratorFrequencyId = @i_MetricnumeratorFrequencyId

	INSERT INTO NumeratorGoal
	SELECT @i_MetricnumeratorFrequencyId
		,t.tKeyId
	FROM @t_EntityTypeId t
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
    ON OBJECT::[dbo].[usp_MetricGoals_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

