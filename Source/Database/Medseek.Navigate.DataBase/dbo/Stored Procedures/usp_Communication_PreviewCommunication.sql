
/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Communication_PreviewCommunication]
Description	  : This procedure is used to display the preview of the message before sending
Created By    :	Pramod
Created Date  : 13-May-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
16-Jul-10 Pramod Included the condition CohortListUsers.StatusCode = 'A' to pick 
	only active records
15-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers	
3-Apr-2013 P.V.P.Mohan changed PopulationDefinitionUsers to PopulationDefinitionPatients
----------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Communication_PreviewCommunication]
(
	@i_AppUserId KEYID ,
	@i_CommunicationTemplateId KEYID,
	@i_PopulationDefinitionID KEYID,
	@v_SenderEmailAddress EmailId
)
AS
BEGIN TRY
      SET NOCOUNT ON
	  DECLARE 
		@i_UserId KeyID,
		@v_SubjectText VARCHAR(200), 
		@v_CommunicationText NVARCHAR(MAX)	

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


	   EXEC usp_Communication_MessageDetail
			@i_AppUserId = @i_AppUserId,
			@i_CommunicationTemplateId = @i_CommunicationTemplateId,
			@v_SenderEmailAddress = @v_SenderEmailAddress,
			@i_UserID = @i_UserId

END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_PreviewCommunication] TO [FE_rohit.r-ext]
    AS [dbo];

