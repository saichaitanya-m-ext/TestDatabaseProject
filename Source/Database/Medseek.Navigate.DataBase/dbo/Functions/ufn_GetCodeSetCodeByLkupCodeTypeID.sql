
/*                    
------------------------------------------------------------------------------                    
Function Name: ufn_GetCodeSetCodeByLkupCodeTypeID               
Description   : This Function is used to get the list of coma seprated codes like cpt,icd etc...          
Created By    : Rathnam                 
Created Date  : 23-July-2013    
------------------------------------------------------------------------------                    
Log History   :                     
DD-MM-YYYY     BY      DESCRIPTION     
                
------------------------------------------------------------------------------                    
*/
CREATE FUNCTION [dbo].[ufn_GetCodeSetCodeByLkupCodeTypeID] (
	@v_CodeType VARCHAR(200)
	,@i_CodeID INT
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
		SELECT @v_GroupCode = csp.ProcedureCode + ' - ' + ISNULL(ProcedureName, '')
		FROM CodeSetProcedure csp
		INNER JOIN LkUpCodeType cgct
			ON cgct.CodeTypeID = csp.CodeTypeID
		WHERE csp.ProcedureCodeID = @i_CodeID
			AND cgct.CodeTypeCode = @v_CodeType
	END
	ELSE
		IF @v_CodeType = 'LOINC'
		BEGIN
			SELECT @v_GroupCode = csp.LoincCode + ' - ' + ISNULL(ShortDescription, '')
			FROM CodesetLOINC csp
			WHERE LOINCCodeID = @i_CodeID
		END
		ELSE
			IF @v_CodeType = 'ICD-9-CM-Diag'
			BEGIN
				SELECT @v_GroupCode = csp.DiagnosisCode + ' - ' + ISNULL(DiagnosisShortDescription, '')
				FROM CodesetICDDiagnosis csp
				INNER JOIN LkUpCodeType cgct
					ON cgct.CodeTypeID = csp.CodeTypeID
				WHERE csp.DiagnosisCodeID = @i_CodeID
					AND cgct.CodeTypeCode = @v_CodeType
			END
			ELSE
				IF @v_CodeType = 'NDC'
				BEGIN
					SELECT @v_GroupCode = csp.DrugCode + ' - ' + ISNULL(DrugName, '')
					FROM CodeSetDrug csp
					WHERE DrugCodeId = @i_CodeID
				END
				ELSE
					IF @v_CodeType = 'CPT_HCPCS_Modifier'
					BEGIN
						SELECT @v_GroupCode = csp.ProcedureCodeModifierCode + ' - ' + ISNULL(NAME, '')
						FROM CodeSetProcedureModifier csp
						WHERE csp.ProcedureCodeModifierId = @i_CodeID
					END
					ELSE
						IF @v_CodeType = 'ICD-9-CM-Proc'
						BEGIN
							SELECT @v_GroupCode = csp.ProcedureCode + ' - ' + ISNULL(ProcedureShortDescription, '')
							FROM CodeSetICDProcedure csp
							WHERE csp.ProcedureCodeID = @i_CodeID
						END
						ELSE
							IF @v_CodeType = 'CMS_POS'
							BEGIN
								SELECT @v_GroupCode = csp.PlaceOfServiceCode + ' - ' + ISNULL(PlaceOfServiceName, '')
								FROM CodeSetCMSPlaceOfService csp
								WHERE csp.PlaceOfServiceCodeID = @i_CodeID
							END
							ELSE
								IF @v_CodeType = 'UB-Revenue'
								BEGIN
									SELECT @v_GroupCode = csp.RevenueCode + ' - ' + ISNULL(Description, '')
									FROM CodeSetRevenue csp
									WHERE csp.RevenueCodeID = @i_CodeID
								END
								ELSE
									IF @v_CodeType = 'TOB'
									BEGIN
										SELECT @v_GroupCode = csp.TypeOfBillCode + ' - ' + ISNULL(ShortDescription, '')
										FROM CodeSetTypeOfBill csp
										WHERE csp.TypeOfBillCodeID = @i_CodeID
									END

	RETURN @v_GroupCode
END
