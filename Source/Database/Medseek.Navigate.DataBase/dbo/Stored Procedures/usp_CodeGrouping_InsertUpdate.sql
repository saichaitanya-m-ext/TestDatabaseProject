
/*      
---------------------------------------------------------------------------------------      
Procedure Name: usp_CodeGrouping_InsertUpdate    
Description   : This proc is used to Insert  CodeGrouping record  
Created By    : Mohan  
Created Date  : 22-MAY-2013  
---------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION     
06-07-2013 Modified By prathyusha. Added New parameter ECTTableColumn 
  
---------------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_CodeGrouping_InsertUpdate] (
	@i_AppUserId KEYID
	,@i_CodeGroupTypeID INT
	,@vc_CodeGroupingName VARCHAR(50)
	,@vc_CodeGroupingDescription VARCHAR(500)
	,@vc_Synonyms VARCHAR(50)
	,@i_CodeTypeGroupersID KEYID
	,@i_ECTHedisTableID INT = NULL
	,@vc_ECTCodeDescription VARCHAR(500) = NULL
	,@i_ECTHedisCodeTypeID INT = NULL
	--,@vc_ECTCodeTableColumn VARCHAR(500) = NULL
	,@b_NonModifiable BIT
	,@b_IsPrimary BIT
	,@b_ProductionStatus StatusCode
	,@b_DisplayStatus BIT
	,@b_StatusCode StatusCode
	,@i_CodeGroupingID INT
	,@o_CodeGroupingID KEYID OUTPUT
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @vc_CodeGroupingSource VARCHAR(50)

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

	BEGIN TRANSACTION

	SET @vc_CodeGroupingSource = (
			SELECT CodeTypeGroupersName
			FROM CodeTypeGroupers
			WHERE CodeTypeGroupersID = @i_CodeTypeGroupersID
			)

	IF @i_CodeGroupingID IS NULL
	BEGIN
		INSERT INTO CodeGrouping (
			CodeGroupingName
			,CodeGroupingDescription
			,CodeTypeGroupersID
			,NonModifiable
			,IsPrimary
			,ProductionStatus
			,DisplayStatus
			,StatusCode
			,CreatedByUserId
			,CreatedDate
			)
		VALUES (
			@vc_CodeGroupingName
			,@vc_CodeGroupingDescription
			,@i_CodeTypeGroupersID
			,@b_NonModifiable
			,@b_IsPrimary
			,@b_ProductionStatus
			,@b_DisplayStatus
			,@b_StatusCode
			,@i_AppUserId
			,GETDATE()
			)

		SELECT @o_CodeGroupingID = SCOPE_IDENTITY()

		IF @i_ECTHedisTableID IS NOT NULL
			AND @vc_CodeGroupingSource = 'HEDIS-ECT'
		BEGIN
			INSERT INTO CodeGroupingECTTable (
				CodeGroupingID
				,ECThedisTableID
				,ECTTableDescription
				,ECTHedisCodeTypeID
				,StatusCode
				,CreatedByUserId
				)
			VALUES (
				@o_CodeGroupingID
				,@i_ECTHedisTableID
				,CASE 
					WHEN @vc_ECTCodeDescription = ''
						THEN NULL
					ELSE @vc_ECTCodeDescription
					END
				,CASE 
					WHEN @i_ECTHedisCodeTypeID = 0
						THEN NULL
					ELSE @i_ECTHedisCodeTypeID
					END
				,@b_StatusCode
				,@i_AppUserId
				)
		END

		BEGIN
			INSERT INTO CodeGroupingSynonyms (
				CodeGroupingID
				,CodeGroupingSynonym
				,CreatedByUserId
				)
			VALUES (
				@o_CodeGroupingID
				,@vc_Synonyms
				,@i_AppUserId
				)
		END
	END
	ELSE
	BEGIN
		IF @i_CodeGroupingID IS NOT NULL
		BEGIN
			UPDATE CodeGrouping
			SET CodeGroupingName = @vc_CodeGroupingName
				,CodeGroupingDescription = @vc_CodeGroupingDescription
				,CodeTypeGroupersID = @i_CodeTypeGroupersID
				,NonModifiable = @b_NonModifiable
				,IsPrimary = @b_IsPrimary
				,ProductionStatus = @b_ProductionStatus
				,DisplayStatus = @b_DisplayStatus
				,StatusCode = @b_StatusCode
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
			WHERE CodeGroupingID = @i_CodeGroupingID

			IF @i_ECTHedisTableID IS NOT NULL
				AND @vc_CodeGroupingSource = 'HEDIS-ECT'
			BEGIN
				UPDATE CodeGroupingECTTable
				SET ECThedisTableID = @i_ECTHedisTableID
					,ECTTableDescription = @vc_ECTCodeDescription
					,ECTHedisCodeTypeID = @i_ECTHedisCodeTypeID
					,StatusCode = @b_StatusCode
					,LastModifiedByUserId = @i_AppUserId
					,LastModifiedDate = GETDATE()
				WHERE CodeGroupingID = @i_CodeGroupingID
			END

			BEGIN
				UPDATE CodeGroupingSynonyms
				SET CodeGroupingSynonym = @vc_Synonyms
					,LastModifiedByUserId = @i_AppUserId
					,LastModifiedDate = GETDATE()
				WHERE CodeGroupingID = @i_CodeGroupingID
			END
		END
	END

	COMMIT TRANSACTION
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
    ON OBJECT::[dbo].[usp_CodeGrouping_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

