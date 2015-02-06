/*          
------------------------------------------------------------------------------          
Procedure Name: usp_UserMedicationImmunizations_Select    
Description   : This procedure is used to get the list of all the detais from the         
 Rx table based on userid and     
    PatientImmunizations table based on ImmunizationID or all immunizationId's        
    details when passed NULL.         
Created By    : PRAVEEN TAKASI          
Created Date  : 13-JAN-2013          
------------------------------------------------------------------------------    
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
04-APR-2013 P.V.P.MOHAN modified UserDrugCodes Table to Rx,UserImmunizations  
   to PatientImmunizations .     
11-dEC-2013 NagaBabu Added PhormacyName column and modified SpecialityName column in First resultset     
exec usp_UserMedicationImmunizations_Select 10937,4222,null,'A',       
-------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_UserMedicationImmunizations_Select] (
	@i_AppUserId KeyId
	,@i_UserID KeyId
	,@i_UserImmunizationID KeyId = NULL
	,@v_StatusCode StatusCode = NULL
	)
AS
BEGIN TRY
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
	END;

	WITH RxC
	AS (
		SELECT DISTINCT NULL AS UserDrugId
			,ISNULL(CodeSetDrug.DrugName, '') DrugName
			,Rx.DateFilled AS DateFilled
			,CodeSetDrug.StrengthUnitNormalized AS DosageName
			,CodeSetDrug.DosageName AS Form
			,NULL AS FrequencyOfTitrationDays
			,CodeSetDrug.Strength
			,Rx.DaysSupply NumberOfDays
			,DBO.ufn_GetUserNameByID(Rx.PrescriberID) AS ProviderName
			--,CodeSetCMSProviderSpecialty.ProviderSpecialtyName AS SpecialityName
			,STUFF((SELECT ',' + cms.ProviderSpecialtyName
			       FROM ProviderSpecialty PS
				   INNER JOIN CodeSetCMSProviderSpecialty CMS WITH (NOLOCK)
				   ON CMS.CMSProviderSpecialtyCodeID = PS.CMSProviderSpecialtyCodeID
			       WHERE PS.ProviderID = Rx.PrescriberID 
				   FOR XML PATH('')),1,1,'') AS SpecialityName
			,Rx.DrugCodeId 
			,p.PharmacyName
		FROM RxClaim Rx WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(DateFilled) DateFilled
				,DrugCodeId
			FROM RxClaim
			WHERE PatientID = @i_UserID
				AND DateFilled BETWEEN DATEADD(YEAR, - 1, GETDATE())
					AND GETDATE()
			GROUP BY PatientID
				,DrugCodeId
			) DT
			ON DT.DrugCodeId = RX.DrugCodeId
				AND DT.DateFilled = RX.DateFilled
		INNER JOIN vw_CodeSetDrug CodeSetDrug WITH (NOLOCK)
			ON CodeSetDrug.DrugCodeId = Rx.DrugCodeId
		LEFT JOIN Pharmacy P
			ON P.PharmacyId = Rx.PharmacyId
		--LEFT JOIN ProviderSpecialty WITH (NOLOCK)
		--	ON Rx.PrescriberID = ProviderSpecialty.ProviderID
		--LEFT JOIN CodeSetCMSProviderSpecialty WITH (NOLOCK)
		--	ON CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
		WHERE Rx.PatientID = @i_UserID
			AND Rx.StatusCode = 'A'
		)
	SELECT UserDrugId
		,DrugName
		,CONVERT(VARCHAR(10), DateFilled, 101) AS StartDate
		,DosageName
		,Form
		,FrequencyOfTitrationDays
		,Strength
		,NumberOfDays
		,ProviderName
		,SpecialityName
		,DrugCodeId 
		,PharmacyName
	FROM RxC
	ORDER BY DateFilled DESC

	SELECT PatientImmunizations.PatientImmunizationID AS UserImmunizationID
		,PatientImmunizations.ImmunizationID
		,PatientImmunizations.PatientID AS UserID
		,PatientImmunizations.ImmunizationDate
		,CASE PatientImmunizations.IsPatientDeclined
			WHEN 0
				THEN 'OPT IN'
			WHEN 1
				THEN 'OPT OUT'
			END AS IsPatientDeclined
		,PatientImmunizations.Comments
		,Immunizations.NAME AS ImmunizationType
		,PatientImmunizations.AdverseReactionComments
		,PatientImmunizations.CreatedByUserId
		,PatientImmunizations.CreatedDate
		,PatientImmunizations.LastModifiedByUserId
		,PatientImmunizations.LastModifiedDate
		,PatientImmunizations.DueDate
		,CASE PatientImmunizations.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS StatusDescription
		,ISNULL(PatientImmunizations.IsPreventive, 0) AS IsPreventive
		,PatientImmunizations.DataSourceID
		,CodeSetDataSource.SourceName
		,PatientImmunizations.ProgramID
	FROM PatientImmunizations WITH (NOLOCK)
	INNER JOIN Immunizations WITH (NOLOCK)
		ON Immunizations.ImmunizationID = PatientImmunizations.ImmunizationID
	LEFT OUTER JOIN CodeSetDataSource WITH (NOLOCK)
		ON CodeSetDataSource.DataSourceId = PatientImmunizations.DataSourceID
	LEFT OUTER JOIN Program WITH (NOLOCK)
		ON Program.ProgramId = PatientImmunizations.ProgramID
	WHERE (PatientImmunizations.PatientID = @i_UserID)
		AND (
			PatientImmunizations.PatientImmunizationID = @i_UserImmunizationID
			OR @i_UserImmunizationID IS NULL
			)
		AND (
			PatientImmunizations.StatusCode = @v_StatusCode
			OR @v_StatusCode IS NULL
			)
END TRY

BEGIN CATCH
	---------------------------------------------------------------------------------------------------------------------------------      
	-- Handle exception      
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserMedicationImmunizations_Select] TO [FE_rohit.r-ext]
    AS [dbo];

