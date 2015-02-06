
/*    
---------------------------------------------------------------------------------------    
Procedure Name: [usp_NPOPatientSupplementalForm_Excel] 2,'2013-06-01','2013-06-12'
Description   : This procedure is used to get the list of all NPOPatientSupplementalForm
Created By    : Gurumoorthy V
Created Date  : 10-Jun-2013  
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_NPOPatientSupplementalForm_Excel] (
	@i_AppUserId INT
	,@dt_FromDate DATETIME = NULL
	,@dt_ToDate DATETIME = NULL
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

	--------------------------------------------------------   
	SELECT 18 AS ORIGIN_ID
		,PatientSupplementalFormID AS ROW_ID
		,P.MemberNum AS CONTRACT_NUM
		,P.FirstName AS MBR_FIRST_NAME
		,P.LastName AS MBR_LAST_NAME
		,P.Gender AS GENDER
		,'" '+REPLACE(CONVERT(VARCHAR(11), P.DateOfBirth, 106), ' ', '-')+'"' AS BIRTH_DT
		,'" '+REPLACE(CONVERT(VARCHAR(11), SF.DateOfDeath, 106), ' ', '-')+'"' AS DEATH_DT
		,PCPMILicenceNo AS PCP_MI_LIC_NUM
		,PCPNPI AS PCP_NPI
		,ServiceProviderNPI AS SERVICE_PROVIDER_NPI
		,ServiceProviderMILicenceNo AS SERVICE_PROVIDER_MI_LIC_NUM
		,'' AS ELIG_CD
		,'' AS DISEASE
		,RecordType AS RECORD_TYPE
		,'" '+REPLACE(CONVERT(VARCHAR(11), DateofService, 106), ' ', '-')+'"' AS SERVICE_DT
		,'" '+ CAST( CASE 
			WHEN (
					SELECT Description
					FROM NPOLkUp
					INNER JOIN NPOLkUpType
						ON NPOLkUp.NPOLkUpTypeID = NPOLkUpType.NPOLkUpTypeID
					WHERE LkUpCodeID = SF.CodeTypeID
						AND LkUpTypeName = 'CodeType'
					) IN (
					'CPT'
					,'CPT_CAT_II'
					,'HCPCS'
					)
				THEN CodeValue
			ELSE NULL
			END AS VARCHAR )  +'"' AS CPT_HCPCS
		,'" '+ CAST( CASE 
			WHEN (
					SELECT Description
					FROM NPOLkUp
					INNER JOIN NPOLkUpType
						ON NPOLkUp.NPOLkUpTypeID = NPOLkUpType.NPOLkUpTypeID
					WHERE LkUpCodeID = SF.CodeTypeID
						AND LkUpTypeName = 'CodeType'
					) IN ('REVENUE')
				THEN CodeValue
			ELSE NULL
			END AS VARCHAR )+'"' AS REVENUE_CODE
		,ServiceCode AS SERVICE_TYPE_CD
		,'' AS DIAG_I_1
		,'' AS DIAG_I_2
		,'' AS DIAG_I_3
		,'' AS DIAG_I_4
		,'' AS DIAG_I_5
		,'' AS DIAG_I_6
		,'' AS DIAG_I_7
		,'' AS DIAG_I_8
		,'' AS DIAG_I_9
		,'' AS DIAG_I_10
		,'"  '+ CAST(  CASE 
			WHEN (
					SELECT Description
					FROM NPOLkUp
					INNER JOIN NPOLkUpType
						ON NPOLkUp.NPOLkUpTypeID = NPOLkUpType.NPOLkUpTypeID
					WHERE LkUpCodeID = SF.CodeTypeID
						AND LkUpTypeName = 'CodeType'
					) IN ('LOINC')
				THEN CodeValue
			ELSE NULL
			END AS VARCHAR )+' "' AS RESULT_LOINC_CD
		,IsNumericResultType AS RESULT_TYPE
		,LabOperator AS RESULT_OPERAND
		,CASE WHEN LabResultValue = '0.00' THEN NULL ELSE LabResultValue END AS RESULT_NUM
		,LabResultTextID AS RESULT_TEXT
		,'' AS RX_METHOD
		,'' AS NDC_CODE
		,'' AS DRUG_NAME
		,'' AS DRUG_CATEGORY
		,'' AS PHARM_DAY_SUPPLY
		,'' AS DOSING
		,'' AS DRUG_QUANTITY
		,'' AS DRUG_UNIT
		,'' AS DRUG_ROUTE
		,'" '+REPLACE(CONVERT(VARCHAR(11), SF.CreatedDate, 106), ' ', '-')+'"' AS FILE_CREATION_DT
		,'T' AS SOURCE
		,Ethnicity.LkUpCode AS ETHNICITY
		,Race.LkUpCode AS RACE
		,rl.LkUpCode AS PRE_LANG_SPOKEN
		,wl.LkUpCode AS PRE_WRIT_LANGUAGE
	FROM NPOPatientSupplementalForm SF
	INNER JOIN Patients P
		ON SF.PatientID = P.PatientID
	LEFT JOIN NPOLkup Ethnicity
		ON Ethnicity.LkUpCodeID = SF.EthnicityID
	LEFT JOIN NPOLkup Race
		ON Race.LkUpCodeID = SF.RaceID
	LEFT JOIN NPOLkup rl
		ON rl.LkUpCodeID = SF.SpokenLanguageID
	LEFT JOIN NPOLkup wl
		ON wl.LkUpCodeID = SF.WrittenLanguageID
	WHERE (
			CONVERT(DATE, SF.CreatedDate) BETWEEN CONVERT(DATE, @dt_FromDate)
				AND CONVERT(DATE, @dt_ToDate)
			)
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
    ON OBJECT::[dbo].[usp_NPOPatientSupplementalForm_Excel] TO [FE_rohit.r-ext]
    AS [dbo];

