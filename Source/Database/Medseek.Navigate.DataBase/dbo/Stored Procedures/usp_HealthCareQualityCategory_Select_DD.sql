/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_HealthCareQualityCategory_Select_DD]
Description	  : This procedure is used to select all the HealthCareQualityCategory records for dropdown.
Created By    :	NagaBabu
Created Date  : 23-Aug-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
26-Aug-2010 NagaBabu modified HealthCareQualityStandardId perameter as null by default
27-Aug-2010 NagaBabu Added HealthCareQualityStandardName as input perameter and joined table 
						HealthCareQualityStandard
27-Sep-2010 NagaBabu Deleted @i_HealthCareQualityStandardId,@i_HealthCareQualityStandardName parameters	
24-Nov-2010 Rathnam added CreatedDate, CreatedbyUserId columns added in the select statement
01-Dec-2010 Rathnam added ufn_GetUserNameByID to get the CreatedByUserName
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityCategory_Select_DD]
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
---------------- All the HealthCareQualityCategory records are retrieved --------


      SELECT 
          HealthCareQualityCategoryID,
		  HealthCareQualityCategoryName,
		  CreatedByUserId,
		  dbo.ufn_GetUserNameByID (CreatedByUserId)AS CreatedByUserName,
          CreatedDate
      FROM
          HealthCareQualityCategory 
      ORDER BY
          HealthCareQualityCategoryName
  
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityCategory_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

