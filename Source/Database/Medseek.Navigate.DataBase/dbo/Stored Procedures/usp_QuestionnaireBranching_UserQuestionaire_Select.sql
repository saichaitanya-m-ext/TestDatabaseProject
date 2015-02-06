/*    select * from patientquestionaire
------------------------------------------------------------------------------    
Procedure Name: usp_QuestionnaireBranching_UserQuestionaire_Select    
Description   : This procedure is used to selecting branching information
			    for specific Questionaire Answer and also the user entered
			    survey detail
Created By    : Pramod    
Created Date  : 13-May-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
20-May-10 Pramod for the branch to Questionset, concatenated QuestionSetID and Name
DECLARE  @t_UserQuestionaireAnswers As UserQuestionaireAnswersTbl
EXEC[usp_QuestionnaireBranching_UserQuestionaire_Select] 23,282626,@t_UserQuestionaireAnswers = @t_UserQuestionaireAnswers
------------------------------------------------------------------------------    
*/ 

CREATE PROCEDURE [dbo].[usp_QuestionnaireBranching_UserQuestionaire_Select]  
(  
	@i_AppUserId KeyID,
	@i_UserQuestionaireId KeyID,
	@t_UserQuestionaireAnswers UserQuestionaireAnswersTbl Readonly
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
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

	SELECT QB.QuestionnaireBranchingId
		   ,QB.RecommendationId AS SystemRecommendationId
		   ,( SELECT RecommendationName
		        FROM Recommendation
			   WHERE RecommendationId = QB.RecommendationId 
			) AS SystemRecommendationName
		   ,QB.BranchToQuestionaireQuestionSetId
		   ,( SELECT CAST(QuestionSet.QuestionSetId AS VARCHAR(12))+ '&' + QuestionSet.QuestionSetName
		        FROM QuestionaireQuestionSet
					 INNER JOIN QuestionSet
					    ON QuestionaireQuestionSet.QuestionSetId = QuestionSet.QuestionSetId
		       WHERE QuestionaireQuestionSetId = QB.BranchToQuestionaireQuestionSetId
		    ) AS QuestionSetIdWithName
		   ,QB.BranchToQuestionSetQuestionsId
		   ,( SELECT QuestionSetId
		        FROM QuestionSetQuestion
		       WHERE QuestionSetQuestionId = QB.BranchToQuestionSetQuestionsId
		    ) AS QuestionSetId2
		   ,QB.QuestionSetBranchingOption
		   ,UQR.RecommendationId
		   ,UQR.ActionComment
		   ,UQR.FrequencyOfTitrationDays
		   ,UQR.CreatedByUserId
		   ,UQR.CreatedDate
	  FROM QuestionnaireBranching QB WITH(NOLOCK)
			INNER JOIN @t_UserQuestionaireAnswers UQA 
				ON UQA.QuestionSetQuestionId = QB.QuestionSetQuestionId
			     AND UQA.AnswerID = QB.BranchingAnswerId			
			INNER JOIN PatientQuestionaire UQ WITH(NOLOCK)
				ON UQA.UserQuestionaireID = UQ.PatientQuestionaireId
				AND UQA.UserQuestionaireID = @i_UserQuestionaireId
			INNER JOIN Questionaire QR WITH(NOLOCK)
				ON QR.QuestionaireId = UQ.QuestionaireId
			INNER JOIN QuestionaireQuestionSet QQS WITH(NOLOCK)
			    ON QQS.QuestionaireId = QR.QuestionaireId
			     AND QQS.QuestionaireQuestionSetId = QB.QuestionaireQuestionSetId
			LEFT OUTER JOIN PatientQuestionaireRecommendations UQR WITH(NOLOCK)
				ON UQR.PatientQuestionaireId = UQA.UserQuestionaireID
  
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
    ON OBJECT::[dbo].[usp_QuestionnaireBranching_UserQuestionaire_Select] TO [FE_rohit.r-ext]
    AS [dbo];

