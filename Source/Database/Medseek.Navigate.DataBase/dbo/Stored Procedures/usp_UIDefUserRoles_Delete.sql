/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UIDefUserRoles_Delete]    
Description   : This procedure is used for deleting the privileges
Created By    : Pramod 
Created Date  : 18-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UIDefUserRoles_Delete]
(
	 @i_AppUserId INT ,
	 @i_UIDefUserRoleId KEYID
 )
AS
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

	DELETE UIDefUserRoles
	 WHERE UIDefUserRoleId = @i_UIDefUserRoleId
		 
     SET @i_numberOfRecordsDeleted = @@ROWCOUNT

     IF @i_numberOfRecordsDeleted <= 0
         RAISERROR ( N'Update of UIDefUserRoles table experienced invalid row count of %d' ,
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
    ON OBJECT::[dbo].[usp_UIDefUserRoles_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

