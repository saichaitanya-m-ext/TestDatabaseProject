/*
--------------------------------------------------------------------------------
Procedure Name: [usp_UserCommunication_SelectByCommunicationId]
Description	  : This procedure is used to show the SMS Text details
Created By    :	NagaBabu
Created Date  : 23-Nov-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
24-Nov-2011 NagaBabu Added select statement from CommunicationSMSConfiguration table
19-mar-2013 P.V.P.Mohan Modified UserCommunication to PatientCommunication and Users to Patient table.
---------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_UserCommunication_SelectByCommunicationId] 
(
	@i_AppUserId KEYID,
	@i_CommunicationId KEYID = NULL
)
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
		
		SELECT 
			Patient.PatientID UserId ,
			'+' + Patient.PrimaryAddressCountryCode + Patient.PrimaryPhoneNumber  AS PhoneNumber,
			REPLACE(CommunicationText,'<BR />','') AS CommunicationText
		FROM PatientCommunication  with (nolock)
		INNER JOIN Patient  with (nolock)
			ON Patient.PatientID = PatientCommunication.PatientID 				
		WHERE CommunicationId = @i_CommunicationId
		  AND ('+' + Patient.PrimaryAddressCountryCode + Patient.PrimaryPhoneNumber IS NOT NULL OR ('+' + Patient.PrimaryAddressCountryCode + Patient.PrimaryPhoneNumber) <> '+1') 
			 	
		SELECT
			CommunicationSMSConfigurationId ,
			SMSUserLogin ,
			SMSUserPassword ,
			SMSCompression
		FROM
			CommunicationSMSConfiguration	
			
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserCommunication_SelectByCommunicationId] TO [FE_rohit.r-ext]
    AS [dbo];

