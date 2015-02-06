/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Communication_MessageDetail]
Description	  : This procedure is used to get the message detail for a user
Created By    :	Pramod
Created Date  : 13-May-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

----------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Communication_MessageDetail]
(
	@i_AppUserId KEYID ,
	@i_CommunicationTemplateId KEYID,
	@v_SenderEmailAddress EmailId,
	@i_UserID KEYID
)
AS
BEGIN TRY
      SET NOCOUNT ON
	  DECLARE 
		@v_EmailIdPrimary EmailId,
		@v_SubjectText VARCHAR(200), 
		@v_CommunicationText NVARCHAR(MAX),
		@v_NotifySubjectText VARCHAR(200), 
		@v_NotifyCommunicationText NVARCHAR(MAX)			

	-- Check if valid Application User ID is passed

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
      BEGIN
           RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
      END

	  EXEC usp_Communication_MessageContent
		@i_AppUserId = @i_AppUserId,
		@i_CommunicationTemplateId = @i_CommunicationTemplateId,
		@i_UserID = @i_UserID,
		@v_EmailIdPrimary = @v_EmailIdPrimary OUT,
		@v_SubjectText = @v_SubjectText OUT, 
		@v_CommunicationText = @v_CommunicationText OUT,
		@v_NotifySubjectText = @v_NotifySubjectText OUT, 
		@v_NotifyCommunicationText = @v_NotifyCommunicationText OUT		

	  SELECT @v_SenderEmailAddress As SenderEmailId,
             @v_EmailIdPrimary AS SendToEmailId,
             @v_SubjectText AS Subject,
             @v_CommunicationText AS CommunicationText

      SELECT Library.PhysicalFileName
        FROM CommunicationTemplateAttachments
			 INNER JOIN Library
			   ON Library.LibraryId = CommunicationTemplateAttachments.LibraryId
       WHERE CommunicationTemplateAttachments.CommunicationTemplateId = @i_CommunicationTemplateId

END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_MessageDetail] TO [FE_rohit.r-ext]
    AS [dbo];

