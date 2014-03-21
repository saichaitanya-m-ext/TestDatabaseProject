/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserMessages_Select_Sent_Draft  
Description   : This procedure is used to get the details from UserMessageRecipients,  
    UserMessages tables and display in the Sent and Draft  
Created By    : Pramod      
Created Date  : 5-Apr-2010  
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserMessages_Select_Sent_Draft]
(    
	@i_AppUserID KeyID, -- Login User Id  
	@i_UserID KeyID,  
	@c_SentOrDraft CHAR(1) = 'S' -- S - Sent, D - Draft  
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
			UserMessages.DeliverOnDate AS MessageSentDate,   
			UserMessages.UserMessageID,  
			UserMessages.SubjectText,
		    (SELECT LEFT(l.list,LEN(l.list)-1)
			   FROM
			       (SELECT COALESCE
						   (ISNULL(Provider.LastName , '') + ' '     
						     + ISNULL(Provider.FirstName , '') + ' '     
							 + ISNULL(Provider.MiddleName , ''),''
						    ) + ';' AS [text()]
					  FROM UserMessageRecipients
						   INNER JOIN Provider on UserMessageRecipients.ProviderID = Provider.ProviderID
				     WHERE UserMessageRecipients.UserMessageID = UserMessages.UserMessageId
			         FOR XML PATH('')
			        )l(list)
			) AS SentToName,
			UserMessages.PatientId ,  
			ISNULL(Patients.FullName,'') AS PatientName,    
			ISNULL( (SELECT COUNT(*)  
					   FROM UserMessageAttachments  
					  WHERE UserMessageAttachments.UserMessageId = UserMessages.UserMessageID  
					 )  
				   , 0 ) AS IsAttachment  
       FROM UserMessages  
			LEFT OUTER JOIN Patients  
				ON Patients.PatientID = UserMessages.PatientId  
      WHERE UserMessages.ProviderID = @i_UserID  
        AND (   
			 ( @c_SentOrDraft = 'S' AND UserMessages.isDraft = 0 ) -- Sent messages 
              OR
			 ( @c_SentOrDraft = 'D' AND UserMessages.isDraft = 1 ) -- Draft messages
            )
        AND ISNULL(UserMessages.MessageState,'') <> 'A'  -- (dont show archived messages)
      ORDER BY 
			UserMessages.CreatedDate DESC,  
			UserMessages.MessageState ASC  

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
    ON OBJECT::[dbo].[usp_UserMessages_Select_Sent_Draft] TO [FE_rohit.r-ext]
    AS [dbo];

