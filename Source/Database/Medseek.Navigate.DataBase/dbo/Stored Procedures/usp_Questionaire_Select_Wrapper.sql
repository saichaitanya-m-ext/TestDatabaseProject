/*
-------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Questionaire_Select_Wrapper]
Description	  : All the Questionaire maintenance dropdown SP's are executed through this wrapper. 
Created By    :	Aditya
Created Date  : 11-Mar-2010
--------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

--------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Questionaire_Select_Wrapper]
(
 @i_AppUserId KEYID 
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

      
      EXEC usp_Disease_Select_DD @i_AppUserId 
      EXEC usp_QuestionaireType_Select_DD @i_AppUserId
      EXEC usp_Question_Select_DD @i_AppUserId
      EXEC usp_QuestionSet_Select_DD @i_AppUserId
      EXEC usp_Recommendation_Select_DD @i_AppUserId
      EXEC usp_AnswerType_Select_DD @i_AppUserId
      EXEC usp_QuestionType_Select_DD @i_AppUserId
      

END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Questionaire_Select_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

