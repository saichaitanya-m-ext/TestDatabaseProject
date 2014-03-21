/*
-------------------------------------------------------------------------------------------------
Procedure Name: usp_QuestionSet_Select_IgnoreQuestionaire
Description	  : This procedure is used to select all the Questions Sets and related data from the 
				QuestionSet table ignoring the selected questionaireid 
Created By    :	Pramod 
Created Date  : 27-Apr-2010
-------------------------------------------------------------------------------------------------
Log History   : 
DD-Mon-YYYY		BY			DESCRIPTION
28-Apr-10 Pramod Removed the LEFT JOIN and included in the NOT EXISTS clause
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_QuestionSet_Select_IgnoreQuestionaire]
( @i_AppUserId KEYID ,
  @i_IgnoreQuestionaireId KEYID
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

------------ Selection from QuestionSet table table starts here ------------
      SELECT DISTINCT
           QuestionSet.QuestionSetId,
           QuestionSet.QuestionSetName,
           QuestionSet.Description,
           QuestionSet.SortOrder
      FROM
           QuestionSet
           --LEFT OUTER JOIN QuestionaireQuestionSet
           --  ON QuestionSet.QuestionSetId = QuestionaireQuestionSet.QuestionSetId
      WHERE QuestionSet.StatusCode = 'A' 
        AND NOT EXISTS
            (SELECT 1 
               FROM QuestionaireQuestionSet 
              WHERE QuestionaireQuestionSet.QuestionSetId = QuestionSet.QuestionSetId
                AND QuestionaireQuestionSet.QuestionaireId = @i_IgnoreQuestionaireId
            )
      ORDER BY
          QuestionSet.SortOrder ,
          QuestionSet.QuestionSetName

END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionSet_Select_IgnoreQuestionaire] TO [FE_rohit.r-ext]
    AS [dbo];

