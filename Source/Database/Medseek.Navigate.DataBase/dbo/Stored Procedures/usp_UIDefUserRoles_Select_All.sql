/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_UIDefUserRoles_Select_All]      
Description   : This procedure is used to get the list of all portals, roles and pages the       
                access    
Created By    : Pramod      
Created Date  : 17-Feb-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UIDefUserRoles_Select_All]    
( @i_AppUserId INT )    
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
      SELECT    
          UIDef.PortalId ,    
          Portals.PortalName,    
          UIDef.MenuItemName ,    
          UIDef.PageURL ,    
          UIDef.PageObject ,    
          UIDef.PageDescription ,    
          UIDef.isDataAdminPage ,    
          UIDefUserRoles.UIDefUserRoleId ,    
          UIDefUserRoles.UIDefId ,    
          UIDefUserRoles.SecurityRoleId ,    
          SecurityRole.RoleName,    
          UIDefUserRoles.ReadYN ,    
          UIDefUserRoles.UpdateYN ,    
          UIDefUserRoles.InsertYN ,    
          UIDefUserRoles.DeleteYN ,
          UIDefUserRoles.LastModifiedDate   
      FROM Portals  with (nolock)    
    INNER JOIN UIDef  with (nolock)    
      ON Portals.PortalId = UIDef.PortalId    
          INNER JOIN UIDefUserRoles  with (nolock)    
            ON UIDef.UIDefId = UIDefUserRoles.UIDefId          
          INNER JOIN SecurityRole  with (nolock)    
            ON SecurityRole.SecurityRoleId = UIDefUserRoles.SecurityRoleId AND    
            SecurityRole.Status='A'  
    
END TRY      
--------------------------------------------------------       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH    
  
select * from SecurityRole
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UIDefUserRoles_Select_All] TO [FE_rohit.r-ext]
    AS [dbo];

