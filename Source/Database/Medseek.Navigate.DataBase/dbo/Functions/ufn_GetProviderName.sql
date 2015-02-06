
/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_GetProviderName]             
Description   : This Function Returns PCPName for patient  
Created By    : Rathnam              
Created Date  : 18-April-2013                
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
------------------------------------------------------------------------------                  
*/
CREATE FUNCTION [dbo].[ufn_GetProviderName] (@i_ProviderID KeyId)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE @v_UserName VARCHAR(200)

	SELECT @v_UserName = CASE 
			WHEN DESCRIPTION IN ('Clinic','Insurance')
				THEN OrganizationName
			ELSE COALESCE(ISNULL(LastName, '') + ' ' + ISNULL(FirstName, '') + ' ' + ISNULL(MiddleName, ''), '')
			END
	FROM Provider WITH (NOLOCK)
	LEFT JOIN CodeSetProviderType WITH (NOLOCK)
		ON CodeSetProviderType.ProviderTypeCodeID = Provider.ProviderTypeID
	WHERE ProviderID = @i_ProviderID

	RETURN ISNULL(@v_UserName, '')
END
