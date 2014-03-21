/*
----------------------------------------------------------------------------------------
Procedure Name:[usp_HealthStatusScoreOrganization_Select] 
Description	  :This Procedure is used to get values from HealthStatusScoreOrganization table 
Created By    :NagaBabu	
Created Date  :13-Jan-2011 
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
18-Jan-2011 Rathnam HealthStatusScoreOrgId added one more column
19-Jan-2011 NagaBabu Added SortOrder in OrderBy Clause
20-Jan-2011 Rathnam Added @v_StatusCode parametar
-----------------------------------------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[usp_HealthStatusScoreOrganization_Select]
( 
	@i_AppUserId KEYID ,
	@v_StatusCode StatusCode = 'A'
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

------------ Selection from HealthStatusScoreOrganization table starts here ------------
      SELECT
          HealthStatusScoreOrgId,
		  Name AS 'OrganizationName',
		  SortOrder ,
		  CASE StatusCode
			  WHEN 'A' THEN 'Active'
			  WHEN 'I' THEN 'InActive'
		  END AS StatusDescription,
		  CreatedByUserId,
		  CreatedDate,
		  LastModifiedByUserId,
		  LastModifiedDate	  
	  FROM
          HealthStatusScoreOrganization WITH(NOLOCK)
      WHERE 
          ((StatusCode = 'A' AND @v_StatusCode = 'A') OR @v_StatusCode = 'I')
      ORDER BY
		  SortOrder,
		  Name 
	  
          
END TRY
-----------------------------------------------------------------------
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthStatusScoreOrganization_Select] TO [FE_rohit.r-ext]
    AS [dbo];

