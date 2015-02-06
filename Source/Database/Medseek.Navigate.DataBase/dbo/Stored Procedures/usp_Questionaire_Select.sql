/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Questionaire_Select    
Description   : This procedure is used to get the list of all Questionaire details  
    for a particular QuestionaireId or get complete list when passed NULL  
Created By    : Aditya    
Created Date  : 26-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
29-June-2010 NagaBabu  Deleted ProgramId firld in select Statement
29-02-2012 Rathnam added  IsMedicationTitration column 
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_Questionaire_Select]  
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
		Questionaire.QuestionaireId,  
		Questionaire.QuestionaireName,  
		Questionaire.Description,  
		Questionaire.QuestionaireTypeId,  
		Questionaire.DiseaseID,  
		--ProgramId,
		Questionaire.CreatedByUserId,  
		Questionaire.CreatedDate,  
		Questionaire.LastModifiedByUserId,  
		Questionaire.LastModifiedDate,  
		  CASE Questionaire.StatusCode   
			 WHEN 'A' THEN 'Active'  
			 WHEN 'I' THEN 'InActive'  
			 ELSE ''  
		  END AS StatusDescription  ,
		CASE WHEN QuestionaireType.QuestionaireTypeName = 'Medication Titration' THEN 'True' ELSE 'False' END	IsMedicationTitration
   FROM Questionaire WITH(NOLOCK)
   INNER JOIN QuestionaireType WITH(NOLOCK)
   ON QuestionaireType.QuestionaireTypeId = Questionaire.QuestionaireTypeId
  WHERE ( QuestionaireId = @i_QuestionaireId   
          OR @i_QuestionaireId IS NULL  
         )  
    AND ( @v_StatusCode IS NULL OR Questionaire.StatusCode = @v_StatusCode ) 
  
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
    ON OBJECT::[dbo].[usp_Questionaire_Select] TO [FE_rohit.r-ext]
    AS [dbo];

