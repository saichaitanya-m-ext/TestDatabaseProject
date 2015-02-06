/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_ProgramName]      
Description   : This Function Returns Program for patient  
Created By    : Gurumoorthy V
Created Date  : 25-Jan-2013
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_ProgramName]
(
  @i_ProgramId KeyId
)
RETURNS  VARCHAR(200)
AS
BEGIN
	DECLARE @v_ProgramName VARCHAR(200)
	
		SELECT @v_ProgramName = ProgramName
		FROM program
		WHERE ProgramId = @i_ProgramId
		
	RETURN @v_ProgramName
END	


