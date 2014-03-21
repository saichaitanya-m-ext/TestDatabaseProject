/*  
-----------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[Usp_UserDocument_Update]  
Description   : This procedure is used to Update the data into UserDocument
Created By    : NagaBabu  
Created Date  : 27-May-2010  
------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY     BY        DESCRIPTION  
22-June-2010 NagaBabu  Added MimeType Parameter in Update statement
27-Sep-2010 NagaBabu modified  @i_numberOfRecordsUpdated > 1 by <> 1	
19-mar-2013 P.V.P.Mohan Modified UserDocument to PatientDocument   
------------------------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_UserDocument_Update]
(
 @i_AppUserId KeyID,  
 @i_UserId KeyID,
 @i_UserDocumentId KeyID,
 @i_DocumentCategoryId KeyID,
 @vc_Name ShortDescription,
 @vb_Body VARBINARY(MAX),
 @i_FileSizeinBytes KeyID,
 @i_DocumentTypeId KeyID,
 @vc_StatusCode StatusCode,
 @vc_MimeType VARCHAR(20)
)
AS
BEGIN TRY

      SET NOCOUNT ON   
 -- Check if valid Application UserID is passed  
      DECLARE @i_numberOfRecordsUpdated INT
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )

         BEGIN
               RAISERROR ( N'Invalid Application UserID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END  
------------    Updation operation takes place   --------------------------  

      UPDATE
          PatientDocument
      SET
          PatientID = @i_UserID ,
		  DocumentCategoryId = @i_DocumentCategoryId ,
		  Name = @vc_Name,
		  Body = @vb_Body,
		  FileSizeinBytes = @i_FileSizeinBytes,
		  DocumentTypeId = @i_DocumentTypeId,
		  StatusCode = @vc_StatusCode,
		  MimeType = @vc_MimeType ,
		  LastModifiedByUserId = @i_AppUserId,
		  LastModifiedDate = GETDATE()
      WHERE
          PatientDocumentId = @i_UserDocumentId
          
      SET @i_numberOfRecordsUpdated = @@ROWCOUNT

      IF @i_numberOfRecordsUpdated <> 1
         RAISERROR ( N'Update of UserDocument Table Experienced Invalid RowCount of %d' ,
         17 ,
         1 ,
         @i_numberOfRecordsUpdated )

      RETURN 0
END TRY   
------------ Exception Handling --------------------------------  
BEGIN CATCH
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserDocument_Update] TO [FE_rohit.r-ext]
    AS [dbo];

