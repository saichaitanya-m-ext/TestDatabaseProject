
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CodeGroupInlineSearch_DD]  2,'hed','ProcedureCode'      
Description   : This procedure is used for drop down from CodeGroupInlineSearch table      
       
Created By    : Gurumoorthy v 
Created Date  : 27-May-2013
------------------------------------------------------------------------------        
Log History   :        
DD-MM-YYYY  BY   DESCRIPTION   
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CodeGroupInlineSearch_DD] (
	@i_AppUserId KEYID
	,@vc_InlineSearchDesc VARCHAR(50) = NULL
	,@vc_CodeGroupType VARCHAR(50) = NULL
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

	IF (@vc_CodeGroupType = 'CPT-CAT-II')
	BEGIN
		SELECT ProcedureCodeID AS ProcedureID
			,ProcedureCode
			,ProcedureName AS ProcedureDescription
			,LeadtimeDays
		FROM CodeSetProcedure CSP
		INNER JOIN LkUpCodeType lkc ON CSP.CodeTypeID = lkc.CodeTypeID
		WHERE lkc.CodeTypeCode = 'CPT-CAT-II'
			AND csp.StatusCode = 'A'
			AND (
				ProcedureCode + ' - ' + ProcedureName LIKE '%' + @vc_InlineSearchDesc + '%'
				OR @vc_InlineSearchDesc IS NULL
				)
	END
	ELSE
		IF (@vc_CodeGroupType = 'HCPCS')
		BEGIN
			SELECT ProcedureCodeID AS ProcedureID
				,ProcedureCode
				,ProcedureName AS ProcedureDescription
				,LeadtimeDays
			FROM CodeSetProcedure CSP
			INNER JOIN LkUpCodeType lkc ON CSP.CodeTypeID = lkc.CodeTypeID
			WHERE lkc.CodeTypeCode = 'HCPCS'
				AND csp.StatusCode = 'A'
				AND (
					ProcedureCode + ' - ' + ProcedureName LIKE '%' + @vc_InlineSearchDesc + '%'
					OR @vc_InlineSearchDesc IS NULL
					)
		END
		ELSE
			IF (@vc_CodeGroupType = 'UB-Revenue')
			BEGIN
				SELECT RevenueCode AS ProcedureCode
					,Description AS ProcedureDescription
					,RevenueCodeID AS ProcedureID
				FROM CodeSetRevenue
				WHERE StatusCode = 'A'
					AND (
						RevenueCode + ' - ' + Description LIKE '%' + @vc_InlineSearchDesc + '%'
						OR @vc_InlineSearchDesc IS NULL
						)
			END
			ELSE
				IF (@vc_CodeGroupType = 'CMS_POS')
				BEGIN
					SELECT PlaceOfServiceCodeID AS ProcedureID
						,PlaceOfServiceCode AS ProcedureCode
						,PlaceOfServiceName AS ProcedureDescription
					FROM CodeSetCMSPlaceOfService
					WHERE StatusCode = 'A'
						AND (
							PlaceOfServiceCode + ' - ' + PlaceOfServiceName LIKE '%' + @vc_InlineSearchDesc + '%'
							OR @vc_InlineSearchDesc IS NULL
							)
				END
				ELSE
					IF (@vc_CodeGroupType = 'TOB')
					BEGIN
						SELECT TypeOfBillCodeID AS ProcedureID
							,TypeOfBillCode AS ProcedureCode
							,LongDescription AS ProcedureDescription
						FROM CodeSetTypeOfBill
						WHERE StatusCode = 'A'
							AND (
								TypeOfBillCode + ' - ' + LongDescription LIKE '%' + @vc_InlineSearchDesc + '%'
								OR @vc_InlineSearchDesc IS NULL
								)
					END
					ELSE
						IF (@vc_CodeGroupType = 'ICD-9-CM-Proc')
						BEGIN
							SELECT ProcedureCodeID AS ProcedureID
								,ProcedureCode AS ProcedureCode
								,ProcedureShortDescription AS ProcedureDescription
							FROM CodeSetICDProcedure
							WHERE StatusCode = 'A'
								AND (
									ProcedureCode + ' - ' + ProcedureShortDescription LIKE '%' + @vc_InlineSearchDesc + '%'
									OR @vc_InlineSearchDesc IS NULL
									)
						END
						ELSE
							IF (@vc_CodeGroupType = 'ICD-9-CM-Diag')
							BEGIN
								SELECT DiagnosisCodeID AS ProcedureID
									,DiagnosisCode AS ProcedureCode
									,DiagnosisShortDescription AS ProcedureDescription
								FROM CodesetICDDiagnosis
								WHERE StatusCode = 'A'
									AND (
										DiagnosisCode + ' - ' + DiagnosisShortDescription LIKE '%' + @vc_InlineSearchDesc + '%'
										OR @vc_InlineSearchDesc IS NULL
										)
							END
							ELSE
								IF (@vc_CodeGroupType = 'CPT_HCPCS_Modifier')
								BEGIN
									SELECT ProcedureCodeModifierId AS ProcedureID
										,ProcedureCodeModifierCode AS ProcedureCode
										,NAME AS ProcedureDescription
									FROM CodeSetProcedureModifier
									WHERE StatusCode = 'A'
										AND (
											ProcedureCodeModifierCode + ' - ' + NAME LIKE '%' + @vc_InlineSearchDesc + '%'
											OR @vc_InlineSearchDesc IS NULL
											)
								END
								ELSE
									IF (@vc_CodeGroupType = 'Code Grouping')
									BEGIN
										SELECT CodeGroupingID AS ProcedureID
											,CodeGroupingName AS ProcedureCode
											,CodeGroupingDescription AS ProcedureDescription
										FROM CodeGrouping
										WHERE StatusCode = 'A'
											AND (
												CodeGroupingName LIKE '%' + @vc_InlineSearchDesc + '%'
												OR @vc_InlineSearchDesc IS NULL
												)
											AND ProductionStatus = 'F'
											AND DisplayStatus = 1
											AND IsPrimary = 1
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
    ON OBJECT::[dbo].[usp_CodeGroupInlineSearch_DD] TO [FE_rohit.r-ext]
    AS [dbo];

