/*    
-------------------------------------------------------------------------------------    
Procedure Name: usp_QuestionaireType_Insert    
Description   : This procedure is used to insert record into QuestionaireType table.
Created By    : Aditya    
Created Date  : 05-Mar-2010    
-------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
-------------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_QuestionaireType_Insert]  
(  
	@i_AppUserId  KeyID,  
	@vc_QuestionaireTypeName ShortDescription,
    @vc_Description LongDescription,
	@vc_StatusCode StatusCode,
	@o_QuestionaireTypeId KeyID OUTPUT
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

	INSERT INTO QuestionaireType
	   ( 
			QuestionaireTypeName,
			Description,
			StatusCode,
			CreatedByUserId
			
	   )
	VALUES
	   ( 
	     @vc_QuestionaireTypeName,
	     @vc_Description,
	     @vc_StatusCode,
	     @i_AppUserId
	     
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_QuestionaireTypeId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert Questionaire Type'
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
    ON OBJECT::[dbo].[usp_QuestionaireType_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

