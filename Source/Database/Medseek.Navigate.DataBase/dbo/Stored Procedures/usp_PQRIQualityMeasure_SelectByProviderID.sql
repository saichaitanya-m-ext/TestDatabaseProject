/*      
------------------------------------------------------------------------------      
Procedure Name: usp_PQRIQualityMeasure_SelectByProviderID       
Description   : This Procedure is used to get the list of Measures based on ProviderUserid and ReportingYear
Created By    : Rathnam
Created Date  : 24-Jan-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasure_SelectByProviderID] 
       (
        @i_AppUserId KEYID
       ,@i_ReportingYear SMALLINT = NULL
       )
AS
BEGIN TRY
      SET NOCOUNT ON
 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
      SELECT DISTINCT
          PQRIQualityMeasure.PQRIQualityMeasureID
         ,PQRIQualityMeasure.Name
      FROM
          PQRIProviderPersonalization WITH(NOLOCK)
      INNER JOIN PQRIProviderQualityMeasure WITH(NOLOCK)
          ON PQRIProviderQualityMeasure.PQRIProviderPersonalizationid = PQRIProviderPersonalization.PQRIProviderPersonalizationid
      INNER JOIN PQRIQualityMeasure WITH(NOLOCK)
          ON PQRIQualityMeasure.PQRIQualityMeasureID = PQRIProviderQualityMeasure.PQRIQualityMeasureID
      WHERE
          ProviderUserID = @i_AppUserId
          AND PQRIProviderPersonalization.StatusCode = 'A'
          AND PQRIQualityMeasure.StatusCode = 'A'
          AND (PQRIProviderPersonalization.ReportingYear = @i_ReportingYear OR @i_ReportingYear IS NULL)
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasure_SelectByProviderID] TO [FE_rohit.r-ext]
    AS [dbo];

