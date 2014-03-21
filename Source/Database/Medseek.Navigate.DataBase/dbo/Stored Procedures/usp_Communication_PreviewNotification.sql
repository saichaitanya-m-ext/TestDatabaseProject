/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Communication_PreviewNotification]
Description	  : This procedure is used to display the preview of the message before sending
Created By    :	Pramod
Created Date  : 13-May-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
26-May-2010 Pramod  Modified the parameter from @i_CommunicationTemplateId to @i_NotifyCommunicationTemplateId
				   as the content and subject for the communication is required on the page
27-May-10 Pramod Replaced the call of usp_Communication_MessageDetail with Select from users and communicationTemplate
16-Jul-10 Pramod Included the condition CohortListUsers.StatusCode = 'A' to pick 
	only active records
28-sep-10 Pramod Modified the SP for showing notification template text and content
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID
18-Mar-2013 P.V.P.Mohan Modified the Users table into Patient table and added PrimaryEmailAddress,PatientID
----------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Communication_PreviewNotification]
(
	@i_AppUserId KEYID ,
	@i_NotifyCommunicationTemplateId KEYID,
	@i_PopulationDefinitionID KEYID,
	@v_SenderEmailAddress EmailId
)
AS
BEGIN TRY
      SET NOCOUNT ON
	  DECLARE 
		@i_UserId KeyID,
		@v_EmailId VARCHAR(256)

	-- Check if valid Application User ID is passed

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
      BEGIN
           RAISERROR ( N'Invalid Application User ID %d passed.' ,
           17 ,
           1 ,
           @i_AppUserId )
      END

	  SELECT TOP 1 @i_UserId = PatientID 
	    FROM PopulationDefinition 
			 INNER JOIN PopulationDefinitionPatients
			    ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionPatients.PopulationDefinitionID
                AND PopulationDefinitionPatients.StatusCode = 'A' -- Select only active records			    
	   WHERE PopulationDefinition.PopulationDefinitionID = @i_PopulationDefinitionID

	  SELECT @v_EmailId = PrimaryEmailAddress
	    FROM Patient
	   WHERE PatientID = @i_UserId

   DECLARE   
	  @v_EmailIdPrimary EmailId,  
	  @v_SubjectText VARCHAR(200),   
	  @v_CommunicationText NVARCHAR(MAX),  
	  @v_NotifySubjectText VARCHAR(200),   
	  @v_NotifyCommunicationText NVARCHAR(MAX)     

   EXEC usp_Communication_MessageContent  
	  @i_AppUserId = @i_AppUserId,  
	  @i_CommunicationTemplateId = @i_NotifyCommunicationTemplateId,  
	  @i_UserID = @i_UserID,  
	  @v_EmailIdPrimary = @v_EmailIdPrimary OUT,  
	  @v_SubjectText = @v_SubjectText OUT,   
	  @v_CommunicationText = @v_CommunicationText OUT,  
	  @v_NotifySubjectText = @v_NotifySubjectText OUT,   
	  @v_NotifyCommunicationText = @v_NotifyCommunicationText OUT    
  
   SELECT 
		@v_SenderEmailAddress As SenderEmailAddress,  
        @v_EmailIdPrimary AS SendToEmailId,  
        @v_SubjectText AS SubjectText,  
        @v_CommunicationText AS CommunicationText  

END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_PreviewNotification] TO [FE_rohit.r-ext]
    AS [dbo];

