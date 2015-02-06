/*
--------------------------------------------------------------------------------
Procedure Name: [usp_Users_SearchForPCP]
Description	  : This procedure is used to get the PCPName of Specific patient
Created By    :	NagaBabu
Created Date  : 29-Aug-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
---------------------------------------------------------------------------------
*/ 
CREATE PROCEDURE [dbo].[usp_Users_SearchForPCP]
(
	@i_AppUserId KeyId,
	@i_PatientUserId KeyId
)
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
------------------------------------------------------------------------------------------------
	SELECT
		[dbo].[ufn_GetPCPName](UserId)AS PCPName 
	FROM
		Users
	WHERE
		Users.UserId = @i_PatientUserId		
	
		
END TRY
------------------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Users_SearchForPCP] TO [FE_rohit.r-ext]
    AS [dbo];

