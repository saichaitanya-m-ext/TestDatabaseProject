/*  
------------------------------------------------------------------------------------------------- 
Procedure Name: [dbo].[usp_CareProviderDashBoard_PatientsByDisease]
Description   : This procedure is used for displaying the data under #of Patients By disease in
			    Care provider dashboard
Created By    : Pramod
Created Date  : 25-May-2010
-------------------------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
9-Jul-10 Pramod Included condition for care team specific patient disease list only 
-------------------------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_PatientsByDisease] 
( @i_AppUserId KEYID)
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

	  SELECT Disease.DiseaseId,
			 Disease.Name,
			 COUNT( DISTINCT UserID ) AS NoOfPatients
	    FROM UserDisease
			 INNER JOIN Disease
			    ON UserDisease.DiseaseID = Disease.DiseaseId
			    AND Disease.StatusCode = 'A'
			    AND UserDisease.StatusCode = 'A'
		 AND EXISTS ( SELECT 1 
						FROM Patients 
							INNER JOIN CareTeamMembers 
								ON Patients.CareTeamId = CareTeamMembers.CareTeamId
								AND CareTeamMembers.UserId = @i_AppUserId
								AND CareTeamMembers.StatusCode = 'A'
					   WHERE Patients.UserId = UserDisease.UserID
					     AND (  ISNULL(Patients.IsDeceased,0) = 0  
								OR Patients.EndDate IS NULL  
							 )
					)
	   GROUP BY 
			 Disease.DiseaseId, Disease.Name

	  SELECT COUNT( DISTINCT UserDisease.UserID ) AS NumberOfPatients
	    FROM UserDisease
			 INNER JOIN Disease
			    ON UserDisease.DiseaseID = Disease.DiseaseId
			    AND Disease.StatusCode = 'A'
			    AND UserDisease.StatusCode = 'A'
		 AND EXISTS ( SELECT 1 
						FROM Patients 
							INNER JOIN CareTeamMembers 
								ON Patients.CareTeamId = CareTeamMembers.CareTeamId
								AND CareTeamMembers.UserId = @i_AppUserId
								AND CareTeamMembers.StatusCode = 'A'
					   WHERE Patients.UserId = UserDisease.UserID
					     AND (  ISNULL(Patients.IsDeceased,0) = 0  
								OR Patients.EndDate IS NULL  
							 )
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_PatientsByDisease] TO [FE_rohit.r-ext]
    AS [dbo];

