/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_InsuranceGroup_Select_DD]
Description	  : This procedure is used to select all the active Groups from  
				the InsuranceGroup dropdown.
Created By    :	Aditya 
Created Date  : 24-Mar-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_InsuranceGroup_Select_DD] @i_AppUserId KEYID
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
---------------- All the Active Insurance Group Names are retrieved --------
      SELECT
          InsuranceGroupID,
		  GroupName 
     FROM
          InsuranceGroup
     WHERE
          StatusCode = 'A'
     ORDER BY
          GroupName
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_InsuranceGroup_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

