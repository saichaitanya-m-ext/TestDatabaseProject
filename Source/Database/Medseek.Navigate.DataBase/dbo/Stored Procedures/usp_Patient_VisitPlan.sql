/*            
------------------------------------------------------------------------------------------            
Procedure Name: [usp_Patient_VisitPlan]23,100478        
Description   : This procedure is used as a wrapperprocedure for Patient Visit plan.            
Created By    : SANTOSH            
Created Date  : 22-June-2013  
------------------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION        
30/07/2013:Santosh added RiskScore to the Result set  
30/07/2013:Santosh added TaskCompletionDate column to resultset Closed Tasks  
30/07/2013:Santosh added Missed Opportunitydate column to resultset Opentasks  
30/07/2013:Santosh added Recommended Preventive screenings  
31/07/2013:Santosh added Result sets StandardQualityMetrics and CareManagementMetrics  
08/08/2013:Santosh added Missed Opportunity to the Closed Task Result Set  
28/08/2013:Mohan commented in task select statement in where statement of Task DueDate 
-------------------------------------------------------------------------------------------            
*/  

CREATE PROCEDURE [dbo].[usp_Patient_VisitPlan]--23,4222  
 (  
 @i_AppUserId KEYID  
 ,@i_UserId KEYID  
 )  
AS  
BEGIN TRY  
 SET NOCOUNT ON  
  
 DECLARE @i_numberOfRecordsSelected INT  
  
 ----- Check if valid Application User ID is passed--------------            
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
  
 DECLARE @v_PlanName VARCHAR(500)  
  
 SELECT @v_PlanName =  ISNULL(igp.PlanName, '')  
 FROM PatientInsurance p WITH(NOLOCK)  
 INNER JOIN (  
  SELECT TOP (1) PatientInsuranceID  
  FROM PatientInsuranceBenefit WITH(NOLOCK)  
  WHERE DateOfEligibility = (  
    SELECT MAX(DateOfEligibility)  
    FROM PatientInsuranceBenefit pib WITH(NOLOCK)  
    INNER JOIN PatientInsurance pie WITH(NOLOCK)  
     ON pib.PatientInsuranceID = pie.PatientInsuranceID  
    WHERE pie.PatientID = @i_UserId  
    )  
  ) d  
  ON p.PatientInsuranceID = d.PatientInsuranceID  
 INNER JOIN InsuranceGroupPlan igp WITH(NOLOCK)  
  ON igp.InsuranceGroupPlanId = p.InsuranceGroupPlanId  
 INNER JOIN InsuranceGroup ig WITH(NOLOCK)  
  ON ig.InsuranceGroupID = igp.InsuranceGroupId  
  
 SELECT PatientID  
  ,MemberNum  
  ,Age  
  ,FullName  
  ,Gender  
  ,CONVERT(VARCHAR(10), GETDATE(),101) StartDate  
  ,[dbo].[ufn_GetPCPName](PatientID) PCPName  
  ,@v_PlanName InsurancePlanName  
 FROM Patients  
 WHERE PatientID = @i_UserId  
---------------------------Identified Condition-------------------  

 SELECT DISTINCT p.PopulationDefinitionName AS NAME
			--,u.StartDate AS DiagnosedDate
			,CONVERT(VARCHAR(10), (
					SELECT MIN(pdpa.OutPutAnchorDate)
					FROM PopulationDefinitionPatientAnchorDate pdpa
					WHERE pdpa.PopulationDefinitionPatientID = u.PopulationDefinitionPatientID
					),101) FirstIdentifiedDate
		--,CONVERT(VARCHAR(10),u.StartDate,101) DiagnosedDate
		FROM PopulationDefinition p WITH (NOLOCK)
		INNER JOIN PopulationDefinitionPatients u WITH (NOLOCK)
			ON u.PopulationDefinitionID = p.PopulationDefinitionID
		INNER JOIN CodeGrouping cg
		   ON cg.CodeGroupingID = p.CodeGroupingID
		INNER JOIN CodeTypeGroupers ct
		   ON ct.CodeTypeGroupersID = cg.CodeTypeGroupersID 
		INNER JOIN [Standard] S
			ON S.StandardId = P.StandardsId	
		WHERE PatientID = @i_UserID
			AND S.Name = 'CCS'
			AND p.DefinitionType = 'C'
			AND u.StatusCode = 'A'
			AND p.StatusCode = 'A'
			AND p.ProductionStatus = 'F'
			AND ISNULL(p.IsDisplayInHomePage, 0) = 1
			AND p.IsDisplayInHomePage = 1
			AND ct.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group'
------------------------------Recommended Preventive Screening------------------  
 SELECT  DISTINCT 
  cl.PopulationDefinitionName AS Name , 
  CONVERT(VARCHAR(10), (
					SELECT MIN(pdpa.OutPutAnchorDate)
					FROM PopulationDefinitionPatientAnchorDate pdpa
					WHERE pdpa.PopulationDefinitionPatientID = clu.PopulationDefinitionPatientID
					),101) StartDate
  --,CONVERT(VARCHAR(26),clu.StartDate,23) AS FirstDateIdentified  
 --,CONVERT(VARCHAR(10),clu.StartDate,101) AutomatedConditionDate  
 FROM PopulationDefinitionPatients clu WITH (NOLOCK)  
 INNER JOIN PopulationDefinition cl WITH (NOLOCK)  
  ON cl.PopulationDefinitionId = clu.PopulationDefinitionId  
 WHERE PatientID = @i_UserID  
  AND cl.StatusCode = 'A'  
  AND clu.StatusCode = 'A'  
  AND cl.DefinitionType = 'P'  
  AND cl.ProductionStatus = 'F'  
  AND ISNULL(cl.IsDisplayInHomePage, 0) = 1  
  AND cl.IsDisplayInHomePage = 1  
 ORDER BY PopulationDefinitionName  
 --EXEC usp_UserProblem_Select @i_AppUserId = @i_AppUserId  
 -- ,@i_UserId = @i_UserId  
 -- ,@v_StatusCode = 'A'  
---------------------------Identified Condition-------------------  
  --SELECT DISTINCT P.LastName+P.FirstName AS Name,StartDate FROM PopulationDefinitionPatients PP  
  --INNER JOIN PopulationDefinition PD  
  --ON PP.PopulationDefinitionID = PD.PopulationDefinitionID  
  --INNER JOIN Patients P  
  --ON P.PatientID = PP.PatientID   
  --WHERE PP.PatientID =  @i_UserId  
  --AND PD.DefinitionType = 'C'  
  --AND StartDate IS NOT NULL  
  
----------------------RiskScore----------------------------------------------------  
 SELECT  DISTINCT 
  ISNULL(CAST(PatientHealthStatusScore.Score AS VARCHAR(200)), '') + ISNULL(PatientHealthStatusScore.ScoreText, '') AS Value  
  ,HealthStatusScoreType.NAME AS RiskScoreName  
  ,CONVERT(VARCHAR(12), PatientHealthStatusScore.DateDetermined, 103) DateDetermined
  --,CONVERT(VARCHAR(26),PatientHealthStatusScore.DateDetermined,23) AS LastRunDate  
 FROM PatientHealthStatusScore WITH (NOLOCK)  
 INNER JOIN HealthStatusScoreType WITH (NOLOCK)  
  ON HealthStatusScoreType.HealthStatusScoreId = PatientHealthStatusScore.HealthStatusScoreId  
 WHERE (PatientHealthStatusScore.PatientID = @i_UserID)  
  AND (PatientHealthStatusScore.StatusCode = 'A')  
 --ORDER BY PatientHealthStatusScore.DateDue DESC  
 -- ,PatientHealthStatusScore.DateDetermined DESC  
  
 ----------------------Medication ---------------------------------------------  
	;with RxC 
    AS (
		SELECT DISTINCT ISNULL(CodeSetDrug.DrugName, '') MedicationName 
			,Rx.DateFilled
			--,CONVERT(VARCHAR(26),Rx.DateFilled,23) StartDate  
			,CodeSetDrug.DosageName AS Dosage  
			,CodeSetDrug.StrengthUnitNormalized AS MedicationStrenght
			,CodeSetDrug.Strength AS QuantityDispensed  
			,Rx.DaysSupply DaysSupply  
			,DBO.ufn_GetUserNameByID(Rx.PrescriberID) AS ProviderName  
			,CodeSetCMSProviderSpecialty.ProviderSpecialtyName AS SpecialityName  
		FROM RxClaim Rx WITH (NOLOCK) 
		INNER JOIN (SELECT MAX(DateFilled)DateFilled ,DrugCodeId
					FROM 
					RxClaim 
					WHERE PatientID = @i_UserID
					AND DateFilled BETWEEN DATEADD(YEAR,-1,GETDATE()) AND GETDATE()
					GROUP BY PatientID,DrugCodeId)DT
			ON DT.DrugCodeId = RX.DrugCodeId
			AND DT.DateFilled = RX.DateFilled			 
		INNER JOIN vw_CodeSetDrug CodeSetDrug WITH (NOLOCK)  
		ON CodeSetDrug.DrugCodeId = Rx.DrugCodeId  
		LEFT JOIN ProviderSpecialty WITH (NOLOCK)  
		ON Rx.PrescriberID = ProviderSpecialty.ProviderID  
		LEFT JOIN CodeSetCMSProviderSpecialty WITH (NOLOCK)  
		ON CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID  
		WHERE Rx.PatientID = @i_UserID  
		AND Rx.StatusCode = 'A'  
		--AND Rx.DateFilled > DATEADD(YEAR,-1,GETDATE())  
		)
		
		SELECT 
			MedicationName ,
			CONVERT(VARCHAR(10),DateFilled,101) AS StartDate ,
			Dosage ,
			MedicationStrenght ,
			QuantityDispensed ,
			DaysSupply ,
			ProviderName ,
			SpecialityName 
		FROM 
			RxC 
		ORDER BY DateFilled DESC	
  
-----------------------------------------utilization-----------------------------------------------------  
 --DECLARE @i_Top INT = 5;  
 --DECLARE @i_Top INT ;  
 CREATE TABLE #PatProc (  
  CodeGroupingID INT  
  ,CodeGroupingName VARCHAR(500)  
  ,ClaimInfoId INT  
  ,DateOfService DATE  
  );  
  
 WITH enctrCTE  
 AS (  
  SELECT DISTINCT cg.CodeGroupingID  
   ,cg.CodeGroupingName  
   ,ppc.ClaimInfoId  
   ,ppc.DateOfService DateOfService  
  FROM PatientProcedureCode ppc  
  INNER JOIN PatientProcedureCodeGroup ppcg  
   ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID  
  INNER JOIN CodeGrouping cg  
   ON cg.CodeGroupingID = ppcg.CodeGroupingID  
  INNER JOIN CodeTypeGroupers ctg  
   ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID  
  INNER JOIN CodeGroupingType cgt  
   ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID  
  WHERE ppc.PatientID = @i_UserId  
   AND ppc.StatusCode = 'A'  
   AND ppcg.StatusCode = 'A'  
   AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))  
   AND cgt.CodeGroupType = 'Utilization Groupers' 
   AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)' 
    
  UNION  
    
  SELECT DISTINCT cg.CodeGroupingID  
   ,cg.CodeGroupingName  
   ,ppc.ClaimInfoId  
   ,ppc.DateOfService DateOfService  
  FROM PatientOtherCode ppc  
  INNER JOIN PatientOtherCodeGroup ppcg  
   ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID  
  INNER JOIN CodeGrouping cg  
   ON cg.CodeGroupingID = ppcg.CodeGroupingID  
  INNER JOIN CodeTypeGroupers ctg  
   ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID  
  INNER JOIN CodeGroupingType cgt  
   ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID  
  WHERE ppc.PatientID = @i_UserId  
   AND ppc.StatusCode = 'A'  
   AND ppcg.StatusCode = 'A'  
   AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))  
   AND cgt.CodeGroupType = 'Utilization Groupers'  
   AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'
   
   UNION
		--- Utilziation Other Group
		SELECT 0 CodeGroupingID
			,'Other' CodeGroupingName
			,ClaimInfoID
			,DateOfAdmit
		FROM ClaimInfo
		WHERE IsOtherUtilizationGroup = 1
		and DateOfAdmit > DATEADD(YEAR, - 1, GETDATE())
			AND PatientID = @i_UserId
  )  
 INSERT INTO #PatProc  
 SELECT CodeGroupingID  
  ,CodeGroupingName  
  ,ClaimInfoId  
  ,MIN(DateOfService)  
 FROM enctrCTE  
 GROUP BY CodeGroupingID  
  ,CodeGroupingName  
  ,ClaimInfoId  
  -----------------------Encounters----------------------
  exec usp_DashBoard_PatientHomePage_ProgramEncounters @i_AppUserId,@i_UserId
 -- ;WITH NCTE
 -- AS
 -- (
 --SELECT DISTINCT COALESCE(ISNULL(P.LastName, '') + ' ' + ISNULL(P.FirstName, '') + ' ' + ISNULL(P.MiddleName, ''), '') AS Provider  
 -- ,CONVERT(VARCHAR(10), ci.DateOfService, 101) EncounterDate  
 -- ,ci.CodeGroupingName AS EncounterType  
 -- ,'' CPTCode  
 -- ,STUFF((  
 --   SELECT DISTINCT ', ' + CAST(CodeSetICDDiagnosis.DiagnosisCode AS VARCHAR(100)) + ' - ' + CodeSetICDDiagnosis.DiagnosisLongDescription  
 --   FROM ClaimLineDiagnosis WITH (NOLOCK)  
 --   INNER JOIN CodeSetICDDiagnosis WITH (NOLOCK)  
 --    ON CodeSetICDDiagnosis.DiagnosisCodeID = ClaimLineDiagnosis.DiagnosisCodeID  
 --   INNER JOIN ClaimLine WITH (NOLOCK)  
 --    ON ClaimLine.ClaimLineID = ClaimLineDiagnosis.ClaimLineID  
 --   WHERE ClaimLine.ClaimInfoID = ci.ClaimInfoId  
 --   --AND CONVERT(DATE, ClaimLine.BeginServiceDate) = CONVERT(DATE, ci.DateOfAdmit)  
 --   FOR XML PATH('')  
 --   ), 1, 2, '') DiagnosisCode  
 -- ,CodesetCMSProviderSpecialty.ProviderSpecialtyName ProviderSpeciality  
 -- ,CASE WHEN ci.CodeGroupingName = 'Acute Inpatient' THEN  
 -- STUFF((  
 --   SELECT DISTINCT ', ' + CAST(csi.ProcedureCode AS VARCHAR) + ' - ' + csi.ProcedureShortDescription  
 --   FROM ClaimProcedure cp WITH (NOLOCK)  
 --   INNER JOIN CodeSetICDProcedure csi WITH (NOLOCK)  
 --    ON cp.ProcedureCodeID = csi.ProcedureCodeID  
 --   INNER JOIN CodeGroupingDetailInternal cgdi WITH (NOLOCK)  
 --    ON cgdi.CodeGroupingCodeID = csi.ProcedureCodeID  
 --   INNER JOIN CodeGrouping cg WITH (NOLOCK)  
 --       ON cg.CodeGroupingID = cgdi.CodeGroupingID   
 --   INNER JOIN CodeTypeGroupers ctg WITH (NOLOCK)  
 --       ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID  
 --   WHERE cp.ClaimInfoID = ci.ClaimInfoId  
 --       AND ctg.CodeTypeGroupersName = 'CCS ICD Procedure 4Classes'  
 --       AND cg.CodeGroupingCode IN (3,4)  
 --   --AND CONVERT(DATE, ClaimLine.BeginServiceDate) = CONVERT(DATE, ci.DateOfAdmit)  
 --   FOR XML PATH('')  
 --   ), 1, 2, '')  
 --   ELSE '' END MajorProcedures  
 --FROM #PatProc ci WITH (NOLOCK)  
 --INNER JOIN Patients ps WITH (NOLOCK)  
 -- ON ps.PatientID = @i_UserId  
 --LEFT JOIN ClaimProvider cp WITH (NOLOCK)  
 -- ON cp.ClaimInfoID = ci.ClaimInfoId  
 --LEFT JOIN ProviderSpecialty WITH (NOLOCK)  
 -- ON ProviderSpecialty.ProviderID = cp.ProviderId  
 --LEFT JOIN Provider P WITH (NOLOCK)  
 -- ON P.ProviderID = ProviderSpecialty.ProviderID  
 --LEFT JOIN CodesetCMSProviderSpecialty WITH (NOLOCK)  
 -- ON CodesetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID  
 -- )
 -- SELECT * FROM NCTE ORDER BY CAST(EncounterDate AS DATE) DESC
 ----WHERE (ci.DateOfService > DATEADD(YEAR, - 1, GETDATE()))  
 ----ORDER BY ci.DateOfService DESC   
--LAB RESULTS ---------------------------  
 ;WITH CTE
 AS
 (
    
 SELECT DISTINCT    
  csl.LoincCodeId    
  ,csl.ShortDescription AS MeasureName    
  ,CAST(ISNULL(CAST(pm.MeasureValueNumeric AS VARCHAR),MeasureValueText) AS VARCHAR(10))  Value    
  ,CONVERT(VARCHAR(10), pm.DateTaken, 101) AS ValueDate    
  ,CONVERT(VARCHAR(10), ISNULL(pm.DueDate, pm.DateTaken), 101) AS DueDateToMeetPatientGoal    
  /*    
  ,dbo.ufn_GetPatientMeasureRangeAndGoal(pm.MeasureId, pm.PatientId, ISNULL(CAST(pm.MeasureValueNumeric AS DECIMAL(10, 2)), 0), pm.MeasureValueText) AS Patientgoal    
  ,CASE     
  WHEN pm.MeasureValueNumeric IS NOT NULL    
  THEN [dbo].[ufn_GetPatientMeasureTrend](pm.DateTaken, pm.MeasureId, pm.PatientMeasureID, pm.MeasureValueNumeric)    
  ELSE 0    
  END TrendLevel    
  */     
  ,CONVERT(VARCHAR(10), pm.DateTaken, 101) DateTaken    
  --CONVERT(VARCHAR(10),pm.DateTaken,23) DateTaken    
 FROM PatientMeasure pm WITH (NOLOCK)    
 INNER JOIN CodeSetLOINC csl WITH (NOLOCK)    
  ON pm.LoincCodeID = csl.LOINCCodeID    
 WHERE pm.PatientID = @i_UserID   
 
 --SELECT DISTINCT    
 -- csl.MetricId AS LoincCodeId    
 -- --,csl.ShortDescription AS MeasureName 
 -- ,csl.Name AS MeasureName       
 -- --,ISNULL(pm.MeasureValueNumeric,MeasureValueText) Value 
 -- ,pm.Value     
 -- --,CONVERT(VARCHAR(10), pm.DateTaken, 101) AS ValueDate    
 -- ,CONVERT(VARCHAR(10), pm.ValueDate, 101) AS ValueDate    
 -- --,CONVERT(VARCHAR(10), ISNULL(pm.DueDate, pm.DateTaken), 101) AS DueDateToMeetPatientGoal   
 -- ,CONVERT(VARCHAR(10), pm.ValueDate, 101) AS DueDateToMeetPatientGoal    
 -- /*    
 -- ,dbo.ufn_GetPatientMeasureRangeAndGoal(pm.MeasureId, pm.PatientId, ISNULL(CAST(pm.MeasureValueNumeric AS DECIMAL(10, 2)), 0), pm.MeasureValueText) AS Patientgoal    
 -- ,CASE     
 -- WHEN pm.MeasureValueNumeric IS NOT NULL    
 -- THEN [dbo].[ufn_GetPatientMeasureTrend](pm.DateTaken, pm.MeasureId, pm.PatientMeasureID, pm.MeasureValueNumeric)    
 -- ELSE 0    
 -- END TrendLevel    
 -- */     
 -- --,CONVERT(VARCHAR(10), pm.DateTaken, 101) DateTaken 
 -- ,CONVERT(VARCHAR(10), pm.ValueDate, 101) AS DateTaken    
 -- --CONVERT(VARCHAR(10),pm.DateTaken,23) DateTaken    
 --FROM NRPatientValue pm WITH (NOLOCK)    
 --INNER JOIN Metric csl WITH (NOLOCK)    
 -- ON pm.MetricID = csl.MetricId       
 --WHERE pm.PatientID = @i_UserID     
   
 UNION  
 SELECT   
  NULL AS LoincCodeId    
  ,'Blood pressure' AS MeasureName    
  ,CAST(SystolicValue AS VARCHAR(10)) + '/' + CAST(DiastolicValue AS VARCHAR(10)) Value    
  ,CONVERT(VARCHAR(10), MeasurementTime, 101) AS ValueDate    
  ,CONVERT(VARCHAR(10), MeasurementTime, 101) AS DueDateToMeetPatientGoal    
  /*    
  ,dbo.ufn_GetPatientMeasureRangeAndGoal(pm.MeasureId, pm.PatientId, ISNULL(CAST(pm.MeasureValueNumeric AS DECIMAL(10, 2)), 0), pm.MeasureValueText) AS Patientgoal    
  ,CASE     
  WHEN pm.MeasureValueNumeric IS NOT NULL    
  THEN [dbo].[ufn_GetPatientMeasureTrend](pm.DateTaken, pm.MeasureId, pm.PatientMeasureID, pm.MeasureValueNumeric)    
  ELSE 0    
  END TrendLevel    
  */     
  ,CONVERT(VARCHAR(10), MeasurementTime , 101) DateTaken    
 FROM   
  PatientVitalSignBloodPressure  
 WHERE   
  PatientID = @i_UserID   
   
 )
 
 SELECT * FROM CTE WHERE CAST(ValueDate AS DATE) BETWEEN  DATEADD(YEAR,-1,GETDATE()) AND GETDATE()   ORDER BY CAST(ValueDate AS DATE) DESC    
----------------------------------------------managed population----------------------  
  SELECT DISTINCT P.ProgramName
  ,CONVERT(VARCHAR(10), pg.EnrollmentStartDate, 101) EnrollmentStartDate  
  --,CONVERT(VARCHAR(26),pg.EnrollmentStartDate,23)EnrollmentStartDate
  FROM PatientProgram pg  
  INNER JOIN Program p  
  ON pg.ProgramID = p.ProgramId  
  WHERE pg.PatientID = @i_UserId  
  AND pg.StatusCode = 'A'  
  AND p.StatusCode = 'A'  
  AND pg.EnrollmentEndDate IS NULL
-------------------------------------------open task-----------------------------------------  
 SELECT Task.TaskId  
     ,TaskType.TaskTypeName AS TaskName  
  , dbo.ufn_GetTypeNamesByTypeId(TaskType.TaskTypeName, Task.TypeID) TaskTypeName  
  ,CONVERT(VARCHAR(10),Task.TaskDueDate,101) AS DueDate  
  ,CONVERT(VARCHAR(10),DATEADD(DD, Task.TerminationDays, Task.TaskDueDate),101) MissedOpportunityDate  
 FROM Task  
 INNER JOIN TaskType  
  ON TaskType.TaskTypeId = Task.TaskTypeId  
 WHERE Task.PatientId = @i_UserID  
  AND Task.TaskDueDate IS NOT NULL  
  --AND Task.TaskDueDate < GETDATE() --> DATEADD(YEAR, -1, GETDATE())  
  AND TaskType.StatusCode = 'A'  
  AND Task.TaskStatusId IN (  
   SELECT TaskStatusID  
   FROM TaskStatus  
   WHERE TaskStatusText = 'Open'  
   )  
 ORDER BY Task.TaskDueDate DESC  
-------------------------------------------------closed Task--------------------------------------------------  
  
  
  SELECT Task.TaskId  
   ,TaskType.TaskTypeName AS TaskTypeName   
  , dbo.ufn_GetTypeNamesByTypeId(TaskType.TaskTypeName, Task.TypeID) TaskName 
  ,CONVERT(VARCHAR(10),Task.TaskDueDate,101) AS DueDate  
  ,CONVERT(VARCHAR(10),Task.TaskCompletedDate,101) AS TaskCompletionDate  
  ,CASE WHEN DATEADD(DD,RemainderDays,TaskDueDate) > = Task.TaskCompletedDate THEN '' ELSE '' END AS MissedOpportunity  
  FROM Task  
   INNER JOIN TaskType  
     ON TaskType.TaskTypeId = Task.TaskTypeId  
     WHERE   
        Task.PatientId = @i_UserID  
       AND  
     Task.TaskDueDate IS NOT NULL  
     AND Task.TaskCompletedDate > DATEADD(YEAR,-1,GETDATE())  
     AND Task.TaskStatusId IN (  
   SELECT TaskStatusID  
   FROM TaskStatus  
   WHERE TaskStatusText = 'Closed Complete'  )
   
    UNION
    
   SELECT Task.TaskId  
 ,TaskType.TaskTypeName AS   TaskName
  , dbo.ufn_GetTypeNamesByTypeId(TaskType.TaskTypeName, Task.TypeID) TaskTypeName   
  ,CONVERT(VARCHAR(10),Task.TaskDueDate,101) AS DueDate  
  ,'' AS TaskCompletionDate  
  ,CASE WHEN DATEADD(DD,RemainderDays,CONVERT(VARCHAR(10),Task.TaskDueDate,101)) > = Task.TaskCompletedDate THEN ' ' ELSE 'Yes' END AS MissedOpportunity  
  FROM Task  
   INNER JOIN TaskType  
     ON TaskType.TaskTypeId = Task.TaskTypeId  
     WHERE   
        Task.PatientId = @i_UserID  
       AND  
     Task.TaskDueDate IS NOT NULL  
     --AND Task.TaskCompletedDate > DATEADD(YEAR,-1,GETDATE())  
     AND Task.TaskStatusId IN (  
   SELECT TaskStatusID  
   FROM TaskStatus  
   WHERE TaskStatusText = 'Closed InComplete'
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
    ON OBJECT::[dbo].[usp_Patient_VisitPlan] TO [FE_rohit.r-ext]
    AS [dbo];

