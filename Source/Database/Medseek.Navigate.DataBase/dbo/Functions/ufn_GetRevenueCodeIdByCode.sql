/*                
------------------------------------------------------------------------------                
Function Name: [[ufn_GetRevenueCodeIdByCode]]
Description   : This Function is used to get RevenueCodeId for a particular RevenueCode.
Created By    : Sivakrishna
Created Date  : 01-Dec-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetRevenueCodeIdByCode]
     (
        @v_RevenueCode  VARCHAR(2)
     )
RETURNS INT
AS
BEGIN
      DECLARE @i_RevenueCodeId VARCHAR(50)
      SELECT @i_RevenueCodeId = RevenueCodeId 
            FROM RevenueCode 
	  WHERE
	      RevenueCode = @v_RevenueCode
      RETURN @i_RevenueCodeId
END
