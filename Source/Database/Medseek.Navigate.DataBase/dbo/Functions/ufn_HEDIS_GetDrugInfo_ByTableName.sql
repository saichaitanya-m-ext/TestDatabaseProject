CREATE FUNCTION [dbo].[ufn_HEDIS_GetDrugInfo_ByTableName]
(
	@TableName varchar(20),

	@ECTCodeVersion_Year int,
	@ECTCodeStatus varchar(1)
)
RETURNS TABLE
AS

RETURN
(

	/************************************************************ INPUT PARAMETERS *************************************************************

	 @TableName = Name of ECT Table for which HEDIS-associated NDC Drug data is to be retrieved.  Examples:  'CDC-A', etc.

	 @ECTCodeVersion_Year = Code Version Year for which valid HEDIS-associated NDC Drug codes and related data is to be retrieved.

	 @ECTCodeStatus = Status of ECT Table for which HEDIS-associated NDC Drug Codes and related data is to be retrieved.
					  Examples:  'A' (for 'Active') or 'I' (for 'Inactive').

	 *********************************************************************************************************************************************/


	SELECT hed_drug.[HEDIS_DrugCodeID], hed_drug.[NDCCode] AS 'DrugCode', hed_drug.[BrandName] AS 'DrugName',
		   hed_drug.[GenericProductName], ect_tbl.[ECTHedisTableName], ect_tbl.[ECTHedisTableLetter], hed_drug.[Route],
		   hed_drug.[CategoryName], hed_drug.[Drug_ID]

	FROM [dbo].[CodeSetHEDIS_DrugCode] hed_drug

	INNER JOIN [dbo].[CodeSetECTHedisTable] ect_tbl ON (ect_tbl.[ECTHedisTableID] = hed_drug.[ECTHedisTableID]) AND
													   (ect_tbl.[ECTHedisTableName] = @TableName) AND
													   (ect_tbl.[StatusCode] = @ECTCodeStatus)

	WHERE hed_drug.[VersionYear] = @ECTCodeVersion_Year
);
