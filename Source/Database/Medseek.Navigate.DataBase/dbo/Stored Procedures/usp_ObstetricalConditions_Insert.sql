
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ObstetricalConditions_Insert    
Description   : This procedure is used to insert record into ObstetricalConditions table
Created By    : Udaykumar    
Created Date  : 6-July-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ObstetricalConditions_Insert]  
(  
	@i_AppUserId INT,  
	@v_ObstetricalName SourceName, 
	@v_Comments LongDescription,
	@v_StatusCode StatusCode,
	@o_ObstetricalConditionsID KeyID OUTPUT
)  
AS    
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  

	INSERT INTO ObstetricalConditions
	   ( ObstetricalName
	    ,Comments
	    ,CreatedByUserId
	    ,StatusCode
	   )
	VALUES
	   ( @v_ObstetricalName
	    ,@v_Comments
	    ,@i_AppUserId
	    ,@v_StatusCode
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_ObstetricalConditionsID = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Insert ObstetricalConditions'
				,17      
				,1      
				,@l_numberOfRecordsInserted                 
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
    ON OBJECT::[dbo].[usp_ObstetricalConditions_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

