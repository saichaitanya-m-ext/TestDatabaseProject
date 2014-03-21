/*    
-------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_Recommendation_Insert]    
Description   : This procedure is used to insert records into Recommendation table.     
Created By    : P.V.P.Mohan   
Created Date  : 25-Oct-2012    
-------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
  
-------------------------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[usp_Recommendation_Insert]    
(    
 @i_AppUserId KEYID ,    
 @vc_RecommendationName varchar(400) ,    
 @vc_Description varchar(400) ,   
 @i_DefaultFrequencyOfTitrationDays int = NULL,   
 @i_SortOrder KeyID = 1,  
 @vc_StatusCode STATUSCODE =NULL,   
 @i_RecommendationId INT OUTPUT    
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
    
------------------insert operation into Questionaire table-----     
       
    
               INSERT INTO    
                   Recommendation    
                   (    
                     RecommendationName ,    
                     Description ,    
                     DefaultFrequencyOfTitrationDays ,    
                     SortOrder ,    
                     StatusCode,  
                     CreatedByUserId ,  
                     CreatedDate  
                    )    
               VALUES    
                   (    
                     @vc_RecommendationName ,    
                     @vc_Description ,    
                     @i_DefaultFrequencyOfTitrationDays,    
                     @i_SortOrder  ,    
                     'A',  
                     @i_AppUserId,  
                     GETDATE()  
                       
                    )    
               SET @i_RecommendationId = SCOPE_IDENTITY()    
    
               RETURN 0    
    
             
END TRY    
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH  


SELECT * FROM Recommendation

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Recommendation_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

