/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_SendMailsForTaskAttempts]  
Description   : This procedure is to be used to ->  Send the emails for attempte tasks
Created By    : Rathnam  
Created Date  : 18-Jan-2012
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
05-April-2012 Rathnam added u.EmailIdPrimary is not null
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_SendMailsForTaskAttempts]

(
 @i_AppUserId KEYID
)
AS
BEGIN
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
                    @i_UserCommunicationId INT
                   ,@i_UserId INT
                   ,@i_CommunicationTypeId INT
                   ,@v_CommunicationText VARCHAR(MAX)
                   ,@v_SenderEmailAddress VARCHAR(150)
                   ,@v_SubjectText VARCHAR(500)
                   ,@v_EmailIdPrimary VARCHAR(100)
                   ,@i_dbmailReferenceId INT

			CREATE TABLE #tblTaskAttemptUsers
				(
					UserCommunicationId INT
					,UserId INT
					,CommunicationTypeId INT
					,CommunicationText VARCHAR(MAX)
					,SenderEmailAddress VARCHAR(150)
					,SubjectText VARCHAR(500)
					,EmailIdPrimary VARCHAR(100)
				)
		    
		    INSERT #tblTaskAttemptUsers
				(
					 UserCommunicationId 
					,UserId 
					,CommunicationTypeId 
					,CommunicationText 
					,SenderEmailAddress 
					,SubjectText 
					,EmailIdPrimary 
		    
				)
		    SELECT
                uc.PatientCommunicationId
               ,uc.PatientId
               ,uc.CommunicationTypeId
               ,uc.CommunicationText
               ,uc.SenderEmailAddress
               ,uc.SubjectText
               ,u.PrimaryEmailAddress
            FROM
                PatientCommunication uc
            INNER JOIN Patient u
                ON u.PatientID = uc.PatientId
            INNER JOIN CommunicationType ct
                ON uc.CommunicationTypeId = ct.CommunicationTypeId
            WHERE
                CommunicationId IS NULL
                AND ct.CommunicationType = 'Email'
                AND uc.CommunicationState = 'Ready to Send'
                AND uc.TaskAttemptsCommunicationLogID IS NULL
                AND u.PrimaryEmailAddress IS NOT NULL
			
			DECLARE @i_TaskAttemptsCommunicationLogID INT
                   
        
            INSERT INTO
                TaskAttemptsCommunicationLog
                (
                 CommunicationTypeID
                ,NoOfCommunication
                ,StatusCode
                ,CreatedByUserId
                ,CreatedDate
                )
                SELECT
                    CommunicationTypeID
                   ,COUNT(UserCommunicationId) 
                   ,'P'
                   ,@i_AppUserId
                   ,GETDATE()
                FROM
                    #tblTaskAttemptUsers
                GROUP BY CommunicationTypeID    

            SELECT
                @i_TaskAttemptsCommunicationLogID = SCOPE_IDENTITY()
                
            DECLARE curAttemptUsers CURSOR
                    FOR SELECT
                            PatientCommunicationId
                           ,UserId
                           ,CommunicationTypeId
                           ,CommunicationText
                           ,SenderEmailAddress
                           ,SubjectText
                           ,EmailIdPrimary
                        FROM
                            #tblTaskAttemptUsers
            OPEN curAttemptUsers
            FETCH NEXT FROM curAttemptUsers INTO 
             @i_UserCommunicationId 
            ,@i_UserId 
            ,@i_CommunicationTypeId 
            ,@v_CommunicationText 
            ,@v_SenderEmailAddress 
            ,@v_SubjectText 
            ,@v_EmailIdPrimary
            WHILE @@FETCH_STATUS = 0
                  BEGIN  -- Begin for cursor   
                  
                        EXEC msdb.dbo.sp_send_dbmail 
                        @profile_name = 'CCM' ,   
                        @recipients = @v_EmailIdPrimary , 
                        @body = @v_CommunicationText , 
                        @subject = @v_SubjectText , 
                        @body_format = 'HTML' ,
                        @mailitem_id = @i_dbmailReferenceId OUTPUT


						 UPDATE PatientCommunication 
						  SET 
							LastModifiedByUserId = @i_AppUserId,
							LastModifiedDate = GETDATE(),
							CommunicationState = 'Sent',
							dbmailReferenceId = @i_dbmailReferenceId,
							TaskAttemptsCommunicationLogID = @i_TaskAttemptsCommunicationLogID
						 WHERE PatientCommunicationId = @i_UserCommunicationId	
						
						SET @i_dbmailReferenceId = NULL
                        FETCH NEXT FROM curAttemptUsers INTO 
                         @i_UserCommunicationId 
						,@i_UserId 
						,@i_CommunicationTypeId 
						,@v_CommunicationText 
						,@v_SenderEmailAddress 
						,@v_SubjectText 
						,@v_EmailIdPrimary
                  END
            CLOSE curAttemptUsers
            DEALLOCATE curAttemptUsers
            
            UPDATE TaskAttemptsCommunicationLog
            SET StatusCode = 'S',
                LastModifiedDate = GETDATE(),
                LastModifiedByUserId = @i_AppUserId
            WHERE TaskAttemptsCommunicationLogId = @i_TaskAttemptsCommunicationLogID
      END TRY
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
      BEGIN CATCH  
    -- Handle exception  
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_SendMailsForTaskAttempts] TO [FE_rohit.r-ext]
    AS [dbo];

