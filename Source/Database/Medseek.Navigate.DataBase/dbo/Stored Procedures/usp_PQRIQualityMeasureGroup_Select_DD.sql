/*  
----------------------------------------------------------------------------------------------   
Procedure Name: usp_PQRIQualityMeasureGroup_Select_DD  
Description   : This procedure is used for the PQRIQualityMeasureGroup dropdown from the PQRIQualityMeasureGroup 
			    table.  
Created By    : Rathnam
Created Date  : 13-Dec-2010 
-----------------------------------------------------------------------------------------------   
Log History   :   
DD-MM-YYYY  BY  DESCRIPTION  
25-Dec-2010		Rama replaced PQRIQualityMeasuretoMeasureGroup by PQRIQualityMeasureGroupToMeasure 
10-Feb-2011 NagaBabu Added @i_ReportingYear 
-----------------------------------------------------------------------------------------------   
*/

CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroup_Select_DD]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureID KEYID = NULL
       ,@i_ReportingYear KEYID 
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
  
------------ Selection from PQRIQualityMeasureGroup table starts here ------------  
      SELECT
          PQRIQualityMeasureGroupID
         ,PQRIMeasureGroupID
         ,Name
      FROM
          PQRIQualityMeasureGroup
      WHERE
          StatusCode = 'A'
          AND (
                PQRIQualityMeasureGroupID NOT IN ( SELECT
                                                       PQRIQualityMeasureGroupID
                                                   FROM
                                                       PQRIQualityMeasureGroupToMeasure
                                                   WHERE
                                                       PQRIQualityMeasureID = @i_PQRIQualityMeasureID
                                                       OR @i_PQRIQualityMeasureID IS NULL )
                OR @i_PQRIQualityMeasureID IS NULL
              )
          AND ReportingYear = @i_ReportingYear        
      ORDER BY
          Name
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroup_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

