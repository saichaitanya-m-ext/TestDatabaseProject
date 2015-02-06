
/*                
------------------------------------------------------------------------------                
Function Name: [ufn_GetVersionNumber]           
Description   : This Function returns the next generated sequence version number 
Created By    : Rathnam
Created Date  : 30-Aug-2012
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
------------------------------------------------------------------------------                
*/  
  
CREATE FUNCTION [dbo].[ufn_GetVersionNumber]
(
	@v_PreviousVerison varchar(5)
)	
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @v_CurrentVerison VARCHAR(100)


SELECT @v_CurrentVerison = 
    CASE
         WHEN substring(@v_PreviousVerison,charindex('.',@v_PreviousVerison)+1,1) = 9 THEN CONVERT(DECIMAL(10,1) , CONVERT(VARCHAR , substring(@v_PreviousVerison , 1 , CHARINDEX('.' , @v_PreviousVerison , 1) - 1) + 1) + '.0')
         ELSE CONVERT(DECIMAL(10,1) , @v_PreviousVerison) + 0.1
    END

	
	RETURN ISNULL(@v_CurrentVerison,'')
END


