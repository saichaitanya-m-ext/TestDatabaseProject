/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Answer_Update
Description   : This procedure is used to update record into Answer table
Created By    : Pramod
Created Date  : 25-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Answer_Update]  
(  
	@i_AppUserId KeyID,
	@i_QuestionId KeyID,
	@i_AnswerId KeyID,
	@v_AnswerDescription ShortDescription,
	@i_Score INT,
	@v_AnswerString VARCHAR(50),
	@i_SortOrder STID,
	@vc_StatusCode StatusCode,
	@vc_AnswerLabel varchar(50)
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

	UPDATE Answer
	   SET AnswerDescription = @v_AnswerDescription,
		   Score = @i_Score,
		   AnswerString = @v_AnswerString,
		   SortOrder = @i_SortOrder,
		   StatusCode = @vc_StatusCode,
		   LastModifiedByUserId = @i_AppUserId,
		   LastModifiedDate = GETDATE(),
		   AnswerLabel = @vc_AnswerLabel
	 WHERE QuestionId = @i_QuestionId
	   AND AnswerId = @i_AnswerId
	   	
    SET @l_numberOfRecordsUpdated = @@ROWCOUNT
     
    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update Answer'
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
    ON OBJECT::[dbo].[usp_Answer_Update] TO [FE_rohit.r-ext]
    AS [dbo];

