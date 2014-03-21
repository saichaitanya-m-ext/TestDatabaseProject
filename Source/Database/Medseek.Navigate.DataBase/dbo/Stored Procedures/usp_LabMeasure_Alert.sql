/*          
------------------------------------------------------------------------------          
Procedure Name: usp_LabMeasure_Alert          
Description   : This procedure is used to get the details from LabMeasur table for Program & Organization level         
Created By    : Rathnam    
Created Date  : 12-Sept-2011         
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
20-Sep-2011 NagaBabu Added 'AND m.StatusCode = 'A'' to where clause in both select statements 
04-Nov-2011 NagaBabu Added 'AND GETDATE() BETWEEN lm.StartDate AND lm.EndDate' to each select statement   
------------------------------------------------------------------------------          
*/ 
CREATE PROCEDURE [dbo].[usp_LabMeasure_Alert]
(
 @i_AppUserId KEYID
,@c_LevelType CHAR(1)= 'O'
)
AS
BEGIN TRY
      SET NOCOUNT ON           
-- Check if valid Application User ID is passed        

      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END        
  
-----Organization level Labmeasures 
      IF @c_LevelType = 'O'
         BEGIN
               SELECT
                   lm.LabMeasureId
                  ,m.MeasureId
                  ,m.Name
                  ,lm.EndDate
               FROM
                   LabMeasure lm
               INNER JOIN Measure m
                   ON lm.MeasureId = m.MeasureId
               WHERE
                   ProgramId IS NULL
                   AND PatientUserID IS NULL
                   AND REPLACE(DATEDIFF(DD , GETDATE() , lm.EndDate),'-','') <= lm.ReminderDaysBeforeEnddate
                   AND GETDATE() BETWEEN lm.StartDate AND lm.EndDate
                   AND m.StatusCode = 'A'  
  
  
 ------ Program level Labmeasures   
               SELECT DISTINCT
                   lm.LabMeasureId
                  ,p.ProgramName
                  ,lm.ProgramId
                  ,m.MeasureId
                  ,m.Name
                  ,lm.EndDate
               FROM
                   LabMeasure lm
               INNER JOIN PatientProgram ups
                   ON ups.ProgramId = lm.ProgramId
               INNER JOIN Program p
                   ON p.ProgramId = ups.ProgramId
               INNER JOIN Measure m
                   ON m.MeasureId = lm.MeasureId
               WHERE
                   lm.PatientUserID IS NULL
                   AND REPLACE(DATEDIFF(DD , GETDATE() , lm.EndDate),'-','') <= lm.ReminderDaysBeforeEnddate
                   AND GETDATE() BETWEEN lm.StartDate AND lm.EndDate
                   AND m.StatusCode = 'A'
                   AND P.StatusCode = 'A'
         END
      ELSE IF @c_LevelType = 'P'
			  BEGIN  ---------------PATIENT LEVEL
					SELECT
						lm.LabMeasureId
					   ,lm.EndDate
					   ,p.PatientID AS UserId
					   ,p.FullName
					   ,m.MeasureId
					   ,m.Name
					FROM
						LabMeasure lm
					INNER JOIN Patients p
						ON p.PatientID = lm.PatientUserID
					INNER JOIN Measure m
						ON m.MeasureId = lm.MeasureId
					WHERE
						lm.ProgramId IS NULL
						AND lm.PatientUserID IS NOT NULL
						AND REPLACE(DATEDIFF(DD , GETDATE() , lm.EndDate),'-','') <= lm.ReminderDaysBeforeEnddate
						AND GETDATE() BETWEEN lm.StartDate AND lm.EndDate
						AND m.StatusCode = 'A'
						AND p.UserStatusCode = 'A'
			  END
         
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
    ON OBJECT::[dbo].[usp_LabMeasure_Alert] TO [FE_rohit.r-ext]
    AS [dbo];

