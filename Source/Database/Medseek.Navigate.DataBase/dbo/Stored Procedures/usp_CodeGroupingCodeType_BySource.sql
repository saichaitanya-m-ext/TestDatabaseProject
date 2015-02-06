
/*  
------------------------------------------------------------------------------  
Procedure Name:   [USP_CODEGROUPINGCODETYPE_BySource] 2,'Internal',2
Description   : This procedure is used to get the details from codegroupingcodetype table
Created By    : Gurumoorthy V  
Created Date  : 22-May-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CodeGroupingCodeType_BySource] (
	@i_AppUserId KEYID
	,@v_CodeSource VARCHAR(50) = NULL
	,@v_ECTHedisTableID KEYID = NULL
	,@v_ECTCodeDescription VARCHAR(200) = NULL
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
				,24
				,@i_AppUserId
				)
	END

	IF (@v_CodeSource IS NULL)
		AND (@v_ECTHedisTableID IS NULL)
	BEGIN
		SELECT DISTINCT CodeGroupingTypeID
			,CodeGroupType
		FROM CodeGroupingType
		WHERE StatusCode = 'A'
	END
	ELSE
		IF (
				@v_CodeSource = 'Internal'
				OR @v_CodeSource = 'Encounter Types(Internal)'
				)
			AND (@v_ECTHedisTableID IS NULL)
		BEGIN
			SELECT DISTINCT CodeTypeID AS CodeGroupingCodeTypeID
				,CodeTypeCode AS CodeGroupingCodeTypeName
			FROM LkUpCodeType
			WHERE StatusCode = 'A'
				AND ISSHOW = 1
		END
		ELSE
			IF (@v_CodeSource = 'HEDIS-ECT')
				AND (@v_ECTHedisTableID IS NULL)
			BEGIN
				SELECT DISTINCT ECTHedisTableID
					,ECTHedisTableName
				FROM codesetECTHedistable
				WHERE StatusCode = 'A'
			END
			ELSE
				IF (@v_ECTHedisTableID IS NOT NULL)
				BEGIN
					IF (@v_ECTCodeDescription IS NULL)
					BEGIN
						SELECT HEDIS_ECTCodeID = ROW_NUMBER() OVER (
								ORDER BY ECTCodeDescription
								)
							,ECTCodeDescription
						FROM (
							SELECT DISTINCT ECTCodeDescription
							FROM CodeSetHEDIS_ECTCode
							WHERE ecthedistableid = @v_ECTHedisTableID
								AND ECTCodeDescription IS NOT NULL
							) AS CodeGroup
					END
					ELSE
						IF (@v_ECTCodeDescription IS NOT NULL)
						BEGIN
							SELECT DISTINCT ct.ECTHedisCodeTypeID AS ECTHedisCodeTypeID
								,CT.ECTHedisCodeTypeCode AS CodeGroupingCodeTypeName
							FROM CodeSetHEDIS_ECTCode ect
							INNER JOIN CodeSetECTHedisCodeType ct ON ect.ECTHedisCodeTypeID = ct.ECTHedisCodeTypeID
							WHERE ECTCodeDescription = @v_ECTCodeDescription
								AND ECTHedistableid = @v_ECTHedisTableID
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
    ON OBJECT::[dbo].[usp_CodeGroupingCodeType_BySource] TO [FE_rohit.r-ext]
    AS [dbo];

