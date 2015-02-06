
CREATE FUNCTION [dbo].[ufn_GetGrouperADTProcedures]
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
	WHERE LCT.CodeTypeCode IN('CPT','HCPCS','ICD-9-CM-Proc','ICD-10-CM-Proc','CPT-CAT-II','CPT-CAT-III')				
);

