/*
----------------------------------------------------------------------------------------
Procedure Name: usp_HealthStatusScoreOrganization_Select_DD
Description	  : This procedure is used to select all the active records from HealthStatusScoreType
				and HealthStatusScoreOrganization tables for the dropdown
Created By    :	Aditya 
Created Date  : 22-Apr-2010
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
19-Aug-2010 NagaBabu  Added ORDER BY clause to the select statement
-----------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_HealthStatusScoreOrganization_Select_DD]
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

------------ Selection from HealthStatusScoreOrganization and HealthStatusScoreType tables starts here ------------
      SELECT
		  HealthStatusScoreOrganization.HealthStatusScoreOrgId,
		  HealthStatusScoreType.HealthStatusScoreId,
          HealthStatusScoreOrganization.Name + ' | ' + HealthStatusScoreType.Name as 'Organization-HealthTest'
    
      FROM
          HealthStatusScoreOrganization   WITH (NOLOCK) 
          INNER JOIN HealthStatusScoreType  WITH (NOLOCK) 
				 ON HealthStatusScoreType.HealthStatusScoreOrgId = HealthStatusScoreOrganization.HealthStatusScoreOrgId 
      WHERE
		  HealthStatusScoreOrganization.StatusCode = 'A'
		  AND HealthStatusScoreType.StatusCode = 'A'
	  ORDER BY
		  HealthStatusScoreOrganization.SortOrder		  
	  
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthStatusScoreOrganization_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

