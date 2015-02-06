
/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetCareTeamNameByID           
Description   : This Function is used for get the careteam name for a careteamID           
Created By    : Kalyan
Created Date  : 09-July-2012
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                
------------------------------------------------------------------------------                
*/  
  
CREATE FUNCTION [dbo].[ufn_GetCareTeamNameByID]
(
	@i_PatientID KeyID 
)	
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @v_CareTeamName VARCHAR(100)
	SELECT 
	    @v_CareTeamName = CareTeamName 
	FROM
	    CareTeam 
    WHERE CareTeamId = @i_PatientID	
	
	RETURN ISNULL(@v_CareTeamName,'')
END


