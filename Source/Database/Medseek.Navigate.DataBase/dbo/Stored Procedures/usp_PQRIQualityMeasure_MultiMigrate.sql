/*          
------------------------------------------------------------------------------          
Procedure Name: usp_PQRIQualityMeasure_MultiMigrate   
Description   : This procedure is used to migrate record in PQRIQualityMeasure,    
				PQRIQualityMeasureDenominator and PQRIQualityMeasureNumerator table    
Created By    : Rama      
Created Date  : 23-Dec-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
16-Feb-2011 Rathnam Alias names changed according to naming conditions and proper alignment.          
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasure_MultiMigrate]
       (
        @i_AppUserId KEYID
       ,@t_PQRIMeasureID TTYPEKEYID READONLY
       ,@i_ToReportingYear SMALLINT
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

      DECLARE @b_TranStarted BIT
      SET @b_TranStarted = 0
      IF ( @@TRANCOUNT = 0 )
         BEGIN
               BEGIN TRANSACTION
               SET @b_TranStarted = 1
         END
      ELSE
         SET @b_TranStarted = 0      
            
 -------------------Migration Started from here-------------------  
 -------------------Migration To PQRIQualityMeasure Table---------       

      DECLARE @t_PQRIQualityMeasureID TABLE
            (
               OldMeasureID INT
              ,NewMeasureID INT
            )

      INSERT INTO
          PQRIQualityMeasure
          (
           PQRIMeasureID
          ,Name
          ,Description
          ,StatusCode
          ,ReportingYear
          ,ReportingPeriod
          ,ReportingPeriodType
          ,PerformancePeriod
          ,PerformancePeriodType
          ,IsBFFS
          ,DocumentLibraryID
          ,DocumentStartPage
          ,SubmissionMethod
          ,ReportingMethod
          ,Note
          ,CreatedByUserId
          ,MigratedPQRIQualityMeasureID
          )
          SELECT
              PQRIQM.PQRIMeasureID
             ,PQRIQM.Name
             ,PQRIQM.Description
             ,PQRIQM.StatusCode
             ,@i_ToReportingYear
             ,PQRIQM.ReportingPeriod
             ,PQRIQM.ReportingPeriodType
             ,PQRIQM.PerformancePeriod
             ,PQRIQM.PerformancePeriodType
             ,PQRIQM.IsBFFS
             ,PQRIQM.DocumentLibraryID
             ,PQRIQM.DocumentStartPage
             ,PQRIQM.SubmissionMethod
             ,PQRIQM.ReportingMethod
             ,PQRIQM.Note
             ,@i_AppUserId
             ,PQRI.tKeyId
          FROM
              PQRIQualityMeasure PQRIQM
          INNER JOIN @t_PQRIMeasureID PQRI
              ON PQRIQM.PQRIQualityMeasureID = PQRI.tKeyId

      INSERT INTO
          @t_PQRIQualityMeasureID
          (
           OldMeasureID
          ,NewMeasureID
          )
          SELECT
              NewPQRIQualityMeasure.MigratedPQRIQualityMeasureID
             ,NewPQRIQualityMeasure.PQRIQualityMeasureID
          FROM
              PQRIQualityMeasure NewPQRIQualityMeasure
          INNER JOIN PQRIQualityMeasure OldPQRIQualityMeasure
              ON NewPQRIQualityMeasure.MigratedPQRIQualityMeasureID = OldPQRIQualityMeasure.PQRIQualityMeasureID
          INNER JOIN @t_PQRIMeasureID PQRI
              ON OldPQRIQualityMeasure.PQRIQualityMeasureID = PQRI.tKeyId
             AND NewPQRIQualityMeasure.MigratedPQRIQualityMeasureID IS NOT NULL
                 
      INSERT INTO
          PQRIQualityMeasureGroupToMeasure
          (
           PQRIQualityMeasureGroupId
          ,PQRIQualityMeasureID
          ,CreatedByUserId
          )
          SELECT
              QualityMeasureGrToMeasure.PQRIQualityMeasureGroupId
             ,PQRI.NewMeasureID
             ,@i_AppUserId
          FROM
              PQRIQualityMeasureGroupToMeasure QualityMeasureGrToMeasure
          INNER JOIN @t_PQRIQualityMeasureID PQRI
              ON PQRI.OldMeasureID = QualityMeasureGrToMeasure.PQRIQualityMeasureID
      
        -------------------Migration To PQRIQualityMeasureDenominator Table---------       

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
          SELECT
              PQRI.NewMeasureID
             ,PQRIQMD.AgeFrom
             ,PQRIQMD.AgeTo
             ,PQRIQMD.Gender
             ,PQRIQMD.Operator1
             ,PQRIQMD.ICDCodeList
             ,PQRIQMD.Operator2
             ,PQRIQMD.CPTCodeList
             ,PQRIQMD.CriteriaSQL
             ,PQRIQMD.StatusCode
             ,@i_AppUserId
          FROM
              PQRIQualityMeasureDenominator PQRIQMD
          INNER JOIN @t_PQRIQualityMeasureID PQRI
              ON PQRI.OLDMeasureID = PQRIQMD.PQRIQualityMeasureID  
  
  -------------------Migration To PQRIQualityMeasureNumerator Table---------   

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
          SELECT
              PQRI.NewMeasureID
             ,PQRIQMN.PerformanceType
             ,PQRIQMN.CriteriaText
             ,PQRIQMN.CriteriaSQL
             ,PQRIQMN.StatusCode
             ,@i_AppUserId
          FROM
              PQRIQualityMeasureNumerator PQRIQMN
          INNER JOIN @t_PQRIQualityMeasureID PQRI
              ON PQRI.OLDMeasureID = PQRIQMN.PQRIQualityMeasureID

      IF ( @b_TranStarted = 1 )
         BEGIN
               SET @b_TranStarted = 0
               COMMIT TRANSACTION
         END
      ELSE
         BEGIN
               ROLLBACK TRANSACTION
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasure_MultiMigrate] TO [FE_rohit.r-ext]
    AS [dbo];

