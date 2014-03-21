/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[Usp_Communication_CommunicationCohorts_Select]
Description	  : This procedure is used to select the data from Communication and cohorts
Created By    :	Pramod
Created Date  : 04-May-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
25-May-2010 Pramod Included the parameter @v_ApprovalState2 to allow 2 approvalstatus
				 values to be passed to the SP. Also, the sortorder is changed to include
				 CommunicationId. Included ISNULL for LastmodifiedDate/createddate for
				 LastUsedDate
26-May-2010 NagaBabu Included Communication.PrintDate in select statement				 
07-Dec-2010 Rathnam added if else condition	for getting the particular communicationid info 
                    from createpdf tab and join with usercommunication table &
                    added isnull condition for 	SubjectText,CommunicationText in else clause
08-Dec-2010 Rathnam Removed the CommunicationType join condition from else clause
                    and added isnull condition for CommunicationTypeId.  
15-Dec-2010 Rathnam Getting the communicationtype from communication table instead of getting
                    from communicationtemplate table in if clause.
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUser
25-Mar-2013 P.V.P.MOhan Modified PatientCommunication in place of UserCommunication                                                   	 
----------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Communication_CommunicationCohorts_Select] 

       (
        @i_AppUserId KEYID
       ,@v_ApprovalState1 VARCHAR(30)
       ,@v_ApprovalState2 VARCHAR(30) = NULL
       ,@i_CommunicationId KEYID = NULL
       ,@v_StatusCode STATUSCODE = NULL
       )
AS
BEGIN TRY

      SET NOCOUNT ON	
	-- Check if valid Application User ID is passed

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )

         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      IF @i_CommunicationId IS NULL
         SELECT
             Communication.CommunicationId
            ,Communication.CommunicationTemplateId
            ,CommunicationTemplate.TemplateName
            ,CommunicationTemplate.Description
            ,Communication.CommunicationTypeId
            ,CommunicationType.CommunicationType
            ,CommunicationTemplate.SubjectText
            ,CommunicationTemplate.NotifyCommunicationTemplateId
            ,CommunicationTemplate.CommunicationText
            ,Communication.SenderEmailAddress
            ,Communication.IsDraft
            ,Communication.SubmittedDate
            ,Communication.ApprovalState
            ,Communication.ApprovalDate
            ,Communication.CreatedByUserId
            ,Communication.CreatedDate
            ,Communication.PrintDate
            ,Communication.LastModifiedByUserId
            ,ISNULL(Communication.LastModifiedDate , Communication.CreatedDate) AS LastUsedDate
            ,CASE Communication.StatusCode
               WHEN 'A' THEN 'Active'
               WHEN 'I' THEN 'Inactive'
             END AS StatusDescription
         FROM
             Communication  WITH (NOLOCK) 
             INNER JOIN CommunicationTemplate  WITH (NOLOCK) 
               ON Communication.CommunicationTemplateId = CommunicationTemplate.CommunicationTemplateId
			 INNER JOIN CommunicationType  WITH (NOLOCK) 
               ON CommunicationType.CommunicationTypeId = Communication.CommunicationTypeId
         WHERE
               (Communication.CommunicationId = @i_CommunicationId OR @i_CommunicationId IS NULL )
           AND (Communication.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
           AND Communication.ApprovalState IN ( @v_ApprovalState1 , ISNULL(@v_ApprovalState2 , '') )
         ORDER BY
             Communication.CommunicationId DESC
      ELSE
         BEGIN
               SELECT TOP 1
                   Communication.CommunicationId
                  ,Communication.CommunicationTemplateId
                  ,CommunicationTemplate.TemplateName
                  ,CommunicationTemplate.Description
                  ,Communication.CommunicationTypeId
                  ,(SELECT CommunicationType FROM CommunicationType WHERE CommunicationTypeId = Communication.CommunicationTypeId) AS CommunicationType
                  ,ISNULL(PatientCommunication.SubjectText , CommunicationTemplate.SubjectText) AS SubjectText
                  ,CommunicationTemplate.NotifyCommunicationTemplateId
                  ,ISNULL(PatientCommunication.CommunicationText , CommunicationTemplate.CommunicationText) AS CommunicationText
                  ,Communication.SenderEmailAddress
                  ,Communication.IsDraft
                  ,Communication.SubmittedDate
                  ,Communication.ApprovalState
                  ,Communication.ApprovalDate
                  ,Communication.CreatedByUserId
                  ,Communication.CreatedDate
                  ,Communication.PrintDate
                  ,Communication.LastModifiedByUserId
                  ,ISNULL(Communication.LastModifiedDate , Communication.CreatedDate) AS LastUsedDate
                  ,CASE Communication.StatusCode
                     WHEN 'A' THEN 'Active'
                     WHEN 'I' THEN 'Inactive'
                   END AS StatusDescription
               FROM
                   Communication  WITH (NOLOCK) 
                   INNER JOIN CommunicationTemplate  WITH (NOLOCK) 
                     ON Communication.CommunicationTemplateId = CommunicationTemplate.CommunicationTemplateId
                   LEFT OUTER JOIN PatientCommunication  WITH (NOLOCK) 
                     ON PatientCommunication.CommunicationId = Communication.CommunicationId
               WHERE
                   Communication.CommunicationId = @i_CommunicationId
         END
      IF @i_CommunicationId IS NOT NULL
         BEGIN

               SELECT
                   CommunicationTemplateAttachments.LibraryId
                  ,Library.Name
                  ,Library.Description
                  ,Library.PhysicalFileName
                  ,Library.DocumentNum
                  ,Library.DocumentLocation
                  ,Library.eDocument
                  ,Library.DocumentSourceCompany
               FROM
                   Communication  WITH (NOLOCK) 
                   INNER JOIN CommunicationTemplateAttachments  WITH (NOLOCK) 
                     ON Communication.CommunicationTemplateId = CommunicationTemplateAttachments.CommunicationTemplateId
                   INNER JOIN Library  WITH (NOLOCK) 
                     ON CommunicationTemplateAttachments.LibraryId = Library.LibraryId
               WHERE
                   Communication.CommunicationId = @i_CommunicationId 

/*		SELECT CommunicationCohorts.CohortListId,
			   CommunicationCohorts.UserID,
			   CommunicationCohorts.IsExcludedByPreference,
*/
               SELECT DISTINCT
                   PopulationDefinition.PopulationDefinitionID 
                  ,PopulationDefinition.PopulationDefinitionName 
               FROM
                   CommunicationCohorts  WITH (NOLOCK) 
                   INNER JOIN PopulationDefinition  WITH (NOLOCK) 
                     ON CommunicationCohorts.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID
               WHERE
                   CommunicationId = @i_CommunicationId

         END
END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_CommunicationCohorts_Select] TO [FE_rohit.r-ext]
    AS [dbo];

