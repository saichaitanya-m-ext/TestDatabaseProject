
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_UserCommunication_Select 10,91516,1,null,0,null,0 
Description   : This procedure is used to get the detais from UserCommunication
				table.      
Created By    : Aditya        
Created Date  : 19-May-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
17-Jun-10 Pramod Added cohortlistid in the query
23-Jun-10 Pramod Included Communication Text in the query and changed FROM INNER JOIN to LEFT OUER JOIN
30-Jun-10 Pramod Included the field "MassCommunicationFlag" into the select
07-July-10 NagaBabu Added ORDER BY Clause
15-July-10 NagaBabu Included CommunicationState field in select statement
04-Aug-2010 NagaBabu Replaced CommunicationText text field in select statement and 
                     added an other variable @fullname
25-Aug-2010 NagaBabu Added MergedIntoUserCommunicationID field to the select statement for showing merged letters 
10-Nov-10 Pramod Modified the select to include IsMergedLetter field
07-Jan-2013 Praveen Added ProgramID in select command.
28-Jan-2013 Praveen Added 2 nullable parameters to call same sp for UserNotes section
19-mar-2013 P.V.P.Mohan Modfified UserCommunication Table to Patient Communication and modified Columns
4-APR-2013 P.V.P.Mohan Modfified In select Query  for AssignedCareProviderId Column
10-APR-2013 P.V.P.Mohan Modfified patient Table to Provider Table and PatientCommunication 
------------------------------------------------------------------------------        
*/
--select * from Provider order by 1 desc  
--select * from PatientCommunication where PatientId = 1 
CREATE PROCEDURE [dbo].[usp_UserCommunication_Select] --10,NULL,1,'A',0,NULL,0
	(
	@i_AppUserId KEYID
	,@i_UserCommunicationId KEYID = NULL
	,@i_UserId KEYID
	,@v_StatusCode StatusCode = NULL
	,@i_TopParam BIT = 0
	,@v_NoteType CHAR(1) = NULL
	,-- P - Patient note, V - Visit Plan (From User, 'V' need to be passed)    
	@b_ShowLastOneYearData BIT = 0
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

	---- Records from UserCommunication,CommunicationType,CommunicationTemplate details are retrieved here -------------------  
	DECLARE @fullname VARCHAR(50)

	SELECT @fullname = FullName
	FROM Patients
	WHERE PatientID = @i_UserId

	IF @i_TopParam = 0
	BEGIN
		SELECT PatientCommunication.PatientCommunicationId UserCommunicationId
			,PatientCommunication.PatientId UserId
			,PatientCommunication.CommunicationTypeId
			,CommunicationType.CommunicationType AS Type
			,PatientCommunication.DateScheduled
			,PatientCommunication.DateSent
			,PatientCommunication.DateDue
			,CASE 
				WHEN PatientCommunication.CommunicationId IS NOT NULL
					THEN 'YES'
				ELSE 'NO'
				END AS MassCommunicationFlag
			,PatientCommunication.eMailDeliveryState
			,PatientCommunication.CommunicationTemplateId
			,CommunicationTemplate.TemplateName
			,CASE PatientCommunication.StatusCode
				WHEN 'A'
					THEN 'Active'
				WHEN 'I'
					THEN 'InActive'
				END AS StatusDescription
			,PatientCommunication.CreatedByUserId
			,PatientCommunication.CreatedDate
			,PatientCommunication.LastModifiedByUserId
			,PatientCommunication.LastModifiedDate
			,(
				SELECT REPLACE(PatientCommunication.CommunicationText, '[FullName]', @fullname)
				) AS CommunicationText
			,PatientCommunication.SubjectText
			,ISNULL(PatientCommunication.SenderEmailAddress, (
					SELECT PrimaryEmailAddress
					FROM Provider
					WHERE ProviderID = PatientCommunication.SentByUserID
						AND AccountStatusCode = 'A'
					)) AS SenderEmailAddress
			,(
				SELECT PrimaryEmailAddress
				FROM Patient
				WHERE PatientID = PatientCommunication.PatientId
					AND AccountStatusCode = 'A'
				) AS SendToEmailAddress
			,(
				SELECT TOP 1 PopulationDefinition.PopulationDefinitionName
				FROM CommunicationCohorts WITH (NOLOCK)
				INNER JOIN PopulationDefinition WITH (NOLOCK) ON CommunicationCohorts.PopulationDefinitionId = PopulationDefinition.PopulationDefinitionId
				WHERE CommunicationCohorts.CommunicationId = PatientCommunication.CommunicationId
					AND CommunicationCohorts.UserId = PatientCommunication.PatientId
				) AS CohortListName
			,PatientCommunication.CommunicationState
			,PatientCommunication.MergedIntoUserCommunicationID
			,CASE 
				WHEN PatientCommunication.IsMergedLetter = 1
					THEN 'YES'
				ELSE 'NO'
				END AS MergeCommunicationFlag
			,PatientCommunication.ProgramID
			,PatientCommunication.AssignedCareProviderId
		FROM PatientCommunication WITH (NOLOCK)
		LEFT OUTER JOIN CommunicationTemplate WITH (NOLOCK) ON CommunicationTemplate.CommunicationTemplateId = PatientCommunication.CommunicationTemplateId
		LEFT OUTER JOIN CommunicationType WITH (NOLOCK) ON CommunicationType.CommunicationTypeId = PatientCommunication.CommunicationTypeId
		LEFT OUTER JOIN Program WITH (NOLOCK) ON Program.ProgramId = PatientCommunication.ProgramID
		WHERE (
				PatientCommunication.PatientCommunicationId = @i_UserCommunicationId
				OR @i_UserCommunicationId IS NULL
				)
			AND (
				PatientCommunication.PatientId = @i_UserId
				OR @i_UserId IS NULL
				)
			AND (
				PatientCommunication.StatusCode = @v_StatusCode
				OR @v_StatusCode IS NULL
				)
		ORDER BY PatientCommunication.DateDue DESC
	END
	ELSE
	BEGIN
		SELECT TOP 5 PatientCommunication.PatientCommunicationId UserCommunicationId
			,PatientCommunication.PatientId UserId
			,PatientCommunication.CommunicationTypeId
			,CommunicationType.CommunicationType AS Type
			,PatientCommunication.DateScheduled
			,PatientCommunication.DateSent
			,PatientCommunication.DateDue
			,CASE 
				WHEN PatientCommunication.CommunicationId IS NOT NULL
					THEN 'YES'
				ELSE 'NO'
				END AS MassCommunicationFlag
			,PatientCommunication.eMailDeliveryState
			,PatientCommunication.CommunicationTemplateId
			,CommunicationTemplate.TemplateName
			,CASE PatientCommunication.StatusCode
				WHEN 'A'
					THEN 'Active'
				WHEN 'I'
					THEN 'InActive'
				END AS StatusDescription
			,PatientCommunication.CreatedByUserId
			,PatientCommunication.CreatedDate
			,PatientCommunication.LastModifiedByUserId
			,PatientCommunication.LastModifiedDate
			,(
				SELECT REPLACE(PatientCommunication.CommunicationText, '[FullName]', @fullname)
				) AS CommunicationText
			,PatientCommunication.SubjectText
			,ISNULL(PatientCommunication.SenderEmailAddress, (
					SELECT PrimaryEmailAddress
					FROM Patient
					WHERE UserId = PatientCommunication.SentByUserID
						AND AccountStatusCode = 'A'
					)) AS SenderEmailAddress
			,(
				SELECT PrimaryEmailAddress
				FROM Patient
				WHERE UserId = PatientCommunication.SentByUserID
					AND AccountStatusCode = 'A'
				) AS SendToEmailAddress
			,(
				SELECT TOP 1 PopulationDefinition.PopulationDefinitionName
				FROM CommunicationCohorts
				INNER JOIN PopulationDefinition ON CommunicationCohorts.PopulationDefinitionId = PopulationDefinition.PopulationDefinitionId
				WHERE CommunicationCohorts.CommunicationId = PatientCommunication.CommunicationId
					AND CommunicationCohorts.UserId = PatientCommunication.PatientId
				) AS CohortListName
			,PatientCommunication.CommunicationState
			,PatientCommunication.MergedIntoUserCommunicationID
			,CASE 
				WHEN PatientCommunication.IsMergedLetter = 1
					THEN 'YES'
				ELSE 'NO'
				END AS MergeCommunicationFlag
		FROM PatientCommunication WITH (NOLOCK)
		LEFT OUTER JOIN CommunicationTemplate WITH (NOLOCK) ON CommunicationTemplate.CommunicationTemplateId = PatientCommunication.CommunicationTemplateId
		LEFT OUTER JOIN CommunicationType WITH (NOLOCK) ON CommunicationType.CommunicationTypeId = PatientCommunication.CommunicationTypeId
		WHERE (
				PatientCommunication.PatientCommunicationId = @i_UserCommunicationId
				OR @i_UserCommunicationId IS NULL
				)
			AND (
				PatientCommunication.PatientId = @i_UserId
				OR @i_UserId IS NULL
				)
			AND (
				PatientCommunication.StatusCode = @v_StatusCode
				OR @v_StatusCode IS NULL
				)
		ORDER BY PatientCommunication.CreatedDate DESC

		EXEC usp_UserNotes_Select @i_AppUserId
			,@i_UserId
			,@v_StatusCode
			,@v_NoteType
			,@b_ShowLastOneYearData
	END
END TRY

BEGIN CATCH
	-- Handle exception        
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserCommunication_Select] TO [FE_rohit.r-ext]
    AS [dbo];

