/*    
----------------------------------------------------------------------------------    
Procedure Name: [usp_Users_Search]    
Description   : This procedure is used to get UsersId,UserLoginName from Users    
Created By    : NagaBabu    
Created Date  : 11-Aug-2010    
----------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
----------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[usp_Users_Select] 
(
  @i_AppUserId KEYID    
)       
AS    
BEGIN TRY    
      SET NOCOUNT ON    
      ----- Check if valid Application User ID is passed--------------    
      IF ( @i_AppUserId IS NULL )    
      OR ( @i_AppUserId <= 0 )    
         BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed.' ,    
               17 ,    
               1 ,    
               @i_AppUserId )    
         END    
   --------- search user from the search criteria ----------------    
      SELECT    
		  UserId ,    
		  UserLoginName    
	  FROM 
	      Users   
          
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID     
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Users_Select] TO [FE_rohit.r-ext]
    AS [dbo];

