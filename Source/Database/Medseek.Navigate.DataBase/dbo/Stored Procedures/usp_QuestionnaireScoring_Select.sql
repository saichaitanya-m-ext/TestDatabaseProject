/*    
------------------------------------------------------------------------------    
Procedure Name: usp_QuestionnaireScoring_Select  23  
Description   : This procedure is used to get the list of all Questionaire details  
    for a particular QuestionaireId or get complete list when passed NULL  
Created By    : Aditya    
Created Date  : 26-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_QuestionnaireScoring_Select]  
(  
	@i_AppUserId KeyID,  
	@i_QuestionaireId KeyID = NULL,
	@v_StatusCode StatusCode = NULL
)  
AS  
BEGIN TRY  
    SET NOCOUNT ON     
-- Check if valid Application User ID is passed  
  
   IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
   BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
   END  
  
   SELECT 
		RangeStartScore,
		RangeEndScore,
		RangeName,
		RangeDescription
		
   FROM QuestionnaireScoring  WITH(NOLOCK)
  WHERE ( QuestionaireId = @i_QuestionaireId   
          OR @i_QuestionaireId IS NULL 
         )  
    AND ( @v_StatusCode IS NULL OR StatusCode = @v_StatusCode ) 
    ORDER BY QuestionnaireScoringID DESC
  
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
    ON OBJECT::[dbo].[usp_QuestionnaireScoring_Select] TO [FE_rohit.r-ext]
    AS [dbo];

