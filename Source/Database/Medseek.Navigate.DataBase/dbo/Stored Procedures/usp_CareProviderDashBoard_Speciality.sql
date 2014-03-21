/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CareProviderDashBoard_Speciality]
Description   : 
Created By    : 
Created Date  : 
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_Speciality]
(
 @i_AppUserId KEYID
,@i_PatientUserID KEYID
)
AS
BEGIN TRY
      SET NOCOUNT ON         
      -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
      SELECT
          UserProviders.ProviderUserId
         ,UserProviders.PatientUserId
         ,Speciality.SpecialityName
         ,dbo.ufn_GetUserNameByID(UserProviders.ProviderUserId) AS ProviderName
      FROM
          UserSpeciality WITH(NOLOCK)
      INNER JOIN UserProviders WITH(NOLOCK)
          ON UserProviders.ProviderUserId = UserSpeciality.UserId
      INNER JOIN Speciality WITH(NOLOCK)
          ON Speciality.SpecialityId = UserSpeciality.SpecialityId
      WHERE
          UserProviders.PatientUserId = @i_PatientUserID
END TRY        
-------------------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_Speciality] TO [FE_rohit.r-ext]
    AS [dbo];

