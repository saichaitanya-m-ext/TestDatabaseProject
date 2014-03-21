/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[[ufn_OrganizationName]]             
Description   : This Function Returns PCPName for patient  
Created By    : NagaBabu              
Created Date  : 24-oct-2011                 
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
29-Aug-2011 NagaBabu Modified the functonality while PCPId field was added to the users table
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_OrganizationName]
(
  @i_OrganizationId KeyId
)
RETURNS  VARCHAR(200)
AS
BEGIN
	DECLARE @v_OrganizationName VARCHAR(200)
			
    SELECT 	@v_OrganizationName = description  
			FROM CodesetProviderType WHERE ProviderTypeCodeID = @i_OrganizationId
 
	
	RETURN @v_OrganizationName

END	
