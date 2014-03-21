/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Patients_Select_MergeLetters 10,6
Description   : This procedure is used to get the details for patient letters
				for a particular patient to be used for merge printing
Created By    : Pramod
Created Date  : 11-Aug-10
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
23-Aug-2010 NagaBabu Added StatusCode = 'A' in  where clause to each select statement  
10-Nov-10 Pramod modified the query to remove th join with communication table
05-APR-13 Mohan modified UserCommunication table to PatientCommuncation 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Patients_Select_MergeLetters]
(  
   @i_AppUserId KEYID,
   @i_PatientUserId KeyID
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
		 @tblPatientLetterDetail 
		 TABLE (UserCommunicationId INT,
				CommunicationId INT,
			    TemplateName ShortDescription,
			    NoOfAttachments INT
			   )

	  INSERT INTO @tblPatientLetterDetail 
			 (UserCommunicationId, CommunicationId, TemplateName, NoOfAttachments)
      SELECT PatientCommunication.PatientCommunicationId UserCommunicationId,
		     PatientCommunication.CommunicationId,
			 CommunicationTemplate.TemplateName,
			 COUNT(CommunicationTemplateAttachments.LibraryId) AS NoOfAttachments
	    FROM  
			 PatientCommunication WITH(NOLOCK)
			 INNER JOIN CommunicationTemplate WITH(NOLOCK)
				ON CommunicationTemplate.CommunicationTemplateId = PatientCommunication.CommunicationTemplateId
			 LEFT OUTER JOIN CommunicationTemplateAttachments WITH(NOLOCK)
				ON CommunicationTemplateAttachments.CommunicationTemplateId = CommunicationTemplate.CommunicationTemplateId
	   WHERE PatientCommunication.PatientId = @i_PatientUserId
	 	 AND PatientCommunication.CommunicationState = 'Ready To Print'
	 	 AND PatientCommunication.StatusCode = 'A'
	 	 AND CommunicationTemplate.StatusCode = 'A' 
	   GROUP BY PatientCommunication.PatientCommunicationId,
		     PatientCommunication.CommunicationId,
			 CommunicationTemplate.TemplateName
/*
	  INSERT INTO @tblPatientLetterDetail (CommunicationId, TemplateName, NoOfAttachments)
      SELECT CommunicationCohorts.CommunicationId,
			 CommunicationTemplate.TemplateName,
			 COUNT(CommunicationTemplateAttachments.LibraryId) AS NoOfAttachments
	    FROM CommunicationCohorts
			 INNER JOIN Communication
				ON Communication.CommunicationId = CommunicationCohorts.CommunicationId
			 INNER JOIN CommunicationTemplate
				ON CommunicationTemplate.CommunicationTemplateId = Communication.CommunicationTemplateId
			 LEFT OUTER JOIN CommunicationTemplateAttachments
				ON CommunicationTemplateAttachments.CommunicationTemplateId = CommunicationTemplate.CommunicationTemplateId
	   WHERE CommunicationCohorts.UserId = @i_PatientUserId
	     AND Communication.ApprovalState = 'Ready To Print'
	     AND Communication.StatusCode = 'A'
	     AND CommunicationTemplate.StatusCode = 'A'
	   GROUP BY CommunicationCohorts.CommunicationId,
			    CommunicationTemplate.TemplateName
*/

      SELECT UserCommunicationId,
			 CommunicationId,
			 TemplateName,
			 NoOfAttachments
	    FROM
             @tblPatientLetterDetail

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
    ON OBJECT::[dbo].[usp_Patients_Select_MergeLetters] TO [FE_rohit.r-ext]
    AS [dbo];

