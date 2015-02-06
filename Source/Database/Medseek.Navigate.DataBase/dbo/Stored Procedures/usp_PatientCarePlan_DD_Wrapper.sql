/*
-------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PatientCarePlan_DD_Wrapper]
Description	  : All the patient CarePlan dropdown SP's are executed through this wrapper. 
Created By    :	Praveen Takasi
Created Date  : 09-Feb-2013
--------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

--------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_PatientCarePlan_DD_Wrapper] --23,NULL,'a'
(
@i_AppUserId KEYID,
@i_ActivityId KEYID = NULL,
@v_StatusCode StatusCode = NULL
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
		exec usp_LifeStyleGoals_DD @i_AppUserId
		exec usp_Program_ByProviderID @i_AppUserId
		exec usp_Activity_Select @i_AppUserId,@i_ActivityId,@v_StatusCode
		exec usp_LifeStyleGoals_DD @i_AppUserId
		exec usp_Questionaire_Select_DD @i_AppUserId
		exec usp_CareTeamMembers_ByProgram_DD @i_AppUserId

END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientCarePlan_DD_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

