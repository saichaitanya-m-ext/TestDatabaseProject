/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UIDef_UIDefUserRoles_Insert]    
Description   : This procedure is used for inserting roles and menu items and privileges
Created By    : Balla Kalyan  
Created Date  : 16-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
12-Aug-2010 NagaBabu Deleted Insert Statement for UIDef table and respective Perameters	    
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UIDef_UIDefUserRoles_Insert]
(
	 @i_AppUserId INT ,
	 @i_ReadYN ISINDICATOR ,
	 @i_UpdateYN ISINDICATOR ,
	 @i_InsertYN ISINDICATOR ,
	 @i_DeleteYN ISINDICATOR ,
	 @i_SecurityRoleId KEYID,
	 @i_UIDefId KEYID
 )
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
   
    INSERT
          UIDefUserRoles
          (
            UIDefId ,
            SecurityRoleId ,
            ReadYN ,
            UpdateYN ,
            InsertYN ,
            DeleteYN ,
            CreatedByUserId )
    VALUES
          (
            @i_UIDefId ,
            @i_SecurityRoleId ,
            @i_ReadYN ,
            @i_UpdateYN ,
            @i_InsertYN ,
            @i_DeleteYN ,
            @i_AppUserId
          )

    SET @i_numberOfRecordsInserted = @@ROWCOUNT

    IF @i_numberOfRecordsInserted <= 0
         RAISERROR ( N'Update of UIDefUserRoles table experienced invalid row count of %d' ,
         17 ,
         1 ,
         @i_numberOfRecordsInserted )
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
    ON OBJECT::[dbo].[usp_UIDef_UIDefUserRoles_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

