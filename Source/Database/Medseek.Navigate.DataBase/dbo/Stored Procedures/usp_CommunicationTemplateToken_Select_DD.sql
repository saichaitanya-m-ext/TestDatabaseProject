/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_CommunicationTemplateToken_Select_DD  
Description   : This procedure is used to get the list for the dropdown from	
				CommunicationTemplateToken
Created By    : Aditya
Created Date  : 05-May-2010  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
19-Aug-2010 NagaBabu Added ORDER BY to the select statement  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CommunicationTemplateToken_Select_DD]
(
	@i_AppUserId keyid
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
-------------------------------------------------------- 
      SELECT
          TagNameInTemplate,
		  TokenString    
      FROM
          CommunicationTemplateToken
      WHERE
          StatusCode = 'A'
      ORDER BY
          TagNameInTemplate     

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
    ON OBJECT::[dbo].[usp_CommunicationTemplateToken_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

