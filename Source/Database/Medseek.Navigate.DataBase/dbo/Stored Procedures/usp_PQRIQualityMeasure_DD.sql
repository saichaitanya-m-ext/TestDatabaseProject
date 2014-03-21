/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_PQRIQualityMeasure_DD]      
Description   : This procedure is used for drop down from PQRIQualityMeasure table    
     
Created By    : Rathnam     
Created Date  : 03-Jan-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasure_DD]
       (
        @i_AppUserId KEYID
       ,@i_ReportingYear SMALLINT
       ,@vc_MeasureIdORDescription SHORTDESCRIPTION = NULL
       )
AS
BEGIN TRY
      SET NOCOUNT ON       
-- Check if valid Application User ID is passed    

      IF ( @i_AppUserId IS NULL )OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      SELECT
          CONVERT(VARCHAR,PQRIQualityMeasureID) + '~' + ISNULL(CONVERT(VARCHAR,DocumentLibraryID),0) AS MeasureAndLibraryID,
          CONVERT(VARCHAR,PQRIMeasureID) + ' - ' + Name AS MeasureName
      FROM
          PQRIQualityMeasure
      WHERE
          ReportingYear = @i_ReportingYear
	  AND StatusCode = 'A'
      AND (CONVERT(VARCHAR,PQRIMeasureID) + ' - ' + Name LIKE '%' + @vc_MeasureIdORDescription + '%' OR @vc_MeasureIdORDescription IS NULL)
      
END TRY      
--------------------------------------------------------       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIQualityMeasure_DD] TO [FE_rohit.r-ext]
    AS [dbo];

