

/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ObstetricalConditions_Update    
Description   : This procedure is used to update record in ObstetricalConditions table
Created By    : Udaykumar    
Created Date  : 6-July-2011   
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ObstetricalConditions_Update]  
(  
	@i_AppUserId INT,
	@i_ObstetricalConditionsID KeyID,
	@v_ObstetricalName SourceName, 
	@v_Comments ShortDescription,
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

	 UPDATE ObstetricalConditions
	    SET	ObstetricalName = @v_ObstetricalName,
	        Comments = @v_Comments,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @v_StatusCode
	  WHERE ObstetricalConditionsID = @i_ObstetricalConditionsID

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update ObstetricalConditions Type Details'  
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
    ON OBJECT::[dbo].[usp_ObstetricalConditions_Update] TO [FE_rohit.r-ext]
    AS [dbo];

