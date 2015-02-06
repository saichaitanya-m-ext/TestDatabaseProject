/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetPatientLastMeasureValue           
Description   : This Function is used to get the MeasureRange Value               
Created By    : Rathnam               
Created Date  : 17-Nov-2012                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
------------------------------------------------------------------------------                
*/

CREATE FUNCTION [dbo].[ufn_GetPatientLastMeasureValue]
(
  @i_PatientUserId KEYID
)
RETURNS VARCHAR(200)
AS
BEGIN
      DECLARE @v_LastMeasureValue VARCHAR(200)
      SELECT TOP 1
          @v_LastMeasureValue = Name + ' - ' + CONVERT(VARCHAR(100) , ISNULL(CONVERT(VARCHAR,MeasureValueNumeric) , MeasureValueText))
      FROM
          UserMeasure
      INNER JOIN Measure
          ON Measure.MeasureId = UserMeasure.MeasureId
      WHERE
          PatientUserID = @i_PatientUserId
      ORDER BY
          DateTaken DESC

      RETURN @v_LastMeasureValue
END
