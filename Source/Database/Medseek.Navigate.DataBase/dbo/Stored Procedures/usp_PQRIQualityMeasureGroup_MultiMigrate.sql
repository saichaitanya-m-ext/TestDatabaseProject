/*        
------------------------------------------------------------------------------        
Procedure Name: usp_PQRIQualityMeasureGroup_MultiMigrate
Description   : This procedure is used to migrate record in PQRIQualityMeasureGroup,
				PQRIQualityMeasureGroupToMeasure,PQRIQualityMeasureGroupDenominator table							   
Created By    : Rama    
Created Date  : 23-Dec-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY  DESCRIPTION 
25-Dec-2010		Rama replaced PQRIQualityMeasuretoMeasureGroup by PQRIQualityMeasureGroupToMeasure  
13-Jan-2011 NagaBabu Added AgeFrom,AgeTo,Gender to Insert statement of PQRIQualityMeasureGroupDenominator table
28-Jan-2011 Rathnam Changed the join conditions for getting OLDMeasureGroupID,migratedmeasure             
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroup_MultiMigrate]
(
	 @i_AppUserId KEYID
	,@t_PQRIMeasureGroupID TTYPEKEYID READONLY
	,@i_ToReportingYear SMALLINT
)
AS
BEGIN TRY

      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsInserted INT       
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
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
 -------------------Migration To PQRIQualityMeasureGroup Table---------     

      DECLARE @t_PQRIQualityMeasureGroupID TABLE
            (
               OLDMeasureGroupID INT
              ,NewMeasureGroupID INT
            )

      INSERT INTO
          PQRIQualityMeasureGroup
          (
			   PQRIMeasureGroupID
			  ,Name
			  ,Description
			  ,StatusCode
			  ,ReportingYear
			  ,ReportingPeriod
			  ,ReportingPeriodType
			  ,PerformancePeriod
			  ,PerformancePeriodType
			  ,GCode
			  ,CompositeGCode
			  ,IsBFFS
			  ,DocumentLibraryID
			  ,DocumentStartPage
			  ,SubmissionMethod
			  ,ReportingMethod
			  ,Note
			  ,CreatedByUserId
			  ,MigratedPQRIQualityMeasureGroupID
          )
          SELECT
              PQRIQMG.PQRIMeasureGroupID
             ,PQRIQMG.Name
             ,PQRIQMG.Description
             ,PQRIQMG.StatusCode
             ,@i_ToReportingYear
             ,PQRIQMG.ReportingPeriod
             ,PQRIQMG.ReportingPeriodType
             ,PQRIQMG.PerformancePeriod
             ,PQRIQMG.PerformancePeriodType
             ,PQRIQMG.GCode
             ,PQRIQMG.CompositeGCode
             ,PQRIQMG.IsBFFS
             ,PQRIQMG.DocumentLibraryID
             ,PQRIQMG.DocumentStartPage
             ,PQRIQMG.SubmissionMethod
             ,PQRIQMG.ReportingMethod
             ,PQRIQMG.Note
             ,@i_AppUserId
             ,PQRI.tKeyId  
          FROM
              PQRIQualityMeasureGroup PQRIQMG
          INNER JOIN @t_PQRIMeasureGroupID PQRI
              ON PQRIQMG.PQRIQualityMeasureGroupID = PQRI.tKeyId
              
      INSERT INTO
          @t_PQRIQualityMeasureGroupID
          (
			   OLDMeasureGroupID
			  ,NewMeasureGroupID
          )
          SELECT
              NewPQRIQualityMeasureGroup.MigratedPQRIQualityMeasureGroupID
             ,NewPQRIQualityMeasureGroup.PQRIQualityMeasureGroupID
          FROM
               PQRIQualityMeasureGroup NewPQRIQualityMeasureGroup
          INNER JOIN PQRIQualityMeasureGroup OldPQRIQualityMeasureGroup
              ON NewPQRIQualityMeasureGroup.MigratedPQRIQualityMeasureGroupID = OldPQRIQualityMeasureGroup.PQRIQualityMeasureGroupID
          INNER JOIN @t_PQRIMeasureGroupID PQRI
              ON OldPQRIQualityMeasureGroup.PQRIQualityMeasureGroupID = PQRI.tKeyId
             AND NewPQRIQualityMeasureGroup.MigratedPQRIQualityMeasureGroupID IS NOT NULL    
           
  -------------------Migration To PQRIQualityMeasureGroupToMeasure Table---------  

      INSERT INTO
          PQRIQualityMeasureGroupToMeasure
          (
			   PQRIQualityMeasureGroupId
			  ,PQRIQualityMeasureID
			  ,CreatedByUserId
          )
          SELECT
			   PQRI.NewMeasureGroupID
			   ,QualityMeasureGrToMeasure.PQRIQualityMeasureId
			   ,@i_AppUserId
          FROM
              PQRIQualityMeasureGroupToMeasure QualityMeasureGrToMeasure
          INNER JOIN @t_PQRIQualityMeasureGroupID PQRI
              ON PQRI.OLDMeasureGroupID = QualityMeasureGrToMeasure.PQRIQualityMeasureGroupID
					
  -------------------Migration To PQRIQualityMeasureGroupDenominator Table---------  
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
          SELECT
              PQRI.NewMeasureGroupID
             ,QualityMeasureGrDenominator.Operator1
             ,QualityMeasureGrDenominator.ICDCodeList
             ,QualityMeasureGrDenominator.Operator2
             ,QualityMeasureGrDenominator.CPTCodeList
             ,QualityMeasureGrDenominator.CriteriaSQL
             ,QualityMeasureGrDenominator.StatusCode
             ,@i_AppUserId
             ,QualityMeasureGrDenominator.AgeFrom
             ,QualityMeasureGrDenominator.AgeTo
             ,QualityMeasureGrDenominator.Gender
          FROM
              PQRIQualityMeasureGroupDenominator QualityMeasureGrDenominator
          INNER JOIN @t_PQRIQualityMeasureGroupID PQRI
              ON PQRI.OLDMeasureGroupID = QualityMeasureGrDenominator.PQRIQualityMeasureGroupID

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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroup_MultiMigrate] TO [FE_rohit.r-ext]
    AS [dbo];

