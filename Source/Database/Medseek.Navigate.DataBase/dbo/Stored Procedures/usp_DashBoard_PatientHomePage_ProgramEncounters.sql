
--usp_DashBoard_PatientHomePage_ProgramEncounterS 123,5  
/*                
------------------------------------------------------------------------------                
Procedure Name: [usp_DashBoard_PatientHomePage_ProgramEncounters]  2,1,1,1              
Description   : This procedure is used to get the details from UserEncounters table               
Created By    : Kalyan                
Created Date  : 19-June-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY  BY    DESCRIPTION                
03-APR-2013 Mohan   Modified UserEncounters to PatientEncounters  CodeSetSpecialty Tables.          
06-11-2013 Gourishankar Removed CodeGrouping Logic and reinstated PatientProcedure and CodeSetSpecialty Tables  
02-08-2013 Santosh added the column UserEncounterID  
------------------------------------------------------------------------------                
*/
CREATE PROCEDURE [dbo].[usp_DashBoard_PatientHomePage_ProgramEncounters] (
	@i_AppUserId KEYID
	,@i_UserId KEYID
	,@b_isLV ISINDICATOR = 0
	,@b_ispopup ISINDICATOR = 0
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

	CREATE TABLE #CodeGrouping (
		CodeGroupingID INT
		,CodeGroupingName VARCHAR(1000)
		,IsOther BIT
		)

	INSERT INTO #CodeGrouping
	SELECT cg.CodeGroupingID
		,cg.CodeGroupingName
		,CASE 
			WHEN cg.CodeGroupingName IN (
					'Surgery'
					,'Anesthesia'
					,'Radiology'
					,'Laboratory'
					)
				THEN 1
			ELSE 0
			END
	FROM CodeGrouping cg WITH (NOLOCK)
	INNER JOIN CodeTypeGroupers ctg WITH (NOLOCK)
		ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN CodeGroupingType cgt WITH (NOLOCK)
		ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	WHERE cgt.CodeGroupType = 'Utilization Groupers'
		AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'

	CREATE TABLE #PatInternalProc (
		CodeGroupingID INT
		,CodeGroupingName VARCHAR(500)
		,DateOfService DATE
		,IsOther BIT
		);

	INSERT INTO #PatInternalProc
	SELECT DISTINCT cg.CodeGroupingID
		,cg.CodeGroupingName
		--,ppc.ClaimInfoId
		,ppc.DateOfService DateOfService
		,cg.IsOther
	FROM PatientProcedureCode ppc WITH (NOLOCK)
	INNER JOIN PatientProcedureCodeGroup ppcg WITH (NOLOCK)
		ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
	INNER JOIN #CodeGrouping cg WITH (NOLOCK)
		ON cg.CodeGroupingID = ppcg.CodeGroupingID
	WHERE ppc.PatientID = @i_UserId
		AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))
	
	UNION
	
	SELECT DISTINCT cg.CodeGroupingID
		,cg.CodeGroupingName
		--,ppc.ClaimInfoId
		,ppc.DateOfService DateOfService
		,cg.IsOther
	FROM PatientOtherCode ppc WITH (NOLOCK)
	INNER JOIN PatientOtherCodeGroup ppcg WITH (NOLOCK)
		ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
	INNER JOIN #CodeGrouping cg WITH (NOLOCK)
		ON cg.CodeGroupingID = ppcg.CodeGroupingID
	WHERE ppc.PatientID = @i_UserId
		AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))

	CREATE TABLE #PatProc (
		CodeGroupingID INT
		,CodeGroupingName VARCHAR(1000)
		,DateOfService DATE
		);

	INSERT INTO #PatProc
	SELECT CodeGroupingID
		,CodeGroupingName
		,DateOfService
	FROM (
		SELECT CodeGroupingID
			,CodeGroupingName
			,DateOfService
			,ROW_NUMBER() OVER (
				PARTITION BY DateOfService ORDER BY CASE 
						WHEN CodeGroupingName = 'Acute Inpatient'
							THEN 1
						WHEN CodeGroupingName = 'Observation Stay'
							THEN 2
						WHEN CodeGroupingName = 'Hospice'
							THEN 3
						ELSE 4
						END
				) sno
		FROM #PatInternalProc
		WHERE IsOther = 0 -- 17 Symphony Internal encounter groupers
		
		UNION ALL
		
		SELECT CodeGroupingID
			,CodeGroupingName
			,DateOfService
			,ROW_NUMBER() OVER (
				PARTITION BY DateOfService ORDER BY CASE 
						WHEN CodeGroupingName = 'Surgery'
							THEN 1
						WHEN CodeGroupingName = 'Anesthesia'
							THEN 2
						WHEN CodeGroupingName = 'Radiology'
							THEN 3
						WHEN CodeGroupingName = 'Laboratory'
							THEN 4
						ELSE 5
						END
				) sno
		FROM #PatInternalProc
		WHERE IsOther = 1
			AND NOT EXISTS (
				SELECT 1
				FROM #PatInternalProc P
				WHERE p.DateOfService = #PatInternalProc.DateOfService
					AND P.IsOther = 0
				) -- If above 17 encounters groupers doesnt satisfy it will go for Other 4 like Surgery,Anesthesia,Radiology,Laboratory
		
		UNION ALL
		
		SELECT DISTINCT 0 CodeGroupingID
			,'Other' CodeGroupingName
			,DateOfAdmit
			,1
		FROM ClaimInfo WITH (NOLOCK)
		WHERE IsOtherUtilizationGroup = 1
			AND DateOfAdmit > DATEADD(YEAR, - 1, GETDATE())
			AND PatientID = @i_UserId
			AND NOT EXISTS (
				SELECT 1
				FROM #PatInternalProc p
				WHERE p.DateOfService = ClaimInfo.DateOfAdmit
				)
		) t
	WHERE t.sno = 1

	SELECT DISTINCT p.*
		,cp.ProviderID
		,ci.claiminfoid AS ClaimID
	INTO #x
	FROM #PatProc p
	INNER JOIN ClaimInfo ci
		ON p.DateOfService = ci.DateOfAdmit
	LEFT JOIN ClaimProvider cp
		ON cp.ClaimInfoID = ci.ClaimInfoID
	WHERE ci.PatientID = @i_UserId
	ORDER BY 3 DESC
	
	
	IF @b_ispopup = 0
	BEGIN
	IF @b_isLV = 1
    BEGIN	
    
   	SELECT ROW_NUMBER() OVER (
			ORDER BY (
					SELECT NULL
					)
			) AS UserEncounterID
	    ,src.EncounterType AS Encounter
	    ,CONVERT(VARCHAR(10), src.EncounterDate, 101) AS 'Date'	
		,COALESCE(ISNULL(P1.LastName, '') + ' ' + ISNULL(P1.FirstName, '') + ' ' + ISNULL(P1.MiddleName, ''), '') AS 'Provider Name'
		,CodesetCMSProviderSpecialty.ProviderSpecialtyName 'Provider Speciality'
		,src.EncounterDate AS DateTaken
		FROM (
		SELECT DISTINCT @i_UserId AS UserId
			,CAST(p.DateOfService AS DATE) EncounterDate
			,p.CodeGroupingName AS EncounterType
			,p.ProviderID UserProviderID
			,'' CPTCode
			FROM #x p WITH (NOLOCK)
		) Src
	LEFT JOIN Provider P1 WITH (NOLOCK)
		ON P1.ProviderID = Src.UserProviderId
	LEFT JOIN ProviderSpecialty WITH (NOLOCK)
		ON ProviderSpecialty.ProviderID = P1.ProviderID
	LEFT JOIN CodesetCMSProviderSpecialty WITH (NOLOCK)
		ON CodesetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
	ORDER BY CAST(EncounterDate AS DATE) DESC
    
    END
    ELSE 
    BEGIN

	SELECT ROW_NUMBER() OVER (
			ORDER BY (
					SELECT NULL
					)
			) AS UserEncounterID
		,Src.UserId
		,COALESCE(ISNULL(P1.LastName, '') + ' ' + ISNULL(P1.FirstName, '') + ' ' + ISNULL(P1.MiddleName, ''), '') AS CareProvider
		,CONVERT(VARCHAR(10), src.EncounterDate, 101) AS EncounterDate
		,src.EncounterType
		,src.EncounterTypeId
		,src.UserProviderID
		,src.CPTCode
		,src.ICDCode
		,CodesetCMSProviderSpecialty.ProviderSpecialtyName ProviderSpeciality
		,src.MajorProcedures
	FROM (
		SELECT DISTINCT @i_UserId AS UserId
			,CAST(p.DateOfService AS DATE) EncounterDate
			,p.CodeGroupingName AS EncounterType
			,p.CodeGroupingID EncounterTypeId
			,p.ProviderID UserProviderID
			,'' CPTCode
			,STUFF((
					SELECT DISTINCT '$$ ' + CAST(CodeSetICDDiagnosis.DiagnosisCode AS VARCHAR) + ' - ' + CodeSetICDDiagnosis.DiagnosisLongDescription
					FROM ClaimLineDiagnosis WITH (NOLOCK)
					INNER JOIN CodeSetICDDiagnosis WITH (NOLOCK)
						ON CodeSetICDDiagnosis.DiagnosisCodeID = ClaimLineDiagnosis.DiagnosisCodeID
					INNER JOIN ClaimLine WITH (NOLOCK)
						ON ClaimLine.ClaimLineID = ClaimLineDiagnosis.ClaimLineID
					INNER JOIN #x ci WITH (NOLOCK)
						ON ci.ClaimID = Claimline.ClaimInfoID
					WHERE ci.DateOfService = p.DateOfService
						AND ((ci.ProviderID = p.ProviderID AND p.Providerid IS NOT NULL) OR (p.Providerid IS NULL AND ci.ProviderID is null))
					FOR XML PATH('')
					), 1, 2, '') ICDCode
			,CASE 
				WHEN p.CodeGroupingName = 'Acute Inpatient'
					THEN STUFF((
								SELECT DISTINCT '$$ ' + CAST(csi.ProcedureCode AS VARCHAR) + ' - ' + csi.ProcedureShortDescription
								FROM ClaimProcedure cp WITH (NOLOCK)
								INNER JOIN CodeSetICDProcedure csi WITH (NOLOCK)
									ON cp.ProcedureCodeID = csi.ProcedureCodeID
								INNER JOIN CodeGroupingDetailInternal cgdi WITH (NOLOCK)
									ON cgdi.CodeGroupingCodeID = csi.ProcedureCodeID
								INNER JOIN CodeGrouping cg WITH (NOLOCK)
									ON cg.CodeGroupingID = cgdi.CodeGroupingID
								INNER JOIN CodeTypeGroupers ctg WITH (NOLOCK)
									ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
								INNER JOIN #x ci WITH (NOLOCK)
									ON ci.ClaimID = cp.ClaimInfoID
								WHERE ci.DateOfService = p.DateOfService
									AND ((ci.ProviderID = p.ProviderID AND p.Providerid IS NOT NULL) OR (p.Providerid IS NULL AND ci.ProviderID is null))
									AND ctg.CodeTypeGroupersName = 'CCS ICD Procedure 4Classes'
									AND cg.CodeGroupingCode IN (
										3
										,4
										)
								FOR XML PATH('')
								), 1, 2, '')
				ELSE ''
				END MajorProcedures
		FROM #x p WITH (NOLOCK)
		) Src
	LEFT JOIN Provider P1 WITH (NOLOCK)
		ON P1.ProviderID = Src.UserProviderId
	LEFT JOIN ProviderSpecialty WITH (NOLOCK)
		ON ProviderSpecialty.ProviderID = P1.ProviderID
	LEFT JOIN CodesetCMSProviderSpecialty WITH (NOLOCK)
		ON CodesetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
	ORDER BY CAST(EncounterDate AS DATE) DESC
	
	
	END
	END
ELSE
   BEGIN
   SELECT src.EncounterType
	     ,CONVERT(VARCHAR(10), src.EncounterDate, 101) AS EncounterDate
		 ,COALESCE(ISNULL(P1.LastName, '') + ' ' + ISNULL(P1.FirstName, '') + ' ' + ISNULL(P1.MiddleName, ''), '') AS CareProvider
		
	FROM (
		SELECT DISTINCT @i_UserId AS UserId
			,CAST(p.DateOfService AS DATE) EncounterDate
			,p.CodeGroupingName AS EncounterType
			,p.ProviderID UserProviderID
			
		FROM #x p WITH (NOLOCK)
		) Src
	LEFT JOIN Provider P1 WITH (NOLOCK)
		ON P1.ProviderID = Src.UserProviderId
	LEFT JOIN ProviderSpecialty WITH (NOLOCK)
		ON ProviderSpecialty.ProviderID = P1.ProviderID
	LEFT JOIN CodesetCMSProviderSpecialty WITH (NOLOCK)
		ON CodesetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
	ORDER BY CAST(EncounterDate AS DATE) DESC
	
	
   
   END	
   
   
;with CTE
AS
(

	   SELECT CASE WHEN AdmitType = 'I' THEN 'Admission' WHEN AdmitType = 'E' THEN 'Emergency Visit' END AS Eventtype,
	   [dbo].[ufn_PatientADTPopup](p.PatientID, 'AdmitDate',P.PatientADTId) AS Eventdate
	   , [dbo].[ufn_PatientADTPopup](p.PatientID, 'Facility',P.PatientADTId) 
	   AS DisChargeFacilityName
	   , [dbo].[ufn_PatientADTPopup](p.PatientID, 'NoOfDays',P.PatientADTId) 
	   AS NumberOfDays
	   ,'N/A' AS InpatientDays
	   ,P.IsReadmit AS ReadmissionFlag
        FROM PatientADT P WHERE PatientId = @i_UserId 
        AND NOT EXISTS (SELECT 1 FROM #X clm WHERE clm.ProviderID = p.PatientId
        AND clm.DateOfService = COALESCE(p.Eventadmitdate,p.VisitAdmitdate,p.MessageAdmitdate)
        )
        
	   UNION		
	   					 
	   SELECT 'Discharge' AS Eventtype,
	   [dbo].[ufn_PatientADTPopup](p.PatientID, 'Dischargedate',P.PatientADTId) AS Eventdate
	   , [dbo].[ufn_PatientADTPopup](p.PatientID, 'Facility',P.PatientADTId) 
	   AS DisChargeFacilityName
	   ,'N/A'  AS NumberOfDays
	   ,[dbo].[ufn_PatientADTPopup](p.PatientID, 'InPatientDays',P.PatientADTId) 
	   AS InpatientDays	
	   ,NULL AS ReadmissionFlag
	   FROM PatientADT P WHERE PatientId = @i_UserId	
	   AND eventdischargedate IS NOT NULL 
	   AND NOT EXISTS (SELECT 1 FROM #X clm WHERE clm.ProviderID = p.PatientId
        AND clm.DateOfService BETWEEN  COALESCE(Eventadmitdate,VisitAdmitdate,MessageAdmitdate) and
        COALESCE(EventDischargedate,VisitDischargedate,VisitDischargedate)
        )

)

SELECT Eventtype,CONVERT(VARCHAR(10),CAST(Eventdate AS DATE),101) EventDate ,DisChargeFacilityName,NumberOfDays,InpatientDays,CASE WHEN ReadmissionFlag = 0 THEN '' WHEN ReadmissionFlag = 1 THEN 'Yes' END ReadmissionFlag FROM CTE ORDER BY CAST(Eventdate AS DATE) ASC
	
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
    ON OBJECT::[dbo].[usp_DashBoard_PatientHomePage_ProgramEncounters] TO [FE_rohit.r-ext]
    AS [dbo];

