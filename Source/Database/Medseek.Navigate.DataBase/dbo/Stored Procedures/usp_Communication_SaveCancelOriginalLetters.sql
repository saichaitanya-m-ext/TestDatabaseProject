/*        
------------------------------------------------------------------------------        
Procedure Name: usp_Communication_SaveCancelOriginalLetters
Description   : This procedure is used for canceling the original letters used
			for the merge and create a new letter / patient communication entry
Created By    : Pramod
Created Date  : 16-Aug-10
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
17-08-2010  Rathnam Transactions added.    
18-08-10 Pramod Included insert into UserCommunicationAttachment table
09-09-10 Pramod Corrected the Union statement for deciding the communication to print
10-Nov-10 Pramod Removed the reference of communication table from the query (update, select etc)
Added the column IsMergedLetter into the insert statement for usercommunication
11-Nov-10 Pramod Modified the SP to include derived communication id
19-Nov-10 Pramod Included condition for select from @t_CommunicationId WHERE tKeyId <> 0 
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Communication_SaveCancelOriginalLetters]
(
 @i_AppUserId KEYID ,
 @i_UserId KEYID ,
 @t_UserCommunicationId TTYPEKEYID READONLY ,
 @t_CommunicationId TTYPEKEYID READONLY ,
 @n_CommunicationText NVARCHAR(MAX) ,
 @t_attachment TTYPEKEYID READONLY ,
 @v_MergeInfo VARCHAR(50) OUTPUT ,
 @o_UserCommunicationId KEYID OUTPUT )
AS
BEGIN TRY
      SET NOCOUNT ON  
-- Check if valid Application User ID is passed      

      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

      DECLARE @l_TranStarted BIT = 0, @i_DerivedCommunicationID KeyID
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @l_TranStarted = 1  -- Indicator for start of transactions  
         END
      ELSE
         SET @l_TranStarted = 0

      IF EXISTS ( --SELECT -- COMMENTED THE BELOW CODE AS ONLY USERCOMMUNICATION IS REFERED
      --                1
      --            FROM
      --                Communication COM
      --            INNER JOIN @t_CommunicationId TCOM
      --            ON  COM.CommunicationId = TCOM.tKeyId
      --            WHERE
      --                COM.ApprovalState <> 'Ready to Print'
      --            UNION
                  SELECT
                      1
                  FROM
                      PatientCommunication UCOM
                  INNER JOIN @t_UserCommunicationId TUCM
                  ON  UCOM.PatientCommunicationId = TUCM.tKeyId
                  WHERE
                      UCOM.CommunicationState <> 'Ready to Print'
               )
         BEGIN
               SET @v_MergeInfo = 'Letters already printed, Please refresh the page'
         END
      ELSE
         BEGIN
			   SELECT TOP 1 @i_DerivedCommunicationID = CommunicationId
			     FROM PatientCommunication UCM
					  INNER JOIN @t_UserCommunicationId TUCM
						ON UCM.PatientCommunicationId = TUCM.tKeyId
				WHERE UCM.CommunicationId IS NOT NULL

			   IF @i_DerivedCommunicationID IS NULL 
					SELECT TOP 1 @i_DerivedCommunicationID = tKeyId FROM @t_CommunicationId WHERE tKeyId <> 0 

               INSERT INTO
                   PatientCommunication
                   (
                     PatientId ,
                     CommunicationTemplateId ,
                     CreatedByUserID ,
                     CreatedDate ,
                     DateScheduled ,
                     DateDue ,
                     CommunicationCohortId ,
                     CommunicationTypeId ,
                     CommunicationState ,
                     CommunicationText ,
                     SubjectText ,
                     IsSentIndicator ,
                     StatusCode,
                     IsMergedLetter,
                     CommunicationId
                   )
               VALUES
                   (
                     @i_UserId ,
                     NULL ,
                     @i_appUserId ,
                     GETDATE() ,
                     GETDATE() ,
                     GETDATE() ,
                     NULL ,
                     ( SELECT
                           CommunicationTypeID
                       FROM
                           CommunicationType
                       WHERE
                           CommunicationType = 'Letter' ) ,
                     'Ready to Print' ,
                     @n_CommunicationText ,
                     'Composite letter' ,
                     0,
                     'A',
                     1,
                     @i_DerivedCommunicationID
                   )

               SET @o_UserCommunicationId = SCOPE_IDENTITY()

               UPDATE
                   PatientCommunication
               SET
                   MergedIntoUserCommunicationID = @o_UserCommunicationId ,
                   StatusCode = 'I'
               WHERE
                   EXISTS ( SELECT
                                1
                            FROM
                                @t_UserCommunicationId TUCM
                            WHERE
                                TUCM.tkeyId = PatientCommunication.PatientCommunicationId
                           )

               --UPDATE
               --    UserCommunication
               --SET
               --    MergedIntoUserCommunicationID = @o_UserCommunicationId ,
               --    StatusCode = 'I'
               --WHERE
               --    EXISTS ( SELECT
               --                 1
               --             FROM
               --                 @t_CommunicationId UCM
               --             WHERE
               --                 UCM.tkeyId = UserCommunication.CommunicationId )

			   INSERT INTO PatientCommunicationAttachment
			     (LibraryId, PatientCommunicationID, CreatedByUserId)
			   SELECT tkeyId, @o_UserCommunicationId, @i_AppUserId
			     FROM @t_attachment

               SET @v_MergeInfo = 'Letters Merged into one and set to Ready to Print'
         END

		 IF ( @l_TranStarted = 1 )  -- If transactions are there then commit  
         BEGIN
                SET @l_TranStarted = 0
                COMMIT TRANSACTION
         END

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
    ON OBJECT::[dbo].[usp_Communication_SaveCancelOriginalLetters] TO [FE_rohit.r-ext]
    AS [dbo];

