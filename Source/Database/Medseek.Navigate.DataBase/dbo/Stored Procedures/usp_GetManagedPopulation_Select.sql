  
/*  
--------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_GetManagedPopulation_Select]23,144145 
Description   : This proc is used to show the patient Population Definition
Created By    : Gurumoorthy V
Created Date  : 11-Feb-2013
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
25-Mar-2013 P.V.P.Mohan Modified PatientID in place of PatientUserID for Task table 
---------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_GetManagedPopulation_Select] --2,6666
(
 @i_AppUserId KEYID
,@i_PatientUserID KEYID
)
AS
BEGIN
      BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END
		SELECT DISTINCT p.ProgramId,
			p.ProgramName ProgramName,
			CT.CareTeamId,
			CT.CareTeamName,
			CONVERT(DATE, ups.EnrollmentStartDate) EnrollmentStartDate,
			'' EnrollmentEndDate,
			'' UserProgramId,
			CASE 
				WHEN ups.EnrollmentStartDate IS NULL
					AND ISNULL(IsPatientDeclinedEnrollment, 0) = 0
					THEN 'Enrollment Pending'
				WHEN ups.EnrollmentStartDate IS NOT NULL
					AND ISNULL(IsPatientDeclinedEnrollment, 0) = 0
					THEN 'Enrolled'
				WHEN ISNULL(IsPatientDeclinedEnrollment, 0) = 1
					THEN 'Dis-Enrolled'
				END EnrollmentStatus,
			(
				SELECT COUNT(1)
				FROM Task t1 WITH (NOLOCK)
				INNER JOIN TaskStatus ts1 WITH (NOLOCK) ON t1.TaskStatusId = ts1.TaskStatusId
				WHERE t1.ProgramID = p.ProgramID
					AND t1.PatientId = ups.PatientId
					AND ts1.TaskStatusText = 'Closed Incomplete'
				) MissedOpportunityNo,
			CASE 
				WHEN LEN(p.ProgramName) > 10
					THEN SUBSTRING(p.ProgramName, 1, 28) + '...'
				ELSE p.ProgramName
				END ShortProgramName
		--FROM PatientProgram ups
		--INNER JOIN CareTeamMembers CTM WITH (NOLOCK) ON ups.ProviderID = CTM.ProviderID
		--INNER JOIN CareTeam CT WITH (NOLOCK) ON CTM.CareTeamId = CT.CareTeamId
		--INNER JOIN Program p ON ups.ProgramId = p.ProgramId
		--WHERE ups.PatientID = @i_PatientUserID
		--	AND ups.StatusCode = 'A'
		--	AND p.StatusCode = 'A'
 FROM PatientProgram ups WITH (NOLOCK)  
 LEFT JOIN ProgramCareTeam CTM WITH (NOLOCK)  
     ON ups.ProgramID = CTM.ProgramId  
 LEFT JOIN CareTeam CT WITH (NOLOCK)  
     ON CTM.CareTeamId = CT.CareTeamId  
 INNER JOIN Program p WITH (NOLOCK)  
  ON ups.ProgramId = p.ProgramId  
 WHERE ups.PatientID = @i_PatientUserID  
  AND ups.StatusCode = 'A'  
  AND p.StatusCode = 'A' 
  AND ups.EnrollmentEndDate IS NULL 
            
      END TRY
      BEGIN CATCH  
---------------------------------------------------------------------------------------------------------------------------------  
    -- Handle exception  
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END  
  


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_GetManagedPopulation_Select] TO [FE_rohit.r-ext]
    AS [dbo];

