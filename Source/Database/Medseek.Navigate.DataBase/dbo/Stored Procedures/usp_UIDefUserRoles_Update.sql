/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UIDefUserRoles_Update]    
Description   : This procedure is used for updating the privileges
Created By    : Pramod 
Created Date  : 18-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
12-Aug-2010 NagaBabu Deleted Insert Statement for UIDefUserRoles table and respective Perameters	       
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UIDefUserRoles_Update]
(
	 @i_AppUserId INT ,
	 @i_ReadYN ISINDICATOR ,
	 @i_UpdateYN ISINDICATOR ,
	 @i_InsertYN ISINDICATOR ,
	 @i_DeleteYN ISINDICATOR ,
	 @i_SecurityRoleId KEYID,
	 @i_UIDefUserRoleId KEYID = NULL
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

		    UPDATE UIDefUserRoles
		       SET 
		           SecurityRoleId = @i_SecurityRoleId,
				   ReadYN = @i_ReadYN,
				   UpdateYN = @i_UpdateYN,
				   InsertYN = @i_InsertYN,
				   DeleteYN = @i_DeleteYN,
				   LastModifiedByUserId = @i_AppUserId,
				   LastModifiedDate = GETDATE()
			 WHERE UIDefUserRoleId = @i_UIDefUserRoleId
		 
		   SET @i_numberOfRecordsInserted = @@ROWCOUNT
        
    IF @i_numberOfRecordsInserted <= 0
         RAISERROR ( N'Update of UIDefUserRoles table experienced invalid row count of %d' ,
         17 ,
         1 ,
         @i_numberOfRecordsInserted )

    RETURN @i_numberOfRecordsInserted

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
    ON OBJECT::[dbo].[usp_UIDefUserRoles_Update] TO [FE_rohit.r-ext]
    AS [dbo];

