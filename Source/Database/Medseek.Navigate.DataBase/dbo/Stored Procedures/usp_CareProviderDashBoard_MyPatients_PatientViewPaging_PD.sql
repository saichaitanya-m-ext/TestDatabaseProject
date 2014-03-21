/*    
--------------------------------------------------------------------------------------------------------------    
Procedure Name: usp_CareProviderDashBoard_MyPatients_PatientViewPaging 23,1,50
Description   : This procedure is to be used for applying filter on care provider dashboard on MyPatients tab by Patientview
Created By    : Rathnam
Created Date  : 18-Dec-2010  
---------------------------------------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY  DESCRIPTION  
---------------------------------------------------------------------------------------------------------------    
*/  --exec usp_CareProviderDashBoard_MyPatients_PatientViewPaging_PD @i_AppUserId = 23
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyPatients_PatientViewPaging_PD]
(
 @i_AppUserId KEYID
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
      DECLARE @i_PatientID INT
      IF EXISTS ( SELECT
                      1
                  FROM
                      CareTeamMembers ctm
                  WHERE
                      ctm.ProviderID = @i_AppUserId
                      AND IsCareTeamManager = 1 )
         BEGIN
               SELECT TOP ( 1 )
                   @i_PatientID = pp.PatientID
               FROM
                   PatientProgram pp WITH ( NOLOCK )
               INNER JOIN Patients p
                   ON p.PatientID = pp.PatientID
               INNER JOIN ProgramCareTeam ppc WITH ( NOLOCK )
                   ON ppc.ProgramID = pp.ProgramID
               INNER JOIN CareTeamMembers ctm WITH ( NOLOCK )
                   ON ctm.CareTeamID = ppc.CareTeamID
               WHERE
                   ctm.ProviderID = @i_AppUserId
                   AND pp.StatusCode = 'A'
                   AND ctm.StatusCode = 'A'
                   AND p.UserStatusCode = 'A'
               ORDER BY
                   1
         END
      ELSE
         BEGIN

               SELECT TOP ( 1 )
                   @i_PatientID = PatientProgram.PatientID
               FROM
                   PatientProgram WITH ( NOLOCK )
               INNER JOIN Patients 
                   ON Patients.PatientID = PatientProgram.PatientID        
               INNER JOIN ProgramCareTeam WITH ( NOLOCK )
                   ON ProgramCareTeam.ProgramID = PatientProgram.ProgramID
               INNER JOIN CareTeamMembers WITH ( NOLOCK )
                   ON CareTeamMembers.CareTeamID = ProgramCareTeam.CareTeamID
               WHERE
                   CareTeamMembers.ProviderID = @i_AppUserId
                   AND CareTeamMembers.ProviderID = PatientProgram.ProviderID
                   AND PatientProgram.StatusCode = 'A'
                   AND CareTeamMembers.StatusCode = 'A'
                   AND Patients.UserStatusCode = 'A'
               ORDER BY
                   1
         END
         SELECT ISNULL(@i_PatientID,0) IsPatient
END TRY
BEGIN CATCH    
----------------------------------------------------------------------------------------------------------   
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyPatients_PatientViewPaging_PD] TO [FE_rohit.r-ext]
    AS [dbo];

