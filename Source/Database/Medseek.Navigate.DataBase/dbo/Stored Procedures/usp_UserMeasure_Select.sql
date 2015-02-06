/*                  
------------------------------------------------------------------------------                  
Procedure Name: usp_UserMeasure_Select 10,16,1,null,0  
Description   : This procedure is used to get the details from UserMeasure Table                
Created By    : Aditya                  
Created Date  : 15-Apr-2010                  
------------------------------------------------------------------------------                  
Log History   :                   
DD-MM-YYYY    BY   DESCRIPTION                  
26-Apr-2010  Pramod   Removed the join condition with LabMeasure as none of the        
                       fields are used in the select statement  
28-June-2010 Rathnam Added UserMeasureGoal Table type variable.  
29-June-2010 NagaBabu Modified isPatientAdministered,StatusDescription fields in Select Statement     
2-Jul-10 Pramod Modified to address issue with measure value display     
21-Oct-10 Pramod Included the case statement for getting the range as the   
   LEN(MeasureRangeGoal) - 6 >=0 THEN  
04-Mar-2011 NagaBabu Added RealisticMin ,RealisticMax     
14-Mar-2011 RamaChandra added MeasureValueText parameter in ufn_GetPatientMeasureRangeAndGoal Function  
29-July-2011 NagaBabu Added IsTextValueForControls field in select list  
17-Aug-2011 NagaBabu Modified querry for MeasureGoal,MeasureRange Fields  
18-Aug-2011 NagaBabu Added ISNULL for parameter for function ufn_GetPatientMeasureRangeAndGoal  
16-Sep-2011 NagaBabu Added changed first input parameter to UserMeasure.DateTaken in ufn_GetPatientMeasureTrend function  
17-Jul-2011 Sivakrishna Added DatasourceId,DatasourceName to existing insert statement and select statement.  
12-Feb-2013 Rathnam added join clause with UserMeasureRange table and commented the dbo.ufn_GetPatientMeasureRangeAndGoal  
20-Mar-2013 P.V.P.Mohan modified UserMeasure to PatientMeasure,DataSource to CodeSetDataSource  
   and modified columns.  
04-APR-2013 P.V.P.MOHAN modified UserMeasure Table to PatientMeasure and Columns of that Table
            and modified the ufn_GetPatientMeasureTrend function  .   
------------------------------------------------------------------------------                  
*/    
    
CREATE PROCEDURE [dbo].[usp_UserMeasure_Select]  --10,16,1,null,null
(  
 @i_AppUserId KEYID ,  
 @i_UserMeasureId KEYID = NULL ,  
 @i_PatientUserId KEYID = NULL ,  
 @v_StatusCode STATUSCODE = NULL,  
 @b_ShowLastOneYearData BIT = 0  
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON                   
-- Check if valid Application User ID is passed                
  
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END  
  
      DECLARE @UserMeasureGoal TABLE  
      (  
        UserMeasureId KEYID ,  
        PatientUserId KEYID ,  
        MeasureId KEYID ,  
        MeasureTypeId KEYID ,  
        MeasureTypeName SOURCENAME ,  
        MeasureName SOURCENAME ,  
        MeasureValueText VARCHAR(200) ,  
        MeasureValue VARCHAR(200) ,  
        MeasureRangeGoal VARCHAR(504) ,  
        MeasureTrend VARCHAR(10) ,  
        Comments VARCHAR(max) ,  
        IsPatientAdministered VARCHAR(3) ,  
        DateTaken USERDATE ,  
        DueDate USERDATE ,  
        CreatedByUserId KEYID ,  
        CreatedDate USERDATE ,  
        LastModifiedByUserId KEYID ,  
        LastModifiedDate USERDATE ,  
        StatusDescription VARCHAR(10),  
        RealisticMin DECIMAL(10,2),  
        RealisticMax DECIMAL(10,2),  
        IsTextValueForControls VARCHAR(10),  
        SynonymMasterMeasureID INT,  
        DataSourceId INT,  
        DataSource VARCHAR(100)  
      )  
  
      INSERT INTO  
          @UserMeasureGoal  
          (  
            UserMeasureId ,  
            PatientUserId ,  
            MeasureId ,  
            MeasureTypeId ,  
            MeasureTypeName ,  
            MeasureName ,  
            MeasureValueText ,  
            MeasureValue ,  
            MeasureRangeGoal ,  
            MeasureTrend ,  
            Comments ,  
            isPatientAdministered ,  
            DateTaken ,  
            DueDate ,  
            CreatedByUserId ,  
            CreatedDate ,  
            LastModifiedByUserId ,  
            LastModifiedDate ,  
            StatusDescription ,  
            RealisticMin ,  
            RealisticMax ,  
            IsTextValueForControls ,  
            SynonymMasterMeasureID,  
            DataSourceId,  
            DataSource  
          )  
        
          
          SELECT DISTINCT  
              PatientMeasure.PatientMeasureID UserMeasureId ,  
              PatientMeasure.PatientID PatientUserId ,  
              PatientMeasure.MeasureId ,  
              Measure.MeasureTypeId ,  
              MeasureType.MeasureTypeName ,  
              Measure.Name AS MeasureName ,  
              ISNULL(PatientMeasure.MeasureValueText , '') MeasureValueText ,  
              CAST(PatientMeasure.MeasureValueNumeric AS VARCHAR(20)) AS MeasureValue ,  
              dbo.ufn_GetPatientMeasureRangeAndGoal(PatientMeasure.MeasureId , PatientMeasure.PatientId , ISNULL(CAST(PatientMeasure.MeasureValueNumeric AS DECIMAL(10,2)),0),PatientMeasure.MeasureValueText) AS MeasureRangeGoal ,  
              --UserMeasureRange.MeasureRange,  
              dbo.ufn_GetPatientMeasureTrend(PatientMeasure.DateTaken , PatientMeasure.MeasureId , PatientMeasure.PatientId , PatientMeasure.MeasureValueNumeric) AS MeasureTrend ,  
              PatientMeasure.Comments ,  
              CASE PatientMeasure.IsPatientAdministered  
    WHEN 0 THEN 'NO'  
    WHEN 1 THEN 'YES'  
    ELSE ''  
     END,  
              PatientMeasure.DateTaken ,  
              PatientMeasure.DueDate ,  
              PatientMeasure.CreatedByUserId ,  
              PatientMeasure.CreatedDate ,  
              PatientMeasure.LastModifiedByUserId ,  
              PatientMeasure.LastModifiedDate ,  
              CASE PatientMeasure.StatusCode  
    WHEN 'A' THEN 'Active'  
    WHEN 'I' THEN 'InActive'  
    ELSE ''  
     END AS StatusDescription ,  
     Measure.RealisticMin ,  
     Measure.RealisticMax ,  
     CASE IsTextValueForControls  
      WHEN 1 THEN 'True'  
      WHEN 0 THEN 'False'  
     END AS IsTextValueForControls ,  
     MeasureSynonyms.SynonymMasterMeasureID  ,  
     PatientMeasure.DataSourceId,  
     CodeSetDataSource.SourceName  
          FROM  
              PatientMeasure WITH(NOLOCK)  
          INNER JOIN Measure WITH(NOLOCK)  
              ON Measure.MeasureId = PatientMeasure.MeasureId  
          INNER JOIN PatientMeasureRange   
              ON PatientMeasure.PatientMeasureID = PatientMeasureRange.PatientMeasureID      
          LEFT OUTER JOIN MeasureSynonyms WITH(NOLOCK)  
     ON (MeasureSynonyms.SynonymMeasureID = Measure.MeasureId   
      OR MeasureSynonyms.SynonymMasterMeasureID = Measure.MeasureId)      
          LEFT OUTER JOIN MeasureType WITH(NOLOCK)  
              ON MeasureType.MeasureTypeId = Measure.MeasureTypeId  
          LEFT JOIN CodeSetDataSource WITH(NOLOCK)  
              ON CodeSetDataSource.DataSourceId = PatientMeasure.DataSourceId  
          WHERE  
              ( PatientMeasure.PatientMeasureId = @i_UserMeasureId  
              OR @i_UserMeasureId IS NULL )  
           AND ( PatientMeasure.PatientId = @i_PatientUserId  
                    OR @i_PatientUserId IS NULL )  
           AND ( PatientMeasure.StatusCode = @v_StatusCode  
                    OR @v_StatusCode IS NULL )  
           AND ( @b_ShowLastOneYearData = 0 OR  
    ( @b_ShowLastOneYearData = 1 AND  
      PatientMeasure.DateTaken > DATEADD(YEAR, -1, GETDATE())  
    )    
       )  
          ORDER BY  
              PatientMeasure.DueDate DESC ,  
              Measure.Name  

      SELECT  
          UserMeasureId ,  
          PatientUserId ,  
          ISNULL(UMG.SynonymMasterMeasureID,UMG.MeasureId) AS MeasureId ,  
          UMG.MeasureTypeId ,  
          MeasureTypeName ,  
          Measure.Name AS MeasureName,  
          ISNULL(MeasureValue, MeasureValueText) AS MeasureValue ,  
          MeasureRangeGoal MeasureGoal,  
          --'' MeasureRange , --Rathnam commented due to performance impact on WP   
          SUBSTRING(MeasureRangeGoal , 1 ,CHARINDEX('-',MeasureRangeGoal)-1) AS MeasureGoal ,  
          CASE   
   WHEN LEN(MeasureRangeGoal) - 11 >=0 THEN  
    SUBSTRING(MeasureRangeGoal , CHARINDEX(MeasureRangeGoal,'-')+1 ,LEN(MeasureRangeGoal))  
   ELSE   
    ''  
    END AS MeasureRange ,  
    SUBSTRING(MeasureRangeGoal , CHARINDEX('-',MeasureRangeGoal)+1 ,LEN(MeasureRangeGoal))AS MeasureRange ,  
          MeasureTrend ,  
          Comments ,  
    IsPatientAdministered ,  
          DateTaken ,  
          DueDate ,  
          UMG.CreatedByUserId ,  
          UMG.CreatedDate ,  
          UMG.LastModifiedByUserId ,  
          UMG.LastModifiedDate ,  
    StatusDescription ,  
    UMG.RealisticMin ,  
    UMG.RealisticMax ,  
    ISNULL(UMG.IsTextValueForControls,'False') AS IsTextValueForControls,  
    DataSourceId,  
    DataSource  
      FROM  
          @UserMeasureGoal UMG   
      INNER JOIN Measure WITH(NOLOCK)  
    ON ISNULL(UMG.SynonymMasterMeasureID,UMG.MeasureId) = Measure.MeasureId   
   AND Measure.IsSynonym = 0   
        
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
    ON OBJECT::[dbo].[usp_UserMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

