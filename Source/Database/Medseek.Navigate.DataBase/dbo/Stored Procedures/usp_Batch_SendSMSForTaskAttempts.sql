/*    
---------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_Batch_SendSMSForTaskAttempts]    
Description   : This procedure is to be used to ->  Send the SMS for attempte tasks  
Created By    : Rathnam    
Created Date  : 18-Jan-2012  
----------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY DESCRIPTION    
----------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Batch_SendSMSForTaskAttempts] 
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

            SELECT
                PatientCommunication.PatientCommunicationId
               ,PatientCommunication.CommunicationTypeId
               ,Patient.PatientID 
               ,'+' + CodeSetCountry.CountryCode + Patient.PrimaryPhoneNumber AS PhoneNumber
               ,REPLACE(CommunicationText , '<BR />' , '') AS CommunicationText
            INTO
                #tblUserCommunication
            FROM
                PatientCommunication
            INNER JOIN Patient
                ON Patient.PatientID = PatientCommunication.PatientID
            INNER JOIN CommunicationType
                ON CommunicationType.CommunicationTypeId = PatientCommunication.CommunicationTypeId
            INNER JOIN CodeSetCountry
                ON CodeSetCountry.CountryID = Patient.PrimaryAddressCountryCodeID    
            WHERE
                CommunicationType.CommunicationType = 'SMS'
                AND PatientCommunication.CommunicationId IS NULL
                AND ( '+' + CodeSetCountry.CountryCode + Patient.PrimaryPhoneNumber IS NOT NULL
                      OR ( '+' + CodeSetCountry.CountryCode + Patient.PrimaryPhoneNumber ) <> '+1'
                    )
                AND PatientCommunication.TaskAttemptsCommunicationLogID IS NULL   
                 
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
                   ,COUNT(PatientCommunicationId) 
                   ,'P'
                   ,@i_AppUserId
                   ,GETDATE()
                FROM
                    #tblUserCommunication
                GROUP BY CommunicationTypeID    

            SELECT
                @i_TaskAttemptsCommunicationLogID = SCOPE_IDENTITY()
                
            UPDATE
                PatientCommunication
            SET
                TaskAttemptsCommunicationLogID = @i_TaskAttemptsCommunicationLogID
               ,LastModifiedByUserId = @i_AppUserId
               ,LastModifiedDate = Getdate()
            FROM
                #tblUserCommunication tbluc
            WHERE
                tbluc.PatientCommunicationId = PatientCommunication.PatientCommunicationId
                
            SELECT
                PatientID
               ,PhoneNumber
               ,CommunicationText
               ,@i_TaskAttemptsCommunicationLogID TaskAttemptsCommunicationLogID
            FROM
                #tblUserCommunication

            SELECT
                CommunicationSMSConfigurationId
               ,SMSUserLogin
               ,SMSUserPassword
               ,SMSCompression
            FROM
                CommunicationSMSConfiguration
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
    ON OBJECT::[dbo].[usp_Batch_SendSMSForTaskAttempts] TO [FE_rohit.r-ext]
    AS [dbo];

