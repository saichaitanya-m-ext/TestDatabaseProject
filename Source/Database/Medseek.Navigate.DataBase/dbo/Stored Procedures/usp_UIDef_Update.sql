/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UIDef_Update]    
Description   : This procedure is used for updating the Menu Item Name, URL etc
Created By    : Pramod 
Created Date  : 18-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UIDef_Update]
(
	 @i_AppUserId INT ,
	 @i_UIDefId KEYID,
	 @i_PortalId KEYID,
	 @v_PageURL LONGDESCRIPTION,
	 @v_PageObject LONGDESCRIPTION,
	 @v_PageDescription LONGDESCRIPTION,
	 @v_MenuItemName SHORTDESCRIPTION,
	 @b_isDataAdminPage ISINDICATOR
 )
AS
BEGIN TRY
    SET NOCOUNT ON
    DECLARE @i_numberOfRecordsChanged INT  
 -- Check if valid Application User ID is passed  
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
    BEGIN
           RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
    END  

	IF @i_UIDefId IS NULL
	   BEGIN
			INSERT
			  UIDef
			  (
				PortalId,
				PageURL,
				PageObject,
				PageDescription,
				MenuItemName,
				isDataAdminPage,
				CreatedByUserId
			   )
			VALUES
			  (
				@i_PortalId,
				@v_PageURL,
				@v_PageObject,
				@v_PageDescription,
				@v_MenuItemName,
				@b_isDataAdminPage,
				@i_AppUserId
			  )
			  SET @i_numberOfRecordsChanged = @@ROWCOUNT
        END
	ELSE
	    BEGIN
		    UPDATE UIDef
		       SET PortalId = @i_PortalId,
				   PageURL = @v_PageURL,
				   PageObject = @v_PageObject,
				   PageDescription = @v_PageDescription,
				   MenuItemName = @v_MenuItemName,
				   isDataAdminPage = @b_isDataAdminPage,
				   LastModifiedByUserId = @i_AppUserId,
				   LastModifiedDate = GETDATE()
			 WHERE UIDefId = @i_UIDefId
		 
		   SET @i_numberOfRecordsChanged = @@ROWCOUNT
        END

    IF @i_numberOfRecordsChanged <= 0
         RAISERROR ( N'Update of UIDef table experienced invalid row count of %d' ,
         17 ,
         1 ,
         @i_numberOfRecordsChanged )

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
    ON OBJECT::[dbo].[usp_UIDef_Update] TO [FE_rohit.r-ext]
    AS [dbo];

