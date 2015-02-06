/*    
-------------------------------------------------------------------------------------------------    
Procedure Name: usp_Questionaire_Select_TreeView    
Description   : This procedure is going to be helpful in building the tree structure for Questionaire    
Created By    : Pramod    
Created Date  : 22-Mar-2010    
-------------------------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY   DESCRIPTION    
10-May-2010 Pramod Included the Status Code as parameter
01-Jul-10  Pramod  Added the field IsEditable into the declare table and also the select statement
06-Jan-2011 NagaBabu Modified 'CName' field datatype from ShortDescription to LongDescription
-------------------------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE[dbo].[usp_Questionaire_Select_TreeView]
( @i_AppUserId KEYID ,    
  @i_QuestionaireId KeyID,
  @v_StatusCode StatusCode = NULL
)    
AS    
BEGIN TRY     
    
 -- Check if valid Application User ID is passed    
 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
 BEGIN    
     RAISERROR ( N'Invalid Application User ID %d passed.' ,    
     17 ,    
     1 ,    
     @i_AppUserId )    
 END    
    
 DECLARE    
    @tblQuestionaire TABLE    
	   (QType VARCHAR(20),  
		CID KeyID,  
		CName LongDescription,  
		ParentID KeyID,  
		QuestionaireQuestionSetId KeyID,  
		QuestionSetQuestionId KeyID,  
		TypeShortCode CHAR(2),  
		TypeParentShortCode CHAR(2),  
		SortOrder INT,
		StatusCode StatusCode,
		IsEditable IsIndicator
	   )   

 INSERT     
   INTO @tblQuestionaire    
     ( QType, CID, CName, ParentID, QuestionaireQuestionSetId,   
       TypeShortCode, TypeParentShortCode, SortOrder, StatusCode, IsEditable )
  SELECT 'QuestionSet',     
		 QuestionaireQuestionSet.QuestionSetId,     
		 QuestionSet.QuestionSetName,    
		 0, -- Changed from NULL to 0 as per developer's request    
		 QuestionaireQuestionSetId,  
		 'QS',  
		 'QR',  
		 1,
		 QuestionaireQuestionSet.StatusCode,
		 1
    FROM QuestionaireQuestionSet  with (nolock)   
   INNER JOIN QuestionSet   with (nolock)  
      ON QuestionaireQuestionSet.QuestionSetId = QuestionSet.QuestionSetId    
   WHERE QuestionaireId = @i_QuestionaireId    
   ORDER BY QuestionaireQuestionSet.SortOrder

 INSERT    
   INTO @tblQuestionaire    
     ( QType, CID, CName, ParentID, QuestionSetQuestionId, QuestionaireQuestionSetId, 
       TypeShortCode, TypeParentShortCode, SortOrder, StatusCode, IsEditable)
  SELECT 'Question',     
		 QuestionSetQuestion.QuestionId,    
		 --QuestionSetQuestion.QuestionSetQuestionId,  
		 Question.Description,    
		 QuestionSetQuestion.QuestionSetId,    
		 QuestionSetQuestion.QuestionSetQuestionId,  
		 tblQuestionaire.QuestionaireQuestionSetId,   
		 'QN',  
		 'QS',  
		 2,
		 QuestionSetQuestion.StatusCode,
		 dbo.ufn_QuestionEditStatus(QuestionSetQuestion.QuestionId)
    FROM QuestionSetQuestion with (nolock)     
   INNER JOIN @tblQuestionaire tblQuestionaire  
      ON QuestionSetQuestion.QuestionSetId = tblQuestionaire.CID    
      AND tblQuestionaire.QType = 'QuestionSet'    
   INNER JOIN Question  with (nolock)   
      ON QuestionSetQuestion.QuestionId = Question.QuestionId    

 INSERT    
   INTO @tblQuestionaire    
     ( QType, CID, CName, ParentID, QuestionaireQuestionSetId, QuestionSetQuestionId, 
       TypeShortCode, TypeParentShortCode, SortOrder, StatusCode, IsEditable)
  SELECT 'Answer',    
		 Answer.AnswerId,    
		 Answer.AnswerDescription,    
		 Answer.QuestionId,   
		 --tblQuestionaire.QuestionSetQuestionId, --Commented this after discussion  
		 tblQuestionaire.QuestionaireQuestionSetId,  
		 tblQuestionaire.QuestionSetQuestionId,   
		 'AN',  
		 'QN',  
		 3,
		 Answer.StatusCode,
		 dbo.ufn_QuestionEditStatus(Answer.QuestionId)
    FROM Answer    
   INNER JOIN @tblQuestionaire tblQuestionaire    
      ON tblQuestionaire.CID = Answer.QuestionId  
         AND tblQuestionaire.QType = 'Question'  

 INSERT    
   INTO @tblQuestionaire    
     ( QType, CID, CName, ParentID, TypeShortCode,   
       TypeParentShortCode, SortOrder, StatusCode, IsEditable)
  SELECT 'Branch',    
	   QuestionnaireBranching.QuestionnaireBranchingId,    
	   'Branch', -- AnswerId (commented as there are no texts for answerid)  
	   tblQuestionaire.CID,  
	   'AB',  
	   'AN',  
	   4,
	   '', -- No status is there for branching
	   1
    FROM QuestionnaireBranching    
   INNER JOIN @tblQuestionaire tblQuestionaire    
     ON QuestionnaireBranching.QuestionaireQuestionSetId = tblQuestionaire.QuestionaireQuestionSetId    
     AND tblQuestionaire.QType = 'Answer'  
     AND QuestionnaireBranching.BranchingAnswerId = tblQuestionaire.CID  

 SELECT QType, CID, CName, ParentID, SortOrder, StatusCode, IsEditable
   FROM @tblQuestionaire
  WHERE ( StatusCode = @v_StatusCode OR @v_StatusCode IS NULL OR StatusCode = '' )
  ORDER BY SortOrder  
    
END TRY    
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Questionaire_Select_TreeView] TO [FE_rohit.r-ext]
    AS [dbo];

