/*                    
------------------------------------------------------------------------------                    
Function Name: ufn_GetLatestMeasureValueByUserIDAndMeasureName               
Description   : This Function is used for getting the latest value for particular   
                By PatientUserid and MeasureID                 
Created By    : Rathnam    
Created Date  : 16-Nov-2011   
------------------------------------------------------------------------------                    
Log History   :                     
DD-MM-YYYY     BY      DESCRIPTION                    
------------------------------------------------------------------------------                    
*/  
--SELECT [dbo].[ufn_GetLatestMeasureValueByUserIDAndMeasureName]('Test by rk',14)  
CREATE FUNCTION [dbo].[ufn_GetLatestMeasureValueByUserIDAndMeasureName]  
(  
  @v_MeasureName VARCHAR(100),  
  @i_PatientID KEYID  
)  
RETURNS VARCHAR(300)  
AS  
BEGIN  
  
      DECLARE @v_LatestMeasureValue VARCHAR(300),  
              @i_MeasureID INT  
      SELECT @i_MeasureID = MeasureId FROM Measure WHERE Name = @v_MeasureName         
      SELECT TOP 1  
          @v_LatestMeasureValue = CASE  
                            WHEN um.MeasureValueText IS NULL THEN @v_MeasureName + ' - ' + CAST(um.MeasureValueNumeric AS VARCHAR(30)) + '  '+ MeasureUOM.uomtext + ' Taken on ' + CONVERT(VARCHAR(10) , um.Datetaken , 101)  
                            ELSE @v_MeasureName + ' - ' + um.MeasureValueText + ' Taken on ' + CONVERT(VARCHAR(10) , um.Datetaken , 101)  
                       END  
        
      FROM  
          PatientMeasure um  
      LEFT OUTER JOIN MeasureSynonyms mss  
      ON mss.SynonymMeasureID = um.MeasureId  
      LEFT OUTER JOIN MeasureUOM  
          ON um.MeasureUOMId = MeasureUOM.MeasureUOMId  
      WHERE  
          um.PatientId = @i_PatientID  
          AND (mss.SynonymMasterMeasureID = @i_MeasureID OR um.MeasureId = @i_MeasureID)  
          AND um.DateTaken IS NOT NULL  
      ORDER BY  
         DateTaken DESC  
  
      RETURN ISNULL(@v_LatestMeasureValue , '')  
END    
    