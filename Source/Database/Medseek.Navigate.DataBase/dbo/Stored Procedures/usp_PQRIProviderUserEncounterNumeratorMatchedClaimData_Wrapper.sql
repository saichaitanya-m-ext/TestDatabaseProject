/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIProviderUserEncounterNumeratorMatchedClaimData_Select]    
Description   :  This procedure is used for PQRIProviderUserTransaction based on PQRIProviderUserEncounterID
Created By    :  Rathnam
Created Date  :  02-Feb-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/   ---[usp_PQRIProviderUserEncounterNumeratorMatchedClaimData_Wrapper]22,27405
CREATE PROCEDURE [dbo].[usp_PQRIProviderUserEncounterNumeratorMatchedClaimData_Wrapper]
       (
        @i_AppUserId KEYID
       ,@i_PQRIProviderUserEncounterID KEYID
       )
AS
BEGIN TRY
      SET NOCOUNT ON

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      IF NOT EXISTS ( SELECT
                          1
                      FROM
                          PQRIProviderUserEncounterNumeratorMatch
                      INNER JOIN PQRIProviderUserEncounter
                          ON PQRIProviderUserEncounter.PQRIProviderUserEncounterID = PQRIProviderUserEncounterNumeratorMatch.PQRIProviderUserEncounterID
                      INNER JOIN PQRIProviderPersonalization
                          ON PQRIProviderPersonalization.PQRIProviderPersonalizationID = PQRIProviderUserEncounter.PQRIProviderPersonalizationID
                      WHERE
                          PQRIProviderUserEncounter.PQRIProviderUserEncounterID = @i_PQRIProviderUserEncounterID
                          AND ProviderUserID = @i_AppUserId 
                    )

         BEGIN
               EXEC usp_PQRIProviderUserEncounterNumeratorMatchedClaimData_Insert 
                    @i_AppUserId = @i_AppUserId , 
                    @i_PQRIProviderUserEncounterID = @i_PQRIProviderUserEncounterID
                    
               EXEC usp_PQRIProviderUserEncounterNumeratorMatchedClaimData_Select 
                    @i_AppUserId = @i_AppUserId , 
                    @i_PQRIProviderUserEncounterID = @i_PQRIProviderUserEncounterID
         END
      ELSE
         BEGIN
               EXEC usp_PQRIProviderUserEncounterNumeratorMatchedClaimData_Select 
                    @i_AppUserId = @i_AppUserId , 
                    @i_PQRIProviderUserEncounterID = @i_PQRIProviderUserEncounterID
         END
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
    ON OBJECT::[dbo].[usp_PQRIProviderUserEncounterNumeratorMatchedClaimData_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

