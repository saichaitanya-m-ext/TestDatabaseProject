/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UsersSecurityRoles_Insert]    
Description   : This procedure is used for inserting into UsersSecurityRoles table
Created By    : Pramod 
Created Date  : 18-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UsersSecurityRoles_Insert]
(
 @i_AppUserId INT ,
 --@i_UserId KEYID ,
 @i_ProviderID KEYID,
 @i_SecurityRoleId KEYID )
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @i_numberOfRecordsInserted INT
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
         DELETE FROM UsersSecurityRoles
	     WHERE ProviderID  = @i_ProviderID 
         
        INSERT INTO
          UsersSecurityRoles
          (
            SecurityRoleId ,
            ProviderID,
            CreatedByUserId )
          SELECT
              @i_SecurityRoleId ,
              @i_ProviderID ,
              @i_AppUserId
         

      SET @i_numberOfRecordsInserted = @@ROWCOUNT

      IF @i_numberOfRecordsInserted <= 0
         RAISERROR ( N'Insert into UsersSecurityRoles table experienced invalid row count of %d' ,
         17 ,
         1 ,
         @i_numberOfRecordsInserted )
       
      RETURN 0
      
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
    ON OBJECT::[dbo].[usp_UsersSecurityRoles_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

