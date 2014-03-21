/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UIDef_Select_DD]  64,1  
Description   : This procedure is used to get the list of ObjectNames and   
    Page Descriptions.  
Created By    : Balla Kalyan  
Created Date  : 16-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
12-Aug-2010	NagaBabu Added ORDER BY clause to the select statement    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UIDef_Select_DD]
(  
 @i_AppUserId INT ,  
 @i_PortalId KEYID )  
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
--------------------------------------------------------   
      SELECT  
          UIDefId ,  
          PortalId ,  
          PageURL ,  
          PageObject ,
          CASE WHEN PageURL IS NOT NULL THEN
					PageDescription + ' ( Page )'
			   ELSE 
					PageDescription + ' ( Menu )'
		  END PageDescription, 
          MenuItemName ,  
          isDataAdminPage  
      FROM  
          UIDef  
      WHERE  
          PortalId = @i_PortalId 
      ORDER BY MenuItemName     
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UIDef_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

