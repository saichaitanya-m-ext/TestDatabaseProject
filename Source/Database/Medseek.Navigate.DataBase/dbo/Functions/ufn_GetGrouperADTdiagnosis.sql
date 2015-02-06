
CREATE FUNCTION [dbo].[ufn_GetGrouperADTdiagnosis]
(
	@vc_CodeGroupers VARCHAR(200)
)
RETURNS TABLE
AS

RETURN
(
	SELECT DISTINCT
		CodeGroupingCodeID 
	FROM CodeGroupingDetailInternal CGDI
	INNER JOIN LkUpCodeType	LCT
		ON CGDI.CodeGroupingCodeTypeID = LCT.CodeTypeID
	INNER JOIN (SELECT KeyValue
				FROM [dbo].[udf_SplitStringToTable](@vc_CodeGroupers,','))DT
		ON CGDI.CodeGroupingID = DT.KeyValue
	WHERE LCT.CodeTypeCode IN('ICD-9-CM-Diag','ICD-10-CM-Diag')				
);

