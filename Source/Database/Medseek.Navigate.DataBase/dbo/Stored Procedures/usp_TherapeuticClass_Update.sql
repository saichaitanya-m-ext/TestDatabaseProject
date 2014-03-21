/*    
------------------------------------------------------------------------------    
Procedure Name: usp_TherapeuticClass_Update  
Description   : This procedure is used to Update record into TherapeuticClass table
Created By    : Aditya    
Created Date  : 08-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_TherapeuticClass_Update]  
(  
	@i_AppUserId KeyID,
	@i_TherapeuticID KeyID,
	@vc_Name ShortDescription, 
	@vc_Description LongDescription,
	@vc_StatusCode StatusCode,
	@i_sortorder STID
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

	 UPDATE TherapeuticClass
	    SET	Name = @vc_Name,
	        Description = @vc_Description,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode,
			sortorder = @i_sortorder
			
	  WHERE TherapeuticID = @i_TherapeuticID

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update TherapeuticClass Details'  
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TherapeuticClass_Update] TO [FE_rohit.r-ext]
    AS [dbo];

