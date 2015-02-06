/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_CodeGropuingBuildDefinition_PDF] 2,70,'CCS Diagnosis Group'  
Description   : This procedure is used to Get the  Table in Tree Structure Format       
Created By    : Gurumoorthy V  
Created Date  : 29-May-2013  
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION    
06-07-2013    Prathyusha MOdified sp for to populate Column                     
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_CodeGropuingBuildDefinition_PDF] (
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

	IF (
			@vc_CodeGroupType <> 'HEDIS-ECT'
			)
	BEGIN
		SELECT DISTINCT CG.CodeGroupingID
			,CASE 
			WHEN CTG.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group' 
				THEN CG.CodeGroupingName + ' - Chronic' 
				ELSE CG.CodeGroupingName 
			END AS CodeGroupingName
			,CTG.CodeTypeGroupersName AS CodeGroupingSource
			,CASE 
			WHEN 
				LEN(CG.CodeGroupingCode)>0 
			THEN CG.CodeGroupingDescription + ' - ' + LTRIM(RTRIM(CTG.CodeTypeShortDescription)) + ' ' + ISNULL(CG.CodeGroupingCode,'') + '' 
			ELSE CG.CodeGroupingDescription 
			END As CodeGroupingDescription
			,'' AS ECTHedisTableName
			,'' AS ECTTableDescription
			,'' AS ECTTableColumn
		FROM CodeGrouping CG
		INNER JOIN CodeTypeGroupers CTG
			ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		WHERE CodeGroupingID = @i_CodeGroupingID

		SELECT DISTINCT ci.CodeGroupingCodeTypeID
			,ct.CodeTypeCode ECTHedisCodeTypeCode
			,ci.CodeGroupingID
			,dbo.ufn_GetGroupCodeListByCodeTypeID(ct.CodeTypeCode, ci.CodeGroupingID) CodeGroupList
		FROM CodeGroupingDetailInternal ci
		INNER JOIN LkUpCodeType ct
			ON ci.CodeGroupingCodeTypeID = ct.CodeTypeID
		WHERE ci.CodeGroupingID = @i_CodeGroupingID
		ORDER BY ECTHedisCodeTypeCode
	END
	ELSE
		BEGIN
			SELECT DISTINCT CG.CodeGroupingID
				,CASE 
					WHEN CTG.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group' 
						THEN CG.CodeGroupingName + ' - Chronic' 
						ELSE CG.CodeGroupingName 
					END AS CodeGroupingName
				,CTG.CodeTypeGroupersName AS CodeGroupingSource
				,CASE 
					WHEN 
						LEN(CG.CodeGroupingCode)>0 
					THEN CG.CodeGroupingDescription + ' - ' + LTRIM(RTRIM(CTG.CodeTypeShortDescription)) + ' ' + ISNULL(CG.CodeGroupingCode,'') + '' 
					ELSE CG.CodeGroupingDescription 
					END As CodeGroupingDescription
				,CST.ECTHedisTableName
				,CGT.ECTTableDescription
				,CGT.ECTTableColumn
			FROM CodeGrouping CG
			INNER JOIN CodeTypeGroupers CTG
				ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
			INNER JOIN CodeGroupingECTTable CGT
				ON CG.CodeGroupingID = CGT.CodeGroupingID
			INNER JOIN CodeSetECTHedisTable CST
				ON CGT.ECThedisTableID = CST.ECTHedisTableID
			WHERE CG.CodeGroupingID = @i_CodeGroupingID

			DECLARE @v_ECTCodeDescription VARCHAR(500)

			SELECT @v_ECTCodeDescription = ECTTableDescription
			FROM CodeGroupingECTTable
			WHERE CodeGroupingID = @i_CodeGroupingID
				AND ECTTableDescription <> ''

			DECLARE @v_ECTCodeTableColumnID VARCHAR(500)

			SELECT @v_ECTCodeTableColumnID = csect.ECTHedisCodeTypeID
			FROM CodeGroupingECTTable Cg
			INNER JOIN CodeSetECTHedisCodeType csect
				ON Cg.ECTTableColumn = csect.ECTHedisCodeTypeCode
			WHERE CodeGroupingID = @i_CodeGroupingID
				AND cg.ECTTableColumn <> '';

			WITH codeCte
			AS (
				SELECT cscc.ECTHedisCodeTypeID
					,csect.ECTHedisCodeTypeCode
					,cscc.ECTCode
					,cget.CodeGroupingID
				FROM CodeGroupingECTTable cget
				INNER JOIN CodeSetECTHedisTable cseht
					ON cget.ECThedisTableID = cseht.ECTHedisTableID
				INNER JOIN CodeSetHEDIS_ECTCode cscc
					ON cscc.ECTHedisTableID = cseht.ECTHedisTableID
				INNER JOIN CodeSetECTHedisCodeType csect
					ON csect.ECTHedisCodeTypeID = cscc.ECTHedisCodeTypeID
				WHERE cget.CodeGroupingID = @i_CodeGroupingID
					AND (
						cscc.ECTCodeDescription = @v_ECTCodeDescription
						OR @v_ECTCodeDescription IS NULL
						)
					AND (
						csect.ECTHedisCodeTypeID = @v_ECTCodeTableColumnID
						OR @v_ECTCodeTableColumnID IS NULL
						)
				)
			SELECT c.ECTHedisCodeTypeID
				,c.ECTHedisCodeTypeCode
				,c.CodeGroupingID
				,STUFF((
						SELECT DISTINCT ', ' + c1.ECTCode
						FROM codeCte c1
						WHERE c1.ECTHedisCodeTypeID = c.ECTHedisCodeTypeID
						FOR XML PATH('')
						), 1, 2, '') CodeGroupList
			FROM codeCte c
			GROUP BY c.ECTHedisCodeTypeID
				,c.ECTHedisCodeTypeCode
				,c.CodeGroupingID
			ORDER BY ECTHedisCodeTypeCode
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
    ON OBJECT::[dbo].[usp_CodeGropuingBuildDefinition_PDF] TO [FE_rohit.r-ext]
    AS [dbo];

