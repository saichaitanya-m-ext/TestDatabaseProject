/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_Reports_CareManagement_Filter]23
Description   : This procedure is used for filters in caremanagement report
Created By    : Rathnam
Created Date  : 21-Nov-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Reports_CareManagement_Filter]
(
 @i_AppUserId KEYID
,@tblProgram TTYPEKEYID READONLY
)
AS
BEGIN
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

            IF NOT EXISTS ( SELECT
                                1
                            FROM
                                @tblProgram )
               BEGIN
                     EXEC usp_TaskDueDates_Select_DD @i_AppUserId

                     SELECT DISTINCT
                         p.ProgramId
                        ,p.ProgramName
                     FROM
                         ProgramCareTeam pct WITH (NOLOCK)
                     INNER JOIN CareTeamMembers cm WITH (NOLOCK)
                         ON pct.CareTeamId = cm.CareTeamId
                     INNER JOIN CareTeam c WITH (NOLOCK)
                         ON c.CareTeamId = pct.CareTeamId
                     INNER JOIN Program p WITH (NOLOCK)
                         ON p.ProgramId = pct.ProgramId
                     WHERE
                         cm.ProviderID = @i_AppUserId
                         AND cm.StatusCode = 'A'
                         AND p.StatusCode = 'A'

                     IF EXISTS ( SELECT 1
                                 FROM
                                     CareTeamMembers
                                 WHERE
                                     ProviderID = @i_AppUserId
                                     AND IsCareTeamManager = 1
                                     AND StatusCode = 'A' )
                        BEGIN
                             SELECT DISTINCT
                                  ctm.ProviderID AS UserID
                                 ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName
                              FROM
                                  CareTeamMembers ctm WITH ( NOLOCK )
                              INNER JOIN CareTeam ct WITH ( NOLOCK )
                                  ON ctm.CareTeamId = ct.CareTeamId
                              INNER JOIN CareTeamMembers ctm1 with(nolock)
                                  ON ctm1.CareTeamId = ct.CareTeamId    
                              WHERE
                                  ctm.StatusCode = 'A'
                                  AND CT.StatusCode = 'A'
                                  AND ctm1.ProviderID = @i_AppUserId
                        END
                     ELSE
                        BEGIN
                              SELECT
                                  @i_AppUserId UserId
                                 ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName
                        END
               END
            ELSE
               BEGIN
                     IF EXISTS ( SELECT
                                     1
                                 FROM
                                     @tblProgram )

                        BEGIN
							   IF EXISTS ( SELECT 1
                                 FROM
                                     CareTeamMembers
                                 WHERE
                                     ProviderID = @i_AppUserId
                                     AND IsCareTeamManager = 1
                                     AND StatusCode = 'A' )
                        BEGIN
                             SELECT DISTINCT
                                  ctm.ProviderID AS UserID
                                 ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName
                              FROM
                                  CareTeamMembers ctm WITH ( NOLOCK )
                              INNER JOIN CareTeam ct WITH ( NOLOCK )
                                  ON ctm.CareTeamId = ct.CareTeamId
                              INNER JOIN CareTeamMembers ctm1 with(nolock)
                                  ON ctm1.CareTeamId = ct.CareTeamId    
                              WHERE
                                  ctm.StatusCode = 'A'
                                  AND CT.StatusCode = 'A'
                                  AND ctm1.ProviderID = @i_AppUserId
                        END
                     ELSE
                        BEGIN
                              SELECT
                                  @i_AppUserId UserId
                                 ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName
                        END
                              /*
                              SELECT DISTINCT
                                  ctm.UserId
                                 ,Dbo.ufn_GetUserNameByID(ctm.UserId) AS CareTeamMemberName
                              FROM
                                  CareTeamMembers ctm
                              INNER JOIN ( SELECT DISTINCT
                                               ct.CareTeamId
                                           FROM
                                               ProgramCareTeam pct WITH (NOLOCK)
                                           INNER JOIN CareTeam ct WITH (NOLOCK)
                                               ON pct.CareTeamId = ct.CareTeamId
                                           INNER JOIN @tblProgram p 
                                               ON p.tKeyId = pct.ProgramId
                                           WHERE
                                               ct.StatusCode = 'A'
                                         ) t
                                  ON t.CareTeamId = ctm.CareTeamId
                              WHERE
                                  ctm.StatusCode = 'A'
                              */    


                              SELECT DISTINCT
                                  ISNULL(pts.PCPId , pts.PCPId) PcpId
                              INTO
                                  #Pcp
                              FROM
                                  Task t
                              INNER JOIN @tblProgram p
                                  ON t.ProgramID = p.tKeyId
                              INNER JOIN Patients pts WITH (NOLOCK)
                                  ON pts.PatientID = t.PatientId

                              SELECT
                                  PCPID
                                 ,Dbo.ufn_GetUserNameByID(PCPID) PcpName
                              FROM
                                  #Pcp
                              WHERE
                                  PCPID IS NOT NULL

                        END
               END
      END TRY        
-------------------------------------------------------------------------------   
      BEGIN CATCH        
    -- Handle exception        
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_CareManagement_Filter] TO [FE_rohit.r-ext]
    AS [dbo];

