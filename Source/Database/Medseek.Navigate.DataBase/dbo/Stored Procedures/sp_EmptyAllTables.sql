
CREATE PROCEDURE [dbo].[sp_EmptyAllTables] --1
(
 @ResetIdentity BIT
)
AS
BEGIN

      DECLARE @SQL VARCHAR(500)

      DECLARE @TableName VARCHAR(255)

      DECLARE @ConstraintName VARCHAR(500)

      DECLARE curAllForeignKeys SCROLL CURSOR
              FOR SELECT
                      Table_Name ,
                      Constraint_Name
                  FROM
                      Information_Schema.Table_Constraints
                  WHERE
                      Constraint_Type = 'FOREIGN KEY' 

      OPEN curAllForeignKeys

      FETCH Next FROM curAllForeignKeys INTO @TableName,@ConstraintName
      WHILE @@FETCH_STATUS = 0

            BEGIN

                  SET @SQL = 'ALTER TABLE ' + @TableName + ' NOCHECK CONSTRAINT ' + @ConstraintName
                  EXECUTE ( @SQL )

                  FETCH Next FROM curAllForeignKeys INTO @TableName,@ConstraintName

            END

      DECLARE curAllTables CURSOR
              FOR SELECT
                      Table_Name
                  FROM
                      Information_Schema.Tables
                  WHERE
                      TABLE_TYPE = 'BASE TABLE'and Table_Name   in(
                      '	ACGPatientResults	'	,
'AttributionMethod'	,
'AttributionType'	,
'ClaimLineICD'	,
'ClaimLineRemarkCode'	,
'CodeSetClaimFilingIndicator'	,
'CodeSetUnitCode'	,
'CohortListCriteriaTreeView'	,
'ECT_HEDIS_Classification'	,
'ECT_HEDIS_Domain'	,
'ECT_HEDIS_Measure'	,
'ECT_HEDIS_SubDomain'	,
'ECT_HEDIS_Table'	,
'ECT_HEDIS_Type'	,
'LabMeasure'	,
'LabMeasureHistory'	,
'Measure'	,
'NumeratorDefUsers'	,
'PatientPCP'	,
'PatientPhysicianAttribution'	,
'PhysicianType'	,
'PopulationDefinition'	,
'PopulationDefinitionCriteria'	,
'RemarkCode'	,
'ReportFilterConfiguration'	,
'UserAllergies'	,
'UserDisease'	,
'UserMeasure'	,
'UserProcedureCodes'


)

      OPEN curAllTables




      FETCH First FROM curAllForeignKeys INTO @TableName,@ConstraintName
      WHILE @@FETCH_STATUS = 0

            BEGIN

                  SET @SQL = 'ALTER TABLE ' + @TableName + ' CHECK CONSTRAINT ' + @ConstraintName
                  EXECUTE ( @SQL )

                  FETCH Next FROM curAllForeignKeys INTO @TableName,@ConstraintName

            END

      CLOSE curAllTables
      DEALLOCATE curAllTables

      CLOSE curAllForeignKeys
      DEALLOCATE curAllForeignKeys

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[sp_EmptyAllTables] TO [FE_rohit.r-ext]
    AS [dbo];

