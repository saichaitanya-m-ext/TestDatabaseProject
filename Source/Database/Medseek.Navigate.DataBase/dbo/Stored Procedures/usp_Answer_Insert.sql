/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Answer_Insert    
Description   : This procedure is used to insert record into Answer table
Created By    : Pramod
Created Date  : 25-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY  DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Answer_Insert]  
(  
	@i_AppUserId KeyID,
	@i_QuestionId KeyID,
	@v_AnswerDescription ShortDescription,
	@i_Score INT,
	@v_AnswerString VARCHAR(50),
	@i_SortOrder STID,
	@vc_StatusCode StatusCode,
	@vc_AnswerLabel varchar(50),
	@o_AnswerId KeyID OUTPUT
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

	INSERT INTO Answer
		( 
			QuestionId,
			AnswerDescription,
			Score,
			AnswerString,
			SortOrder,
			CreatedByUserId,
			StatusCode,
			AnswerLabel
			
	   )
	VALUES
	   ( 
			@i_QuestionId,
			@v_AnswerDescription,
			@i_Score,
			@v_AnswerString,
			@i_SortOrder,
			@i_AppUserId,
			@vc_StatusCode,
			@vc_AnswerLabel
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_AnswerId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert Answer'
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
    ON OBJECT::[dbo].[usp_Answer_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

