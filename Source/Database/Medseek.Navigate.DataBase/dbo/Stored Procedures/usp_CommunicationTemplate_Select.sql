
/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[Usp_CommunicationTemplate_Select]
Description	  : This procedure is used to select the data from Communication Templates. 
Created By    :	Aditya
Created Date  : 30-Apr-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
25-May-2010 Pramod Order by CommunicationTemplateId is included in the query
					LastUsed is changed to make LastModifiedDate for CommunicationTemplate
					LastUsed is changed to keep MAX(SentDate) from the communication table
					for the particular template
21-June-2010 NagaBabu Added MimeType field in second select statement
28-June-2011 NagaBabu Joined Communication table with CommunicationTemplate and added CASE statement to LastSentDate
						field in first select Statement
29-June-2011 NagaBabu Deleted Join with Communication table and deleted case statement  
11-July-2011 NagaBabu Added CASE statement for the field LastSentDate  						
----------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_CommunicationTemplate_Select] (
	@i_AppUserId KEYID
	,@i_CommunicationTemplateId KEYID = NULL
	,@v_StatusCode StatusCode = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	SELECT DISTINCT CommunicationTemplate.CommunicationTemplateId
		,(
			CASE 
				WHEN CommunicationType.CommunicationType = 'Letter'
					THEN (
							SELECT MAX(Communication.PrintDate)
							FROM Communication
							WHERE Communication.CommunicationTemplateId = CommunicationTemplate.CommunicationTemplateId
							)
				ELSE (
						SELECT MAX(Communication.CommunicationSentDate)
						FROM Communication
						WHERE Communication.CommunicationTemplateId = CommunicationTemplate.CommunicationTemplateId
						)
				END
			) AS LastSentDate
		,CommunicationTemplate.TemplateName
		,CommunicationTemplate.Description
		,CommunicationTemplate.CommunicationTypeId
		,CommunicationType.CommunicationType
		,CommunicationTemplate.SubjectText
		,CommunicationTemplate.SenderEmailAddress
		,CommunicationTemplate.IsDraft
		,CommunicationTemplate.NotifyCommunicationTemplateId
		,CommunicationTemplate.CommunicationText
		,CommunicationTemplate.SubmittedDate
		,CommunicationTemplate.ApprovalState
		,CommunicationTemplate.CreatedByUserId
		,CommunicationTemplate.CreatedDate
		,CommunicationTemplate.LastModifiedByUserId
		,CommunicationTemplate.LastModifiedDate
		,CASE CommunicationTemplate.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'Inactive'
			END AS StatusDescription
	FROM CommunicationTemplate WITH (NOLOCK)
	INNER JOIN CommunicationType WITH (NOLOCK) ON CommunicationType.CommunicationTypeId = CommunicationTemplate.CommunicationTypeId
	WHERE (
			CommunicationTemplate.CommunicationTemplateId = @i_CommunicationTemplateId
			OR @i_CommunicationTemplateId IS NULL
			)
		AND (
			CommunicationTemplate.StatusCode = @v_StatusCode
			OR @v_StatusCode IS NULL
			)
	ORDER BY CommunicationTemplate.CommunicationTemplateId DESC

	IF @i_CommunicationTemplateId IS NOT NULL
	BEGIN
		SELECT CommunicationTemplateAttachments.LibraryId
			,Library.NAME
			,Library.Description
			,Library.PhysicalFileName
			,Library.DocumentNum
			,Library.DocumentLocation
			,Library.eDocument
			,Library.DocumentSourceCompany
			,Library.MimeType
		FROM CommunicationTemplateAttachments WITH (NOLOCK)
		INNER JOIN Library WITH (NOLOCK) ON CommunicationTemplateAttachments.LibraryId = Library.LibraryId
		WHERE CommunicationTemplateId = @i_CommunicationTemplateId
	END
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CommunicationTemplate_Select] TO [FE_rohit.r-ext]
    AS [dbo];

