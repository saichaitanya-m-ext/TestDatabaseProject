/*  
----------------------------------------------------------------------------------------------   
Procedure Name: usp_Recommendation_Select_DD  
Description   : This procedure is used for the Recommendation dropdown from the Recommendation 
			    table.  
Created By    : Aditya   
Created Date  : 11-Jan-2010  
-----------------------------------------------------------------------------------------------   
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
11-June-2010 NagaBabu   Modified RecommendationId field in SELECT statement
07-Sept-2010 Rathnam    Added QuestionaireID, QuestionaireName columns in SELECT statement
19-Nov-2010  Rathnam    added distinct condition in select statement.
24-Feb-2012 NagaBabu Replaced INNER JOIN by LEFT OUTER JOIN between Recommendation and RecommendationRule
-----------------------------------------------------------------------------------------------   
*/
CREATE PROCEDURE [dbo].[usp_Recommendation_Select_DD]
(
 @i_AppUserId KEYID )
AS
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END  
  
------------ Selection from Recommendation table starts here ------------  
   
      SELECT DISTINCT
          Recommendation.RecommendationId ,
          CAST(Recommendation.RecommendationId AS VARCHAR(4)) + '*' + 
               ISNULL(CAST(Recommendation.DefaultFrequencyOfTitrationDays AS VARCHAR(4)),'') + '*' + 
               ISNULL(CAST (RecommendationRule.NextQuestionaireID AS VARCHAR(4)),'') + '*' + 
               ISNULL(Questionaire.QuestionaireName,'') AS RecommendationIDandDays, 
          Recommendation.RecommendationName,
          Recommendation.SortOrder 
      FROM
          Recommendation with (nolock)
      LEFT OUTER JOIN RecommendationRule with (nolock)
      ON  Recommendation.RecommendationId = RecommendationRule.RecommendationID
      LEFT OUTER JOIN Questionaire with (nolock)
      ON  RecommendationRule.NextQuestionaireID = Questionaire.QuestionaireId
      WHERE
          Recommendation.StatusCode = 'A'
      ORDER BY
          Recommendation.SortOrder ,
          Recommendation.RecommendationName
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Recommendation_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

