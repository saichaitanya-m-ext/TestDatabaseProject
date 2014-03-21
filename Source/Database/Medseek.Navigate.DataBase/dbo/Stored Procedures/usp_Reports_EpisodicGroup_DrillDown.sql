
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_EpisodeGroupers_DrillDown        
Description   : This procedrue is used to get the EpisodeGroupers,UsersEpisode Patients drilldown   
Created By    : Rathnam
Created Date  : 16-Nov-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Reports_EpisodicGroup_DrillDown]
(
 @i_AppUserId KEYID ,
 @i_GrouperSystemId KEYID ,
 @i_GrouperDiseaseID KEYID ,
 @i_GrouperStageID KEYID = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON         
-- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
      IF @i_GrouperDiseaseID IS NOT NULL
      AND @i_GrouperStageID IS NULL
         BEGIN
               SELECT
                   p.UserId ,
                   ISNULL(p.MemberNum , '') MemberNum ,
                   p.FullName AS PatientName ,
                   CASE
                        WHEN p.PhoneNumberPrimary = ' ' THEN NULL
                        ELSE P.PhoneNumberPrimary
                   END AS PhoneNumberPrimary ,
                   (
                     SELECT
                         CallTimeName
                     FROM
                         CallTimePreference
                     WHERE
                         CallTimePreferenceId = P.CallTimePreferenceId
                   ) AS CallTimePreference ,
                   CONVERT(VARCHAR , ISNULL(Age , '')) + ' ' + ISNULL(Gender , '') AgeAndGender ,
                   (
                     SELECT TOP 1
                         ISNULL(CONVERT(VARCHAR , ISNULL(ScheduledDate , DateDue) , 101) , '')
                     FROM
                         UserEncounters
                     WHERE
                         Userid = P.Userid
                         AND StatusCode = 'A'
                         AND EncounterDate IS NULL
                     ORDER BY
                         EncounterDate DESC
                   ) AS NextOfficeVisit ,
                   (
                     SELECT TOP 1
                         ISNULL(CONVERT(VARCHAR , EncounterDate , 101) , '')
                     FROM
                         UserEncounters
                     WHERE
                         Userid = p.Userid
                         AND StatusCode = 'A'
                         AND EncounterDate IS NOT NULL
                     ORDER BY
                         EncounterDate DESC
                   ) AS LastOfficeVisit ,
                   REPLACE(REPLACE(STUFF((
                                           SELECT TOP 2
                                               ', ' + ProgramName
                                           FROM
                                               Program
                                           INNER JOIN UserPrograms
                                               ON UserPrograms.ProgramId = Program.ProgramId
                                           WHERE
                                               UserPrograms.Userid = p.Userid
                                               AND UserPrograms.EnrollmentStartDate IS NOT NULL
                                               AND UserPrograms.EnrollmentEndDate IS NULL
                                               AND UserPrograms.IsPatientDeclinedEnrollment = 0
                                               AND Program.StatusCode = 'A'
                                               AND UserPrograms.StatusCode = 'A'
                                           ORDER BY
                                               UserPrograms.EnrollmentStartDate DESC
                                           FOR
                                               XML PATH('')
                                         ) , 1 , 2 , '') , '&GT' , '>') , '&LT' , '<') AS ProgramName ,
                   STUFF((
                           SELECT TOP 2
                               ', ' + Name
                           FROM
                               Disease WITH (NOLOCK)
                           INNER JOIN UserDisease WITH (NOLOCK)
                               ON UserDisease.DiseaseId = Disease.DiseaseId
                           WHERE
                               UserDisease.Userid = p.Userid
                               AND UserDisease.DiagnosedDate IS NOT NULL
                               AND UserDisease.StatusCode = 'A'
                               AND Disease.StatusCode = 'A'
                           ORDER BY
                               UserDisease.DiagnosedDate DESC
                           FOR
                               XML PATH('')
                         ) , 1 , 2 , '') AS DiseaseName ,
                   (
                     SELECT
                         COUNT(ISNULL(CONVERT(VARCHAR , UserPrograms.EnrollmentStartDate , 101) , '') + ' - ' + ISNULL(Program.ProgramName , ''))
                     FROM
                         Program  WITH (NOLOCK)
                     INNER JOIN UserPrograms WITH (NOLOCK)
                         ON UserPrograms.ProgramId = Program.ProgramId
                     WHERE
                         UserPrograms.Userid = p.Userid
                         AND UserPrograms.EnrollmentStartDate IS NOT NULL
                         AND UserPrograms.EnrollmentEndDate IS NULL
                         AND UserPrograms.IsPatientDeclinedEnrollment = 0
                         AND Program.StatusCode = 'A'
                         AND UserPrograms.StatusCode = 'A'
                   ) AS ProgramCount ,
                   (
                     SELECT
                         COUNT(Disease.DiseaseId)
                     FROM
                         Disease WITH (NOLOCK)
                     INNER JOIN UserDisease WITH (NOLOCK)
                         ON UserDisease.DiseaseId = Disease.DiseaseId
                     WHERE
                         UserDisease.Userid = p.Userid
                         AND UserDisease.DiagnosedDate IS NOT NULL
                         AND UserDisease.StatusCode = 'A'
                         AND Disease.StatusCode = 'A'
                   ) AS DiseaseCount ,
                   gst.StageID Stage ,
                   gst.Description
               FROM
                   Patients P WITH (NOLOCK)
               INNER JOIN UserEpisodicGroup ueg WITH (NOLOCK)
                   ON ueg.PatientUserID = p.UserId
               INNER JOIN GrouperStage gst WITH (NOLOCK)
                   ON ueg.GrouperStageID = gst.GrouperStageId
               INNER JOIN GrouperDisease gd WITH (NOLOCK)
                   ON gd.GrouperDiseaseId = gst.GrouperDiseaseID
               INNER JOIN GrouperSystem gs WITH (NOLOCK)
                   ON gs.GrouperSystemId = gd.GrouperSystemID
               WHERE
                   gs.GrouperSystemId = @i_GrouperSystemId
                   AND gd.GrouperDiseaseId = @i_GrouperDiseaseID
                   AND ueg.StatusCode = 'A'
                   AND gd.StatusCode = 'A'
                   AND gs.StatusCode = 'A'
         END
      ELSE
         BEGIN
               IF @i_GrouperDiseaseID IS NOT NULL
               AND @i_GrouperStageID IS NOT NULL
                  BEGIN
                        SELECT
                            p.UserId ,
                            ISNULL(p.MemberNum , '') MemberNum ,
                            p.FullName AS PatientName ,
                            CASE
                                 WHEN p.PhoneNumberPrimary = ' ' THEN NULL
                                 ELSE P.PhoneNumberPrimary
                            END AS PhoneNumberPrimary ,
                            (
                              SELECT
                                  CallTimeName
                              FROM
                                  CallTimePreference
                              WHERE
                                  CallTimePreferenceId = P.CallTimePreferenceId
                            ) AS CallTimePreference ,
                            CONVERT(VARCHAR , ISNULL(Age , '')) + ' ' + ISNULL(Gender , '') AgeAndGender ,
                            (
                              SELECT TOP 1
                                  ISNULL(CONVERT(VARCHAR , ISNULL(ScheduledDate , DateDue) , 101) , '')
                              FROM
                                  UserEncounters
                              WHERE
                                  Userid = P.Userid
                                  AND StatusCode = 'A'
                                  AND EncounterDate IS NULL
                              ORDER BY
                                  EncounterDate DESC
                            ) AS NextOfficeVisit ,
                            (
                              SELECT TOP 1
                                  ISNULL(CONVERT(VARCHAR , EncounterDate , 101) , '')
                              FROM
                                  UserEncounters
                              WHERE
                                  Userid = p.Userid
                                  AND StatusCode = 'A'
                                  AND EncounterDate IS NOT NULL
                              ORDER BY
                                  EncounterDate DESC
                            ) AS LastOfficeVisit ,
                            REPLACE(REPLACE(STUFF((
                                                    SELECT TOP 2
                                                        ', ' + ProgramName
                                                    FROM
                                                        Program
                                                    INNER JOIN UserPrograms
                                                        ON UserPrograms.ProgramId = Program.ProgramId
                                                    WHERE
                                                        UserPrograms.Userid = p.Userid
                                                        AND UserPrograms.EnrollmentStartDate IS NOT NULL
                                                        AND UserPrograms.EnrollmentEndDate IS NULL
                                                        AND UserPrograms.IsPatientDeclinedEnrollment = 0
                                                        AND Program.StatusCode = 'A'
                                                        AND UserPrograms.StatusCode = 'A'
                                                    ORDER BY
                                                        UserPrograms.EnrollmentStartDate DESC
                                                    FOR
                                                        XML PATH('')
                                                  ) , 1 , 2 , '') , '&GT' , '>') , '&LT' , '<') AS ProgramName ,
                            STUFF((
                                    SELECT TOP 2
                                        ', ' + Name
                                    FROM
                                        Disease WITH (NOLOCK)
                                    INNER JOIN UserDisease  WITH (NOLOCK)
                                        ON UserDisease.DiseaseId = Disease.DiseaseId
                                    WHERE
                                        UserDisease.Userid = p.Userid
                                        AND UserDisease.DiagnosedDate IS NOT NULL
                                        AND UserDisease.StatusCode = 'A'
                                        AND Disease.StatusCode = 'A'
                                    ORDER BY
                                        UserDisease.DiagnosedDate DESC
                                    FOR
                                        XML PATH('')
                                  ) , 1 , 2 , '') AS DiseaseName ,
                            (
                              SELECT
                                  COUNT(ISNULL(CONVERT(VARCHAR , UserPrograms.EnrollmentStartDate , 101) , '') + ' - ' + ISNULL(Program.ProgramName , ''))
                              FROM
                                  Program WITH (NOLOCK)
                              INNER JOIN UserPrograms  WITH (NOLOCK)
                                  ON UserPrograms.ProgramId = Program.ProgramId
                              WHERE
                                  UserPrograms.Userid = p.Userid
                                  AND UserPrograms.EnrollmentStartDate IS NOT NULL
                                  AND UserPrograms.EnrollmentEndDate IS NULL
                                  AND UserPrograms.IsPatientDeclinedEnrollment = 0
                                  AND Program.StatusCode = 'A'
                                  AND UserPrograms.StatusCode = 'A'
                            ) AS ProgramCount ,
                            (
                              SELECT
                                  COUNT(Disease.DiseaseId)
                              FROM
                                  Disease  WITH (NOLOCK)
                              INNER JOIN UserDisease  WITH (NOLOCK)
                                  ON UserDisease.DiseaseId = Disease.DiseaseId
                              WHERE
                                  UserDisease.Userid = p.Userid
                                  AND UserDisease.DiagnosedDate IS NOT NULL
                                  AND UserDisease.StatusCode = 'A'
                                  AND Disease.StatusCode = 'A'
                            ) AS DiseaseCount ,
                            gst.StageID AS Stage ,
                            gst.Description
                        FROM
                            Patients P WITH (NOLOCK)
                        INNER JOIN UserEpisodicGroup ueg WITH (NOLOCK)
                            ON ueg.PatientUserID = p.UserId
                        INNER JOIN GrouperStage gst WITH (NOLOCK)
                            ON ueg.GrouperStageID = gst.GrouperStageId
                        INNER JOIN GrouperDisease gd WITH (NOLOCK)
                            ON gd.GrouperDiseaseId = gst.GrouperDiseaseID
                        INNER JOIN GrouperSystem gs  WITH (NOLOCK)
                            ON gs.GrouperSystemId = gd.GrouperSystemID
                        WHERE
                            gs.GrouperSystemId = @i_GrouperSystemId
                            AND gd.GrouperDiseaseId = @i_GrouperDiseaseID
                            AND gst.GrouperStageId = @i_GrouperStageID
                            AND ueg.StatusCode = 'A'
                            AND gd.StatusCode = 'A'
                            AND gs.StatusCode = 'A'


                  END
         END
END TRY
------------------------------------------------------------------------------------------------------------
BEGIN CATCH        
-- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_EpisodicGroup_DrillDown] TO [FE_rohit.r-ext]
    AS [dbo];

