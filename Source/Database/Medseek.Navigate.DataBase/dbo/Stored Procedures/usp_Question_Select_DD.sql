/*  
----------------------------------------------------------------------------------------  
Procedure Name: usp_Question_Select_DD  
Description   : This procedure is used for the Questions dropdown from the Questions 
			    table.  
Created By    : Aditya   
Created Date  : 11-Jan-2010  
-----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
-----------------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_Question_Select_DD]
(
 @i_AppUserId KEYID )
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
  
------------ Selection from Question table starts here ------------  
      SELECT
          QuestionId,
          Description,
          QuestionText
      FROM
          Question
      WHERE
          StatusCode = 'A'
      ORDER BY
		  Description    
     
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Question_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

