/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_HealthCareQualityBCategory_Select_DD]
Description	  : This procedure is used to select all the HealthCareQualityBCategory records for dropdown.
Created By    :	NagaBabu
Created Date  : 23-Aug-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
24-Nov-2010 Rathnam added CreatedDate, CreatedbyUserId columns added in the select statement
01-Dec-2010 Rathnam added ufn_GetUserNameByID to get the CreatedByUserName
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityBCategory_Select_DD] 
(	
	@i_AppUserId KEYID,
	@i_HealthCareQualityCategoryId KEYID
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
---------------- All the HealthCareQualityBCategory records are retrieved --------
      SELECT
          HealthCareQualityBCategoryId,
		  HealthCareQualityBCategoryName,
		  CreatedByUserId,
		  dbo.ufn_GetUserNameByID (CreatedByUserId)AS CreatedByUserName,
          CreatedDate
      FROM
          HealthCareQualityBCategory
      WHERE
		  HealthCareQualityCategoryId = @i_HealthCareQualityCategoryId    
      ORDER BY
          HealthCareQualityBCategoryName
        
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityBCategory_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

