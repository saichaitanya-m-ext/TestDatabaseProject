/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_UserMessage_SendToAllCareTeamMembers]
Description	  : This procedure is used to send the Internal message usng internal messaging				
Created By    :	Pramod
Created Date  : 13-Jul-10
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
----------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_UserMessage_SendToAllCareTeamMembers]--  23,172906,'sdd','fgdg'

(
 @i_AppUserId KEYID
,@i_PatientUserId KEYID
,@v_SubjectText VARCHAR(200)
,@v_CommunicationText NVARCHAR(MAX)
,@t_CareProvider TTYPEKEYID READONLY
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

      DECLARE
              @i_UserID KEYID
             ,@t_Attachment ATTACHMENTTBL
             ,@t_MessageToUserId USERIDTBLTYPE
             ,@i_UserMessageId KEYID

		 -- Steps for sending internal messages


      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_CareProvider )
         BEGIN
               INSERT INTO
                   @t_MessageToUserId
                   (
                     UserId
                   )
                   SELECT DISTINCT
                       ProviderID
                   FROM
                       Provider
                   INNER JOIN @t_CareProvider CareTeamMembers
                       ON CareTeamMembers.tKeyId = Provider.ProviderID

         END
      ELSE
         BEGIN

               INSERT INTO
                   @t_MessageToUserId
                   (
                     UserId
                   )
                   SELECT DISTINCT
                       ctm.ProviderID
                   FROM
                       PatientCareTeam pct
                   INNER JOIN CareTeamMembers ctm
                       ON pct.CareTeamID = ctm.CareTeamId
                   WHERE
                       PatientID = @i_PatientUserId

         END  

--	  Internal message sent to the user
      EXEC usp_UserMessage_And_Attachments_Insert 
      @i_AppUserId = @i_AppUserId , 
      @vc_SubjectText = @v_SubjectText , 
      @vc_MessageText = @v_CommunicationText , 
      @i_UserId = @i_AppUserId , 
      @i_PatientUserId = @i_PatientUserId , 
      @t_Attachment = @t_Attachment , 
      @t_MessageToUserId = @t_MessageToUserId , 
      @i_UserMessageId = @i_UserMessageId OUT
      
END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserMessage_SendToAllCareTeamMembers] TO [FE_rohit.r-ext]
    AS [dbo];

