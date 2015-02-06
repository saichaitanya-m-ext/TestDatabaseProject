/*        
-------------------------------------------------------------------------------------------------        
Procedure Name: [dbo].[usp_Questionaire_Select_All]        
Description   : This procedure is used to select all the Questionaire details.         
Created By    : Balla Kalyan         
Created Date  : 15-Mar-2010        
-------------------------------------------------------------------------------------------------        
Log History   :         
DD-Mon-YYYY  BY   DESCRIPTION        
22-Mar-2010  Pramod -> Included the select for questionset and questionairequestionset record      
             for specific questionaireId     
22-Apr-2010  Pramod -> Removed the join on Disease and included in the select
29-June-2010 NagaBabu  Deleted ProgramId firld in select Statement   
27-09-2011	Gurumoorthy.V Included column(Questionaire.MaxScore) in select statement,to get max score   
-------------------------------------------------------------------------------------------------        
*/        
        
CREATE PROCEDURE  [dbo].[usp_Questionaire_Select_All]        
(        
 @i_AppUserId KEYID ,        
 @i_QuestionaireId KEYID = NULL,      
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
        
------------ Selection from Questionaire, QuestionaireType,Disease tables starts here ------------        
      SELECT        
          QuestionaireId ,        
          QuestionaireName ,        
          Questionaire.Description ,        
          QuestionaireType.QuestionaireTypeId ,        
          QuestionaireType.QuestionaireTypeName ,        
          Questionaire.DiseaseID,  
          --Questionaire.ProgramId,    
          ( SELECT Disease.Name FROM Disease WHERE Disease.DiseaseId = Questionaire.DiseaseID ) AS Name,        
          CASE Questionaire.StatusCode  
            WHEN 'A' THEN 'Active'  
            WHEN 'I' THEN 'InActive'  
            ELSE ''  
          END AS StatusDescription, 
          Questionaire.MaxScore,
          Questionaire.CreatedByUserId,      
          Questionaire.CreatedDate,      
          Questionaire.LastModifiedByUserId,      
          Questionaire.LastModifiedDate        
      FROM        
          Questionaire  with (nolock)  
      INNER JOIN QuestionaireType with (nolock)        
          ON Questionaire.QuestionaireTypeId = QuestionaireType.QuestionaireTypeId   
      WHERE        
            ( Questionaire.QuestionaireId = @i_QuestionaireId OR @i_QuestionaireId IS NULL )      
        AND ( @v_StatusCode IS NULL or Questionaire.StatusCode = @v_StatusCode )      
            
     IF @i_QuestionaireId IS NOT NULL      
     SELECT  
		 QuestionaireQuestionSet.QuestionaireQuestionSetId,      
		 QuestionaireQuestionSet.QuestionaireId,      
		 QuestionaireQuestionSet.QuestionSetId,      
		 QuestionaireQuestionSet.SortOrder,      
		 CASE QuestionaireQuestionSet.StatusCode   
			 WHEN 'A' THEN 'Active'  
			 WHEN 'I' THEN 'InActive'  
			 ELSE ''  
		  END AS StatusDescription,     
		 QuestionaireQuestionSet.IsShowPanel,      
		 QuestionaireQuestionSet.IsShowQuestionSetName,      
		 QuestionSet.QuestionSetName,      
		 QuestionSet.Description,      
		 QuestionaireQuestionSet.CreatedByUserId,      
		 QuestionaireQuestionSet.CreatedDate,      
		 QuestionaireQuestionSet.LastModifiedByUserId,      
		 QuestionaireQuestionSet.LastModifiedDate      
     FROM      
		 QuestionaireQuestionSet with (nolock)       
    INNER JOIN QuestionSet with (nolock)      
        ON QuestionaireQuestionSet.QuestionSetId = QuestionSet.QuestionSetId      
    WHERE      
         QuestionaireQuestionSet.QuestionaireId = @i_QuestionaireId       
     AND ( @v_StatusCode IS NULL or QuestionaireQuestionSet.StatusCode = @v_StatusCode )          
    ORDER BY      
		 QuestionaireQuestionSet.SortOrder,      
		 QuestionaireQuestionSet.QuestionSetId       
              
END TRY        
BEGIN CATCH        
        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT        
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId        
        
      RETURN @i_ReturnedErrorID        
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Questionaire_Select_All] TO [FE_rohit.r-ext]
    AS [dbo];

