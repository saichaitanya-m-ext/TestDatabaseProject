  
  
/*    
---------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_Batch_SendIVRForTaskAttempts]    
Description   : This procedure is to be used to ->  Send the IVR for attempte tasks  
Created By    : Rathnam    
Created Date  : 18-Jan-2012  
----------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY DESCRIPTION    
25-Jan-2012 NagaBabu Added ISNULL Condition for last select statement
----------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Batch_SendIVRForTaskAttempts]
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
                    uc.UserCommunicationId
                   ,u.PhoneNumberPrimary PhoneNumber
                   ,COALESCE(ISNULL(u.LastName , '') + ', ' + ISNULL(u.FirstName , '') + '. ' + ISNULL(u.MiddleName , '') + ' ' + ISNULL(u.UserNameSuffix , '') , '') PatientName
                   ,REPLACE(uc.CommunicationText , '<BR />' , '') PatientInformation
                   ,CASE
                         WHEN dbo.ufn_GetPCPName(u.UserId) = '' THEN dbo.ufn_GetPCPName(u.UserId)
                         ELSE 'David Phil'
                    END AS ProviderName
                   ,CONVERT(VARCHAR , GETDATE() + 1 , 101) AppointmentDate
                   ,uc.CommunicationTypeId
                INTO #tblUserCommunication   
                FROM
                    UserCommunication uc
                INNER JOIN Users u
                    ON u.UserId = uc.UserId
                INNER JOIN CommunicationType ct
                    ON uc.CommunicationTypeId = ct.CommunicationTypeId
                WHERE
                    ct.CommunicationType = 'IVR'
                    AND uc.CommunicationState = 'Ready to Print'
                    AND uc.CommunicationId IS NULL
                    AND uc.TaskAttemptsCommunicationLogID IS NULL 
                    
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
                    #tblUserCommunication
                GROUP BY CommunicationTypeID    

            SELECT
                @i_TaskAttemptsCommunicationLogID = SCOPE_IDENTITY()
                
            UPDATE
                UserCommunication
            SET
                TaskAttemptsCommunicationLogID = @i_TaskAttemptsCommunicationLogID
               ,LastModifiedByUserId = @i_AppUserId
               ,LastModifiedDate = Getdate()
            FROM
                #tblUserCommunication tbluc
            WHERE
                tbluc.UserCommunicationId = UserCommunication.UserCommunicationId
            
            INSERT INTO
                CommunicationIVRPhoneCallStatus
                (
                 UserCommunicationId
                ,PhoneNumber
                ,PatientName
                ,PatientInformation
                ,ProviderName
                ,AppointmentDate
                ,CallStatus
                ,CreatedByUserId
                )
                SELECT
                    UserCommunicationId
                   ,PhoneNumber
                   ,PatientName
                   ,PatientInformation
                   ,ProviderName
                   ,AppointmentDate
                   ,NULL
                   ,@i_AppUserId
                FROM
                    #tblUserCommunication 
                SELECT ISNULL(@i_TaskAttemptsCommunicationLogID,0) TaskAttemptsCommunicationLogID    
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
    ON OBJECT::[dbo].[usp_Batch_SendIVRForTaskAttempts] TO [FE_rohit.r-ext]
    AS [dbo];

