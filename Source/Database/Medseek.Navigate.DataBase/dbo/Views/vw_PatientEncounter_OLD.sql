


 
CREATE VIEW [dbo].[vw_PatientEncounter_OLD]  
AS  

WITH enctrCTE  
AS (  

 SELECT  cg.CodeGroupingID  
  ,ppc.PatientID  
  ,cg.CodeGroupingName  
  ,ppc.ClaimInfoId  
  ,ppc.DateOfService AS DateOfService  
 FROM PatientProcedureCode ppc  
 INNER JOIN PatientProcedureCodeGroup ppcg  
  ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID  
 INNER JOIN CodeGrouping cg  
  ON cg.CodeGroupingID = ppcg.CodeGroupingID  
 INNER JOIN CodeTypeGroupers ctg  
  ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID  
 INNER JOIN CodeGroupingType cgt  
  ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID  
 WHERE ppc.StatusCode = 'A'  
  AND ppcg.StatusCode = 'A'  
  AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))  
  AND cgt.CodeGroupType = 'Utilization Groupers'  
  AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'  
  AND NOT EXISTS (  SELECT 1
					FROM  ClaimInfo CI
					WHERE CI.IsOtherUtilizationGroup = 1
					AND ppc.PatientID = CI.PatientID
					AND ppc.DateOfService = CI.DateOfAdmit)
 UNION  
 SELECT  cg.CodeGroupingID  
  ,ppc.PatientID  
  ,cg.CodeGroupingName  
  ,ppc.ClaimInfoId  
  ,ppc.DateOfService AS DateOfService  
 FROM PatientOtherCode ppc  
 INNER JOIN PatientOtherCodeGroup ppcg  
  ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID  
 INNER JOIN CodeGrouping cg  
  ON cg.CodeGroupingID = ppcg.CodeGroupingID  
 INNER JOIN CodeTypeGroupers ctg  
  ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID  
 INNER JOIN CodeGroupingType cgt  
  ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID  
 WHERE ppc.StatusCode = 'A'  
  AND ppcg.StatusCode = 'A'  
  AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))  
  AND cgt.CodeGroupType = 'Utilization Groupers'  
  AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'  
  AND NOT EXISTS (  SELECT 1
					FROM  ClaimInfo CI
					WHERE CI.IsOtherUtilizationGroup = 1
					AND ppc.PatientID = CI.PatientID
					AND ppc.DateOfService = CI.DateOfAdmit)
UNION
SELECT  0  
  ,CI.PatientID 
  ,'Other'  
  ,CI.ClaimInfoId  
  ,CI.DateOfAdmit AS DateOfService  
 FROM  ClaimInfo CI
 WHERE CI.IsOtherUtilizationGroup = 1
)  
SELECT CodeGroupingID  
 ,PatientID  
 ,CodeGroupingName  
 ,ClaimInfoId  
 ,MIN(DateOfService) DateOfService  
FROM enctrCTE  
WHERE (DateOfService > DATEADD(YEAR,-1,GETDATE()))
GROUP BY CodeGroupingID  
 ,CodeGroupingName  
 ,ClaimInfoId  
 ,PatientID  


