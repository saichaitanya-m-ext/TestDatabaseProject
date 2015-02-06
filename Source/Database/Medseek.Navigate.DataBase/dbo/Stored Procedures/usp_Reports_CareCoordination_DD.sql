
/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Reports_CareCoordination_DD]  10939,'P'
Description   : This stored procedure is used to getting the drop downs from cohortlist & Programs 
                based user roles
Created By    : Rathnam
Created Date  : 14-Nov-2011
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY     DESCRIPTION  
DROP PROC usp_Reports_CareCoordination_DD_Test
----------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_Reports_CareCoordination_DD]--23,'P'

(
 @i_AppUserId KEYID ,
 @b_IsAdminOrProvider CHAR(1) --Admin--->'A'  , Provider----> 'P'

)
AS
BEGIN TRY   

-- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END


      IF @b_IsAdminOrProvider = 'A'
         BEGIN
               SELECT
                   PopulationDefinitionID ,
                   PopulationDefinitionName
               FROM
                   PopulationDefinition 
               WHERE
                   StatusCode = 'A'
               ORDER BY
                   PopulationDefinitionName

               SELECT
                   ProgramId ,
                   ProgramName
               FROM
                   Program
               WHERE
                   StatusCode = 'A'
               ORDER BY
                   ProgramName

         END
      ELSE
         BEGIN
               SELECT DISTINCT
                   cl.PopulationDefinitionID ,
                   cl.PopulationDefinitionName
               FROM
                    PopulationDefinitionPatients clu WITH (NOLOCK)
               INNER JOIN PatientProgram PP
                  ON PP.PatientID = clu.PatientID       
               INNER JOIN ProgramCareTeam PCT
                  ON PP.ProgramID = PCT.ProgramId   
               INNER JOIN CareTeamMembers ctm WITH (NOLOCK)
                   ON ctm.CareTeamId = PCT.CareTeamId
                      --AND ctm.StatusCode = 'A'
               INNER JOIN CareTeam c  WITH (NOLOCK)
                   ON ctm.CareTeamId = c.CareTeamId
                      AND c.StatusCode = 'A'
               INNER JOIN PopulationDefinition cl WITH (NOLOCK)
                   ON cl.PopulationDefinitionID = clu.PopulationDefinitionID
               WHERE
                   ctm.ProviderID = @i_AppUserId
                   AND clu.Statuscode = 'A'
               ORDER BY
                   cl.PopulationDefinitionName

               SELECT DISTINCT
                   pg.ProgramId ,
                   pg.ProgramName
               FROM
                   PatientProgram ups WITH (NOLOCK)
               INNER JOIN ProgramCareTeam PCT
                  ON ups.ProgramID = PCT.ProgramId   
               INNER JOIN CareTeamMembers ctm WITH (NOLOCK)
                   ON ctm.CareTeamId = PCT.CareTeamId
                      AND ctm.StatusCode = 'A'
               INNER JOIN CareTeam c  WITH (NOLOCK)
                   ON ctm.CareTeamId = c.CareTeamId
                      AND c.StatusCode = 'A'
               INNER JOIN Program pg  WITH (NOLOCK)
                   ON pg.ProgramId = ups.ProgramId
               WHERE
                   ctm.ProviderID = @i_AppUserId
                     AND ups.StatusCode = 'A'
               ORDER BY
                   pg.ProgramName

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
    ON OBJECT::[dbo].[usp_Reports_CareCoordination_DD] TO [FE_rohit.r-ext]
    AS [dbo];

