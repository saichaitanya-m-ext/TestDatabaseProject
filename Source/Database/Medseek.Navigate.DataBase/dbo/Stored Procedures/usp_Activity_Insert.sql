/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Activity_Insert    
Description   : This procedure is used to insert record into Activity table
Created By    : Aditya    
Created Date  : 15-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
15-Feb-2011 Rathnam Changed the Length of @vc_Description parameter 
23-Feb-2011 Rathnam changed the length of @vc_Description parameter from 500 to 1500   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Activity_Insert]  
(  
	@i_AppUserId KeyID,
	@vc_Name ShortDescription,
	@vc_Description VARCHAR(1500),
	@i_ParentActivityId KeyID, 
	@vc_StatusCode StatusCode,
	@o_ActivityId KeyID OUTPUT
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
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

	INSERT INTO Activity
		( 
			Name,
			Description,
			ParentActivityId,
			CreatedByUserId,
			StatusCode
	   )
	VALUES
	   ( 
			@vc_Name,
			@vc_Description, 
			@i_ParentActivityId,
			@i_AppUserId,
			@vc_StatusCode
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_ActivityId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert Activity Type'
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Activity_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

