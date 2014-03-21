/*                
------------------------------------------------------------------------------                
Function Name: [ufn_GetProviderTypeIdByCode]
Description   : This Function is used to get ProviderId for a particular ProviderCode.
Created By    : Sivakrishna
Created Date  : 01-Dec-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetProviderTypeIdByCode]
     (
        @v_ProviderTypeCode  CHAR(1)
     )
RETURNS INT
AS
BEGIN
      DECLARE @i_TypeId VARCHAR(50)
      SELECT @i_TypeId = ProviderTypeId 
            FROM ProviderType 
	  WHERE
	      ProviderTypeCode = @v_ProviderTypeCode
      RETURN @i_TypeId
END
