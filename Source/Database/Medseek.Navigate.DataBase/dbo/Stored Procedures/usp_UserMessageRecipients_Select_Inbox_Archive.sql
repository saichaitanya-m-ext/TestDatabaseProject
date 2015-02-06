/*          
------------------------------------------------------------------------------          
Procedure Name: usp_UserMessageRecipients_Select_Inbox_Archive      
Description   : This procedure is used to get the details from UserMessageRecipients,      
    UserMessages and UserMessageAttachments tables and display in the Inbox.        
Created By    : Pramod          
Created Date  : 2-Apr-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
15-09-10 Pramod Included the FromUser name in the query
03-05-11 Rathnam added Two concatinated columns for each select statement.
------------------------------------------------------------------------------          
*/        
CREATE PROCEDURE [dbo].[usp_UserMessageRecipients_Select_Inbox_Archive]        
(        
 @i_AppUserId KeyID, -- Login User Id      
 @i_UserID KeyID,    
 @c_InboxOrArchive CHAR(1) = 'I' -- Inbox, A - Archive      
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
      
   -- Inbox related messages        
      SELECT     
		   UserMessages.DeliverOnDate AS MessageReceivedDate,       
		   UserMessageRecipients.ProviderID ToUserId,     
		   COALESCE
			(ISNULL(Recipients.LastName , '') + ' '
			   + ISNULL(Recipients.FirstName , '') + ' '     
			   + ISNULL(Recipients.MiddleName , ''),''
		    ) AS RecipientName,
		   COALESCE
			(ISNULL(FromUser.LastName , '') + ' '
			   + ISNULL(FromUser.FirstName , '') + ' '     
			   + ISNULL(FromUser.MiddleName , ''),''
		    ) AS FromUserName,
		   UserMessages.UserMessageId,      
		   UserMessages.SubjectText,                                                                                                                                                                                                                                   
		   CASE UserMessageRecipients.MessageState      
			WHEN 'V' THEN 'Viewed'      
			WHEN 'N' THEN 'Not Viewed'      
			WHEN 'A' THEN 'Archive'      
		   END AS MessageState,    
		   UserMessages.PatientId PatientUserId,      
		   Patients.FullName AS PatientName,      
		   ISNULL((SELECT COUNT(*)      
					 FROM UserMessageAttachments      
					 WHERE UserMessageAttachments.UserMessageId = UserMessages.UserMessageID      
				   )      
			   ,0) AS IsAttachment,
			COALESCE
			(ISNULL(FromUser.LastName , '') + ' '
			   + ISNULL(FromUser.FirstName , '') + ' '     
			   + ISNULL(FromUser.MiddleName , ''),''
		    ) + ' \n ' + ISNULL(UserMessages.SubjectText,'') AS FromUserNameAndSubjecttext,
		    ISNULL(Patients.FullName,'') + ' \n ' + ISNULL(CONVERT(VARCHAR,UserMessages.DeliverOnDate),'') AS PatientNameAndMessageReceivedDate        
       FROM UserMessages       WITH(NOLOCK)
			INNER JOIN UserMessageRecipients   WITH(NOLOCK)    
				ON UserMessages.UserMessageID = UserMessageRecipients.UserMessageID      
			INNER JOIN Provider Recipients     WITH(NOLOCK)
				ON Recipients.ProviderID = UserMessageRecipients.ProviderID    
		    INNER JOIN Provider FromUser  WITH(NOLOCK)
				ON UserMessages.ProviderID = FromUser.ProviderID
			LEFT JOIN Patients WITH(NOLOCK)
				ON Patients.PatientID = UserMessages.PatientId
      WHERE UserMessageRecipients.ProviderID = @i_UserID
        AND (       
		     ( @c_InboxOrArchive = 'I' AND UserMessageRecipients.MessageState IN ( 'N', 'V' ) ) -- Only Viewed and Not viewed displayed      
               OR      
		     ( @c_InboxOrArchive = 'A' AND UserMessageRecipients.MessageState = 'A' ) -- Archived      
            )
	  UNION ALL
      SELECT     
		   UserMessages.DeliverOnDate AS MessageReceivedDate,       
		   UserMessages.Providerid UserId ,
		   COALESCE
			(ISNULL(Provider.LastName , '') + ' '     
			   + ISNULL(Provider.FirstName , '') + ' '     
			   + ISNULL(Provider.MiddleName , ''),''
		    ) AS RecipientName,
		   COALESCE
			(ISNULL(Provider.LastName , '') + ' '     
			   + ISNULL(Provider.FirstName , '') + ' '     
			   + ISNULL(Provider.MiddleName , ''),''
		    ) AS FromUserName,
		   UserMessages.UserMessageId,      
		   UserMessages.SubjectText,                                                                                                                                                                                                                                   
		   'Archive' AS MessageState,    
		   UserMessages.PatientId PatientUserId,      
		   ISNULL(Patients.FullName,'') AS PatientName,      
		   ISNULL((SELECT COUNT(*)      
					 FROM UserMessageAttachments      
					WHERE UserMessageAttachments.UserMessageId = UserMessages.UserMessageID      
				   )      
			   ,0) AS IsAttachment,
			COALESCE
			(ISNULL(Provider.LastName , '') + ' '     
			   + ISNULL(Provider.FirstName , '') + ' '     
			   + ISNULL(Provider.MiddleName , ''),''
		    ) + ' \n ' + ISNULL(UserMessages.SubjectText,'') AS FromUserNameAndSubjecttext,
		    ISNULL(Provider.FirstName,'') + ' ' + ISNULL(Provider.LastName,'') + ' \n ' + ISNULL(CONVERT(VARCHAR,UserMessages.DeliverOnDate),'') AS PatientNameAndMessageReceivedDate                 
       FROM UserMessages WITH(NOLOCK)
			INNER JOIN Provider WITH(NOLOCK)
			    ON Provider.ProviderID = UserMessages.ProviderID
			LEFT JOIN Patients  WITH(NOLOCK)
				ON Patients.PatientID = UserMessages.PatientId      
      WHERE UserMessages.ProviderID = @i_UserID      
        AND ( @c_InboxOrArchive = 'A' AND UserMessages.MessageState = 'A' ) -- Archived      

      ORDER BY     
		   1 DESC     

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
    ON OBJECT::[dbo].[usp_UserMessageRecipients_Select_Inbox_Archive] TO [FE_rohit.r-ext]
    AS [dbo];

