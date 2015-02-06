/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_Library_Select_DD  
Description   : This procedure is used to get the list for the dropdown from Library.
Created By    : Aditya
Created Date  : 12-May-2010  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
19-Aug-2010 NagaBabu Added ORDER BY clause to the select statement  
13-Oct-10 Pramod Included default value for pdf for the new parameter
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Library_Select_DD]
(
	@i_AppUserId keyid,
	@v_MimeType VARCHAR(20) = 'application/pdf'
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
      SELECT l.LibraryId,
		     l.Name,
		     dt.Name AS DocumentType    
        FROM
             Library L join DocumentType dt on L.DocumentTypeId=dt.DocumentTypeId
       WHERE l.StatusCode = 'A'
         AND ( l.MimeType = @v_MimeType OR @v_MimeType IS NULL )
       ORDER BY l.Name

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
    ON OBJECT::[dbo].[usp_Library_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

