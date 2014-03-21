
CREATE FUNCTION [dbo].[ufn_ProcedureTypeCodeId]
(
	@vc_CPTCode VARCHAR(10)
)
RETURNS INT
AS

BEGIN
	
	DECLARE @vc_CodeType VARCHAR(20) ,
			@vc_CodeTypeId INT
	SELECT @vc_CodeType = CASE WHEN ISNUMERIC(SUBSTRING(@vc_CPTCode,1,5)) = 1 THEN 'CPT'
								 WHEN ISNUMERIC(SUBSTRING(@vc_CPTCode,1,1)) = 0 AND ISNUMERIC(SUBSTRING(@vc_CPTCode,2,4)) = 1 THEN 'HCPCS'
								 WHEN ISNUMERIC(SUBSTRING(@vc_CPTCode,1,4)) = 1 AND ISNUMERIC(SUBSTRING(@vc_CPTCode,5,1)) = 0 THEN 'CPT-CAT-II'
								 ELSE 'HIPPS'
							END	 
	SELECT @vc_CodeTypeId = CodeTypeId FROM LkUpCodeType WHERE CodeTypeCode = @vc_CodeType
	
   RETURN @vc_CodeTypeId

END


