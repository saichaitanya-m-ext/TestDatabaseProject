/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserMessages_Recepients_Detail  
Description   : This procedure is used to get the details from UserMessageRecipients,  
    UserMessages tables   
Created By    : Pramod      
Created Date  : 5-Apr-2010  
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
24-Aug-10 Pramod For attachment Inlcuded join with Library table
02-May-2011 NagaBabu Modified 'MailtoPersonName' field in second resultset table 
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserMessages_Recepients_Detail]
(    
 @i_AppUserId KeyID, -- Login User Id  
 @i_UserMessageID KeyID  
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
	   UserMessages.SubjectText,  
	   UserMessages.MessageText,  
	   UserMessages.DeliverOnDate,  
	   UserMessages.ProviderID UserId,  
	   ISNULL(FromUser.FirstName,'') + ' ' + ISNULL(FromUser.LastName,'') AS FromUserName,  
	   UserMessages.isDraft,  
	   CASE UserMessages.MessageState  
		   WHEN 'V' THEN 'Viewed'  
		   WHEN 'N' THEN 'Not Viewed'  
		   WHEN 'A' THEN 'Archive'  
	   END AS MessageState,  
	   UserMessages.PatientId PatientUserId,  
	   Patients.FullName AS PatientName  
   FROM UserMessages  
   INNER JOIN Provider FromUser  
       ON FromUser.ProviderID = UserMessages.ProviderID  
   LEFT OUTER JOIN Patients  
       ON Patients.PatientID = UserMessages.PatientId        
   WHERE UserMessages.UserMessageId = @i_UserMessageID  
  
   IF EXISTS (SELECT 1 FROM UserMessageRecipients umr WHERE UserMessageID = @i_UserMessageID AND ProviderID IS NOT NULL)
   BEGIN
   SELECT 
	   UserMessageRecipients.ProviderID ToUserId,  
	   UserMessageRecipients.MessageState,  
	   --  ISNULL(Users.FirstName,'') + ' ' + ISNULL(Users.LastName,'') + SPACE(2)  
	   --  + CASE UserMessageRecipients.MessageState  
		  -- WHEN 'V' THEN 'Viewed'  
		  -- WHEN 'N' THEN 'Not Viewed'  
		  -- WHEN 'A' THEN 'Archive'  
		   --END   
	   --  AS MailtoPersonName 
	   ISNULL(Provider.FirstName,'') + ' ' + ISNULL(Provider.LastName,'') AS MailtoPersonName  
   FROM UserMessageRecipients  
   INNER JOIN Provider  
       ON UserMessageRecipients.ProviderID = Provider.ProviderID
   WHERE UserMessageRecipients.UserMessageId = @i_UserMessageID  
  END
  ELSE
  BEGIN
  SELECT 
	   UserMessageRecipients.ProviderID ToUserId,  
	   UserMessageRecipients.MessageState,  
	   Patients.FullName AS MailtoPersonName  
   FROM UserMessageRecipients  
   INNER JOIN Patients  
       ON UserMessageRecipients.PatientID = Patients.PatientID
   WHERE UserMessageRecipients.UserMessageId = @i_UserMessageID  
  END
   SELECT   
	   Attachments.AttachmentName,  
	   Attachments.AttachmentExtension,  
	   Attachments.AttachmentBody,  
	   Attachments.FileType,  
	   Attachments.MimeType,  
	   Attachments.FileSizeInBytes  
   FROM UserMessageAttachments  
   INNER JOIN Attachments  
       ON UserMessageAttachments.AttachmentId = Attachments.AttachmentId  
   WHERE UserMessageAttachments.UserMessageId = @i_UserMessageID
   UNION
   SELECT   
	   Library.Name AS AttachmentName,  
	   '' AS AttachmentExtension,  
	   Library.eDocument AS AttachmentBody,  
	   Library.MimeType AS FileType,  
	   Library.MimeType AS MimeType,  
	   NULL AS FileSizeInBytes
    FROM UserMessageAttachments  
    INNER JOIN Library
        ON Library.Libraryid = UserMessageAttachments.LibraryId
    WHERE UserMessageAttachments.UserMessageId = @i_UserMessageID              
    
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
    ON OBJECT::[dbo].[usp_UserMessages_Recepients_Detail] TO [FE_rohit.r-ext]
    AS [dbo];

