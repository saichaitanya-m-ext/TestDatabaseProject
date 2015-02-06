/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UsersSecurityRoles_Select_ByUserId]    
Description   : This procedure is used for getting the list of roles for user
Created By    : Pramod 
Created Date  : 18-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
17-Aug-2010 NagaBabu Added order by clause    
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UsersSecurityRoles_Select_ByUserId]
(
 @i_AppUserId INT
,@i_UserId KEYID
,@i_IsPatient BIT
	 --@i_PortalId KEYID

)
AS
BEGIN TRY
      SET NOCOUNT ON

 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
      IF @i_IsPatient = 1
         BEGIN
               SELECT DISTINCT
                   UsersSecurityRoles.SecurityRoleId
                  ,SecurityRole.RoleName
                  ,SecurityRole.RoleDescription
               FROM
                   UsersSecurityRoles WITH ( NOLOCK )
               INNER JOIN SecurityRole WITH ( NOLOCK )
                   ON UsersSecurityRoles.SecurityRoleId = SecurityRole.SecurityRoleId
               WHERE
                   UsersSecurityRoles.PatientID = @i_UserId
	  -- AND SecurityRole.PortalId = @i_PortalId
               ORDER BY
                   SecurityRole.RoleName
         END
      ELSE
         BEGIN
               SELECT DISTINCT
                   UsersSecurityRoles.SecurityRoleId
                  ,SecurityRole.RoleName
                  ,SecurityRole.RoleDescription
               FROM
                   UsersSecurityRoles WITH ( NOLOCK )
               INNER JOIN SecurityRole WITH ( NOLOCK )
                   ON UsersSecurityRoles.SecurityRoleId = SecurityRole.SecurityRoleId
               WHERE
                   UsersSecurityRoles.ProviderID = @i_UserId

         END
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
    ON OBJECT::[dbo].[usp_UsersSecurityRoles_Select_ByUserId] TO [FE_rohit.r-ext]
    AS [dbo];

