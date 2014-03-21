/*  
----------------------------------------------------------------------------------------------   
Procedure Name: [usp_PQRIQualityMeasure_Select_DD]  
Description   : This procedure is used for the PQRIQualityMeasure dropdown from the PQRIQualityMeasure
			    table.  
Created By    : Rathnam
Created Date  : 15-Dec-2010 
-----------------------------------------------------------------------------------------------   
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION
01-Feb-2011 NagaBabu Added @i_ReportingYear Parameter as well as in WHERE condition   
-----------------------------------------------------------------------------------------------   
*/

CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasure_Select_DD]
(
 @i_AppUserId KEYID ,
 @i_ReportingYear KEYID
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
  
------------ Selection from PQRIQualityMeasure table starts here ------------  
   
      SELECT 
          PQRIQualityMeasureID,
          PQRIMeasureID,
		  Name
      FROM
          PQRIQualityMeasure
      WHERE
          StatusCode = 'A'
      AND ReportingYear = @i_ReportingYear   
      ORDER BY
          PQRIMeasureID,Name
          
END TRY
-------------------------------------------------------------------------------------------------------
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIQualityMeasure_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

