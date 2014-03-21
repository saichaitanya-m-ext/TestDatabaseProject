/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Communication_ContentDetail]
Description	  : This procedure is to be used get detail related to communication 
Created By    :	Pramod
Created Date  : 22-Jun-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
21-Jul-10 Pramod Changed @i_CommunicationId to table type @t_CommunicationId and included
		parameter @b_PrintIndividualLetter for deciding whether to print individual letter or not
19-Aug-10 Pramod Major change in CreatePDF logic
20-Aug-10 Pramod Included the for update, internal message entry
24-Aug-10 Pramod For attachmentextension set '' and included begin trans
25-Aug-10 Pramod Included update communication to Printed
11-Nov-10 Pramod Corrected the Cursor to include join for getting individual letters also
05-Dec-11 Rathnam Created temp tables #tblUserCommunication,#t_Param_CommunicationId 
                  and commented the CommunicationText, subject text columns from the cursor select
                  statement for improving the performance
03-APR-2013 Mohan Modified UserCommunication to PatientCommunication Tables  UserMessageRecipients columns.    
----------------------------------------------------------------------------------------
*/
--DECLARE @t_Param_CommunicationId AS ttypeKeyID
--EXEC [usp_Communication_ContentDetail] @i_AppUserId = 2,@t_Param_CommunicationId= @t_Param_CommunicationId,@b_PrintIndividualLetter = 0
CREATE PROCEDURE [dbo].[usp_Communication_ContentDetail]
(
	@i_AppUserId KEYID,
	@t_Param_CommunicationId ttypeKeyID READONLY,
	@b_PrintIndividualLetter BIT
)
AS
BEGIN TRY
      SET NOCOUNT ON
	-- Check if valid Application User ID is passed

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
      BEGIN
           RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
      END

	  DECLARE 
		@i_CommunicationId KeyId,
		@i_UserCommunicationId KeyId,
		@i_UserId KeyId,
		@nv_CommunicationText NVARCHAR(MAX),
		@v_SubjectText VARCHAR(200),
		@i_UserMessageId KeyID
		
	  CREATE TABLE
	    #tblUserMessageDetail 
	    ( UserCommunicationId INT,
		  CommmunicationId INT,
		  UserId INT ,
		  SentByUserID INT,
		  SubjectText VARCHAR(200), 
		  CommunicationText NVARCHAR(MAX)
		)

	  DECLARE
		@t_MessageToUserId UserIdTblType,
		@t_Attachment AttachmentTbl

      DECLARE @l_TranStarted BIT = 0
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @l_TranStarted = 1  -- Indicator for start of transactions  
         END
      ELSE
         SET @l_TranStarted = 0

	  DECLARE @i_CommunicationTypeId INT

	  SET @i_CommunicationTypeId 
			= (SELECT CommunicationTypeId
				 FROM CommunicationType 
				WHERE CommunicationType = 'Letter'
			   )         
	  --DECLARE
	  --   curMassUsers CURSOR
	  --   FOR SELECT UserCommunication.CommunicationId,
			--		UserCommunication.UserCommunicationId,
			--		UserCommunication.UserId,
			--		UserCommunication.CommunicationText,
			--		UserCommunication.SubjectText
	  --         FROM UserCommunication
			--		 INNER JOIN @t_Param_CommunicationId ParamCommunication
			--		    ON ParamCommunication.tKeyId = UserCommunication.CommunicationId
			--  WHERE UserCommunication.StatusCode = 'A'
			--    AND UserCommunication.CommunicationState = 'Ready to Print'
			--    AND (  ( @b_PrintIndividualLetter = 1 )
			--			OR ( @b_PrintIndividualLetter = 0
			--				 AND UserCommunication.CommunicationId IS NOT NULL
			--				)
			--		)
			--FOR UPDATE

	  CREATE TABLE #tblUserCommunication
	  (
		CommunicationId INT, 
		UserCommunicationId INT,
		UserId INT
		--CommunicationText NVARCHAR(MAX),
		--SubjectText VARCHAR(200)
	  )
	  
	  CREATE TABLE #t_Param_CommunicationId
	  (
	  CommunicationID INT
	  )
	  
	  INSERT #t_Param_CommunicationId
	  SELECT tKeyId FROM @t_Param_CommunicationId
	  
	  INSERT INTO #tblUserCommunication
			  (
				CommunicationId,
				UserCommunicationId,
				UserId
				--CommunicationText,
				--SubjectText
			  )
			 SELECT PatientCommunication.CommunicationId,
					PatientCommunication.PatientCommunicationId UserCommunicationId,
					PatientCommunication.PatientId UserId
					--UserCommunication.CommunicationText,
					--UserCommunication.SubjectText
			   FROM PatientCommunication
					 INNER JOIN #t_Param_CommunicationId ParamCommunication
						ON ParamCommunication.CommunicationID = PatientCommunication.CommunicationId
			  WHERE PatientCommunication.StatusCode = 'A'
				AND PatientCommunication.CommunicationTypeId = @i_CommunicationTypeId
				AND PatientCommunication.CommunicationState = 'Ready to Print'
			  UNION
			 SELECT PatientCommunication.CommunicationId,
					PatientCommunication.PatientCommunicationId UserCommunicationId,
					PatientCommunication.PatientId UserId
					--UserCommunication.CommunicationText,
					--UserCommunication.SubjectText
			   FROM PatientCommunication
			  WHERE @b_PrintIndividualLetter = 1
				AND PatientCommunication.CommunicationId IS NULL
				AND PatientCommunication.CommunicationState = 'Ready to Print'
				AND PatientCommunication.StatusCode = 'A'
				AND PatientCommunication.CommunicationTypeId = @i_CommunicationTypeId
				AND EXISTS 
					( SELECT 1
						FROM #t_Param_CommunicationId ParamCommunication
							 INNER JOIN PatientCommunication UCM
								ON UCM.CommunicationId = ParamCommunication.CommunicationID
								AND UCM.PatientId = PatientCommunication.PatientId
					   WHERE UCM.CommunicationState = 'Ready to Print'
					)

	  DECLARE
		 curMassUsers CURSOR FOR
			 SELECT 
				CommunicationId,
				UserCommunicationId,
				UserId
				--CommunicationText,
				--SubjectText
			 FROM #tblUserCommunication	
			--FOR UPDATE
	  
	  OPEN curMassUsers
	  FETCH NEXT FROM curMassUsers 
		INTO @i_CommunicationId,
			 @i_UserCommunicationId,
			 @i_UserId
			 --@nv_CommunicationText,
			 --@v_SubjectText

	  WHILE @@FETCH_STATUS = 0
	  BEGIN
		  SELECT @nv_CommunicationText = CommunicationText, @v_SubjectText = SubjectText 
		  FROM 
			  PatientCommunication WITH (NOLOCK) 
		  WHERE 
		      PatientCommunicationId = @i_UserCommunicationId
	  
		 -- Steps for sending internal messages NEED TO BE INCLUDED HERE
		 INSERT INTO UserMessages    
			 (     
				SubjectText,    
				MessageText,    
				ProviderID,    
				isDraft,    
				MessageState,    
				PatientId,    
				CreatedByUserId    
			 )    
		  VALUES    
			 (     
				@v_SubjectText,
				@nv_CommunicationText,
				@i_AppUserId,
				0,
				'S',
				@i_UserId,
				@i_AppUserId    
			 )
		  SET @i_UserMessageId = SCOPE_IDENTITY()
		  INSERT INTO UserMessageRecipients    
				(     
				   UserMessageID,    
				   PatientID,    
				   MessageState,    
				   CreatedByUserId    
				) 
			VALUES 
				(  @i_UserMessageId,
				   @i_UserId,
				   'N',
				   @i_AppUserId
				)

		   INSERT INTO UserMessageAttachments
		    ( UserMessageId, LibraryId, CreatedByUserId)
		   SELECT @i_UserMessageId, CommunicationTemplateAttachments.LibraryId, @i_AppUserId
		     FROM Communication
				  INNER JOIN CommunicationTemplate
					 ON CommunicationTemplate.CommunicationTemplateId = Communication.CommunicationTemplateId
				  INNER JOIN CommunicationTemplateAttachments
					 ON CommunicationTemplateAttachments.CommunicationTemplateId = CommunicationTemplate.CommunicationTemplateId 
			 WHERE Communication.CommunicationId = @i_CommunicationId

		  UPDATE PatientCommunication
			 SET CommunicationState = 'Printed',
				 UserMessageId = @i_UserMessageId,
				 LastModifiedByUserId = @i_AppUserId,
				 LastModifiedDate = GETDATE()
		   WHERE PatientCommunicationId = @i_UserCommunicationId
		     AND CommunicationState = 'Ready To Print'

		  INSERT INTO #tblUserMessageDetail (UserCommunicationId, CommmunicationId, UserId, SubjectText, CommunicationText)
		  VALUES (@i_UserCommunicationId, @i_CommunicationId, @i_UserID, @v_SubjectText, @nv_CommunicationText)
		  
		  SET @nv_CommunicationText = NULL
		  SET @v_SubjectText = NULL
	      FETCH NEXT FROM curMassUsers 
		  INTO @i_CommunicationId,
			   @i_UserCommunicationId,
			   @i_UserId
			   --@nv_CommunicationText,
			   --@v_SubjectText
	  END
	  CLOSE curMassUsers
	  DEALLOCATE curMassUsers

	  UPDATE Communication
	     SET ApprovalState = 'Printed'
	   WHERE EXISTS ( SELECT 1 FROM #t_Param_CommunicationId tblCID WHERE tblCID.CommunicationID = Communication.CommunicationId)

	  IF ( @l_TranStarted = 1 )  -- If transactions are there then commit  
      BEGIN
            SET @l_TranStarted = 0
            COMMIT TRANSACTION
      END

	  SELECT TBLMSG.UserCommunicationId AS CommunicationId, TBLMSG.UserId, 
			 TBLMSG.SubjectText, TBLMSG.CommunicationText,
			 dbo.ufn_GetUserNameByID(TBLMSG.UserId) FullName  
	    FROM #tblUserMessageDetail TBLMSG
	   ORDER BY TBLMSG.UserId
	
	   SELECT TMSG.UserCommunicationId AS CommunicationId, LIB.eDocument, LIB.MimeType
		 FROM #tblUserMessageDetail TMSG
			  INNER JOIN PatientCommunicationAttachment UCA WITH(NOLOCK)
				ON TMSG.UserCommunicationId = UCA.PatientCommunicationID
			  INNER JOIN Library LIB
				ON LIB.LibraryId = UCA.LibraryId
END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_ContentDetail] TO [FE_rohit.r-ext]
    AS [dbo];

