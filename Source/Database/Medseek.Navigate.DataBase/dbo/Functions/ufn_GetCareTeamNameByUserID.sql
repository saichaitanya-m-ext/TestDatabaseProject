/*                  
------------------------------------------------------------------------------                  
Function Name: ufn_GetCareTeamNameByUserID             
Description   : This Function is used for get the careteam name for particular Patient               
Created By    : Rathnam  
Created Date  : 29-06-2011  
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
------------------------------------------------------------------------------                  
*/    
    
CREATE FUNCTION [dbo].[ufn_GetCareTeamNameByUserID]  
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
     CareTeam c  
    INNER JOIN PatientCareteam p   
        ON c.CareTeamID = p.CareTeamID  
    WHERE PatientID = @i_PatientID   
   
 RETURN ISNULL(@v_CareTeamName,'')  
END  
   
  