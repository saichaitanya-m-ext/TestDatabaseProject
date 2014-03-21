/*                
------------------------------------------------------------------------------                
Function Name: [ufn_GetPatientMeasureLatestValueAndDateTaken_Drill]     
Description   : This Function Returns Patient Latest MeasureValue, Name & Datetaken for patient
Created By    : NagaBabu                
Created Date  : 29-Apr-2011               
------------------------------------------------------------------------------                
Log History   :   
05-Sept-2011 Rathnam modified the exists clause  
06-Sept-2011 Rathnam added @dt_DateTaken parameter            
------------------------------------------------------------------------------                
--*/ 
--SELECT [dbo].[ufn_GetPatientMeasureLatestValueAndDateTaken_Drill](5,80,'2010-08-17 04:08:18.040')
CREATE FUNCTION [dbo].[ufn_GetPatientMeasureLatestValueAndDateTaken_Drill]
(
   @i_PatientUserId KeyId ,
   @i_MeasureId KeyId,
   @dt_DateTaken DATETIME = NULL
)
RETURNS VARCHAR(300)
AS
BEGIN
		DECLARE @d_MeasureValue DECIMAL(10,2),
		        @vc_PatientMeasure VARCHAR(200),
		        @vc_MeasureRange VARCHAR(10),
		        @i_UserMeasureId KEYID,
		        @vc_MeasureTrend VARCHAR(5),
		        @vc_MeasureValueText VARCHAR(200)
		        
		      
		SELECT @vc_PatientMeasure = ISNULL(CAST(UserMeasure.MeasureValueNumeric AS VARCHAR(15)), UserMeasure.MeasureValueText)
								   + ', ' + CONVERT(VARCHAR,UserMeasure.DateTaken,101)
		                          
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
		  AND EXISTS  
				 ( SELECT MAX(UM2.Datetaken)
					 FROM UserMeasure UM2  
					WHERE UM2.PatientUserId = UserMeasure.PatientUserId  
					  AND UM2.MeasureId = UserMeasure.MeasureId  
				   AND UM2.StatusCode = 'A'
				   AND (UM2.DateTaken = @dt_DateTaken OR @dt_DateTaken IS NULL)  
				   HAVING MAX(UM2.Datetaken) = UserMeasure.Datetaken
				  )
				 
		 RETURN  ISNULL(@vc_PatientMeasure,'')
END
