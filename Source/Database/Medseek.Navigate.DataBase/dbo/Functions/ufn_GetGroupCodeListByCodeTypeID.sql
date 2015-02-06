/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetGroupCodeListByCodeTypeID           
Description   : This Function is used to get the list of coma seprated codes like cpt,icd etc...      
Created By    : Rathnam             
Created Date  : 29-May-2013
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION 
            
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetGroupCodeListByCodeTypeID] (
	@v_CodeType VARCHAR(500)
	,@i_CodeGroupingID INT
	)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @v_GroupCodeList VARCHAR(MAX)

	IF @v_CodeType IN (
			'CPT'
			,'CPT-CAT-II'
			,'HCPCS'
			)
	BEGIN
		SELECT @v_GroupCodeList = STUFF((
					SELECT DISTINCT ', ' + csp.ProcedureCode 
					FROM CodeGroupingDetailInternal cgdi
					INNER JOIN CodeSetProcedure csp
						ON csp.ProcedureCodeID = cgdi.CodeGroupingCodeID
					INNER JOIN LkUpCodeType cgct
						ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
					WHERE CodeGroupingID = @i_CodeGroupingID
						AND cgct.CodeTypeCode = @v_CodeType
					FOR XML PATH('')
					), 1, 2, '')
	END
	ELSE
		IF @v_CodeType = 'LOINC'
		BEGIN
			SELECT @v_GroupCodeList = STUFF((
						SELECT DISTINCT ', ' + csp.LoincCode 
						FROM CodeGroupingDetailInternal cgdi
						INNER JOIN CodesetLOINC csp
							ON csp.LoincCodeId = cgdi.CodeGroupingCodeID
						INNER JOIN LkUpCodeType cgct
							ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
						WHERE CodeGroupingID = @i_CodeGroupingID
							AND cgct.CodeTypeCode = @v_CodeType
						FOR XML PATH('')
						), 1, 2, '')
		END
		ELSE
			IF @v_CodeType = 'ICD-9-CM-Diag'
			BEGIN
				SELECT @v_GroupCodeList = STUFF((
							SELECT DISTINCT ', ' + csp.DiagnosisCode 
							FROM CodeGroupingDetailInternal cgdi
							INNER JOIN CodesetICDDiagnosis csp
								ON csp.DiagnosisCodeID = cgdi.CodeGroupingCodeID
							INNER JOIN LkUpCodeType cgct
								ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
							WHERE CodeGroupingID = @i_CodeGroupingID
								AND cgct.CodeTypeCode = @v_CodeType
							FOR XML PATH('')
							), 1, 2, '')
			END
			ELSE
				IF @v_CodeType = 'NDC'
				BEGIN
					SELECT @v_GroupCodeList = STUFF((
								SELECT DISTINCT ', ' + csp.DrugCode 
								FROM CodeGroupingDetailInternal cgdi
								INNER JOIN CodeSetDrug csp
									ON csp.DrugCodeId = cgdi.CodeGroupingCodeID
								INNER JOIN LkUpCodeType cgct
									ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
								WHERE CodeGroupingID = @i_CodeGroupingID
									AND cgct.CodeTypeCode = @v_CodeType
								FOR XML PATH('')
								), 1, 2, '')
				END
				ELSE
					IF @v_CodeType = 'CPT_HCPCS_Modifier'
					BEGIN
						SELECT @v_GroupCodeList = STUFF((
									SELECT DISTINCT ', ' + csp.ProcedureCodeModifierCode 
									FROM CodeGroupingDetailInternal cgdi
									INNER JOIN CodeSetProcedureModifier csp
										ON csp.ProcedureCodeModifierId = cgdi.CodeGroupingCodeID
									INNER JOIN LkUpCodeType cgct
										ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
									WHERE CodeGroupingID = @i_CodeGroupingID
										AND cgct.CodeTypeCode = @v_CodeType
									FOR XML PATH('')
									), 1, 2, '')
					END
					ELSE
						IF @v_CodeType = 'ICD-9-CM-Proc'
						BEGIN
							SELECT @v_GroupCodeList = STUFF((
										SELECT DISTINCT ', ' + csp.ProcedureCode 
										FROM CodeGroupingDetailInternal cgdi
										INNER JOIN CodeSetICDProcedure csp
											ON csp.ProcedureCodeID = cgdi.CodeGroupingCodeID
										INNER JOIN LkUpCodeType cgct
											ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
										WHERE CodeGroupingID = @i_CodeGroupingID
											AND cgct.CodeTypeCode = @v_CodeType
										FOR XML PATH('')
										), 1, 2, '')
						END
						ELSE
							IF @v_CodeType = 'CMS_POS'
							BEGIN
								SELECT @v_GroupCodeList = STUFF((
											SELECT DISTINCT ', ' + csp.PlaceOfServiceCode 
											FROM CodeGroupingDetailInternal cgdi
											INNER JOIN CodeSetCMSPlaceOfService csp
												ON csp.PlaceOfServiceCodeID = cgdi.CodeGroupingCodeID
											INNER JOIN LkUpCodeType cgct
												ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
											WHERE CodeGroupingID = @i_CodeGroupingID
												AND cgct.CodeTypeCode = @v_CodeType
											FOR XML PATH('')
											), 1, 2, '')
							END
							ELSE
								IF @v_CodeType = 'UB-Revenue'
								BEGIN
									SELECT @v_GroupCodeList = STUFF((
												SELECT DISTINCT ', ' + csp.RevenueCode 
												FROM CodeGroupingDetailInternal cgdi
												INNER JOIN CodeSetRevenue csp
													ON csp.RevenueCodeID = cgdi.CodeGroupingCodeID
												INNER JOIN LkUpCodeType cgct
													ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
												WHERE CodeGroupingID = @i_CodeGroupingID
													AND cgct.CodeTypeCode = @v_CodeType
												FOR XML PATH('')
												), 1, 2, '')
								END
								ELSE
									IF @v_CodeType = 'TOB'
									BEGIN
										SELECT @v_GroupCodeList = STUFF((
													SELECT DISTINCT ', ' + csp.TypeOfBillCode 
													FROM CodeGroupingDetailInternal cgdi
													INNER JOIN CodeSetTypeOfBill csp
														ON csp.TypeOfBillCodeID = cgdi.CodeGroupingCodeID
													INNER JOIN LkUpCodeType cgct
														ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
													WHERE CodeGroupingID = @i_CodeGroupingID
														AND cgct.CodeTypeCode = @v_CodeType
													FOR XML PATH('')
													), 1, 2, '')
									END

	RETURN @v_GroupCodeList
END
