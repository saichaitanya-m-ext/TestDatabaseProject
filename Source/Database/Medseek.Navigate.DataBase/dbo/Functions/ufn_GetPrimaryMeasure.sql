/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_GetPrimaryMeasure]          
Description   : This Function Returns PrimaryMeasure with MeasureId for patient  
Created By    : NagaBabu              
Created Date  : 15-June-2011                 
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
  
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_GetPrimaryMeasure]
(
  @i_DiseseId KeyID
)
RETURNS VARCHAR(200)
AS 
BEGIN
	DECLARE @v_Measure VARCHAR(200)
	
	SELECT @v_Measure = CAST(Measure.MeasureId AS VARCHAR(4)) + ' * ' + Name
	FROM
		DiseaseMeasure 
    INNER JOIN Measure
		ON DiseaseMeasure.MeasureId = Measure.MeasureId
	WHERE DiseaseMeasure.DiseaseId = @i_DiseseId
	AND IsPrimaryMeasure = 1
	
	IF @v_Measure IS NULL
	
		SELECT TOP 1 @v_Measure = CAST(Measure.MeasureId AS VARCHAR(4)) + ' * ' + Name
		FROM
			DiseaseMeasure 
		INNER JOIN Measure
			ON DiseaseMeasure.MeasureId = Measure.MeasureId
		WHERE DiseaseMeasure.DiseaseId = @i_DiseseId
		AND DiseaseMeasure.StatusCode = 'A'
		ORDER BY Measure.SortOrder ASC
		
	RETURN @v_Measure	
END

