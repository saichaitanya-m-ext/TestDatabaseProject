/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PQRIQualityMeasureGroup_Select]
Description	  : This procedure is used to get the details of PQRIQualityMeasureGroup.
Created By    :	Rathnam 
Created Date  : 15-Dec-2010
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
12-Jan-2011 NagaBabu Added MigratedPQRIQualityMeasureGroupID,IsAllowEdit fields in First select Statement
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroup_Select]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureGroupID KEYID
       )
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
----------- Select all the PQRIQualityMeasure details ---------------
      SELECT
          PQRIQualityMeasureGroupID
         ,PQRIMeasureGroupID
         ,Name AS PQRIQualityMeasureName
         ,Description
         ,StatusCode
         ,ReportingYear
         ,ReportingPeriod
         ,ReportingPeriodType
         ,PerformancePeriod
         ,PerformancePeriodType
         ,GCode
		 ,CompositeGCode
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
         ,MigratedPQRIQualityMeasureGroupID
         ,IsAllowEdit
      FROM
          PQRIQualityMeasureGroup WITH(NOLOCK)
      WHERE
          PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID

      SELECT 
          PQRIQualityMeasure.PQRIQualityMeasureID,
		  PQRIQualityMeasure.PQRIMeasureID,
		  PQRIQualityMeasure.Name
      FROM
          PQRIQualityMeasure WITH(NOLOCK)
      INNER JOIN PQRIQualityMeasureGroupToMeasure WITH(NOLOCK)
          ON PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureID = PQRIQualityMeasure.PQRIQualityMeasureID
      WHERE
          PQRIQualityMeasureGroupToMeasure.PQRIQualityMeasureGroupId = @i_PQRIQualityMeasureGroupID
      ORDER BY
          PQRIQualityMeasure.Name
              
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroup_Select] TO [FE_rohit.r-ext]
    AS [dbo];

