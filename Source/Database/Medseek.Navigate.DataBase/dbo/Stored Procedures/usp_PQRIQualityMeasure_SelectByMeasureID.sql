/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PQRIQualityMeasure_SelectByMeasureID]
Description	  : This procedure is used to get the details of PQRIQualityMeasure.
Created By    :	Rathnam 
Created Date  : 13-Dec-2010
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
14-Dec-2010		Rathnam included CallNote in the select statement.
25-Dec-2010		Rama replaced PQRIQualityMeasuretoMeasureGroup by PQRIQualityMeasureGroupToMeasure  
---------------------------------------------------------------------------------
*/		
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasure_SelectByMeasureID]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureID KEYID
       )
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
----------- Select all the PQRIQualityMeasure details ---------------
      SELECT
          PQRIQualityMeasureID
         ,PQRIMeasureID
         ,Name AS PQRIQualityMeasureName
         ,Description
         ,StatusCode
         ,ReportingYear
         ,ReportingPeriod
         ,ReportingPeriodType
         ,PerformancePeriod
         ,PerformancePeriodType
         ,IsBFFS
         ,DocumentLibraryID
         ,DocumentStartPage
         ,SubmissionMethod
         ,ReportingMethod
         ,Note
         ,CreatedByUserId
         ,CreatedDate
         ,LastModifiedByUserId
         ,LastModifiedDate
         ,MigratedPQRIQualityMeasureID
         ,IsAllowEdit
      FROM
          PQRIQualityMeasure WITH(NOLOCK)
      WHERE
          PQRIQualityMeasureID = @i_PQRIQualityMeasureID

      SELECT 
          PQRIQualityMeasureGroup.PQRIQualityMeasureGroupID,
          PQRIQualityMeasureGroup.Name
      FROM
          PQRIQualityMeasureGroup WITH(NOLOCK)
      INNER JOIN PQRIQualityMeasureGroupToMeasure  WITH(NOLOCK)
          ON PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureGroupID = PQRIQualityMeasureGroup.PQRIQualityMeasureGroupID
      WHERE
          PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureID = @i_PQRIQualityMeasureID
      ORDER BY
          PQRIQualityMeasureGroup.Name
              
END TRY
---------------------------------------------------------------------------------------------------------------
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIQualityMeasure_SelectByMeasureID] TO [FE_rohit.r-ext]
    AS [dbo];

