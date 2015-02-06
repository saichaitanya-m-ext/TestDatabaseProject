/*  
------------------------------------------------------------------------------------------------- 
Procedure Name: [dbo].[usp_CareProviderDashBoard_PatientsByProgram]
Description   : This procedure is used for displaying the data under #of Patients By Program in
			    Care provider dashboard
Created By    : Pramod
Created Date  : 25-May-2010
-------------------------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
15-Sep-10 Pramod Included condition for care team member specific programs only (Added the exist clause)
-------------------------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_PatientsByProgram]
( @i_AppUserId KEYID
)
AS  
BEGIN TRY   
    SET NOCOUNT ON   
-- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
      BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
      END

	  SELECT Program.ProgramId,
			 Program.ProgramName,
			 COUNT( DISTINCT UserId ) AS NoOfPatients
	    FROM UserPrograms
			 INNER JOIN Program
			    ON UserPrograms.ProgramId = Program.ProgramId
			    AND Program.StatusCode = 'A'
			    AND UserPrograms.StatusCode = 'A'
	   WHERE EXISTS 
			( SELECT 1   
			    FROM Patients   
					INNER JOIN CareTeamMembers   
						ON Patients.CareTeamId = CareTeamMembers.CareTeamId  
						AND CareTeamMembers.UserId = @i_AppUserId  
						AND CareTeamMembers.StatusCode = 'A'  
			   WHERE Patients.UserId = UserPrograms.UserID
			)  
	   GROUP BY 
			Program.ProgramId,
			Program.ProgramName

	  SELECT COUNT( DISTINCT UserID ) AS NumberOfPatients
	    FROM UserPrograms
			 INNER JOIN Program
			    ON UserPrograms.ProgramId = Program.ProgramId
			     AND Program.StatusCode = 'A'
			    AND UserPrograms.StatusCode = 'A'
	   WHERE EXISTS 
			( SELECT 1   
			    FROM Patients   
					INNER JOIN CareTeamMembers   
						ON Patients.CareTeamId = CareTeamMembers.CareTeamId  
						AND CareTeamMembers.UserId = @i_AppUserId  
						AND CareTeamMembers.StatusCode = 'A'  
			   WHERE Patients.UserId = UserPrograms.UserID
			) 

END TRY
BEGIN CATCH
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_PatientsByProgram] TO [FE_rohit.r-ext]
    AS [dbo];

