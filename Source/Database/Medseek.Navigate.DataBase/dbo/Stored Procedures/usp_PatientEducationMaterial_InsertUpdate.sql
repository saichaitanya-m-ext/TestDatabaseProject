/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PatientEducationMaterial_InsertUpdate]    
Description   : This procedure is used to Insert the PatientEducationMaterial data  
Created By    : Rathnam
Created Date  : 24-May-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
06-Jun-2011 Rathnam added @i_DiseaseID one more parameters 
03-feb-2012 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  PatientEducationMaterial table 
10-Dec-2012 Rathnam removed the diseaseid parameter and removed from the table 
09-JAN-2013 Praveen Resolved issue by adding programid in update query
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_PatientEducationMaterial_InsertUpdate]
(
 @i_AppUserId KEYID
,@d_DueDate USERDATE
,@v_PEMTaskName LONGDESCRIPTION
,@i_PatientUserID KEYID
,@b_IsPatientViewable ISINDICATOR
,@v_Comments SHORTDESCRIPTION
,@v_StatusCode STATUSCODE
,@tblLibraryId TTYPEKEYID READONLY
,@tblDocumentNameAndContent TBLDOCUMENT READONLY
,@i_PatientEducationMaterialID KEYID = NULL
,@o_PatientEducationMaterialID KEYID OUT
,@d_DateSent USERDATE = NULL
,@i_ProgramID KEYID = NULL
,@b_IsAdhoc BIT = 0
,@i_AssignedCareProviderId KEYID=NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON
	-- Check if valid Application User ID is passed 
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
      DECLARE @b_TranStarted BIT = 0
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @b_TranStarted = 1  -- Indicator for start of transactions
         END
      ELSE
         BEGIN
               SET @b_TranStarted = 0
         END

      IF @i_PatientEducationMaterialID IS NOT NULL
         BEGIN

               IF NOT EXISTS ( SELECT
                                   1
                               FROM
                                   EducationMaterial
                               WHERE
                                   Name = @v_PEMTaskName )
                  BEGIN
                        INSERT INTO
                            EducationMaterial
                            (
                              Name
                            ,StatusCode
                            ,CreatedByUserId
                            )
                        VALUES
                            (
                              @v_PEMTaskName
                            ,@v_StatusCode
                            ,@i_AppUserId
                            )
                  END
               ELSE

                  BEGIN

                        UPDATE
                            EducationMaterial
                        SET
                            StatusCode = @v_StatusCode
                           ,LastModifiedByUserId = @i_AppUserId
                           ,LastModifiedDate = GETDATE()
                        WHERE
                            EducationMaterialID = ( SELECT
                                                        EducationMaterialID
                                                    FROM
                                                        EducationMaterial
                                                    WHERE
                                                        Name = @v_PEMTaskName )
                  END





               UPDATE
                   PatientEducationMaterial
               SET
                   EducationMaterialID = ( SELECT EducationMaterialID FROM EducationMaterial WHERE Name = @v_PEMTaskName )
                  ,PatientID = @i_PatientUserID
                  ,DueDate = @d_DueDate
                  ,IsPatientViewable = @b_IsPatientViewable
                  ,Comments = @v_Comments
                  ,StatusCode = @v_StatusCode
                  ,ProviderID = @i_AssignedCareProviderId
                  ,LastModifiedByUserId = @i_AppUserId
                  ,LastModifiedDate = GETDATE()
                  ,DateSent = @d_DateSent
                  ,Isadhoc = @b_IsAdhoc
                  ,ProgramID=@i_ProgramID
               WHERE
                   PatientEducationMaterialID = @i_PatientEducationMaterialID

               DELETE  FROM
                       PatientEducationMaterialLibrary
               WHERE
                       PatientEducationMaterialID = @i_PatientEducationMaterialID
                       AND LibraryId NOT IN ( SELECT
                                                  LibraryId
                                              FROM
                                                  PatientEducationMaterialLibrary
                                              INNER JOIN @tblLibraryId tblLibraryId
                                                  ON PatientEducationMaterialLibrary.LibraryId = tblLibraryId.tKeyId
                                              WHERE
                                                  PatientEducationMaterialID = @i_PatientEducationMaterialID )

               INSERT INTO
                   PatientEducationMaterialLibrary
                   (
                     PatientEducationMaterialID
                   ,LibraryId
                   ,CreatedByUserId
                   )
                   SELECT
                       @i_PatientEducationMaterialID
                      ,tblLibraryId.tKeyId
                      ,@i_AppUserId
                   FROM
                       @tblLibraryId tblLibraryId
                   WHERE
                       NOT EXISTS ( SELECT
                                        1
                                    FROM
                                        PatientEducationMaterialLibrary
                                    WHERE
                                        PatientEducationMaterialID = @i_PatientEducationMaterialID
                                        AND LibraryId = tblLibraryId.tKeyId )
               DELETE  FROM
                       PatientEducationMaterialDocuments
               WHERE
                       PatientEducationMaterialID = @i_PatientEducationMaterialID
                       AND DcoumentName NOT IN ( SELECT
                                                     tblDocNameAndContent.DocumentName
                                                 FROM
                                                     PatientEducationMaterialDocuments
                                                 INNER JOIN @tblDocumentNameAndContent tblDocNameAndContent
                                                     ON PatientEducationMaterialDocuments.DcoumentName = tblDocNameAndContent.DocumentName
                                                        AND PatientEducationMaterialDocuments.MimeType = tblDocNameAndContent.MimeType
                                                 WHERE
                                                     PatientEducationMaterialID = @i_PatientEducationMaterialID )

               INSERT INTO
                   PatientEducationMaterialDocuments
                   (
                     PatientEducationMaterialID
                   ,DcoumentName
                   ,Content
                   ,CreatedByUserId
                   ,MimeType
                   )
                   SELECT
                       @i_PatientEducationMaterialID
                      ,tblDocNameAndContent.DocumentName
                      ,tblDocNameAndContent.DocumentContent
                      ,@i_AppUserId
                      ,tblDocNameAndContent.MimeType
                   FROM
                       @tblDocumentNameAndContent tblDocNameAndContent
                   WHERE
                       NOT EXISTS ( SELECT
                                        1
                                    FROM
                                        PatientEducationMaterialDocuments
                                    WHERE
                                        PatientEducationMaterialID = @i_PatientEducationMaterialID
                                        AND DcoumentName = tblDocNameAndContent.DocumentName )
         END
      ELSE
         BEGIN

               IF NOT EXISTS ( SELECT
                                   1
                               FROM
                                   EducationMaterial
                               WHERE
                                   Name = @v_PEMTaskName )
                  BEGIN
                        INSERT INTO
                            EducationMaterial
                            (
                              Name
                            ,StatusCode
                            ,CreatedByUserId
                            )
                        VALUES
                            (
                              @v_PEMTaskName
                            ,@v_StatusCode
                            ,@i_AppUserId
                            )


                  END



               INSERT INTO
                   PatientEducationMaterial
                   (
                     PatientID
                   ,EducationMaterialID
                   ,DueDate
                   ,IsPatientViewable
                   ,Comments
                   ,StatusCode
                   ,ProviderID
                   ,ProgramID
                   ,DateSent
                   ,CreatedByUserId
                   )
                   SELECT
                       @i_PatientUserID
                      ,edu.EducationMaterialID
                      ,@d_DueDate
                      ,@b_IsPatientViewable
                      ,@v_Comments
                      ,@v_StatusCode
                      ,@i_AssignedCareProviderId
                      ,@i_ProgramID
                      ,CASE
                            WHEN @b_IsPatientViewable = 0 THEN NULL
                            ELSE @d_DateSent
                       END
                      ,@i_AppUserId
                   FROM
                       EducationMaterial edu
                   WHERE
                       edu.Name = @v_PEMTaskName

               SELECT
                   @o_PatientEducationMaterialID = SCOPE_IDENTITY()
               IF EXISTS ( SELECT
                               1
                           FROM
                               @tblLibraryId )
                  BEGIN
                        INSERT INTO
                            PatientEducationMaterialLibrary
                            (
                              PatientEducationMaterialID
                            ,LibraryId
                            ,CreatedByUserId
                            )
                            SELECT
                                @o_PatientEducationMaterialID
                               ,tblLibraryId.tKeyId
                               ,@i_AppUserId
                            FROM
                                @tblLibraryId tblLibraryId
                  END
               IF EXISTS ( SELECT
                               1
                           FROM
                               @tblDocumentNameAndContent )
                  BEGIN
                        INSERT INTO
                            PatientEducationMaterialDocuments
                            (
                              PatientEducationMaterialID
                            ,DcoumentName
                            ,Content
                            ,CreatedByUserId
                            ,MimeType
                            )
                            SELECT
                                @o_PatientEducationMaterialID
                               ,tblDocNameAndContent.DocumentName
                               ,tblDocNameAndContent.DocumentContent
                               ,@i_AppUserId
                               ,tblDocNameAndContent.MimeType
                            FROM
                                @tblDocumentNameAndContent tblDocNameAndContent
                  END
         END
      IF ( @b_TranStarted = 1 )  -- If transactions are there, then commit
         BEGIN
               SET @b_TranStarted = 0
               COMMIT TRANSACTION
         END
      ELSE
         BEGIN
               ROLLBACK TRANSACTION
         END
      RETURN 0
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
    ON OBJECT::[dbo].[usp_PatientEducationMaterial_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

