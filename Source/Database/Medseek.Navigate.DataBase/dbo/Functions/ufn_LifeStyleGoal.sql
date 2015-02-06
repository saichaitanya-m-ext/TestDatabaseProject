/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_LifeStyleGoal]        
Description   : This Function Returns LifeStyleGoals for patient  
Created By    : Gurumoorthy V
Created Date  : 25-Jan-2013
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_LifeStyleGoal]
(
  @i_LifeStyleGoalId KeyId
)
RETURNS  VARCHAR(200)
AS
BEGIN
	DECLARE @v_LifeStyleGoal VARCHAR(200),
			@i_PCPId KeyId
	
		SELECT @v_LifeStyleGoal = LifeStyleGoal
		FROM LifeStyleGoals
		WHERE LifeStyleGoalId = @i_LifeStyleGoalId 
		
	RETURN @v_LifeStyleGoal
END	

