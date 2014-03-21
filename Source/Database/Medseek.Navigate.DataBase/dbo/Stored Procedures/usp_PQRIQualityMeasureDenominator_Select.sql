/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PQRIQualityMeasureDenominator_Select]
Description	  : This procedure is used to get the details of PQRIQualityMeasureDenominator
                based on PQRIQualityMeasureID.
Created By    :	Rathnam 
Created Date  : 14-Dec-2010
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
12-Dec-2010		Rama Changed the ProcedureName by ProcedureDescription
22-Feb-2011    Rathnam isnull function added for a variable @vc_ICDCodeList 
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureDenominator_Select]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureID KEYID
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
          PQRIQualityMeasureDenominatorID
         ,PQRIQualityMeasureID
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
         ,CreatedDate
         ,LastModifiedByUserId
         ,LastModifiedDate
      FROM
          PQRIQualityMeasureDenominator
      WHERE
          PQRIQualityMeasureID = @i_PQRIQualityMeasureID

      DECLARE
          @vc_ICDCodeList VARCHAR(MAX)
         ,@vc_CPTCodeList VARCHAR(MAX)
         ,@vc_ICDCodeSql VARCHAR(MAX)
         ,@vc_CPTCodeSql VARCHAR(MAX)

      SELECT
          @vc_ICDCodeList = ISNULL(ICDCodeList,'')
         ,@vc_CPTCodeList = ISNULL(CPTCodeList,'')
      FROM
          PQRIQualityMeasureDenominator
      WHERE
          PQRIQualityMeasureID = @i_PQRIQualityMeasureID

      SET @vc_ICDCodeSql = 
      'SELECT 
          CodeSetICD.ICDCodeId,
          CodeSetICD.ICDCode,
          CodeSetICD.ICDDescription
      FROM
          CodeSetICD
      WHERE ICDCode IN (' + '''' + REPLACE(ISNULL(@vc_ICDCodeList,'') , ', ' , ''',''') + '''' + ')'
      EXEC ( @vc_ICDCodeSql )

      SET @vc_CPTCodeSql = 
      'SELECT 
          ProcedureId,
		  ProcedureCode,
          ProcedureName AS ProcedureDescription
      FROM
          CodeSetProcedure
      WHERE ProcedureCode IN (' + '''' + REPLACE(ISNULL(@vc_CPTCodeList,'') , ', ' , ''',''') + '''' + ')'
      EXEC ( @vc_CPTCodeSql )
      
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureDenominator_Select] TO [FE_rohit.r-ext]
    AS [dbo];

