/*                  
------------------------------------------------------------------------------                  
Function Name: ufn_GetEncounterTypeIDByClaimInfo             
Description   : This Function is used to get the EncounterTypeID by claim infoid   
Created By    : Rathnam                  
Created Date  : 19-April-2013  
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
  
------------------------------------------------------------------------------                  
*/--select [dbo].[ufn_GetEncounterTypeIDByClaimInfo] (2)  
CREATE FUNCTION [dbo].[ufn_GetEncounterTypeIDByClaimInfo] (@i_ClaimInfoID INT)
RETURNS INT
AS
BEGIN
	DECLARE @v_ERDescription VARCHAR(50)
		,@i_EncounterTypeID INT
		,@i_Top INT = 1

--DECLARE @tblEncounterType TABLE
--(
--EncounterName varchar(200)
--)
	SELECT  TOP (@i_Top) @v_ERDescription = e.ECTCodeDescription
	FROM CodeSetHEDIS_ECTCode e WITH (NOLOCK)
	INNER JOIN CodeSetECTHedisTable t WITH (NOLOCK)
		ON t.ECTHedisTableID = e.ECTHedisTableID
	INNER JOIN CodeSetECTHedisCodeType ct WITH (NOLOCK)
		ON ct.ECTHedisCodeTypeID = e.ECTHedisCodeTypeID
	INNER JOIN CodeSetProcedure cp WITH (NOLOCK)
		ON cp.ProcedureCode = e.ECTCode
	INNER JOIN ClaimLine cl WITH (NOLOCK)
		ON cl.ProcedureCodeID = cp.ProcedureCodeID
	WHERE t.ECTHedisTableName = 'CDC-C'
		AND ct.ECTHedisCodeTypeCode = 'CPT'
		AND cl.ClaimInfoID = @i_ClaimInfoID
		ORDER BY ECTCodeDescription
		

	IF @v_ERDescription IS NULL
	BEGIN
		SELECT TOP (@i_Top) @v_ERDescription = e.ECTCodeDescription
		FROM CodeSetHEDIS_ECTCode e WITH (NOLOCK)
		INNER JOIN CodeSetECTHedisTable t WITH (NOLOCK)
			ON t.ECTHedisTableID = e.ECTHedisTableID
		INNER JOIN CodeSetECTHedisCodeType ct WITH (NOLOCK)
			ON ct.ECTHedisCodeTypeID = e.ECTHedisCodeTypeID
		INNER JOIN CodeSetRevenue cr WITH (NOLOCK)
			ON cr.RevenueCode = e.ECTCode
		INNER JOIN ClaimLine cl WITH (NOLOCK)
			ON cr.RevenueCodeID = cl.RevenueCodeID
		WHERE t.ECTHedisTableName = 'CDC-C'
			AND ct.ECTHedisCodeTypeCode = 'RevCode'
			AND cl.ClaimInfoID = @i_ClaimInfoID
			ORDER BY ECTCodeDescription
	END

	SET @v_ERDescription = CASE 
			WHEN @v_ERDescription = 'Acute inpatient'
				THEN 'Acute inpatient'
			WHEN @v_ERDescription = 'ED'
				THEN 'Emergency Department'
			WHEN @v_ERDescription = 'Nonacute inpatient'
				THEN 'Nonacute inpatient'
			WHEN @v_ERDescription = 'Outpatient'
				THEN 'Outpatient/Office'
			WHEN @v_ERDescription IS NULL
				THEN 'Other'
			END

	SELECT @i_EncounterTypeID = EncounterTypeID
	FROM EncounterType
	WHERE NAME = @v_ERDescription

	RETURN @i_EncounterTypeID
END
