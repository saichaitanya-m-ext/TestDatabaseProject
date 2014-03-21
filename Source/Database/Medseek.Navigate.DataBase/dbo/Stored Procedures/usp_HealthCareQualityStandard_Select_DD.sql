
/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_HealthCareQualityStandard_Select_DD]
Description	  : This procedure is used to select all the HealthCareQualityStandard records for dropdown.
Created By    :	NagaBabu
Created Date  : 23-Aug-2010
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
24-11-2010 Rathnam added CreatedDate, CreatedbyUserId columns added in the select statement
01-12-2010 Rathnam added ufn_GetUserNameByID to get the CreatedByUserName
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_HealthCareQualityStandard_Select_DD]
(
 @i_AppUserId KEYID ,
 @b_MeasureTypeStatus BIT=NULL ----1 - Organization,0- Standard

)
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
---------------- All the HealthCareQualityStandard records are retrieved --------
      IF @b_MeasureTypeStatus = 1 ----- Organisation
         BEGIN
               SELECT
                   HealthCareQualityStandardId ,
                   HealthCareQualityStandardName ,
                   CreatedByUserId ,
                   dbo.ufn_GetUserNameByID(CreatedByUserId) AS CreatedByUserName ,
                   CreatedDate,
                   CustomMeasureType                   
               FROM
                   HealthCareQualityStandard WITH(NOLOCK)
               WHERE
                   CustomMeasureType = 'Organization'
               ORDER BY
                   HealthCareQualityStandardName
         END
      ELSE
         IF @b_MeasureTypeStatus = 0 ----- Standard
            BEGIN
                  SELECT
                      HealthCareQualityStandardId ,
                      HealthCareQualityStandardName ,
                      CreatedByUserId ,
                      dbo.ufn_GetUserNameByID(CreatedByUserId) AS CreatedByUserName ,
                      CreatedDate,
                      CustomMeasureType
                  FROM
                      HealthCareQualityStandard WITH(NOLOCK)
                  WHERE
                      CustomMeasureType = 'Standard'
                  ORDER BY
                      HealthCareQualityStandardName
            END
         ELSE
            BEGIN
                  SELECT
                      HealthCareQualityStandardId ,
                      HealthCareQualityStandardName ,
                      CreatedByUserId ,
                      dbo.ufn_GetUserNameByID(CreatedByUserId) AS CreatedByUserName ,
                      CreatedDate,
                      CustomMeasureType
                  FROM
                      HealthCareQualityStandard WITH(NOLOCK)
                  ORDER BY
                      HealthCareQualityStandardName
            END
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityStandard_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

