/*            
--------------------------------------------------------------------------------------------  
Procedure Name: usp_PatientDashBoard_Documents  23
Description   : This procedure is used to get the details from DocumentCategory,UserDocument
                DocumentType Tables.  
Created By    : Rathnam  
Created Date  : 10-Feb-2013  
---------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY     BY       DESCRIPTION     
18-July-2013 Mohan Added isPatientViewable In where Clause      
---------------------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_PatientDashBoard_Documents]
(
 @i_AppUserId KEYID ,
 @i_UserId KEYID = NULL ,
 @i_UserDocumentId KEYID = NULL ,
 @v_StatusCode STATUSCODE = NULL
 --@vc_MimeType VARCHAR(20) = NULL  
)
AS
BEGIN TRY
      SET NOCOUNT ON             
 -- Check if valid Application User ID is passed            
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application UserID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END  
      
EXEC usp_UserDocument_Select
 @i_AppUserId = @i_AppUserId ,
 @i_UserId  = @i_UserId ,
 @i_UserDocumentId = @i_UserDocumentId ,
 @v_StatusCode = @v_StatusCode
 
      SELECT
          DocumentCategoryId ,
          CategoryName AS DocumentCategoryName 
           FROM
          DocumentCategory
      WHERE
      StatusCode='A' AND isPatientViewable = 1

EXEC [usp_DocumentType_Select_DD] @i_AppUserId = @i_AppUserId
                                                          
END TRY
BEGIN CATCH            
    -- Handle Exception            
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientDashBoard_Documents] TO [FE_rohit.r-ext]
    AS [dbo];

