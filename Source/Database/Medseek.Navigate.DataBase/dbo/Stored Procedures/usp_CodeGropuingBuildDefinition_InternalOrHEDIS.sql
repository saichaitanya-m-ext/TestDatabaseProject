
/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_CodeGropuingBuildDefinition_InternalOrHEDIS] 2,368,'HEDIS-l'  
Description   : This procedure is used to Get the  Table in Tree Structure Format       
Created By    : Gurumoorthy V  
Created Date  : 28-May-2013  
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION    
06-07-2013    Prathyusha MOdified sp for to populate Column
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_CodeGropuingBuildDefinition_InternalOrHEDIS] (
	@i_AppUserID KEYID
	,@i_CodeGroupingID KEYID
	,@vc_CodeGroupType VARCHAR(20)
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

	IF (@vc_CodeGroupType <> 'HEDIS-ECT')
	BEGIN
		SELECT DISTINCT CodeGroupingID
			,CodeGroupingName --+ ' - ' +  CTG.CodeTypeGroupersName AS CodeGroupingName
			,NULL AS CodeGroupingID
		FROM CodeGrouping CG
		INNER JOIN CodeTypeGroupers CTG ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		WHERE CodeGroupingID = @i_CodeGroupingID

		--UNION ALL
		SELECT DISTINCT CI.CodeGroupingCodeTypeID
			,CT.CodeTypeCode AS ECTHedisCodeTypeCode
			,CI.CodeGroupingID
		FROM CodeGroupingDetailInternal CI
		INNER JOIN LkUpCodeType CT ON CI.CodeGroupingCodeTypeID = CT.CodeTypeID
		WHERE CI.CodeGroupingID = @i_CodeGroupingID
		ORDER BY ECTHedisCodeTypeCode

		--UNION ALL
		SELECT DISTINCT CodeGroupingDetailInternalID AS CodeGroupingDetailInternallID
			,dbo.ufn_GetCodeSetCodeByLkupCodeTypeID(ct.CodeTypeCode, ci.CodeGroupingCodeID) CodeGroupingCodeID
			,ct.CodeTypeID AS CodeGroupingCodeTypeID
		FROM CodeGroupingDetailInternal ci
		INNER JOIN LkUpCodeType ct ON ci.CodeGroupingCodeTypeID = ct.CodeTypeID
		WHERE ci.CodeGroupingID = @i_CodeGroupingID
	END
	ELSE
	BEGIN
		SELECT DISTINCT CodeGroupingID
			,CodeGroupingName -- + ' - ' +  CTG.CodeTypeGroupersName AS CodeGroupingName
			,NULL AS CodeGroupingID
		FROM CodeGrouping CG
		INNER JOIN CodeTypeGroupers CTG ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		WHERE CodeGroupingID = @i_CodeGroupingID

		DECLARE @v_ECTCodeDescription VARCHAR(500)

		SELECT @v_ECTCodeDescription = ECTTableDescription
		FROM CodeGroupingECTTable
		WHERE CodeGroupingID = @i_CodeGroupingID
			AND ECTTableDescription <> ''

		DECLARE @v_ECTCodeTableColumnID VARCHAR(500)

		SELECT @v_ECTCodeTableColumnID = Cg.ECTHedisCodeTypeID
		FROM CodeGroupingECTTable Cg
		WHERE CodeGroupingID = @i_CodeGroupingID
			AND cg.ECTHedisCodeTypeID <> ''

		SELECT DISTINCT cscc.ECTHedisCodeTypeID AS CodeGroupingCodeTypeID
			,csect.ECTHedisCodeTypeCode
			,cget.CodeGroupingID
		FROM CodeGroupingECTTable cget
		INNER JOIN CodeSetECTHedisTable cseht ON cget.ECThedisTableID = cseht.ECTHedisTableID
		INNER JOIN CodeSetHEDIS_ECTCode cscc ON cscc.ECTHedisTableID = cseht.ECTHedisTableID
		INNER JOIN CodeSetECTHedisCodeType csect ON csect.ECTHedisCodeTypeID = cscc.ECTHedisCodeTypeID
		WHERE cget.CodeGroupingID = @i_CodeGroupingID
			AND (
				cscc.ECTCodeDescription = @v_ECTCodeDescription
				OR @v_ECTCodeDescription IS NULL
				)
			AND (
				csect.ECTHedisCodeTypeID = @v_ECTCodeTableColumnID
				OR @v_ECTCodeTableColumnID IS NULL
				)
		ORDER BY ECTHedisCodeTypeCode

		CREATE TABLE #HedisECT (
			CodeGroupingDetailInternallID INT IDENTITY(1, 1)
			,ECTCode VARCHAR(2000)
			,CodeGroupingCodeTypeID INT
			)

		INSERT INTO #HedisECT
		SELECT DISTINCT ECTCode + ' - ' + ISNULL(ECTCodeDescription, '') AS ECTCode
			,csect.ECTHedisCodeTypeID AS CodeGroupingCodeTypeID
		FROM CodeGroupingECTTable cget
		INNER JOIN CodeSetECTHedisTable cseht ON cget.ECThedisTableID = cseht.ECTHedisTableID
		INNER JOIN CodeSetHEDIS_ECTCode cscc ON cscc.ECTHedisTableID = cseht.ECTHedisTableID
		INNER JOIN CodeSetECTHedisCodeType csect ON csect.ECTHedisCodeTypeID = cscc.ECTHedisCodeTypeID
		WHERE cget.CodeGroupingID = @i_CodeGroupingID
			AND (
				cscc.ECTCodeDescription = @v_ECTCodeDescription
				OR @v_ECTCodeDescription IS NULL
				)
			AND (
				csect.ECTHedisCodeTypeID = @v_ECTCodeTableColumnID
				OR @v_ECTCodeTableColumnID IS NULL
				)

		SELECT *
		FROM #HedisECT
	END
END TRY

-----------------------------------------------------------------------------------------------------------------------------------        
BEGIN CATCH
	-- Handle exception            
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CodeGropuingBuildDefinition_InternalOrHEDIS] TO [FE_rohit.r-ext]
    AS [dbo];

