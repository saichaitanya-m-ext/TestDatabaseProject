
/*
---------------------------------------------------------------------------------
Procedure Name: [usp_Communication_UserCommunication_Insert]
Description	  : This procedure is used to insert the Communication and UserCommunication
Created By    :	NagaBabu
Created Date  : 28-Feb-2012
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_communication_usercommunication_insert] (
	@i_AppUserId KEYID
	,@o_CommunicationId KEYID OUT
	,@i_CommunicationTemplateId KEYID
	,@v_SenderEmailAddress VARCHAR(256)
	,@b_IsDraft ISINDICATOR
	,@d_SubmittedDate USERDATE
	,@v_ApprovalState VARCHAR(30)
	,@d_ApprovalDate USERDATE
	,@v_StatusCode STATUSCODE
	,@t_UserIdlist TTYPEKEYID READONLY
	,@i_CommunicationTypeID KEYID
	,@v_SubjectText NVARCHAR(MAX)
	,@vc_CommunicationText NVARCHAR(MAX) = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT

	-- Check if valid Application User ID is passed
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed to insert Communication'
				,17
				,1
				,@i_AppUserId
				)
	END

	DECLARE @l_TranStarted BIT = 0

	IF (@@TRANCOUNT = 0)
	BEGIN
		BEGIN TRANSACTION

		SET @l_TranStarted = 1 -- Indicator for start of transactions
	END
	ELSE
	BEGIN
		SET @l_TranStarted = 0
	END

	------------ Insert operation takes place here---------------
	INSERT INTO Communication (
		CommunicationTemplateId
		,SenderEmailAddress
		,IsDraft
		,SubmittedDate
		,ApprovalState
		,ApprovalDate
		,CreatedByUserId
		,StatusCode
		,CommunicationTypeId
		)
	VALUES (
		@i_CommunicationTemplateId
		,@v_SenderEmailAddress
		,@b_IsDraft
		,@d_SubmittedDate
		,@v_ApprovalState
		,@d_ApprovalDate
		,@i_AppUserId
		,@v_StatusCode
		,@i_CommunicationTypeID
		)

	SET @l_numberOfRecordsInserted = @@ROWCOUNT
	SET @o_CommunicationId = SCOPE_IDENTITY()

	DECLARE @i_UserID INT
		,@v_EmailIdPrimary VARCHAR(150)
		,@v_NotifyCommunicationText VARCHAR(MAX)
		,@v_Derived_ApprovalState VARCHAR(150)
		,@v_CommunicationTypeName VARCHAR(50)
		,@i_dbmailReferenceId INT
		,@o_UserCommunicationId INT

	SELECT @v_CommunicationTypeName = CommunicationType
	FROM CommunicationType
	WHERE CommunicationTypeId = @i_CommunicationTypeID

	DECLARE curMassUsers CURSOR
	FOR
	SELECT t.tkeyid
		,u.PrimaryEmailAddress
	FROM @t_UserIdlist t
	INNER JOIN Patient u ON t.tkeyId = u.Patientid

	OPEN curMassUsers

	FETCH NEXT
	FROM curMassUsers
	INTO @i_UserID
		,@v_EmailIdPrimary

	WHILE @@FETCH_STATUS = 0
	BEGIN -- Begin for cursor curMoneyPlanDetails
		EXEC usp_Communication_MessageContent @i_AppUserId = @i_AppUserId
			,@i_CommunicationTemplateId = @i_CommunicationTemplateId
			,@i_UserID = @i_UserID
			,@v_EmailIdPrimary = @v_EmailIdPrimary OUT
			,@v_SubjectText = @v_SubjectText OUT
			,@v_CommunicationText = @vc_CommunicationText OUT
			,@v_NotifySubjectText = @v_SubjectText OUT
			,@v_NotifyCommunicationText = @v_NotifyCommunicationText OUT

		SET @v_Derived_ApprovalState = CASE 
				WHEN @v_CommunicationTypeName IN (
						'SMS'
						,'Email'
						,'Fax'
						)
					THEN 'Sent'
				WHEN @v_CommunicationTypeName IN (
						'Phone'
						,'IVR'
						)
					THEN 'Called'
				WHEN @v_CommunicationTypeName = 'Letter'
					THEN 'Ready to Print'
				ELSE ''
				END

		-- External Email sent via database mail otherwise there is no need
		IF @v_CommunicationTypeName IN (
				'SMS'
				,'Email'
				,'Fax'
				,'Phone'
				,'IVR'
				)
		BEGIN
			IF ISNULL(@v_EmailIdPrimary, '') <> ''
				AND ISNULL(@vc_CommunicationText, '') <> ''
			BEGIN --ISNULL(@v_NotifyCommunicationText,'') <> ''
				EXEC msdb.dbo.sp_send_dbmail @profile_name = 'CCM'
					,
					--@from_address = @v_SenderEmailAddress,
					@recipients = @v_EmailIdPrimary
					,@body = @vc_CommunicationText
					,
					--@v_NotifyCommunicationText, 
					@subject = @v_SubjectText
					,@body_format = 'HTML'
					,@mailitem_id = @i_dbmailReferenceId OUTPUT
			END
					--UPDATE Communication
					--SET CommunicationSentDate = GETDATE(),
					-- ApprovalState = @v_Derived_ApprovalState
					-- WHERE CommunicationId = @o_CommunicationId
		END

		INSERT INTO PatientCommunication (
			PatientId
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
		VALUES (
			@i_UserID
			,NULL
			,@i_AppUserId
			,@i_CommunicationTypeId
			,@vc_CommunicationText
			,1
			,@v_SubjectText
			,@v_SenderEmailAddress
			,@i_AppUserId
			,NULL
			,GETDATE()
			,@o_CommunicationId
			,@i_dbmailReferenceId
			,@v_Derived_ApprovalState
			,@i_CommunicationTemplateId
			)

		SET @o_UserCommunicationId = SCOPE_IDENTITY()

		IF @v_CommunicationTypeName = 'IVR'
		BEGIN
			DECLARE @o_CommunicationIVRCallStatusId KEYID

			INSERT INTO CommunicationIVRPhoneCallStatus (
				PatientCommunicationId
				,PhoneNumber
				,PatientName
				,PatientInformation
				,ProviderName
				,AppointmentDate
				,CallStatus
				,CreatedByUserId
				)
			SELECT @o_UserCommunicationId
				,Users.PrimaryPhoneNumber
				,COALESCE(ISNULL(Users.LastName, '') + ', ' + ISNULL(Users.FirstName, '') + '. ' + ISNULL(Users.MiddleName, '') + ' ' + ISNULL(Users.NameSuffix, ''), '')
				,REPLACE(@vc_CommunicationText, '<BR />', '')
				--,ISNULL(( SELECT TOP 1
				--              COALESCE(ISNULL(Users.LastName , '') + ', ' + ISNULL(Users.FirstName , '') + '. ' + ISNULL(Users.MiddleName , '') + ' ' + ISNULL(Users.UserNameSuffix , '') , '')
				--          FROM
				--              Users
				--          INNER JOIN UserProviders
				--              ON Users.UserId = UserProviders.ProviderUserId
				--                 AND Users.IsProvider = 1
				--                 AND UserProviders.PatientUserId = @i_UserID ) , 'David Philip') AS ProviderName'' AS ProviderName
				,'David Philip' AS ProviderName
				,CONVERT(VARCHAR, GETDATE() + 1, 101)
				,NULL
				,@i_AppUserId
			FROM Patients Users
			WHERE PatientID = @i_UserID
				AND Users.PrimaryPhoneNumber IS NOT NULL
				AND Users.PrimaryPhoneNumber <> ''

			SET @o_CommunicationIVRCallStatusId = SCOPE_IDENTITY()
		END

		SET @v_SubjectText = ''
		SET @vc_CommunicationText = ''
		SET @v_SubjectText = ''
		SET @v_NotifyCommunicationText = ''

		FETCH NEXT
		FROM curMassUsers
		INTO @i_UserID
			,@v_EmailIdPrimary
	END

	CLOSE curMassUsers

	DEALLOCATE curMassUsers

	IF (@l_TranStarted = 1) -- If transactions are there, then commit
	BEGIN
		SET @l_TranStarted = 0

		COMMIT TRANSACTION
	END

	RETURN 0
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_communication_usercommunication_insert] TO [FE_rohit.r-ext]
    AS [dbo];

