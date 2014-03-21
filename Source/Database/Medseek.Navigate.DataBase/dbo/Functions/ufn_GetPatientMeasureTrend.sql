/*                  
------------------------------------------------------------------------------                  
Function Name: ufn_GetPatientMeasureTrend             
Description   : This Function Returns measure trend Value for patient  
Created By    : Pramod                  
Created Date  : 24-June-2010                  
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
16-Sep-2011 NagaBabu Replaced Parameter @i_Usermeasureid by @d_Datetaken    
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_GetPatientMeasureTrend]  
(  
  @d_Datetaken DATETIME,  
  @i_MeasureId KeyID,  
  @i_PatientUserId KeyID,  
  @i_MeasureValueNumeric DECIMAL(10,2)  
)   
RETURNS VARCHAR(2)  
AS   
BEGIN  
  
 DECLARE @d_MeasureValue DECIMAL(10,2),  
   @i_Current_UserMeasureId KEYID,  
   @v_returnValue VARCHAR(2)  
  
 -- Patient Level measure value calculation  
 SELECT TOP 1 @d_MeasureValue = MeasureValueNumeric, @i_Current_UserMeasureId = PatientMeasureID  
 FROM PatientMeasure  
    WHERE MeasureId = @i_MeasureId  
    AND PatientID = @i_PatientUserId  
    --AND UserMeasureId < @i_UserMeasureId 
    AND Datetaken < @d_Datetaken
    AND Datetaken IS NOT NULL
    AND MeasureValueNumeric IS NOT NULL  
 ORDER BY DateTaken DESC  
  
 IF @@ROWCOUNT > 0   
  SET @v_returnValue =  
   CASE   
      WHEN @i_MeasureValueNumeric > @d_MeasureValue THEN  
     '1'  
      WHEN @i_MeasureValueNumeric = @d_MeasureValue THEN  
     '0'  
      WHEN @i_MeasureValueNumeric < @d_MeasureValue THEN  
     '-1'  
      ELSE   
     ''     
   END  
 ELSE  
  SET @v_returnValue = ' ' 
  
 RETURN @v_returnValue  
END
