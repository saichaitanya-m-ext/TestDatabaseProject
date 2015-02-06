/*                
------------------------------------------------------------------------------                
Function Name: [ufn_GetPatientMeasureLatestValueAndDateTaken]        
Description   : This Function Returns Patient Latest MeasureValue, Name & Datetaken for patient
Created By    : Rathnam                
Created Date  : 19-Dec-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
14-Mar-2011    Ramachandra added  @vc_MeasureValueText parameter in DBO.ufn_GetPatientMeasureRange
15-Mar-2011    Rathnam commented the ufn_GetPatientMeasureRange the function and getting the Range values
                       from usermeasurerange table.
16-Sep-2011 NagaBabu Replaced @i_Usermeasureid by @d_Datetaken                       
------------------------------------------------------------------------------                
--*/ 
CREATE FUNCTION [dbo].[ufn_GetPatientMeasureLatestValueAndDateTaken]
(
   @i_PatientUserId KeyId ,
   @i_MeasureId KeyId
)
RETURNS VARCHAR(300)
AS
BEGIN
		DECLARE @d_MeasureValue DECIMAL(10,2),
		        @vc_PatientMeasure VARCHAR(200),
		        @vc_MeasureRange VARCHAR(10),
		        @d_Datetaken DATETIME,
		        @vc_MeasureTrend VARCHAR(5),
		        @vc_MeasureValueText VARCHAR(200)
		SELECT @vc_PatientMeasure = ISNULL(CAST(UserMeasure.MeasureValueNumeric AS VARCHAR(15)), UserMeasure.MeasureValueText) 
		                           + '$$' + CONVERT(VARCHAR,UserMeasure.DateTaken,101) 
		                           + '$$' + Measure.Name
		                           + '$$' + CONVERT(VARCHAR,Measure.MeasureId),
		       @d_MeasureValue = UserMeasure.MeasureValueNumeric,
		       @d_Datetaken = UserMeasure.DateTaken ,
		       @vc_MeasureRange = UserMeasureRange.MeasureRange
        FROM
            UserMeasure
        INNER JOIN Measure
            ON Measure.MeasureId = UserMeasure.MeasureId
        INNER JOIN UserMeasureRange
            ON UserMeasureRange.UserMeasureID = UserMeasure.UserMeasureID     
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
		 --SELECT @vc_MeasureRange = DBO.ufn_GetPatientMeasureRange(@i_MeasureId,@i_PatientUserId,@d_MeasureValue,@vc_MeasureValueText) 
		 SELECT @vc_MeasureTrend = dbo.ufn_GetPatientMeasureTrend (@d_Datetaken, @i_MeasureId, @i_PatientUserId, @d_MeasureValue)
		 RETURN  ISNULL(@vc_PatientMeasure,'')+ '$$' + ISNULL(@vc_MeasureRange,'')+'$$'+ ISNULL(@vc_MeasureTrend,'')
END
