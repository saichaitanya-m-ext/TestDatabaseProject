
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_PatientCommunication_SelectMore      
Description   : This procedure is used to get the detais from PatientCommunication,
				CommunicationTemplateAttachments and Library tables.      
Created By    : Aditya        
Created Date  : 20-May-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
15-July-10 NagaBabu Included CommunicationState field in select statement           
10-Nov-10 Pramod Modified the attachment query to include PatientCommunicationAttachment table        
------------------------------------------------------------------------------        
*/  

CREATE PROCEDURE [dbo].[usp_UserCommunication_SelectMore]  
(  
 @i_AppUserId KEYID ,  
 @i_UserCommunicationId KEYID 
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
           
---- Records from PatientCommunication,CommunicationTemplateAttachments,Library details are retrieved here -------------------  
  
      SELECT  
			PatientCommunication.PatientCommunicationId,
			PatientCommunication.PatientId UserId,
			CASE 
				WHEN PatientCommunication.dbmailReferenceId = NULL THEN 'YES'  
				ELSE 'NO'  
			END AS dbmailReferenceId,
			PatientCommunication.eMailDeliveryState,
			PatientCommunication.CommunicationTemplateId,
			Library.LibraryId,
			Library.DocumentTypeId,
			Library.Name,
			Library.Description,
			Library.PhysicalFileName,
			Library.DocumentNum,
			Library.DocumentLocation,
			--Library.eDocument,
			'' AS eDocument,
			Library.DocumentSourceCompany,
			Library.MimeType,
			PatientCommunication.CommunicationState
		
      FROM  
			PatientCommunication  with (nolock)
			INNER JOIN PatientCommunicationAttachment  with (nolock)
				ON PatientCommunicationAttachment.PatientCommunicationId = PatientCommunication.PatientCommunicationId
		    INNER JOIN Library  with (nolock)
				ON Library.LibraryId = PatientCommunicationAttachment.LibraryId 
      WHERE  
           ( PatientCommunication.PatientCommunicationId = @i_UserCommunicationId OR @i_UserCommunicationId IS NULL ) 
            

END TRY        
   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH       

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserCommunication_SelectMore] TO [FE_rohit.r-ext]
    AS [dbo];

