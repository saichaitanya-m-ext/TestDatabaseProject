/*      
------------------------------------------------------------------------------      
Procedure Name: usp_Recommendation_Select    
Description   : This procedure is used to get the records from the Recommendation    
    table    
Created By    : P.V.P.MOHAN      
Created Date  : 26-Oct-2012      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/   
--select * from Recommendation   
CREATE PROCEDURE [dbo].[usp_Recommendation_Select] -- 1
(    
 @i_AppUserId KeyID,    
 @i_RecommendationId KeyID  = NULL   
   
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
    
   SELECT  Recommendation.RecommendationId,
     Recommendation.RecommendationName,    
     Recommendation.Description,  
     Recommendation.DefaultFrequencyOfTitrationDays ,   
     Recommendation.SortOrder ,  
     Recommendation.CreatedByUserId AS 'UserID',    
     Recommendation.CreatedDate,    
     Recommendation.LastModifiedByUserId,    
     Recommendation.LastModifiedDate,    
     CASE Recommendation.StatusCode     
   WHEN 'A' THEN 'Active'    
   WHEN 'I' THEN 'InActive'    
   ELSE ''    
     END AS StatusDescription    
   FROM   Recommendation  
       
  WHERE ( Recommendation.RecommendationId = @i_RecommendationId OR @i_RecommendationId IS NULL )     
  
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
    ON OBJECT::[dbo].[usp_Recommendation_Select] TO [FE_rohit.r-ext]
    AS [dbo];

