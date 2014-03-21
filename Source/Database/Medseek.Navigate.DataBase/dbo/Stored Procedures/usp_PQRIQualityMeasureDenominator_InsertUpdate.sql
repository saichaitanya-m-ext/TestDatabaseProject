/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PQRIQualityMeasureDenominator_InsertUpdate]        
Description   : This procedure is used to insert record OR update the record 
                into PQRIQualityMeasureDenominator table based on PQRIQualityMeasureID   
Created By    : Rathnam  
Created Date  : 15-Dec-2010      
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureDenominator_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureID KEYID
       ,@i_AgeFrom SMALLINT
       ,@i_AgeTo SMALLINT
       ,@c_Gender UNIT
       ,@vc_Operator1 VARCHAR(3)
       ,@vc_ICDCodeList VARCHAR(MAX)
       ,@vc_Operator2 VARCHAR(3)
       ,@vc_CPTCodeList VARCHAR(MAX)
       ,@vc_CriteriaSQL VARCHAR(MAX)
       ,@vc_StatusCode STATUSCODE
       )
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsInserted INT       
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
                      PQRIQualityMeasureDenominator
                  WHERE
                      PQRIQualityMeasureID = @i_PQRIQualityMeasureID )

         BEGIN
               UPDATE
                   PQRIQualityMeasureDenominator
               SET
                   AgeFrom = @i_AgeFrom
                  ,AgeTo = @i_AgeTo
                  ,Gender = @c_Gender
                  ,Operator1 = @vc_Operator1
                  ,ICDCodeList = @vc_ICDCodeList
                  ,Operator2 = @vc_Operator2
                  ,CPTCodeList = @vc_CPTCodeList
                  ,CriteriaSQL = @vc_CriteriaSQL
                  ,StatusCode = @vc_StatusCode
                  ,LastModifiedByUserId = @i_AppUserId
                  ,LastModifiedDate = GETDATE()
               WHERE
                   PQRIQualityMeasureID = @i_PQRIQualityMeasureID
         END
      ELSE
         BEGIN
               INSERT INTO
                   PQRIQualityMeasureDenominator
                   (
                    PQRIQualityMeasureID
                   ,AgeFrom
                   ,AgeTo
                   ,Gender
                   ,Operator1
                   ,ICDCodeList
                   ,Operator2
                   ,CPTCodeList
                   ,CriteriaSQL
                   ,StatusCode
                   ,CreatedByUserId
                   )
               VALUES
                   (
                    @i_PQRIQualityMeasureID
                   ,@i_AgeFrom
                   ,@i_AgeTo
                   ,@c_Gender
                   ,@vc_Operator1
                   ,@vc_ICDCodeList
                   ,@vc_Operator2
                   ,@vc_CPTCodeList
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureDenominator_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

