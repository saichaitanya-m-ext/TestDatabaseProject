/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UsersSecurityRoles_Delete]    
Description   : This procedure is used for deleting from UsersSecurityRoles table
Created By    : Pramod 
Created Date  : 18-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
27-Sep-2010 NagaBabu Modified @i_numberOfRecordsDeleted <= 0 by < 1       
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UsersSecurityRoles_Delete]
(
	 @i_AppUserId INT ,
	 @i_ProviderID KEYID ,
	 @i_SecurityRoleId KEYID
 )
AS
--declare	 @t_SecurityRoleId TABLE ( SecurityRoleId KEYID )
BEGIN TRY
    SET NOCOUNT ON
	DECLARE @i_numberOfRecordsDeleted INT
 -- Check if valid Application User ID is passed  
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
    BEGIN
           RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
    END  

	DELETE FROM UsersSecurityRoles
	 WHERE ProviderID = @i_ProviderID 
	   AND SecurityRoleId = @i_SecurityRoleId

    SET @i_numberOfRecordsDeleted = @@ROWCOUNT

    IF @i_numberOfRecordsDeleted < 1
         RAISERROR ( N'Delete from  UsersSecurityRoles table experienced invalid row count of %d' ,
         17 ,
         1 ,
         @i_numberOfRecordsDeleted )
    
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
    ON OBJECT::[dbo].[usp_UsersSecurityRoles_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

