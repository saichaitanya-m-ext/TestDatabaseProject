﻿/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_CallTimePreference_Select_DD]
Description	  : This procedure is used to select all the active records from the  
				CallTimePreference table for the dropdown.
Created By    :	Aditya 
Created Date  : 15-Apr-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
19-Aug-2010  NagaBabu Added SortOrder,Description to ORDER BY clause
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_CallTimePreference_Select_DD]
(	
	@i_AppUserId KEYID
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
---------------- All the Active CallTimePreference records are retrieved --------
      SELECT
		  CallTimePreferenceId,
		  CallTimeName,
		  Description
     FROM
          CallTimePreference
     WHERE
          StatusCode = 'A'
     ORDER BY
		  SortOrder ,
          CallTimeName
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CallTimePreference_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

