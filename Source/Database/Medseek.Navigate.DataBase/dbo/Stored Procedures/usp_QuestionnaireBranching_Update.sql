/*    
------------------------------------------------------------------------------    
Procedure Name: usp_QuestionnaireBranching_Update    
Description   : This procedure is used to update record in QuestionnaireBranching table
Created By    : Pramod
Created Date  : 25-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_QuestionnaireBranching_Update]  
(  
	@i_AppUserId KeyID,
	@i_QuestionnaireBranchingId KeyID,
	@i_QuestionaireId KeyID,
	@i_QuestionSetId KeyID,
	@i_QuestionId KeyID,
	@i_BranchingAnswerId KeyID,
	@i_RecommendationId KeyID,
    @i_BranchToQuestionaireQuestionSetId KeyID = NULL,
    @i_BranchToQuestionSetQuestionsId KeyID = NULL,
	@i_QuestionSetBranchingOption CHAR(4)
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE 
		@l_numberOfRecordsUpdated INT,
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
	   	
	UPDATE QuestionnaireBranching
       SET QuestionaireQuestionSetId = @i_QuestionaireQuestionSetId
           ,QuestionSetQuestionId = @i_QuestionSetQuestionId
           ,BranchingAnswerId = @i_BranchingAnswerId
           ,RecommendationId = @i_RecommendationId
           ,BranchToQuestionaireQuestionSetId = @i_BranchToQuestionaireQuestionSetId
           ,BranchToQuestionSetQuestionsId = @i_BranchToQuestionSetQuestionsId 
           ,QuestionSetBranchingOption = @i_QuestionSetBranchingOption
           ,LastModifiedByUserId = @i_AppUserId
           ,LastModifiedDate = GETDATE()
	 WHERE QuestionnaireBranchingId = @i_QuestionnaireBranchingId
	       
    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT

    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update QuestionnaireBranching'
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
    ON OBJECT::[dbo].[usp_QuestionnaireBranching_Update] TO [FE_rohit.r-ext]
    AS [dbo];

