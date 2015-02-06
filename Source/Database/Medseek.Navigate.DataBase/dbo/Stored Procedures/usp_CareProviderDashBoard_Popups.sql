  
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_CareProviderDashBoard_Popups  10941,4010,'Encounters',null      
Description   : This Procedure is used for getting popupdata by patientuseid in careprovider dashboard tabs      
Created By    : Rathnam      
Created Date  : 22-Dec-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
20-Jan-2011 Rathnam changed the conditions for Healthrisk score       
15-Feb-2011 Rathnam Modified the Healthrisk score conditions         
09-May-2011 Rathnam added @v_PopUpType = 'ICDCode' tab.      
26-May-2011 Rathnam added @v_PopUpType = 'CPTCode' tab.      
09-Aug-2011 NagaBabu Added @v_PopUpType = 'DiseaseMarker' tab      
11-Aug-2011 NagaBabu Added 'AND UserDisease.DiseaseMarkerStatus = 'N'' for 'DiseaseMarker' Tab      
17-Aug-2011 NagaBabu Modified ICDMarker,MeasureMarker Fields      
12-Sep-2011 NagaBabu Replaced MeasureMarker,ICDMarker fields by SelectedCriteria      
08-Nov-2012 sivakrishna Added YtdUtilization,CareGaps,RxUtilization,ERVisits If Clauses to give the popup details.      
08/07/2013 Santosh Commented the COlumn Comments    

------------------------------------------------------------------------------          
*/    
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_Popups]-- 10,820,'Encounters',null    
 (    
 @i_AppUserId KEYID    
 ,@i_PatientUserId KEYID    
 ,@v_PopUpType VARCHAR(15)    
 ,@d_LastOfficeVisist DATETIME = NULL 
 ,@t_tDiseaseID ttypekeyid READONLY
 ,@t_tProgramID ttypekeyid READONLY 
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
 
 
 
 CREATE TABLE #TEMP
 (
 DiseaseID INT
 )
 
 INSERT INTO #TEMP
 SELECT * FROM @t_tDiseaseID
 
 
 CREATE TABLE #TEST
 (
 ProgramID INT
 )
 
 INSERT INTO #TEST
 SELECT * FROM @t_tProgramID
 
 DECLARE @vc_SQL VARCHAR(MAX),
         @v_SQL VARCHAR(MAX)  
    
 ------------------ Diseases that have been diagnosed for the patient ------------------------      
  IF @v_PopUpType = 'Diseases'    
  SET @vc_SQL = 'SELECT  ISNULL(PopulationDefinition.PopulationDefinitionName, '''') AS Conditions    
  FROM PopulationDefinitionPatients ConditionDefinitionUser WITH (NOLOCK)    
  INNER JOIN PopulationDefinition WITH (NOLOCK)    
   ON ConditionDefinitionUser.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID   '
   
    IF EXISTS (SELECT 1 FROM #TEMP)
    BEGIN
    
    SET @vc_SQL = @vc_SQL + ' INNER JOIN #TEMP
                                ON DiseaseID =  ConditionDefinitionUser.PopulationDefinitionID '
       
    end 
    
  SET @vc_SQL = @vc_SQL + ' WHERE ConditionDefinitionUser.PatientID = ' + CAST(@i_PatientUserId AS VARCHAR) +'
   AND PopulationDefinition.StatusCode = ''A''    
   AND ConditionDefinitionUser.StatusCode = ''A''    
   AND PopulationDefinition.DefinitionType = ''C'''    
   
    
    PRINT (@vc_SQL)
    EXEC (@vc_SQL)
   
  --ORDER BY StartDate DESC    
      
    
 ------------------ Active programs the patient is enrolled in ------------------------       
 IF @v_PopUpType = 'programs'
     
 SET @v_SQL = 'SELECT ISNULL(CONVERT(VARCHAR, PatientProgram.EnrollmentStartDate, 101), '''') + '' - '' + ISNULL(Program.ProgramName, '''') AS [Managed Population]    
  FROM PatientProgram WITH (NOLOCK)    
  INNER JOIN Program WITH (NOLOCK)    
   ON PatientProgram.ProgramId = Program.ProgramId    
    AND Program.StatusCode = ''A''    
    AND PatientProgram.StatusCode = ''A'''    
  
   IF EXISTS (SELECT 1 FROM #TEST)
   BEGIN
   SET @v_SQL = @v_SQL + 'INNER JOIN #TEST
                               ON #TEST.ProgramID = PatientProgram.ProgramID '
     
   
   END
   
   SET @v_SQL = @v_SQL + 'WHERE PatientProgram.PatientID = '+CAST(@i_PatientUserId AS VARCHAR)+'   
   AND PatientProgram.EnrollmentStartDate IS NOT NULL    
   AND PatientProgram.EnrollmentEndDate IS NULL    
   AND PatientProgram.IsPatientDeclinedEnrollment = 0    
--  ORDER BY PatientProgram.EnrollmentStartDate DESC '

   PRINT(@v_SQL)
    EXEC (@v_SQL)
    
 IF @v_PopUpType = 'Encounters'    
 BEGIN   
 

  -----------------------Past Encounters-------------------------       
 --CREATE TABLE #CodeGrouping (
	--	CodeGroupingID INT
	--	,CodeGroupingName VARCHAR(1000)
	--	,IsOther BIT
	--	)

	--INSERT INTO #CodeGrouping
	--SELECT cg.CodeGroupingID
	--	,cg.CodeGroupingName
	--	,CASE 
	--		WHEN cg.CodeGroupingName IN (
	--				'Surgery'
	--				,'Anesthesia'
	--				,'Radiology'
	--				,'Laboratory'
	--				)
	--			THEN 1
	--		ELSE 0
	--		END
	--FROM CodeGrouping cg WITH (NOLOCK)
	--INNER JOIN CodeTypeGroupers ctg WITH (NOLOCK)
	--	ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	--INNER JOIN CodeGroupingType cgt WITH (NOLOCK)
	--	ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	--WHERE cgt.CodeGroupType = 'Utilization Groupers'
	--	AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'

	--CREATE TABLE #PatInternalProc (
	--	CodeGroupingID INT
	--	,CodeGroupingName VARCHAR(500)
	--	,DateOfService DATE
	--	,IsOther BIT
	--	);

	--INSERT INTO #PatInternalProc
	--SELECT DISTINCT cg.CodeGroupingID
	--	,cg.CodeGroupingName
	--	--,ppc.ClaimInfoId
	--	,ppc.DateOfService DateOfService
	--	,cg.IsOther
	--FROM PatientProcedureCode ppc WITH (NOLOCK)
	--INNER JOIN PatientProcedureCodeGroup ppcg WITH (NOLOCK)
	--	ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
	--INNER JOIN #CodeGrouping cg WITH (NOLOCK)
	--	ON cg.CodeGroupingID = ppcg.CodeGroupingID
	--WHERE ppc.PatientID = @i_PatientUserId
	--	AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))
	
	--UNION
	
	--SELECT DISTINCT cg.CodeGroupingID
	--	,cg.CodeGroupingName
	--	--,ppc.ClaimInfoId
	--	,ppc.DateOfService DateOfService
	--	,cg.IsOther
	--FROM PatientOtherCode ppc WITH (NOLOCK)
	--INNER JOIN PatientOtherCodeGroup ppcg WITH (NOLOCK)
	--	ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
	--INNER JOIN #CodeGrouping cg WITH (NOLOCK)
	--	ON cg.CodeGroupingID = ppcg.CodeGroupingID
	--WHERE ppc.PatientID = @i_PatientUserId
	--	AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))

	--CREATE TABLE #PatProc (
	--	CodeGroupingID INT
	--	,CodeGroupingName VARCHAR(1000)
	--	,DateOfService DATE
	--	);

	--INSERT INTO #PatProc
	--SELECT CodeGroupingID
	--	,CodeGroupingName
	--	,DateOfService
	--FROM (
	--	SELECT CodeGroupingID
	--		,CodeGroupingName
	--		,DateOfService
	--		,ROW_NUMBER() OVER (
	--			PARTITION BY DateOfService ORDER BY CASE 
	--					WHEN CodeGroupingName = 'Acute Inpatient'
	--						THEN 1
	--					WHEN CodeGroupingName = 'Observation Stay'
	--						THEN 2
	--					WHEN CodeGroupingName = 'Hospice'
	--						THEN 3
	--					ELSE 4
	--					END
	--			) sno
	--	FROM #PatInternalProc
	--	WHERE IsOther = 0 -- 17 Symphony Internal encounter groupers
		
	--	UNION ALL
		
	--	SELECT CodeGroupingID
	--		,CodeGroupingName
	--		,DateOfService
	--		,ROW_NUMBER() OVER (
	--			PARTITION BY DateOfService ORDER BY CASE 
	--					WHEN CodeGroupingName = 'Surgery'
	--						THEN 1
	--					WHEN CodeGroupingName = 'Anesthesia'
	--						THEN 2
	--					WHEN CodeGroupingName = 'Radiology'
	--						THEN 3
	--					WHEN CodeGroupingName = 'Laboratory'
	--						THEN 4
	--					ELSE 5
	--					END
	--			) sno
	--	FROM #PatInternalProc
	--	WHERE IsOther = 1
	--		AND NOT EXISTS (
	--			SELECT 1
	--			FROM #PatInternalProc P
	--			WHERE p.DateOfService = #PatInternalProc.DateOfService
	--				AND P.IsOther = 0
	--			) -- If above 17 encounters groupers doesnt satisfy it will go for Other 4 like Surgery,Anesthesia,Radiology,Laboratory
		
	--	UNION ALL
		
	--	SELECT DISTINCT 0 CodeGroupingID
	--		,'Other' CodeGroupingName
	--		,DateOfAdmit
	--		,1
	--	FROM ClaimInfo WITH (NOLOCK)
	--	WHERE IsOtherUtilizationGroup = 1
	--		AND DateOfAdmit > DATEADD(YEAR, - 1, GETDATE())
	--		AND PatientID = @i_PatientUserId
	--		AND NOT EXISTS (
	--			SELECT 1
	--			FROM #PatInternalProc p
	--			WHERE p.DateOfService = ClaimInfo.DateOfAdmit
	--			)
	--	) t
	--WHERE t.sno = 1

	--SELECT DISTINCT p.*
	--	,cp.ProviderID
	--	,ci.claiminfoid
	--INTO #x
	--FROM #PatProc p
	--INNER JOIN ClaimInfo ci
	--	ON p.DateOfService = ci.DateOfAdmit
	--LEFT JOIN ClaimProvider cp
	--	ON cp.ClaimInfoID = ci.ClaimInfoID
	--WHERE ci.PatientID = @i_PatientUserId
	--ORDER BY 3 DESC
	
	
	--SELECT src.EncounterType
	--     ,CONVERT(VARCHAR(10), src.EncounterDate, 101) AS EncounterDate
	--	 ,COALESCE(ISNULL(P1.LastName, '') + ' ' + ISNULL(P1.FirstName, '') + ' ' + ISNULL(P1.MiddleName, ''), '') AS CareProvider
		
		
		
	--FROM (
	--	SELECT DISTINCT @i_PatientUserId AS UserId
	--		,CAST(p.DateOfService AS DATE) EncounterDate
	--		,p.CodeGroupingName AS EncounterType
			
	--		,p.ProviderID UserProviderID
			
			
	--	FROM #x p WITH (NOLOCK)
	--	) Src
	--LEFT JOIN Provider P1 WITH (NOLOCK)
	--	ON P1.ProviderID = Src.UserProviderId
	--LEFT JOIN ProviderSpecialty WITH (NOLOCK)
	--	ON ProviderSpecialty.ProviderID = P1.ProviderID
	--LEFT JOIN CodesetCMSProviderSpecialty WITH (NOLOCK)
	--	ON CodesetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
	--ORDER BY CAST(EncounterDate AS DATE) DESC
	
	   DECLARE @i_UserId INT = @i_patientUserid,
	           @b_ispopup ISINDICATOR = 1,
	           @b_isLV ISINDICATOR = 0
	   EXEC [usp_DashBoard_PatientHomePage_ProgramEncounters] @i_AppUserId ,@i_UserId ,@b_isLV,@b_ispopup
	
	--SELECT 
		 
	--	 CONVERT(VARCHAR(10), src.EncounterDate, 101) AS EncounterDate
	--	,src.EncounterType
	--	,COALESCE(ISNULL(P1.LastName, '') + ' ' + ISNULL(P1.FirstName, '') + ' ' + ISNULL(P1.MiddleName, ''), '') AS CareProvider
	--	FROM (
	--	SELECT DISTINCT 
	--		--,COALESCE(ISNULL(P.LastName, '') + ' ' + ISNULL(P.FirstName, '') + ' ' + ISNULL(P.MiddleName, ''), '') AS CareProvider
	--		CAST(p.DateOfService AS DATE) EncounterDate
	--		,p.CodeGroupingName AS EncounterType
	--		,p.CodeGroupingID EncounterTypeId
	--		--,cp.ProviderID UserProviderID
	--		,(
	--			SELECT TOP 1 ClaimProvider.ProviderID
	--			FROM ClaimInfo ci WITH (NOLOCK)
	--			INNER JOIN Claimprovider WITH (NOLOCK)
	--				ON Claimprovider.ClaimInfoID = ci.ClaimInfoID
	--			WHERE ci.DateOfAdmit = p.DateofService
	--			ORDER BY 1 DESC
	--			) UserProviderID
	--		,'' CPTCode
	--					--,CodesetCMSProviderSpecialty.ProviderSpecialtyName ProviderSpeciality
	--		FROM #PatProc p WITH (NOLOCK)
	--	) Src
	--LEFT JOIN Provider P1 WITH (NOLOCK)
	--	ON P1.ProviderID = Src.UserProviderId
	--LEFT JOIN ProviderSpecialty WITH (NOLOCK)
	--	ON ProviderSpecialty.ProviderID = P1.ProviderID
	--LEFT JOIN CodesetCMSProviderSpecialty WITH (NOLOCK)
	--	ON CodesetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
	--ORDER BY CAST(EncounterDate AS DATE) DESC
    
    
  -----------------------Future Encounters-------------------------   
  SELECT  '' AS  'Scheduled Date','' AS 'Encounter Type', '' AS 'Care Provider','' AS Comments WHERE 1 =0    
  END    
    
 ----------------------------Risk Score for each type-------------------------      
 IF @v_PopUpType = 'Risk'    
  SELECT CONVERT(VARCHAR, UHS.DateDetermined, 101) AS 'Date'    
   ,HealthRisk.[Risk Score Type] AS 'Risk Score Type'    
   ,CASE     
    WHEN UHS.Score IS NOT NULL    
     THEN CONVERT(VARCHAR, UHS.Score) + '%'    
    ELSE UHS.ScoreText    
    END AS Score    
  FROM PatientHealthStatusScore UHS WITH (NOLOCK)    
  INNER JOIN HealthStatusScoreType UST WITH (NOLOCK)    
   ON UST.HealthStatusScoreId = UHS.HealthStatusScoreId    
  INNER JOIN (    
   SELECT DISTINCT MAX(PatientHealthStatusId) AS UserHealthStatusId    
    ,HealthStatusScoreOrganization.NAME + ' - ' + HealthStatusScoreType.NAME AS 'Risk Score Type'    
   FROM PatientHealthStatusScore WITH (NOLOCK)    
   INNER JOIN HealthStatusScoreType WITH (NOLOCK)    
    ON HealthStatusScoreType.HealthStatusScoreId = PatientHealthStatusScore.HealthStatusScoreId    
   INNER JOIN HealthStatusScoreOrganization WITH (NOLOCK)    
    ON HealthStatusScoreOrganization.HealthStatusScoreOrgId = HealthStatusScoreType.HealthStatusScoreOrgId    
   WHERE PatientHealthStatusScore.PatientID = @i_PatientUserId    
    AND PatientHealthStatusScore.StatusCode = 'A'    
    AND HealthStatusScoreType.StatusCode = 'A'    
   GROUP BY HealthStatusScoreOrganization.NAME + ' - ' + HealthStatusScoreType.NAME    
   ) HealthRisk    
   ON HealthRisk.UserHealthStatusId = UHS.PatientHealthStatusId    
  WHERE UHS.PatientID = @i_PatientUserId    
   AND UHS.StatusCode = 'A'    
   AND UST.StatusCode = 'A'    
  ORDER BY UHS.DateDetermined DESC    
    
 IF @v_PopUpType = 'ICDCode'    
  AND @d_LastOfficeVisist IS NOT NULL    
  SELECT DISTINCT TOP 50 cg.DiagnosisCode AS ICDCode    
   ,cg.DiagnosisLongDescription AS ICDCodeDescription    
  FROM PatientDiagnosisCode pdc WITH (NOLOCK)    
  INNER JOIN PatientDiagnosisCodeGroup pdg    
   ON pdg.PatientDiagnosisCodeID = pdc.PatientDiagnosisCodeID    
  INNER JOIN CodeSetICDDiagnosis cg    
      ON cg.DiagnosisCodeID = pdc.DiagnosisCodeID     
  WHERE pdc.PatientID = @i_PatientUserId    
   AND CAST(pdc.DateOfService AS DATE)= CAST(@d_LastOfficeVisist AS DATE)    
   AND pdc.StatusCode = 'A'    
    
 IF @v_PopUpType = 'CPTCode'    
  AND @d_LastOfficeVisist IS NOT NULL    
  SELECT DISTINCT TOP 50 cg.ProcedureCode CPTCode    
   ,cg.ProcedureName CPTCodeDescription     
  FROM PatientProcedureCode ppc WITH (NOLOCK)    
  INNER JOIN PatientProcedureCodeGroup ppcg WITH (NOLOCK)    
   ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID    
  INNER JOIN CodeSetProcedure cg    
   ON cg.ProcedureCodeID = ppc.ProcedureCodeID    
  WHERE ppc.PatientID = @i_PatientUserId    
   AND CAST(ppc.DateOfService AS DATE) = CAST(@d_LastOfficeVisist AS DATE)    
       
    
 ----------------------------------------------------------------------------------------------      
 --    IF @v_PopUpType = 'DiseaseMarker'      
 --SELECT DISTINCT      
 -- UserDisease.UserID,      
 -- CONVERT(VARCHAR,UserDisease.DiagnosedDate,101) AS DiagnosedDate ,      
 -- UserDisease.DiseaseId ,      
 -- Disease.Name ,      
 -- DiseaseMarkerCriteria.CriteriaText AS SelectedCriteria ,      
 --          CASE UserDisease.DiseaseMarkerStatus      
 --  WHEN 'A' THEN 'Accepted'      
 --  WHEN 'N' THEN 'NotAccepted'      
 --  WHEN 'M' THEN 'Manuel'      
 --  ELSE ''      
 -- END AS DiseaseMarkerStatus             
 --FROM       
 -- UserDisease WITH (NOLOCK)      
 --INNER JOIN Disease  WITH (NOLOCK)      
 -- ON UserDisease.DiseaseId = Disease.DiseaseId      
 --INNER JOIN DiseaseMarkerCriteria WITH (NOLOCK)      
 -- ON DiseaseMarkerCriteria.DiseaseId = Disease.DiseaseId       
 --WHERE UserDisease.UserID = @i_PatientUserId      
 --  AND UserDisease.DiseaseMarkerStatus = 'N'        
 ---------------------          
 IF @v_PopUpType = 'YTDUtilization'    
  SELECT DATEPART(YY, CI.PaidDate) AS Year    
   ,CAST(SUM(CASE     
      WHEN CI.ClaimInfoId IS NULL    
       THEN 0    
      ELSE 1    
      END) AS VARCHAR) AS TotalNumberOfClaims    
   ,'$' + CAST(SUM(CASE     
      WHEN CI.NetPaidAmount IS NULL    
       THEN 0    
      ELSE CI.NetPaidAmount    
      END) AS VARCHAR) TotalAmountPaid    
  FROM ClaimInfo CI WITH (NOLOCK)    
  WHERE CI.PatientID = @i_PatientUserId    
   AND CAST(CI.PaidDate AS DATE) BETWEEN CAST(DATEADD(YY, - 3, GETDATE()) AS DATE)    
    AND CAST(GETDATE() AS DATE)    
  GROUP BY DATEPART(YY, CI.PaidDate)    
  ORDER BY DATEPART(YY, CI.PaidDate) DESC    
    
 --------------------------------------         
 IF @v_PopUpType = 'ERVisits'    
  SELECT DATEPART(YY, CI.PaidDate) AS Year    
   ,CAST(SUM(CASE     
      WHEN CL.ClaimLineID IS NULL    
       THEN 0    
      ELSE 1    
      END) AS VARCHAR) AS TotalNoOfVisists    
   ,'$' + CAST(SUM(CASE     
      WHEN CI.NetPaidAmount IS NULL    
       THEN 0    
      ELSE CI.NetPaidAmount    
      END) AS VARCHAR) AS TotalAmountPaid    
  FROM ClaimInfo CI WITH (NOLOCK)    
  INNER JOIN ClaimLine CL WITH (NOLOCK)    
   ON CI.ClaimInfoId = CL.ClaimInfoID    
  --INNER JOIN CodeSetCMSPlaceOfService PS WITH (NOLOCK)    
  -- ON CL.PlaceOfServiceCodeID = PS.PlaceOfServiceCodeID    
  --INNER JOIN EncounterType ET WITH (NOLOCK)    
  -- ON PS.EncounterTypeID = ET.EncounterTypeId    
  INNER JOIN vw_PatientEncounter PE    
   ON PE.ClaimInfoId = CI.ClaimInfoId    
  WHERE --ET.Name = 'ER'    
   PE.CodeGroupingName = 'ED'    
   AND CI.PatientID = @i_PatientUserId    
   AND CAST(CI.PaidDate AS DATE) BETWEEN CAST(DATEADD(YY, - 3, GETDATE()) AS DATE)    
    AND CAST(GETDATE() AS DATE)    
  GROUP BY DATEPART(YY, CI.PaidDate)    
  ORDER BY DATEPART(YY, CI.PaidDate) DESC    
    
 -----------------------------------------------      
 IF @v_PopUpType = 'RxUtilization'    
  SELECT Rx.RxClaimNumber AS RxClaimNum    
   ,CSD.DrugCode    
   ,CSD.DrugName    
   ,CONVERT(VARCHAR(12), Rx.DateFilled, 101) AS DateOfTaken    
   ,SUM(CASE     
     WHEN Rx.QuantityDispensed IS NULL    
      THEN 0    
     ELSE Rx.QuantityDispensed    
     END)    
  FROM RxClaim Rx WITH (NOLOCK)    
  INNER JOIN PatientDrugCodes Ud WITH (NOLOCK)    
   ON Rx.RxClaimId = ud.RxClaimId    
  INNER JOIN CodeSetDrug CSD WITH (NOLOCK)    
   ON UD.DrugCodeId = CSD.DrugCodeId    
  WHERE Ud.PatientID = @i_PatientUserId    
   AND CAST(Rx.DateFilled AS DATE) BETWEEN CAST(DATEADD(YY, - 3, GETDATE()) AS DATE)    
    AND CAST(GETDATE() AS DATE)    
  GROUP BY Rx.RxClaimNumber    
   ,CSD.DrugCode    
   ,CSD.DrugName    
   ,Rx.DateFilled    
    
 --------------------------------------            
 IF @v_PopUpType = 'CareGaps'    
  SELECT ISNULL(Dbo.ufn_GetTypeNamesByTypeId(ty.TaskTypeName, t.TypeID), t.ManualTaskName) AS TaskName    
   ,    
   --CONVERT(VARCHAR(10),DATEADD(DD,t.RemainderDays,t.TaskDueDate),101) MissedOpportunityDate      
   CONVERT(VARCHAR(10), CASE     
     WHEN ISNULL(t.TerminationDays, 0) <> 0    
      THEN DATEADD(Day, t.TerminationDays, t.TaskDueDate)    
     ELSE t.TaskDuedate    
     END, 101) MissedOpportunityDate    
  FROM Task t WITH (NOLOCK)    
  INNER JOIN TaskStatus ts WITH (NOLOCK)    
   ON t.TaskStatusId = ts.TaskStatusId    
  INNER JOIN TaskType ty WITH (NOLOCK)    
   ON ty.TaskTypeId = t.TaskTypeId    
  WHERE ts.TaskStatusText = 'Closed Incomplete'    
   AND t.PatientId = @i_PatientUserId    
END TRY    
    
---------------------------------------------------------------           
BEGIN CATCH    
 -- Handle exception          
 DECLARE @i_ReturnedErrorID INT    
    
 EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
 RETURN @i_ReturnedErrorID    
END CATCH 

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_Popups] TO [FE_rohit.r-ext]
    AS [dbo];

