/*    
------------------------------------------------------------------------------    
Procedure Name: usp_OrganizationUser_Update
Description   : This procedure is used to update the details in OrganizationUser table
Created By    : Aditya
Created Date  : 08-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION

------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_OrganizationUser_Update]
(  
	@i_AppUserId KeyID,
	@i_OrganizationId KeyID,
	@i_UserId KeyID,
	@vc_StatusCode StatusCode,
	@i_isPrimary IsIndicator,
	@vc_Comments LongDescription,
	@i_OrganizationUserId KeyID 
)  
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
  
	DECLARE @l_numberOfRecordsUpdated INT

	UPDATE OrganizationUser
	   SET OrganizationId = @i_OrganizationId, 
	       isPrimary = @i_isPrimary,
		   Comments = @vc_Comments,
		   LastModifiedByUserId = @i_AppUserId,
		   LastModifiedDate = GETDATE(),
		   StatusCode = @vc_StatusCode
	 WHERE  ProviderUserId = @i_UserId
		AND OrganizationUserId = @i_OrganizationUserId

    SET @l_numberOfRecordsUpdated = @@ROWCOUNT

    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update OrganizationUser'
				,17      
				,1      
				,@l_numberOfRecordsUpdated
			)              
	END  

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
    ON OBJECT::[dbo].[usp_OrganizationUser_Update] TO [FE_rohit.r-ext]
    AS [dbo];

