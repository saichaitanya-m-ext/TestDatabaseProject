/*
---------------------------------------------------------------------------------
Procedure Name: usp_UserIdByMemberNumber_Select
Description	  : This proc is used to getting the member number from users
				
Created By    :	Gurumoorthy
Created Date  : 08-June-2012
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_UserIdByMemberNumber_Select]--42,'vintha'
(
 @i_AppUserId KEYID,
 @v_MemberNumber VARCHAR(50)
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
---------------- All the Active CareTeam records are retrieved --------
      
      SELECT 
		patientid UserId,
		FullName,
		MemberNum
	  FROM
		Patients WITH(NOLOCK)
	  WHERE 
			MemberNum = @v_MemberNumber OR FullName=@v_MemberNumber
      
END TRY
------------------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserIdByMemberNumber_Select] TO [FE_rohit.r-ext]
    AS [dbo];

