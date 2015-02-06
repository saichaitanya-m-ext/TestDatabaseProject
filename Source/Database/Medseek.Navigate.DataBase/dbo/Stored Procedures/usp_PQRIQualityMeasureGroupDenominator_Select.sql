/*
--------------------------------------------------------------------------------
Procedure Name: [usp_PQRIQualityMeasureGroupDenominator_Select] 
Description	  : This procedure is used to get the details of PQRIQualityMeasureGroupDenominator
                based on PQRIQualityMeasureGroupID.
Created By    :	Rathnam 
Created Date  : 16-Dec-2010
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
30-Dec-2010    Rama added usp_PQRIQualityMeasureGroupCorrelate _SelectGender procedure
13-Jan-2011	 NagaBabu Added AgeFrom,AgeTo,Gender to Select statement	
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupDenominator_Select]
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureGroupID KEYID
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
         
      SELECT
          GroupDenomenator.PQRIQualityMeasureGroupDenominatorID
         ,GroupDenomenator.PQRIQualityMeasureGroupID
         ,GroupDenomenator.Operator1
         ,GroupDenomenator.ICDCodeList
         ,GroupDenomenator.Operator2
         ,GroupDenomenator.CPTCodeList
         ,GroupDenomenator.CriteriaSQL
         ,GroupDenomenator.StatusCode
         ,GroupDenomenator.CreatedByUserId
         ,GroupDenomenator.CreatedDate
         ,GroupDenomenator.LastModifiedByUserId
         ,GroupDenomenator.LastModifiedDate
         ,GroupDenomenator.AgeFrom
         ,GroupDenomenator.AgeTo
         ,GroupDenomenator.Gender
      FROM
          PQRIQualityMeasureGroupDenominator GroupDenomenator
      WHERE
          GroupDenomenator.PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID

      DECLARE
              @vc_ICDCodeList VARCHAR(MAX)
             ,@vc_CPTCodeList VARCHAR(MAX)
             ,@vc_ICDCodeSql VARCHAR(MAX)
             ,@vc_CPTCodeSql VARCHAR(MAX)

      SELECT
          @vc_ICDCodeList = ISNULL(ICDCodeList,'')
         ,@vc_CPTCodeList = ISNULL(CPTCodeList,'')
      FROM
          PQRIQualityMeasureGroupDenominator
      WHERE
          PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID

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
      EXEC [usp_PQRIQualityMeasureGroupCorrelate_SelectGender]
		   @i_AppUserId =  @i_AppUserId
		   ,@i_PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupDenominator_Select] TO [FE_rohit.r-ext]
    AS [dbo];

