/*          
------------------------------------------------------------------------------------------          
Procedure Name: [usp_PD_Medications_wrapper]          
Description   : This procedure is used as a wrapper procedure for Medications and Immunization sections
Created By    : Praveen Takasi
Created Date  : 12-March-2013
------------------------------------------------------------------------------------------     
*/
CREATE PROCEDURE [dbo].[usp_PD_Medications_wrapper]
(
	@i_AppUserId KeyID,
	@i_PatientUserId KeyID = NULL
)
AS
BEGIN TRY
	SET NOCOUNT ON
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
      BEGIN      
          RAISERROR ( N'Invalid Application User ID %d passed.' ,      
               17 ,      
               1 ,      
               @i_AppUserId )      
      END     
	EXEC usp_CareTeamMembers_ByProgram_DD @i_AppUserId
END TRY
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PD_Medications_wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

