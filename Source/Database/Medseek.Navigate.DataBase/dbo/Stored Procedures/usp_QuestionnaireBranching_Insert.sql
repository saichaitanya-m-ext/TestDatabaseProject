/*    
------------------------------------------------------------------------------    
Procedure Name: usp_QuestionnaireBranching_Insert    
Description   : This procedure is used to insert record into QuestionnaireBranching table
Created By    : Pramod
Created Date  : 25-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_QuestionnaireBranching_Insert]  
(  
	@i_AppUserId KeyID,
	@i_QuestionaireId KeyID,
	@i_QuestionSetId KeyID,
	@i_QuestionId KeyID,
	@i_BranchingAnswerId KeyID,
	@i_RecommendationId KeyID,
    @i_BranchToQuestionaireQuestionSetId KeyID = NULL,
    @i_BranchToQuestionSetQuestionsId KeyID = NULL,
	@i_QuestionSetBranchingOption CHAR(4),
	@o_QuestionnaireBranchingId KeyID OUTPUT
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE 
		@l_numberOfRecordsInserted INT,
		@i_QuestionaireQuestionSetId KeyID,
        @i_QuestionSetQuestionId KeyID

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

	SELECT @i_QuestionaireQuestionSetId = QuestionaireQuestionSetId
	  FROM QuestionaireQuestionSet
	 WHERE QuestionaireId = @i_QuestionaireId
	   AND QuestionSetId = @i_QuestionSetId
	   
	SELECT @i_QuestionSetQuestionId = QuestionSetQuestionId
	  FROM QuestionSetQuestion
	 WHERE QuestionSetId = @i_QuestionSetId
	   AND QuestionId = @i_QuestionId
	   
	INSERT INTO QuestionnaireBranching
          ( QuestionaireQuestionSetId
           ,QuestionSetQuestionId
           ,BranchingAnswerId
           ,RecommendationId
           ,BranchToQuestionaireQuestionSetId
           ,BranchToQuestionSetQuestionsId
           ,QuestionSetBranchingOption
           ,CreatedByUserId
           )
	 VALUES
	      ( @i_QuestionaireQuestionSetId
           ,@i_QuestionSetQuestionId
           ,@i_BranchingAnswerId
           ,@i_RecommendationId
           ,@i_BranchToQuestionaireQuestionSetId
           ,@i_BranchToQuestionSetQuestionsId
           ,@i_QuestionSetBranchingOption
           ,@i_AppUserId
	       )
	       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_QuestionnaireBranchingId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert QuestionnaireBranching'
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
    ON OBJECT::[dbo].[usp_QuestionnaireBranching_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

