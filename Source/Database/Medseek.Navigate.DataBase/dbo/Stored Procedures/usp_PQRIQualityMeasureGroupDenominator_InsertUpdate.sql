/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PQRIQualityMeasureGroupDenominator_InsertUpdate]        
Description   : This procedure is used to insert record OR update the record 
                into PQRIQualityMeasureGroupDenominator table based on PQRIQualityMeasureGroupID   
Created By    : Rathnam  
Created Date  : 16-Dec-2010      
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION  
13-Jan-2011 NagaBabu  Added AgeFrom,AgeTo,Gender to Update,Insert statements    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupDenominator_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureGroupID KEYID
       ,@i_AgeFrom SMALLINT = NULL
       ,@i_AgeTo SMALLINT = NULL
       ,@c_Gender UNIT = NULL
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
                      PQRIQualityMeasureGroupDenominator
                  WHERE
                      PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID)

         BEGIN
               UPDATE
                   PQRIQualityMeasureGroupDenominator
               SET
                  PQRIQualityMeasureGroupID=@i_PQRIQualityMeasureGroupID
                  ,Operator1 = @vc_Operator1
                  ,ICDCodeList = @vc_ICDCodeList
                  ,Operator2 = @vc_Operator2
                  ,CPTCodeList = @vc_CPTCodeList
                  ,CriteriaSQL = @vc_CriteriaSQL
                  ,StatusCode = @vc_StatusCode
                  ,LastModifiedByUserId = @i_AppUserId
                  ,LastModifiedDate = GETDATE()
                  ,AgeFrom = @i_AgeFrom
                  ,AgeTo = @i_AgeTo
                  ,Gender = @c_Gender
               WHERE
                   PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID
         END
      ELSE
         BEGIN
               INSERT INTO
                   PQRIQualityMeasureGroupDenominator
                   (
                    PQRIQualityMeasureGroupID
                   ,Operator1
                   ,ICDCodeList
                   ,Operator2
                   ,CPTCodeList
                   ,CriteriaSQL
                   ,StatusCode
                   ,CreatedByUserId
				   ,AgeFrom
				   ,AgeTo 
				   ,Gender 
                   )
               VALUES
                   (
                    @i_PQRIQualityMeasureGroupID
                   ,@vc_Operator1
                   ,@vc_ICDCodeList
                   ,@vc_Operator2
                   ,@vc_CPTCodeList
                   ,@vc_CriteriaSQL
                   ,@vc_StatusCode
                   ,@i_AppUserId
				   ,@i_AgeFrom
				   ,@i_AgeTo 
				   ,@c_Gender 
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupDenominator_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

