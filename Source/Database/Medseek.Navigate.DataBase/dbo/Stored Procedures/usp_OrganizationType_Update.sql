/*    
------------------------------------------------------------------------------    
Procedure Name: usp_OrganizationType_Update    
Description   : This procedure is used to update record in OrganizationType table
Created By    : Pramod    
Created Date  : 24-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_OrganizationType_Update]  
(  
	@i_AppUserId INT,
	@i_OrganizationTypeId KeyID,
	@v_OrganizationType VARCHAR(50), 
	@v_Description ShortDescription,
	@v_StatusCode StatusCode
)  
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  

	 UPDATE OrganizationType
	    SET	OrganizationType = @v_OrganizationType,
	        Description = @v_Description,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @v_StatusCode
	  WHERE OrganizationTypeID = @i_OrganizationTypeId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update Organization Type Details'  
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
    ON OBJECT::[dbo].[usp_OrganizationType_Update] TO [FE_rohit.r-ext]
    AS [dbo];

