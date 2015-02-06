/*                
------------------------------------------------------------------------------                
Function Name: [[ufn_GetServiceTypeIdByCode]]
Description   : This Function is used to get ServiceTypeId for a particular ServiceCode.
Created By    : Sivakrishna
Created Date  : 01-Dec-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetServiceTypeIdByCode]
     (
        @v_ServiceTypeCode  VARCHAR(2)
     )
RETURNS INT
AS
BEGIN
      DECLARE @i_TypeId VARCHAR(50)
      SELECT @i_TypeId = ServiceTypeId 
            FROM ServiceType 
	  WHERE
	      ServiceTypeCode = @v_ServiceTypeCode
      RETURN @i_TypeId
END
