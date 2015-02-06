
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserCommunication_Insert    
Description   : This procedure is used to insert record into UserCommunication table
Created By    : NagaBabu   
Created Date  : 24-Feb-2010    
-----------------------------------------------------------------------------------------
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
23-Jun-10 Pramod Included template specific content and subject
24-Jun-10 Pramod Made call to usp_Communication_MessageContent to get message text detail
15-July-10 NagaBabu Added CommunicationState as perameter in Select statement
10-Nov-10 Pramod Included insert code for attachment
03-feb-2011 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  UserCommunication table 
22-Oct-2012 Rathnam added ProgramID parameter for the enrollment tasks to the particular assignment 
19-Mar-2013 P.V.P.Mohan Modified table UserCommunication to PatientCommunication and UserId to PatientID
------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_UserCommunication_Insert] (
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
	,@vc_CommunicationText NVARCHAR(MAX) = NULL
	,@vc_IsSentIndicator IsIndicator = NULL
	,@vc_SubjectText VARCHAR(200) = NULL
	,@vc_SenderEmailAddress VARCHAR(256) = NULL
	,@i_UserMessageId KeyID = NULL
	,@i_CommunicationId KeyID = NULL
	,@i_dbmailReferenceId INT = NULL
	,@vc_eMailDeliveryState VARCHAR(20) = NULL
	,@vc_CommunicationState VARCHAR(20) = NULL
	,@o_UserCommunicationId KeyID OUTPUT
	,@b_IsAdhoc BIT = 0
	,@i_ProgramID KEYID = NULL
	,@b_IsEnrollment BIT = 0
	,@i_AssignedCareProviderID KeyID = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT
		,@vc_TemplateCommunicationText NVARCHAR(MAX) = NULL
		,@vc_TemplateSubjectText VARCHAR(200) = NULL
		,@vc_EmailIdPrimary EmailId
		,@vc_NotifySubjectText VARCHAR(200)
		,@vc_NotifyCommunicationText NVARCHAR(MAX)

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

	IF @vc_CommunicationText IS NULL
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

	INSERT INTO PatientCommunication (
		PatientId
		,CommunicationCohortId
		,CommunicationTypeId
		,CommunicationTemplateId
		,DateScheduled
		,DateSent
		,DateDue
		,StatusCode
		,SentByUserID
		,CommunicationText
		,IsSentIndicator
		,SubjectText
		,SenderEmailAddress
		,UserMessageId
		,CommunicationId
		,dbmailReferenceId
		,eMailDeliveryState
		,CreatedByUserId
		,CommunicationState
		,IsAdhoc
		,ProgramID
		,IsEnrollment
		,AssignedCareProviderID
		)
	VALUES (
		@i_UserId
		,@i_CommunicationCohortId
		,@i_CommunicationTypeId
		,@i_CommunicationTemplateId
		,@dt_DateScheduled
		,@dt_DateSent
		,@dt_DateDue
		,@vc_StatusCode
		,@i_SentByUserID
		,@vc_TemplateCommunicationText
		,@vc_IsSentIndicator
		,@vc_TemplateSubjectText
		,@vc_SenderEmailAddress
		,@i_UserMessageId
		,@i_CommunicationId
		,@I_dbmailReferenceId
		,@vc_eMailDeliveryState
		,@i_AppUserId
		,@vc_CommunicationState
		,@b_IsAdhoc
		,@i_ProgramID
		,@b_IsEnrollment
		,@i_AssignedCareProviderID
		)

	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		,@o_UserCommunicationId = SCOPE_IDENTITY()

	IF @l_numberOfRecordsInserted <> 1
	BEGIN
		RAISERROR (
				N'Invalid row count %d in insert into UserCommunication'
				,17
				,1
				,@l_numberOfRecordsInserted
				)
	END

	IF @b_IsEnrollment = 0
	BEGIN
		INSERT INTO PatientCommunicationAttachment (
			LibraryId
			,PatientCommunicationID
			,CreatedByUserId
			)
		SELECT CommunicationTemplateAttachments.LibraryId
			,@o_UserCommunicationId
			,@i_AppUserId
		FROM CommunicationTemplate WITH (NOLOCK)
		INNER JOIN CommunicationTemplateAttachments WITH (NOLOCK) ON CommunicationTemplate.CommunicationTemplateId = CommunicationTemplateAttachments.CommunicationTemplateId
			AND CommunicationTemplate.StatusCode = 'A'
		WHERE CommunicationTemplate.CommunicationTemplateId = @i_CommunicationTemplateId
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
    ON OBJECT::[dbo].[usp_UserCommunication_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

