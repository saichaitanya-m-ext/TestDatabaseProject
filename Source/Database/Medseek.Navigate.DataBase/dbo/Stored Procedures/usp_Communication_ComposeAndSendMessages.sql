/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Communication_ComposeAndSendMessages]
Description	  : This procedure is to be used to ->
				Create and send External messages using dbmail
				Create and send the Internal message usng internal messaging				
Created By    :	Pramod
Created Date  : 14-May-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
17-May-10 Pramod Include insert into UserCommunication and update of communication.sentdate
26-May-10 Pramod Attachment is removed from external mail, External mail is going to have
				 messages from notification template and different from internal messages
				 Included condition for CommunicationType = 'Email' for sending DB mail
30-Jun-10 Pramod Included parameter @i_Param_CommunicationId to initiate communication
				 for specific ID only
19-Aug-10 Pramod Major logic change with communication type
24-Aug-10 Pramod included @i_CommunicationTemplateId into the insert
17-Oct-10 Pramod Fixed problem with usercommunication insert as it should insert multiple records
20-Oct-10 Pramod Corrected issue with usercommunication insert. Added condition for not null emailid
15-Dec-10 Pramod Since communicationtypeid is now included in communication table, the cursor query
				 no more needs a join with CommunicationTemplate table
07-Oct-10 Rathnam added to dbmail stored procedrue ISNULL(@v_NotifyCommunicationText,'') <> ''	
17-NOV-10 Rathnam commented the -@from_address = @v_SenderEmailAddress while sending the dbmail
23-N0v-2011 NagaBabu Added insert script into CommunicationIVRPhoneCallStatus table as conditioned based
17-Jan-2012 NagaBabu Added Conditions for IVR Communicationtype	
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers	
19-Nov-2012 P.V.P.Mohan Added another join Statement and placed Patient table in place of Users table and NameSuffix in 
			place of UserNameSuffix and PatientProvider in place of UserProvider	 
----------------------------------------------------------------------------------------
*/  
CREATE PROCEDURE [dbo].[usp_Communication_ComposeAndSendMessages]--64,null,461
(
	@i_AppUserId KEYID,
	@d_Date DATETIME = NULL,
	@i_Param_CommunicationId KeyID = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON
	  DECLARE 
		@v_profile_name VARCHAR(24) = 'CCM',
		@i_CommunicationTemplateId KEYID,
		@v_SenderEmailAddress EmailId,
		@i_UserID KEYID,
		@i_PopulationDefinitionID KeyID,
		@i_CommunicationId KeyID,
		@v_EmailIdPrimary EmailId,
		@v_SubjectText VARCHAR(200), 
		@v_CommunicationText NVARCHAR(MAX),
		@v_NotifySubjectText VARCHAR(200), 
		@v_NotifyCommunicationText NVARCHAR(MAX),
		@t_Attachment AttachmentTbl,
		@t_MessageToUserId UserIdTblType,
		@i_CommunicationTypeId KeyID,
		@i_UserMessageId KeyID,
		@i_dbmailReferenceId INT,
		@i_CommunicationCohortId KeyID,
		@v_CommunicationTypeName SourceName

	-- Check if valid Application User ID is passed

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
      BEGIN
           RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
      END

	  DECLARE @v_Derived_ApprovalState VARCHAR(30),
			  @o_UserCommunicationId KeyID
  DECLARE @V VARCHAR(500)
	  DECLARE
	     curMassUsers CURSOR
	     FOR SELECT Communication.CommunicationId,
					Communication.CommunicationTemplateId,
					Communication.SenderEmailAddress,
					CommunicationCohorts.CommunicationCohortId,
					CommunicationCohorts.UserId,
					CommunicationCohorts.PopulationDefinitionID,
					Communication.CommunicationTypeId,
					(SELECT CommunicationType FROM CommunicationType 
					  WHERE CommunicationType.CommunicationTypeId = Communication.CommunicationTypeId
					)
					AS CommunicationTypeName
	           FROM Communication
				     INNER JOIN CommunicationCohorts
				       ON Communication.CommunicationId = CommunicationCohorts.CommunicationId
				     --INNER JOIN CommunicationTemplate
				     --  ON CommunicationTemplate.CommunicationTemplateId = Communication.CommunicationTemplateId
			  WHERE ( CONVERT(VARCHAR(10), Communication.SubmittedDate, 121) = CONVERT(VARCHAR(10), @d_Date, 121)
					  OR @d_Date IS NULL
					)
			    AND ( Communication.CommunicationId = @i_Param_CommunicationId 
					  OR @i_Param_CommunicationId IS NULL 
					)
				--AND Communication.ApprovalState IN ( 'Ready To Send', 'Ready to Print', 'Ready To Call')

	  OPEN curMassUsers
	  FETCH NEXT FROM curMassUsers 
		INTO @i_CommunicationId,
			 @i_CommunicationTemplateId,
			 @v_SenderEmailAddress,
			 @i_CommunicationCohortId,
			 @i_UserId,
			 @i_PopulationDefinitionID,
			 @i_CommunicationTypeId,
			 @v_CommunicationTypeName

	  WHILE @@FETCH_STATUS = 0
	  BEGIN  -- Begin for cursor curMoneyPlanDetails
		  
		 EXEC usp_Communication_MessageContent
			@i_AppUserId = @i_AppUserId,
			@i_CommunicationTemplateId = @i_CommunicationTemplateId,
			@i_UserID = @i_UserID,
			@v_EmailIdPrimary = @v_EmailIdPrimary OUT,
			@v_SubjectText = @v_SubjectText OUT, 
			@v_CommunicationText = @v_CommunicationText OUT,
			@v_NotifySubjectText = @v_NotifySubjectText OUT,
			@v_NotifyCommunicationText = @v_NotifyCommunicationText OUT
      
		SET @v_Derived_ApprovalState 
			= CASE WHEN @v_CommunicationTypeName IN ( 'SMS', 'Email', 'Fax' ) THEN 'Sent'
				   WHEN @v_CommunicationTypeName IN ('Phone','IVR') THEN 'Called'
				   WHEN @v_CommunicationTypeName = 'Letter' THEN 'Ready to Print'
				   ELSE ''
			  END
		 -- External Email sent via database mail otherwise there is no need
		IF @v_CommunicationTypeName IN ( 'SMS', 'Email', 'Fax', 'Phone','IVR' )
		BEGIN
			 -- Steps for sending internal messages
			 INSERT INTO @t_MessageToUserId (UserId)
			 VALUES (@i_UserID)
--SELECT @i_AppUserId, @v_SubjectText,@v_CommunicationText,@i_UserID,@i_UserID
			 -- Internal message sent to the user
			 
			 EXEC usp_UserMessage_And_Attachments_Insert
				@i_AppUserId = @i_AppUserId,
				@vc_SubjectText	= @v_SubjectText,
				@vc_MessageText	= @v_CommunicationText,
				@i_UserId = @i_AppUserId,
				@i_PatientUserId = @i_UserID,
				@t_Attachment = @t_Attachment,
				@t_MessageToUserId = @t_MessageToUserId,
				@i_UserMessageId = @i_UserMessageId OUT
				

			
			 DELETE FROM @t_MessageToUserId
			 DELETE FROM @t_Attachment
--select @v_EmailIdPrimary, @i_UserID
			 IF ISNULL( @v_EmailIdPrimary,'') <> '' AND ISNULL(@v_CommunicationText,'') <> '' --ISNULL(@v_NotifyCommunicationText,'') <> ''
			 
				
				EXEC msdb.dbo.sp_send_dbmail 
					@profile_name = @v_profile_name, 
					--@from_address = @v_SenderEmailAddress,
					@recipients = @v_EmailIdPrimary, 
					@body = @v_CommunicationText,--@v_NotifyCommunicationText, 
					@subject = @v_NotifySubjectText,
					@body_format = 'HTML',
					@mailitem_id = @i_dbmailReferenceId OUTPUT
			 
			  
			  
				
		END
			  
		INSERT INTO PatientCommunication
			   (PatientId
			   ,CommunicationCohortId
			   ,SentByUserID
			   ,CommunicationTypeId
			   ,CommunicationText
			   ,IsSentIndicator
			   ,SubjectText
			   ,SenderEmailAddress
			   ,CreatedByUserId
			   ,UserMessageId
			   ,DateSent
			   ,CommunicationId
			   ,dbmailReferenceId
			   ,CommunicationState
			   ,CommunicationTemplateId
			   )
		 VALUES
			 (
			   @i_UserID
			   ,@i_CommunicationCohortId
			   ,@i_AppUserId
			   ,@i_CommunicationTypeId
			   ,@v_CommunicationText
			   ,1
			   ,@v_SubjectText
			   ,@v_SenderEmailAddress
			   ,@i_AppUserId
			   ,@i_UserMessageId
			   ,GETDATE()
			   ,@i_CommunicationId
			   ,@i_dbmailReferenceId
			   ,@v_Derived_ApprovalState
			   ,@i_CommunicationTemplateId
			 )
			 SET @o_UserCommunicationId = SCOPE_IDENTITY()
	 
			 
			 IF @i_CommunicationTypeId = (SELECT CommunicationTypeId 
										  FROM CommunicationType
										  WHERE CommunicationType = 'IVR')
				BEGIN
					DECLARE @o_CommunicationIVRCallStatusId KeyId 
					INSERT INTO CommunicationIVRPhoneCallStatus 
					(
						PatientCommunicationId ,
						PhoneNumber ,
						PatientName ,
						PatientInformation ,
						ProviderName ,
						AppointmentDate ,
						CallStatus ,
						CreatedByUserId	
					)
					SELECT
						@o_UserCommunicationId ,
						Patient.PrimaryPhoneNumber PhoneNumberPrimary ,
						COALESCE(ISNULL(Patient.LastName , '') + ', '     
						   + ISNULL(Patient.FirstName , '') + '. '     
						   + ISNULL(Patient.MiddleName , '') + ' '  
						   + ISNULL(Patient.NameSuffix ,'')    
							,'')   ,
						REPLACE(@v_CommunicationText,'<BR />','') ,
						ISNULL((SELECT TOP 1 COALESCE(ISNULL(Patient.LastName , '') + ', '     
									   + ISNULL(Patient.FirstName , '') + '. '     
									   + ISNULL(Patient.MiddleName , '') + ' '  
									   + ISNULL(Patient.NameSuffix  ,'')    
										,'')
						 FROM
							 Patient 
						 INNER JOIN Users
							 ON Users.UserId = Patient.UserId 	
						 INNER JOIN PatientProvider
							 ON Patient.PatientID = PatientProvider.PatientID 	 
							 AND Users.IsProvider = 1
							 AND PatientProvider.PatientProviderID = @i_UserID
						),'David Philip') AS ProviderName ,
						CONVERT(VARCHAR,GETDATE() + 1,101) ,
						NULL ,
						@i_AppUserId
					FROM 
						Patient
					WHERE PatientID = @i_UserID 
						AND Patient.PrimaryPhoneNumber IS NOT NULL 
						AND Patient.PrimaryPhoneNumber <> ''
					SET @o_CommunicationIVRCallStatusId = SCOPE_IDENTITY()
					 	
				END

			 INSERT INTO PatientCommunicationAttachment (PatientCommunicationID, LibraryId,CreatedByUserId)
			 SELECT @o_UserCommunicationId, LibraryId , @i_AppUserId
			   FROM CommunicationTemplateAttachments
			  WHERE CommunicationTemplateAttachments.CommunicationTemplateId = @i_CommunicationTemplateId
			  
			  UPDATE Communication
				 SET CommunicationSentDate = GETDATE(),
					 ApprovalState = @v_Derived_ApprovalState
			   WHERE CommunicationId = @i_CommunicationId

			  SET @v_SubjectText = ''
			  SET @v_CommunicationText = ''
			  SET @i_UserMessageId = NULL
			  SET @v_NotifySubjectText = ''
			  SET @v_NotifyCommunicationText = ''

		  FETCH NEXT FROM curMassUsers 
		    INTO @i_CommunicationId,
				 @i_CommunicationTemplateId,
				 @v_SenderEmailAddress,
				 @i_CommunicationCohortId,
				 @i_UserId,
				 @i_PopulationDefinitionID,
				 @i_CommunicationTypeId,
				 @v_CommunicationTypeName
	  END
	  CLOSE curMassUsers
	  DEALLOCATE curMassUsers
	  
				

END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_ComposeAndSendMessages] TO [FE_rohit.r-ext]
    AS [dbo];

