
/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetGroupCodeNameListByCodeType           
Description   : This Function is used to get the list of coma seprated codes like cpt,icd etc...      
Created By    : Rathnam             
Created Date  : 29-May-2013
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION 
            
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetGroupCodeNameListByCodeType] (
	 @v_CodeType VARCHAR(500)
	,@i_TypeID INT
	)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @v_GroupCode VARCHAR(1000)
	IF @v_CodeType IN (
			'CPT'
			,'CPT-CAT-II'
			,'HCPCS'
			)
	BEGIN

		SELECT @v_GroupCode = csp.ProcedureCode + ' - ' + ISNULL(ProcedureName, '')
		FROM CodeSetProcedure csp
		WHERE csp.ProcedureCodeID = @i_TypeID
	END
	ELSE
		IF @v_CodeType = 'LOINC'
		BEGIN
			SELECT @v_GroupCode = csp.LoincCode + ' - ' + ISNULL(ShortDescription, '')
			FROM CodesetLOINC csp
			WHERE csp.LoincCodeId = @i_TypeID
		END
		ELSE
			IF @v_CodeType = 'ICD-9-CM-Diag'
			BEGIN
				SELECT @v_GroupCode = csp.DiagnosisCode + ' - ' + ISNULL(DiagnosisShortDescription, '')
				FROM CodesetICDDiagnosis csp
				WHERE csp.DiagnosisCodeID = @i_TypeID
			END
			ELSE
				IF @v_CodeType = 'NDC'
				BEGIN
					SELECT @v_GroupCode = csp.DrugCode + ' - ' + ISNULL(DrugName, '')
					FROM CodeSetDrug csp
					WHERE csp.DrugCodeId = @i_TypeID
				END
				ELSE
					IF @v_CodeType = 'CPT_HCPCS_Modifier'
					BEGIN
						SELECT @v_GroupCode = csp.ProcedureCodeModifierCode + ' - ' + ISNULL(NAME, '')
						FROM CodeSetProcedureModifier csp
						WHERE csp.ProcedureCodeModifierId = @i_TypeID
					END
					ELSE
						IF @v_CodeType = 'ICD-9-CM-Proc'
						BEGIN
							SELECT @v_GroupCode = csp.ProcedureCode + ' - ' + ISNULL(ProcedureShortDescription, '')
							FROM CodeSetICDProcedure csp
							WHERE csp.ProcedureCodeID = @i_TypeID
						END
						ELSE
							IF @v_CodeType = 'CMS_POS'
							BEGIN
								SELECT @v_GroupCode = csp.PlaceOfServiceCode + ' - ' + ISNULL(PlaceOfServiceName, '')
								FROM CodeSetCMSPlaceOfService csp
								WHERE csp.PlaceOfServiceCodeID = @i_TypeID
							END
							ELSE
								IF @v_CodeType = 'UB-Revenue'
								BEGIN
									SELECT @v_GroupCode = csp.RevenueCode + ' - ' + ISNULL(Description, '')
									FROM CodeSetRevenue csp
									WHERE csp.RevenueCodeID = @i_TypeID
								END
								ELSE
									IF @v_CodeType = 'TOB'
									BEGIN
										SELECT @v_GroupCode = csp.TypeOfBillCode + ' - ' + ISNULL(ShortDescription, '')
										FROM CodeSetTypeOfBill csp
										WHERE csp.TypeOfBillCodeID = @i_TypeID
									END

	RETURN @v_GroupCode
END
