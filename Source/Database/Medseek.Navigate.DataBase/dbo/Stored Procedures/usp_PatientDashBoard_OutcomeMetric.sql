

  
    
/*      
--------------------------------------------------------------------------------      
Procedure Name: [dbo].[usp_PatientDashBoard_OutcomeMetric] 10,4222     
Description   : This proc is used to show the patient demographic information in to the PatientHomepage      
Created By    : Rathnam      
Created Date  : 12-Dec-2012     
---------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
04-Jan-2013 NagaBabu Added Third resultset for patientPopulation managedpopulation    
12-Jan-2013 NagaBabu Added fourth,fifth resultssets newly     
03-APR-2013 Mohan Modified UserMeasure to PatientMeasure and modified Triggers of this Table.     
04-APR-2013 Mohan commented the Case Condition of PatientMeasueRange and added the GetMeasureandrange Function       
29-July-2013 Rathnam removed the measure join and kept Loinc code join    
---------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_PatientDashBoard_OutcomeMetric] -- 10,23    
 (    
 @i_AppUserId KEYID    
 ,@i_PatientUserID KEYID    
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
 END    
    
 DECLARE @dt_todaydate DATE = GETDATE()   
 --DECLARE @i_Top INT = 5    
 ;WITH CTE
 AS
 (
    
 SELECT DISTINCT    
  csl.LoincCodeId AS LoincCodeId    
  ,csl.ShortDescription AS MeasureName    
  ,CAST(ISNULL(CAST(pm.MeasureValueNumeric AS VARCHAR),MeasureValueText) AS VARCHAR) Value  
  --,NULL AS Value   
  ,CONVERT(VARCHAR(10), pm.DateTaken, 101) AS ValueDate    
  --,CONVERT(VARCHAR(10), ISNULL(pm.DueDate, pm.DateTaken), 101) AS DueDateToMeetPatientGoal
  ,CONVERT(VARCHAR(10), pm.DateTaken, 101) AS DueDateToMeetPatientGoal   
  /*    
  ,dbo.ufn_GetPatientMeasureRangeAndGoal(pm.MeasureId, pm.PatientId, ISNULL(CAST(pm.MeasureValueNumeric AS DECIMAL(10, 2)), 0), pm.MeasureValueText) AS Patientgoal    
  ,CASE     
  WHEN pm.MeasureValueNumeric IS NOT NULL    
  THEN [dbo].[ufn_GetPatientMeasureTrend](pm.DateTaken, pm.MeasureId, pm.PatientMeasureID, pm.MeasureValueNumeric)    
  ELSE 0    
  END TrendLevel    
  */     
  ,CONVERT(VARCHAR(10), pm.DateTaken, 101) AS DateTaken    
  --CONVERT(VARCHAR(10),pm.DateTaken,23) DateTaken    
 FROM PatientMeasure pm WITH (NOLOCK)    
 INNER JOIN CodeSetLoinc csl WITH (NOLOCK)    
  ON pm.LOINCCodeID = csl.LoincCodeId    
 WHERE pm.PatientID = @i_PatientUserID 
  AND pm.DateTaken >= DATEADD(YEAR,-1,@dt_todaydate)   
   
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
  PatientID = @i_PatientUserID   
  AND MeasurementTime >= DATEADD(YEAR,-1,@dt_todaydate)
   
 )
 
 SELECT * FROM CTE  ORDER BY CAST(ValueDate AS DATE) DESC
   
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
    ON OBJECT::[dbo].[usp_PatientDashBoard_OutcomeMetric] TO [FE_rohit.r-ext]
    AS [dbo];

