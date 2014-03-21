
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_Get_SMSIntegrationforPatient      
Description   : This procedure is used to get the SMS Integration for Patient  
Created By    : Suresh G          
Created Date  : 01-May-2012     
usp_Get_SMSIntegrationforPatient 23,144338,1  
@i_PageType :- AdhocTask = 0 PatientCommunication = 1 MassCommunication = 2  defaultpage = 3
------------------------------------------------------------------------------          
Log History   :       
DD-Mon-YYYY  BY  DESCRIPTION  
02-May-2012 Nagababu Added PatientName,Phone,SMSDetails fields to first resultset  
18-Mar-2013 P.V.P.Mohan changed Table name for userCommunication to PatientCommunication,Users to Patient
			 and Modified PatientID in place of UserID.
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Get_SMSIntegrationforPatient] (
	@i_AppUserId KEYID
	,@i_PatientUserId INT --Same AS Communication_Id
	,@i_PageType INT
	)
AS
BEGIN
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

		IF (@i_PageType = 0) --For AdhocTask
		BEGIN
			SELECT DISTINCT Patient.PatientID UserId
				,'+' + ISNULL(CodeSetCountry.CountryCode, '') + Patient.PrimaryPhoneNumber AS PhoneNumber
				,'Dear' + '  ' + + COALESCE(ISNULL(Patient.LastName, '') + ', ' + ISNULL(Patient.FirstName, '') + ' ' + ISNULL(Patient.MiddleName, '') + ' ' + ISNULL(Patient.NameSuffix, ''), '') + 'you are due for' + ' ' + TaskType.TaskTypeName + ' ' + 'on' + ' ' + CAST(Task.TaskDueDate AS VARCHAR) AS SMSDetails
			FROM Patient
			INNER JOIN Task ON Task.PatientId = Patient.PatientId
			INNER JOIN TaskAttempts ON TaskAttempts.TaskId = Task.TaskId
			INNER JOIN CommunicationType ON CommunicationType.CommunicationTypeId = TaskAttempts.CommunicationTypeId
			INNER JOIN TaskType ON Task.TaskTypeId = TaskType.TaskTypeId
			INNER JOIN TaskStatus ON TaskStatus.TaskStatusId = Task.TaskStatusId
			INNER JOIN CodeSetCountry ON CodeSetCountry.CountryID = Patient.PrimaryAddressCountyID
			WHERE CommunicationType.CommunicationType = 'SMS'
				AND Task.PatientId = @i_PatientUserId
		END

		IF (@i_PageType = 1) -- For PatientCommunication
		BEGIN
			SELECT DISTINCT Patient.PatientID UserId
				,'+' + ISNULL(CodeSetCountry.CountryCode, '') + Patient.PrimaryPhoneNumber AS PhoneNumber
				,REPLACE(CommunicationText, '<BR />', '') AS SMSDetails
				,PatientCommunicationId
			FROM PatientCommunication
			INNER JOIN Patient ON Patient.PatientId = PatientCommunication.PatientId
			INNER JOIN CommunicationType ON CommunicationType.CommunicationTypeId = PatientCommunication.CommunicationTypeId
			INNER JOIN CodeSetCountry ON CodeSetCountry.CountryID = Patient.PrimaryAddressCountyID
			WHERE CommunicationType.CommunicationType = 'SMS'
				AND Patient.UserId = @i_PatientUserId
		END

		IF (@i_PageType = 2) --For MassCommunication
		BEGIN
			SELECT DISTINCT Patient.PatientID UserId
				,'+' + ISNULL(CodeSetCountry.CountryCode, '') + Patient.PrimaryPhoneNumber AS PhoneNumber
				,REPLACE(CommunicationText, '<BR />', '') AS SMSDetails
			FROM PatientCommunication
			INNER JOIN Patient ON Patient.PatientId = PatientCommunication.PatientId
			INNER JOIN CodeSetCountry ON CodeSetCountry.CountryID = Patient.PrimaryAddressCountyID
			WHERE CommunicationId = @i_PatientUserId
				AND (
					'+' + CodeSetCountry.CountryCode + Patient.PrimaryPhoneNumber IS NOT NULL
					OR ('+' + CodeSetCountry.CountryCode + Patient.PrimaryPhoneNumber) <> '+1'
					)
		END

		SELECT CommunicationSMSConfigurationId
			,SMSUserLogin
			,SMSUserPassword
			,SMSCompression
		FROM CommunicationSMSConfiguration(NOLOCK)
	END TRY

	--------------------------------------------------------------------------------------------------------------------------------------------------------------------------          
	BEGIN CATCH
		-- Handle exception      
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Get_SMSIntegrationforPatient] TO [FE_rohit.r-ext]
    AS [dbo];

