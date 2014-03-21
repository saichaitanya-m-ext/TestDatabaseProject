/*                
------------------------------------------------------------------------------                
Function Name : [ufn_GetPQRIQMDenominatorByQMID] 
Description   : This procedure is used get the denominators for list of QualityMeasures
Created By    : Rathnam
Created Date  : 06-Jan-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------                
*/ 
--select [dbo].[ufn_GetPQRIQMDenominatorByQMID] ('6,18')
CREATE FUNCTION [dbo].[ufn_GetPQRIQMDenominatorByQMID] 
     (
       @v_PQRIQualityMeasureIDS VARCHAR(MAX)
     )
RETURNS VARCHAR(MAX)
AS
BEGIN
	  DECLARE @v_PQRIQMDenominator VARCHAR(MAX) = ''

      DECLARE @tblQMID TABLE
      (
       QMID INT
      )
      INSERT INTO @tblQMID
      SELECT CONVERT(INT,KeyValue) FROM [dbo].[udf_SplitStringToTable](@v_PQRIQualityMeasureIDS,',')
             
      SELECT @v_PQRIQMDenominator = @v_PQRIQMDenominator + CriteriaSQL + ' OR ' FROM PQRIQualityMeasureDenominator
      WHERE PQRIQualityMeasureID IN (SELECT QM.QMID FROM @tblQMID QM )
      
      RETURN CASE WHEN  @v_PQRIQMDenominator <> '' THEN  ' AND (' + SUBSTRING(@v_PQRIQMDenominator, 1, LEN(@v_PQRIQMDenominator)-2) + ' )'
                  ELSE NULL 
             END
END
