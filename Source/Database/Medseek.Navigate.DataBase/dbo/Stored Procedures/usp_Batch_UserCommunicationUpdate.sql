/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Batch_UserCommunicationUpdate    
Description   : This procedure is used to insert record into UserCommunication table
Created By    : Rathnam   
Created Date  : 01-Feb-2013
-----------------------------------------------------------------------------------------
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Batch_UserCommunicationUpdate]
(
 @i_AppUserId KEYID,
 @i_ProgramID KEYID = NULL
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON
            DECLARE
                    @l_numberOfRecordsInserted INT
                   ,@vc_TemplateCommunicationText NVARCHAR(MAX) = NULL
                   ,@vc_TemplateSubjectText VARCHAR(200) = NULL
                   ,@vc_EmailIdPrimary EMAILID
                   ,@vc_NotifySubjectText VARCHAR(200)
                   ,@vc_NotifyCommunicationText NVARCHAR(MAX)		

	-- Check if valid Application User ID is passed    
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END

            DECLARE
                    @i_CommunicationTemplateId INT
                   ,@i_UserID INT
                   ,@i_UserCommunicationId INT

            DECLARE curTaskScheduling CURSOR
                    FOR SELECT
                            PatientCommunicationId
                           ,PatientID
                           ,CommunicationTemplateId
                        FROM
                            PatientCommunication WITH ( NOLOCK )
                        WHERE
                            CommunicationState = 'Ready to Generate'
                        AND (ProgramId = @i_ProgramID OR @i_ProgramID IS NULL)    
            OPEN curTaskScheduling
            FETCH NEXT FROM curTaskScheduling INTO @i_UserCommunicationId,@i_UserID,@i_CommunicationTemplateId
			WHILE @@FETCH_STATUS = 0
			BEGIN
			
            EXEC usp_Communication_MessageContent 
            @i_AppUserId = @i_AppUserId , 
            @i_CommunicationTemplateId = @i_CommunicationTemplateId , 
            @i_UserID = @i_UserID , 
            @v_EmailIdPrimary = @vc_EmailIdPrimary OUT , 
            @v_SubjectText = @vc_TemplateSubjectText OUT , 
            @v_CommunicationText = @vc_TemplateCommunicationText OUT , 
            @v_NotifySubjectText = @vc_NotifySubjectText OUT , 
            @v_NotifyCommunicationText = @vc_NotifyCommunicationText OUT
	
			IF @i_UserCommunicationId IS NOT NULL AND ISNULL(@vc_TemplateCommunicationText,'') <> ''
			BEGIN
            INSERT INTO
                PatientCommunicationText
                SELECT
                    @i_UserCommunicationId
                   ,@vc_TemplateCommunicationText
                   ,@vc_TemplateSubjectText
			END
			
			UPDATE
                PatientCommunication
            SET
                SubjectText = @vc_TemplateSubjectText
               ,CommunicationText = @vc_TemplateCommunicationText
               ,CommunicationState = CASE
                                          WHEN CommunicationTypeId IN ( 1 , 4 , 5 , 6 ) THEN 'Ready to Send'
                                          WHEN CommunicationTypeId IN ( 3 ) THEN 'Ready to Print'
                                     END
            WHERE PatientCommunicationid = @i_UserCommunicationId

            FETCH NEXT FROM curTaskScheduling INTO @i_UserCommunicationId,@i_UserID,@i_CommunicationTemplateId
			END
            CLOSE curTaskScheduling
            DEALLOCATE curTaskScheduling

            --UPDATE
            --    PatientCommunication
            --SET
            --    SubjectText = @vc_TemplateSubjectText
            --   ,CommunicationText = @vc_TemplateCommunicationText
            --   ,CommunicationState = CASE
            --                              WHEN CommunicationTypeId IN ( 1 , 4 , 5 , 6 ) THEN 'Ready to Send'
            --                              WHEN CommunicationTypeId IN ( 3 ) THEN 'Ready to Print'
            --                         END
            --FROM
            --    PatientCommunicationText
            --WHERE
            --    PatientCommunicationText.PatientCommunicationId = PatientCommunication.PatientCommunicationId
            --    AND ISNULL(PatientCommunicationText.CommunicationText,'') <> ''

            DELETE  FROM
                    PatientCommunicationText
            WHERE
                    ISNULL(CommunicationText,'') <> ''
      END TRY    
--------------------------------------------------------     
      BEGIN CATCH    
    -- Handle exception    
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_UserCommunicationUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

