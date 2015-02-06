
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [usp_Numerator_MeasureSelect_DD] 
Description   : This Procedure used to get the Program and cohortList mapped to LabMeasure  
Created By    : P.V.P.MOhan
Created Date  : 22-Nov-2012
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  

---------------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_Numerator_MeasureSelect_DD]   --23,12

(
 @i_AppUserId INT
,@i_MetricId INT = NULL
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
-------------------------------------------------------- 
      DECLARE
       
             @i_DenominatorID KEYID ,
             @vc_DenominatorType Varchar(1);

      SELECT
       
         @i_DenominatorID = DenominatorID,
         @vc_DenominatorType =  DenominatorType
      FROM
          metric
      WHERE
          MetricId = @i_MetricId


      IF @vc_DenominatorType = 'M'
      
         BEGIN
               SELECT DISTINCT
                   Measure.MeasureId
                  ,Measure.Name
                  ,Metric.MetricId
                  
               FROM
                   Metric
               INNER JOIN Program
                   ON Metric.DenominatorID = Program.ProgramId
               INNER JOIN LabMeasure
                   ON Program.ProgramId = LabMeasure.ProgramId
               INNER JOIN Measure
                   ON Measure.MeasureId = LabMeasure.MeasureId
               WHERE
                   Metric.MetricId = @i_MetricId
                   AND Metric.StatusCode = 'A'
                  AND  metric.DenominatorType = 'M'
         END
      ELSE
         BEGIN
               SELECT
                   Measure.MeasureId
                  ,Measure.Name
               FROM
                   Measure
               WHERE
                   Measure.StatusCode = 'A'
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
    ON OBJECT::[dbo].[usp_Numerator_MeasureSelect_DD] TO [FE_rohit.r-ext]
    AS [dbo];

