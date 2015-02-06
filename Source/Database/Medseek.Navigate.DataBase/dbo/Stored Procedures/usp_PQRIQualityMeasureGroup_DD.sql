/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_PQRIQualityMeasureGroup_DD]      
Description   : This procedure is used for drop down from PQRIQualityMeasureGroup table    
     
Created By    : Rathnam     
Created Date  : 03-Jan-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION 
10-Jan-2011 Rathnam added one more concatenation column in the select statement.      
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroup_DD]
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
          ISNULL(CONVERT(VARCHAR,PQRIQualityMeasureGroupID),0) + '~' + 
          ISNULL(CONVERT(VARCHAR,DocumentLibraryID),0) + '~' + 
		  ISNULL( STUFF(( SELECT 
					  ',' + CONVERT(VARCHAR,PQRIQualityMeasureId)
				  FROM
					   PQRIQualityMeasureGroupToMeasure
				  
				  WHERE
					  PQRIQualityMeasureGroupId = PQRIQualityMeasureGroup.PQRIQualityMeasureGroupID
					 
				   FOR
					   XML PATH('') ) , 1 , 1 , ''),'') AS MeasureGroupAndLibraryID,
          PQRIMeasureGroupID + ' - ' + Name AS MeasureName
      FROM
          PQRIQualityMeasureGroup
      WHERE
          ReportingYear = @i_ReportingYear
	  AND StatusCode = 'A'
      AND (PQRIMeasureGroupID + ' - ' + Name LIKE '%' + @vc_MeasureIdORDescription + '%' OR @vc_MeasureIdORDescription IS NULL)
      
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroup_DD] TO [FE_rohit.r-ext]
    AS [dbo];

