/*
---------------------------------------------------------------------------------
Procedure Name: [usp_PatientDashboard_UserAppointments_Wrapper]
Description	  : This procedure is used to insert the Communication and cohorts
Created By    :	Praveen
Created Date  : 04-May-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
03-APR-2013 Mohan Commented on  usp_Organization_Facility_Select and Modified usp_CareTeamMembers_ByProgram_DD .   
----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PatientDashboard_UserAppointments_Wrapper]
(
 @i_AppUserID KEYID
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
		 
		 EXEC usp_Organization_Facility_Select @i_AppUserId
		 EXEC usp_EncounterType_Select_DD @i_AppUserId
		 EXEC usp_Program_ByProviderID @i_AppUserId
		 EXEC usp_CareTeamMembers_ByProgram_DD @i_AppUserID
		 
      END TRY
-----------------------------------------------------------------------------------------------------------------------------------      
      BEGIN CATCH          
    -- Handle exception          
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientDashboard_UserAppointments_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

