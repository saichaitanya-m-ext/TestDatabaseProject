/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_HealthCareQualityMeasureNrDrDefinition_Delete]      
Description   : This procedure is used to Delete record from HealthCareQualityMeasureNrDrDefinition table  
Created By    : Rathnam      
Created Date  : 12-Nov-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Delete]
       (
        @i_AppUserId KEYID
       ,@i_HealthCareQualityMeasureNrDrDefinitionID KEYID
       )
AS
BEGIN TRY

      SET NOCOUNT ON
      DECLARE @i_NumberOfRecordsDeleted INT     
 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
------------DELETE OPERATION -----------------

      DELETE  FROM
              HealthCareQualityMeasureNrDrDefinition
      WHERE
              HealthCareQualityMeasureNrDrDefinitionID = @i_HealthCareQualityMeasureNrDrDefinitionID

      SELECT
          @i_NumberOfRecordsDeleted = @@ROWCOUNT

      IF @i_NumberOfRecordsDeleted <> 1
         BEGIN
               RAISERROR ( N'Invalid Row count %d passed to HealthCareQualityMeasureNrDrDefinition'
               ,17
               ,1
               ,@i_NumberOfRecordsDeleted )
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
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasureNrDrDefinition_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

