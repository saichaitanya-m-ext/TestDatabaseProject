


 
CREATE VIEW [dbo].[vw_PatientEncounter]  
AS  

WITH enctrCTE  
AS (  

 SELECT  cg.CodeGroupingID  
  ,CI.PatientID  
  ,cg.CodeGroupingName  
  ,CI.ClaimInfoId  
  ,CI.DateOfAdmit AS DateOfService  
 FROM ClaimCodeGroup CCG
 INNER JOIN ClaimInfo CI
  ON CI.ClaimInfoId = CCG.ClaimInfoID 
 INNER JOIN CodeGrouping cg  
  ON cg.CodeGroupingID = CCG.CodeGroupingID  
 INNER JOIN CodeTypeGroupers ctg  
  ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID  
 INNER JOIN CodeGroupingType cgt  
  ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID  
 WHERE (CI.DateOfAdmit > DATEADD(YEAR, - 1, GETDATE()))  
  AND cgt.CodeGroupType = 'Utilization Groupers'  
  AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'  
  AND NOT EXISTS (  SELECT 1
					FROM  ClaimInfo CI1
					WHERE CI.IsOtherUtilizationGroup = 1
					AND CI1.PatientID = CI.PatientID
					AND CI1.DateOfAdmit = CI.DateOfAdmit)
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


