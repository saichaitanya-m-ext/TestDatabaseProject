/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetLatestA1CByUserID           
Description   : This Function is used for getting the latest A1C value for particular Patient             
Created By    : Rathnam
Created Date  : 29-06-2011
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
------------------------------------------------------------------------------                
*/  
  
CREATE FUNCTION [dbo].[ufn_GetLatestA1CByUserID]
(
	@i_PatientID KeyID 
)	
RETURNS VARCHAR(300)
AS
BEGIN
    DECLARE @v_LastA1C VARCHAR(300)
	SELECT TOP 1
			 @v_LastA1C = 
			 CASE
				WHEN PatientMeasure.MeasureValueText IS NULL 
					THEN CAST(PatientMeasure.MeasureValueNumeric AS VARCHAR(30)) 
							+ MeasureUOM.uomtext + ' Taken on ' 
							+ CONVERT(VARCHAR(10) , PatientMeasure.Datetaken , 101)
				ELSE PatientMeasure.MeasureValueText + ' Taken on ' 
					 + CONVERT(varchar(10) , PatientMeasure.Datetaken , 101)
			 END
	    FROM
		     PatientMeasure 
		      LEFT OUTER JOIN MeasureUOM
				 ON  PatientMeasure.MeasureUOMId = MeasureUOM.MeasureUOMId
	   WHERE
		     PatientMeasure.PatientId = @i_PatientID
		 AND PatientMeasure.MeasureId 
		      = ( SELECT MeasureId
					FROM Measure
				   WHERE Name = 'A1c' 
				 )
	  ORDER BY
		  PatientId,
		  DateTaken DESC	
	
	RETURN ISNULL(@v_LastA1C,'')
END

