/*                    
------------------------------------------------------------------------------                    
Function Name: [ufn_GetUserNameByID]    
Description   : This Function is used to get UserName for a particular User.    
Created By    : Rathnam    
Created Date  : 01-Dec-2010    
------------------------------------------------------------------------------    
Log History :    
DD-MM-YYYY     BY      DESCRIPTION    
------------------------------------------------------------------------------                    
*/ --select dbo.[ufn_GetUserNameByID] (8588944)    
    
CREATE FUNCTION [dbo].[ufn_GetUserNameByID]    
     (    
        @i_UserId KEYID    
     )    
RETURNS VARCHAR(150)    
AS    
BEGIN    
      DECLARE @v_UserName VARCHAR(150)    
      SELECT @v_UserName =     
   COALESCE(ISNULL(provider.LastName+',  '  , '') +       
    + ISNULL(provider.FirstName , '') + ' '       
    + ISNULL(provider.MiddleName , ''),'')      
   FROM     
    provider    
   WHERE    
       provider.ProviderID = @i_UserId    
      RETURN @v_UserName    
END
