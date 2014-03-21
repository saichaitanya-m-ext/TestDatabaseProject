/*                  
------------------------------------------------------------------------------                  
Function Name : [dbo].[ufn_GetPCPName]             
Description   : This Function Returns PCPName for patient  
Created By    : NagaBabu              
Created Date  : 14-June-2011                 
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY     BY      DESCRIPTION                  
29-Aug-2011 NagaBabu Modified the functonality while PCPId field was added to the users table
------------------------------------------------------------------------------                  
*/      
CREATE FUNCTION [dbo].[ufn_GetPCPName]
(
  @i_PatientUserId KeyId
)
RETURNS  VARCHAR(200)
AS
BEGIN
	DECLARE @v_UserName VARCHAR(200),
			@i_PCPId KeyId
	

	
	SELECT TOP 1 @i_PCPId = ProviderID FROM PatientPCP pp WHERE pp.PatientId = @i_PatientUserId
	ORDER BY ISNULL(CareEndDate,CareBeginDate) DESC 
	
    
	IF (@i_PCPId IS NOT NULL OR @i_PCPId <> '')
	
		SELECT @v_UserName = COALESCE(ISNULL(LastName,'') + ' ' +
									  ISNULL(FirstName,'') + ' ' +
									  ISNULL(MiddleName,''),'')
		FROM Provider
		WHERE ProviderID = @i_PCPId 
	ELSE
		SET @v_UserName = ' '
		
	RETURN @v_UserName
END	
