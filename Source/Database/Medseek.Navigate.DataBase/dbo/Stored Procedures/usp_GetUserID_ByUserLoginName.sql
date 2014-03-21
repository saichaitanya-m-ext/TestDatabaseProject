﻿/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_GetUserID_ByUserLoginName]            
Description   : 
Created By    : Rathnam            
Created Date  : 19-Sep-2011            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------            
*/

CREATE PROCEDURE [dbo].[usp_GetUserID_ByUserLoginName]
(  
  @i_AppUserId KeyID ,  
  @v_UserLoginName VARCHAR(50)
)  
AS  
BEGIN TRY       
   SET NOCOUNT ON   
-- Check if valid Application User ID is passed      
  IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
    BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
    END
	
	SELECT UserID 
	FROM
	Users 
	WHERE UserLoginName = @v_UserLoginName
			
END TRY  
-------------------------------------------------------------------------------------------------------------------------   
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID   
END CATCH  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_GetUserID_ByUserLoginName] TO [FE_rohit.r-ext]
    AS [dbo];

