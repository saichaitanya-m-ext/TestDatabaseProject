CREATE FUNCTION [dbo].[ufn_HEDIS_GetECTCodeInfo_ByTableName2]
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

	 @TableName = Name of ECT Code Table whose HEDIS-associated ECT Codes are to be retrieved.  Examples:  'CDC-A', 'CDC-C', 'CBP-A',
				  'LBP-D', etc.

	 @ECTCodeVersion_Year = Code Version Year for which valid HEDIS-associated ECT Codes data are to be retrieved.

	 @ECTCodeStatus = Status of ECT Table for which HEDIS-associated ECT Codes are to be retrieved.  Examples:  'A' (for 'Active') or
					  'I' (for 'Inactive').

	 *********************************************************************************************************************************************/


	SELECT ect.[HEDIS_ECTCodeID], ect.[ECTCode], ect.[ECTCodeDescription], ect_d.[ECTHedisDomainCode],
		   ect_m.[ECTHedisMeasureCode], ect_sd.[ECTHedisSubDomainCode], ect_c.[ECTHedisClassCode],
		   ect_tbl.[ECTHedisTableName], ect_tbl.[ECTHedisTableLetter], ect_typ.[ECTHedisCodeTypeCode],
		   ect.[IsBillingValid], ect.[VersionYear]

	FROM [dbo].[CodeSetHEDIS_ECTCode] ect

	INNER JOIN [dbo].[CodeSetECTHedisTable] ect_tbl ON (ect_tbl.[ECTHedisTableID] = ect.[ECTHedisTableID]) AND
													   (ect_tbl.[ECTHedisTableName] = @TableName) AND
													   (ect_tbl.[StatusCode] = @ECTCodeStatus)

	LEFT OUTER JOIN [dbo].[CodeSetECTHedisDomain] ect_d ON ect_d.[ECTHedisDomainID] = ect.[ECTHedisDomainID]
	
	LEFT OUTER JOIN [dbo].[CodeSetECTHedisMeasure] ect_m ON ect_m.[ECTHedisMeasureID] = ect.[ECTHedisMeasureID]

	LEFT OUTER JOIN [dbo].[CodeSetECTHedisSubDomain] ect_sd ON ect_sd.[ECTHedisSubDomainID] = ect.[ECTHedisSubDomainID]

	LEFT OUTER JOIN [dbo].[CodeSetECTHedisClassification] ect_c ON ect_c.[ECTHedisClassID] = ect.[ECTHedisClassID]

	LEFT OUTER JOIN [CodeSetECTHedisCodeType] ect_typ ON ect_typ.[ECTHedisCodeTypeID] = ect.[ECTHedisCodeTypeID]

	WHERE ect.[VersionYear] = @ECTCodeVersion_Year
);
