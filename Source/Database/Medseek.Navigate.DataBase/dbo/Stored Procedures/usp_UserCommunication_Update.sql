
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserCommunication_Update    
Description   : This procedure is used to Update records in UserCommunication table
Created By    : Aditya    
Created Date  : 06-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
15-July-10 NagaBabu Included CommunicationState perameter in Update statement 
22-Jul-10 Pramod Included condition for internal message when message state              
			in ('Printed','Called','Sent')
9-Nov-10 Pramod Corrected to get values for template into comm text and subject
24-Jan-2012 NagaBabu Added else statement for defining @vc_TemplateCommunicationText 
19-mar-2013 P.V.P.Mohan Modified UserCommunication to PatientCommunication.
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UserCommunication_Update] (
	@i_AppUserId KeyID
	,@i_UserId KeyID
	,@dt_DateDue UserDate
	,@dt_DateScheduled UserDate
	,@dt_DateSent UserDate
	,@i_CommunicationCohortId KeyID
	,@i_CommunicationTypeId KeyID
	,@i_CommunicationTemplateId KeyID
	,@vc_StatusCode StatusCode
	,@i_SentByUserID KeyID = NULL
	,@vc_CommunicationText NVARCHAR(max) = NULL
	,@vc_IsSentIndicator IsIndicator
	,@vc_SubjectText VARCHAR(200) = NULL
	,@vc_SenderEmailAddress VARCHAR(256) = NULL
	,@i_UserMessageId KeyID = NULL
	,@i_CommunicationId KeyID = NULL
	,@i_dbmailReferenceId INT
	,@vc_eMailDeliveryState VARCHAR(20)
	,@i_UserCommunicationId KeyID
	,@vc_CommunicationState VARCHAR(20) = NULL
	,@i_ProgramID INT = NULL
	,@i_AssignedCareProviderID KeyID = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsUpdated INT
		,@t_MessageToUserId UserIdTblType
		,@i_ReturnUserMessageId KeyID
		,@t_Attachment AttachmentTbl

	-- Check if valid Application User ID is passed    
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	-- INCLUDE INTERNAL MESSAGE CREATION STEP WHEN @vc_CommunicationState in ('Printed','Called','Sent')
	IF @vc_CommunicationState IN (
			'Printed'
			,'Called'
			,'Sent'
			)
	BEGIN
		-- Steps for sending internal messages
		INSERT INTO @t_MessageToUserId (UserId)
		VALUES (@i_UserID)

		-- Internal message sent to the user
		EXEC usp_UserMessage_And_Attachments_Insert @i_AppUserId = @i_AppUserId
			,@vc_SubjectText = @vc_SubjectText
			,@vc_MessageText = @vc_CommunicationText
			,@i_UserId = @i_SentByUserID
			,@t_Attachment = @t_Attachment
			,@t_MessageToUserId = @t_MessageToUserId
			,@i_UserMessageId = @i_ReturnUserMessageId OUT
	END

	DECLARE @vc_TemplateCommunicationText NVARCHAR(MAX) = NULL
		,@vc_TemplateSubjectText VARCHAR(200) = NULL
		,@vc_EmailIdPrimary EmailId
		,@vc_NotifySubjectText VARCHAR(200)
		,@vc_NotifyCommunicationText NVARCHAR(MAX)

	IF @vc_CommunicationText IS NULL
		OR @vc_CommunicationText = ''
	BEGIN
		EXEC usp_Communication_MessageContent @i_AppUserId = @i_AppUserId
			,@i_CommunicationTemplateId = @i_CommunicationTemplateId
			,@i_UserID = @i_UserID
			,@v_EmailIdPrimary = @vc_EmailIdPrimary OUT
			,@v_SubjectText = @vc_TemplateSubjectText OUT
			,@v_CommunicationText = @vc_TemplateCommunicationText OUT
			,@v_NotifySubjectText = @vc_NotifySubjectText OUT
			,@v_NotifyCommunicationText = @vc_NotifyCommunicationText OUT
	END
	ELSE
	BEGIN
		SET @vc_TemplateCommunicationText = @vc_CommunicationText
	END

	UPDATE PatientCommunication
	SET PatientId = @i_UserId
		,DateDue = @dt_DateDue
		,DateScheduled = @dt_DateScheduled
		,DateSent = @dt_DateSent
		,CommunicationCohortId = @i_CommunicationCohortId
		,CommunicationTypeId = @i_CommunicationTypeId
		,CommunicationTemplateId = @i_CommunicationTemplateId
		,StatusCode = @vc_StatusCode
		,SentByUserID = @i_SentByUserID
		,CommunicationText = @vc_TemplateCommunicationText
		,IsSentIndicator = @vc_IsSentIndicator
		,SubjectText = @vc_TemplateSubjectText
		,SenderEmailAddress = @vc_SenderEmailAddress
		,UserMessageId = ISNULL(@i_ReturnUserMessageId, @i_UserMessageId)
		,CommunicationId = @i_CommunicationId
		,dbmailReferenceId = @i_dbmailReferenceId
		,eMailDeliveryState = @vc_eMailDeliveryState
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
		,CommunicationState = @vc_CommunicationState
		,ProgramID = @i_ProgramID
		,AssignedCareProviderID = @i_AssignedCareProviderID
	WHERE PatientCommunicationId = @i_UserCommunicationId

	SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT

	IF @l_numberOfRecordsUpdated <> 1
	BEGIN
		RAISERROR (
				N'Invalid Row count %d passed to update UserCommunication'
				,17
				,1
				,@l_numberOfRecordsUpdated
				)
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
    ON OBJECT::[dbo].[usp_UserCommunication_Update] TO [FE_rohit.r-ext]
    AS [dbo];

