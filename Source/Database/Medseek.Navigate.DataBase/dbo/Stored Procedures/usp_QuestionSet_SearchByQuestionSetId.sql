/*
-------------------------------------------------------------------------------------------------
Procedure Name: usp_QuestionSet_SearchByQuestionSetId
Description	  : This procedure is used to select all the Questions Sets and related data from the 
				QuestionSet table or select the QuestionSet data based on the QuestionSet id. 
Created By    :	Aditya 
Created Date  : 20-Jan-2010
-------------------------------------------------------------------------------------------------
Log History   : 
DD-Mon-YYYY		BY			DESCRIPTION
22-Mar-2010	   Pramod Included the condition to get the list of questions for the particular questionset 
5-Apr-2010	   Pramod Changed the inner join to left outer join as per page requirement
27-Apr-2010    Pramod Removed the unnecessary fields from the select
-------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_QuestionSet_SearchByQuestionSetId]
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
           QuestionSet with (nolock)
           LEFT OUTER JOIN QuestionaireQuestionSet with (nolock)
             ON QuestionSet.QuestionSetId = QuestionaireQuestionSet.QuestionSetId
      WHERE
			ISNULL( QuestionaireQuestionSet.QuestionaireId, 0 ) <> @i_IgnoreQuestionaireId
        AND QuestionSet.StatusCode = 'A' 
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
    ON OBJECT::[dbo].[usp_QuestionSet_SearchByQuestionSetId] TO [FE_rohit.r-ext]
    AS [dbo];

