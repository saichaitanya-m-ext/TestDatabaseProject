/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_GetPhoneNumberFormat]             
Description   : This Function Returns PhoneNumber Format  
Created By    : Rathnam              
Created Date  : 22-June-2012                 
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_GetPhoneNumberFormat]
(
  @v_PhoneNumber VARCHAR(20)
)
RETURNS  VARCHAR(20)
AS
BEGIN

DECLARE @v_ReturnPhoneNumber varchar(20)
	SELECT @v_ReturnPhoneNumber = CASE WHEN len(ltrim(rtrim(@v_PhoneNumber)))='10' THEN 
			'('+SUBSTRING(@v_PhoneNumber,1,3)+')'+' '+ SUBSTRING(@v_PhoneNumber,4,3)+'-'+SUBSTRING(@v_PhoneNumber,7,4) 
		else 	@v_PhoneNumber
		end
	RETURN @v_ReturnPhoneNumber
END	
