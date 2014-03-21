/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetPatientMeasureLatestValue          
Description   : This Function Returns Patient Latest MeasureValue for patient
Created By    : Pramod                
Created Date  : 09-July-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
05-Setp-2011 Rathnam modified the exist clause
------------------------------------------------------------------------------                
*/    
CREATE FUNCTION [dbo].[ufn_GetPatientMeasureLatestValue]
(
   @i_PatientUserId KeyId ,
   @i_MeasureId KeyId
)
RETURNS VARCHAR(200)
AS
BEGIN
		DECLARE @vc_MeasureValue VARCHAR(200)
		SELECT @vc_MeasureValue = ISNULL(CAST(UserMeasure.MeasureValueNumeric AS VARCHAR(15)), UserMeasure.MeasureValueText) 
        FROM
            UserMeasure
        INNER JOIN Measure
            ON Measure.MeasureId = UserMeasure.MeasureId
        WHERE
              UserMeasure.PatientUserId = @i_PatientUserId
          AND UserMeasure.MeasureId = @i_MeasureId
          AND UserMeasure.StatusCode = 'A'
          AND Measure.StatusCode = 'A'
          --AND UserMeasure.DateTaken > DATEADD(YEAR, -1, GETDATE())
          AND EXISTS  
				 ( SELECT MAX(UM2.Datetaken)
					 FROM UserMeasure UM2  
					WHERE UM2.PatientUserId = UserMeasure.PatientUserId  
					  AND UM2.MeasureId = UserMeasure.MeasureId  
				   AND UM2.StatusCode = 'A'  
				   HAVING MAX(UM2.Datetaken) = UserMeasure.Datetaken
				  )
		 ORDER BY UserMeasure.DateTaken DESC, Measure.Name
		RETURN @vc_MeasureValue 
END
