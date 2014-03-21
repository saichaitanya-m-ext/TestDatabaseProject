/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PQRIQualityMeasureNumerator_InsertUpdate]        
Description   : This procedure is used to insert record OR update the record 
                into PQRIQualityMeasureNumerator table based on PQRIQualityMeasureID   
Created By    : Rathnam  
Created Date  : 15-Dec-2010      
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureNumerator_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureID KEYID
       ,@vc_PerformanceType VARCHAR(3)
       ,@vc_CriteriaText VARCHAR(MAX)
       ,@vc_CriteriaSQL VARCHAR(MAX)
       ,@vc_StatusCode STATUSCODE
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


      IF EXISTS ( SELECT
                      1
                  FROM
                      PQRIQualityMeasureNumerator
                  WHERE
                      PQRIQualityMeasureID = @i_PQRIQualityMeasureID AND PerformanceType = @vc_PerformanceType)

         BEGIN
               UPDATE
                   PQRIQualityMeasureNumerator
               SET
				   CriteriaText = @vc_CriteriaText
                  ,CriteriaSQL = @vc_CriteriaSQL
                  ,StatusCode = @vc_StatusCode
                  ,LastModifiedByUserId = @i_AppUserId
                  ,LastModifiedDate = GETDATE()
               WHERE
                   PQRIQualityMeasureID = @i_PQRIQualityMeasureID AND PerformanceType = @vc_PerformanceType
         END
      ELSE
         BEGIN
               INSERT INTO
                   PQRIQualityMeasureNumerator
                   (
                    PQRIQualityMeasureID
                   ,PerformanceType
				   ,CriteriaText
                   ,CriteriaSQL
                   ,StatusCode
                   ,CreatedByUserId
                   )
               VALUES
                   (
                    @i_PQRIQualityMeasureID
                   ,@vc_PerformanceType 
                   ,@vc_CriteriaText 
                   ,@vc_CriteriaSQL
                   ,@vc_StatusCode
                   ,@i_AppUserId
                   )
         END
      RETURN 0
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureNumerator_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

