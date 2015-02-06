/*                    
------------------------------------------------------------------------------                    
Function Name: ufn_GetGroupCodeByCodeTypeID               
Description   : This Function is used to get the list of coma seprated codes like cpt,icd etc...          
Created By    : Rathnam                 
Created Date  : 29-May-2013    
------------------------------------------------------------------------------                    
Log History   :                     
DD-MM-YYYY     BY      DESCRIPTION     
                
------------------------------------------------------------------------------                    
*/
CREATE FUNCTION [dbo].[ufn_GetGroupCodeByCodeTypeID] (
	@v_CodeType VARCHAR(200)
	,@i_CodeGroupingID INT
	,@i_CodeGroupingDetailInternal INT
	)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @v_GroupCode VARCHAR(100)

	IF @v_CodeType IN (
			'CPT'
			,'CPT-CAT-II'
			,'HCPCS'
			)
	BEGIN
		SELECT @v_GroupCode = csp.ProcedureCode + ' - ' + ISNULL(ProcedureName,'')
		FROM CodeGroupingDetailInternal cgdi
		INNER JOIN CodeSetProcedure csp
			ON csp.ProcedureCodeID = cgdi.CodeGroupingCodeID
		INNER JOIN LkUpCodeType cgct
			ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
		WHERE CodeGroupingID = @i_CodeGroupingID
			AND cgct.CodeTypeCode = @v_CodeType
			AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
	END
	ELSE
		IF @v_CodeType = 'LOINC'
		BEGIN
			SELECT @v_GroupCode = csp.LoincCode + ' - '+ ISNULL(ShortDescription,'')
			FROM CodeGroupingDetailInternal cgdi
			INNER JOIN CodesetLOINC csp
				ON csp.LoincCodeId = cgdi.CodeGroupingCodeID
			INNER JOIN LkUpCodeType cgct
				ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
			WHERE CodeGroupingID = @i_CodeGroupingID
				AND cgct.CodeTypeCode = @v_CodeType
				AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
		END
		ELSE
			IF @v_CodeType = 'ICD-9-CM-Diag'
			BEGIN
				SELECT @v_GroupCode = csp.DiagnosisCode + ' - ' +  ISNULL(DiagnosisShortDescription,'')
				FROM CodeGroupingDetailInternal cgdi
				INNER JOIN CodesetICDDiagnosis csp
					ON csp.DiagnosisCodeID = cgdi.CodeGroupingCodeID
				INNER JOIN LkUpCodeType cgct
					ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
				WHERE CodeGroupingID = @i_CodeGroupingID
					AND cgct.CodeTypeCode = @v_CodeType
					AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
			END
			ELSE
				IF @v_CodeType = 'NDC'
				BEGIN
					SELECT @v_GroupCode = csp.DrugCode + ' - ' + ISNULL(DrugName,'')
					FROM CodeGroupingDetailInternal cgdi
					INNER JOIN CodeSetDrug csp
						ON csp.DrugCodeId = cgdi.CodeGroupingCodeID
					INNER JOIN LkUpCodeType cgct
						ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
					WHERE CodeGroupingID = @i_CodeGroupingID
						AND cgct.CodeTypeCode = @v_CodeType
						AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
				END
				ELSE
					IF @v_CodeType = 'CPT_HCPCS_Modifier'
					BEGIN
						SELECT @v_GroupCode = csp.ProcedureCodeModifierCode + ' - ' + ISNULL(Name,'')
						FROM CodeGroupingDetailInternal cgdi
						INNER JOIN CodeSetProcedureModifier csp
							ON csp.ProcedureCodeModifierId = cgdi.CodeGroupingCodeID
						INNER JOIN LkUpCodeType cgct
							ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
						WHERE CodeGroupingID = @i_CodeGroupingID
							AND cgct.CodeTypeCode = @v_CodeType
							AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
					END
					ELSE
						IF @v_CodeType = 'ICD-9-CM-Proc'
						BEGIN
							SELECT @v_GroupCode = csp.ProcedureCode + ' - ' + ISNULL(ProcedureShortDescription,'')
							FROM CodeGroupingDetailInternal cgdi
							INNER JOIN CodeSetICDProcedure csp
								ON csp.ProcedureCodeID = cgdi.CodeGroupingCodeID
							INNER JOIN LkUpCodeType cgct
								ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
							WHERE CodeGroupingID = @i_CodeGroupingID
								AND cgct.CodeTypeCode = @v_CodeType
								AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
						END
						ELSE
							IF @v_CodeType = 'CMS_POS'
							BEGIN
								SELECT @v_GroupCode = csp.PlaceOfServiceCode + ' - ' + ISNULL(PlaceOfServiceName,'')
								FROM CodeGroupingDetailInternal cgdi
								INNER JOIN CodeSetCMSPlaceOfService csp
									ON csp.PlaceOfServiceCodeID = cgdi.CodeGroupingCodeID
								INNER JOIN LkUpCodeType cgct
									ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
								WHERE CodeGroupingID = @i_CodeGroupingID
									AND cgct.CodeTypeCode = @v_CodeType
									AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
							END
							ELSE
								IF @v_CodeType = 'UB-Revenue'
								BEGIN
									SELECT @v_GroupCode = csp.RevenueCode + ' - ' + ISNULL(Description,'')
									FROM CodeGroupingDetailInternal cgdi
									INNER JOIN CodeSetRevenue csp
										ON csp.RevenueCodeID = cgdi.CodeGroupingCodeID
									INNER JOIN LkUpCodeType cgct
										ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
									WHERE CodeGroupingID = @i_CodeGroupingID
										AND cgct.CodeTypeCode = @v_CodeType
										AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
								END
								ELSE
									IF @v_CodeType = 'TOB'
									BEGIN
										SELECT @v_GroupCode = csp.TypeOfBillCode + ' - ' + ISNULL(ShortDescription,'')
										FROM CodeGroupingDetailInternal cgdi
										INNER JOIN CodeSetTypeOfBill csp
											ON csp.TypeOfBillCodeID = cgdi.CodeGroupingCodeID
										INNER JOIN LkUpCodeType cgct
											ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
										WHERE CodeGroupingID = @i_CodeGroupingID
											AND cgct.CodeTypeCode = @v_CodeType
											AND cgdi.CodeGroupingDetailInternalID = @i_CodeGroupingDetailInternal
									END

	RETURN @v_GroupCode
END
