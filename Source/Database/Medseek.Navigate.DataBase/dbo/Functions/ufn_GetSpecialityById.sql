
/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_GetSpecialityById]             
Description   : This Function is used to get the SpecialityName based on Id  
Created By    : Kalyan             
Created Date  : 22-June-2012                 
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
------------------------------------------------------------------------------                  
*/
CREATE FUNCTION [dbo].[ufn_GetSpecialityById] (@i_SpecialityId KeyId)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE @v_SpecialityName VARCHAR(200)

	SELECT @v_SpecialityName = ProviderSpecialtyName
	FROM CodeSetCMSProviderSpecialty
	WHERE CMSProviderSpecialtyCodeID = @i_SpecialityId

	RETURN @v_SpecialityName
END
