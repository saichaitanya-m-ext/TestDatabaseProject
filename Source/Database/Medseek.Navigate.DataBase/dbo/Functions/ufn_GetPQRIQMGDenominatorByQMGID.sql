/*                
------------------------------------------------------------------------------                
Function Name : [ufn_GetPQRIQMGDenominatorByQMGID] 
Description   : This procedure is used get the denominators for list of QualityMeasuresGroups
Created By    : Rathnam
Created Date  : 06-Jan-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------                
*/

--select [dbo].[ufn_GetPQRIQMGDenominatorByQMGID]  ('130')
CREATE FUNCTION [dbo].[ufn_GetPQRIQMGDenominatorByQMGID] 
     (
       @v_PQRIQualityMeasureGroupIDS VARCHAR(MAX)
     )
RETURNS VARCHAR(MAX)
AS
BEGIN
	  DECLARE @v_PQRIQMGDenominator VARCHAR(MAX) = ''

      DECLARE @tblQMID TABLE
      (
       QMID INT
      )
      INSERT INTO @tblQMID
      SELECT CONVERT(INT,KeyValue) FROM [dbo].[udf_SplitStringToTable](@v_PQRIQualityMeasureGroupIDS,',')
             
      SELECT @v_PQRIQMGDenominator = @v_PQRIQMGDenominator + CriteriaSQL + ' OR ' FROM PQRIQualityMeasureGroupDenominator
      WHERE PQRIQualityMeasureGroupID IN (SELECT QM.QMID FROM @tblQMID QM )
      
      RETURN CASE WHEN  @v_PQRIQMGDenominator <> '' THEN  ' AND (' + SUBSTRING(@v_PQRIQMGDenominator, 1, LEN(@v_PQRIQMGDenominator)-2) + ' )'
                  ELSE NULL 
             END
END
