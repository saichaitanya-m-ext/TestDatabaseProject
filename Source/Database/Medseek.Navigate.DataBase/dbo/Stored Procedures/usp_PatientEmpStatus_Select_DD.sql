/*
---------------------------------------------------------------------------------
Procedure Name: [usp_PatientEmpStatus _Select_DD]
Description	  : This proc is used to getting the PatientEmpStatus 
				
Created By    :	Sivakrishna
Created Date  : 18-Jan-2012
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

----------------------------------------------------------------------------------
*/ 
CREATE PROCEDURE [dbo].[usp_PatientEmpStatus_Select_DD]
(
 @i_AppUserId KEYID
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
---------------- All the Active CareTeam ords are retrieved --------
      SELECT DISTINCT
		    PatientEmpStatusId AS Code,
		    Description
	  FROM 
		 PatientEmpStatus
      WHERE StatusCode = 'A' 
      ORDER BY PatientEmpStatusId
     
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
    ON OBJECT::[dbo].[usp_PatientEmpStatus_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

