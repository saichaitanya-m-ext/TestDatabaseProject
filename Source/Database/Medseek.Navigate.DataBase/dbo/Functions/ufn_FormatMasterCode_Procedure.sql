CREATE FUNCTION [dbo].[ufn_FormatMasterCode_Procedure]
(
	@vc_CPTCode VARCHAR(10)
)
RETURNS varchar(5)
AS

BEGIN
	
	DECLARE @vc_CodeType VARCHAR(5) 
	SELECT @vc_CodeType = CASE WHEN ISNUMERIC(SUBSTRING(@vc_CPTCode,1,5)) = 1 AND LEN(@vc_CPTCode) = 5 THEN @vc_CPTCode
								 WHEN ISNUMERIC(SUBSTRING(@vc_CPTCode,1,1)) = 0 AND ISNUMERIC(SUBSTRING(@vc_CPTCode,2,4)) = 1 AND LEN(@vc_CPTCode) = 5 THEN @vc_CPTCode
								 WHEN ISNUMERIC(SUBSTRING(@vc_CPTCode,1,4)) = 1 AND ISNUMERIC(SUBSTRING(@vc_CPTCode,5,1)) = 0 AND LEN(@vc_CPTCode) = 5 THEN @vc_CPTCode
								 ELSE NULL
							END	 
	
   RETURN @vc_CodeType

END

