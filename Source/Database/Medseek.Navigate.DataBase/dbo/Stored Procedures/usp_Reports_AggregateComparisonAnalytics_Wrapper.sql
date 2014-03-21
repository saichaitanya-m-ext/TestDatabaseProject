
/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_Reports_AggregateComparisonAnalytics_Wrapper]            
Description   : This functionality shall enable the user to compare the performance and outcomes 
                of different Provider entities to find out the performance of each of them or as a 
                group as compared to their peers, the cohorts, the clinic or Organization as a benchmark  
Created By    : Rathnam            
Created Date  : 14-July-2011            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION 
17-Jan-2012 NagaBabu Added #tblTypesList and modified last select statement as getting data from #tblTypesList  
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_Reports_AggregateComparisonAnalytics_Wrapper]
(
 @i_AppUserId KEYID ,
 @v_ComparisonList1 VARCHAR(MAX) ,
 @v_MeasureIdList VARCHAR(MAX) ,
 @i_DiseaseID INT )
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

      CREATE TABLE #tblTypePatients
      (
        UserId INT ,
        DateTaken DATETIME ,
        Ranges VARCHAR(20) ,
        MeasureId INT ,
        MeasureName VARCHAR(500) ,
        TypeID INT ,
        TypeName VARCHAR(500) ,
        WhichType VARCHAR(30) ,
        SetType VARCHAR(10) ,
        ProcedureID INT ,
        ProcedureName VARCHAR(500) )
		-- Getting @v_ComparisonList1 selected type of data from the following sp	
      INSERT INTO
          #tblTypePatients
          EXEC [dbo].[usp_Reports_ProviderConditionalReport] 
	  		@i_AppUserId = @i_AppUserId , 
			@v_ComparisonList = @v_ComparisonList1 , 
			@i_DiseaseID = @i_DiseaseID , 
			@v_MeasureIdList = @v_MeasureIdList , 
			@b_IsMeasureDrillDown = 0 , 
			@b_IsProcessDrillDown = 0


      SELECT
          WhichType AS [Type] ,
          TypeID ,
          TypeName ,
          MeasureId AS MeasureId ,
          MeasureName AS MeasureName ,
          COUNT(UserId) AS PatientCount ,
          SUM(CASE
                   WHEN Ranges = 'Good' THEN 1
                   ELSE 0
              END) AS GoodCount ,
          SUM(CASE
                   WHEN Ranges = 'Fair' THEN 1
                   ELSE 0
              END) AS FairCount ,
          SUM(CASE
                   WHEN Ranges = 'Poor' THEN 1
                   ELSE 0
              END) AS PoorCount ,
          SUM(CASE
                   WHEN Ranges = 'Undefined' THEN 1
                   ELSE 0
              END) AS UndefinedCount
      INTO
          #tblTypesList
      FROM
          #tblTypePatients
      WHERE
          SetType = 'Measures'
      GROUP BY
          MeasureId ,
          MeasureName ,
          TypeID ,
          TypeName ,
          WhichType

      SELECT
          [Type] ,
          TypeID ,
          TypeName ,
          MeasureId ,
          MeasureName ,
          PatientCount ,
          GoodCount ,
          FairCount ,
          PoorCount ,
          UndefinedCount
      FROM
          #tblTypesList
      SELECT
          WhichType AS [Type] ,
          TypeID ,
          TypeName ,
          MeasureId AS MeasureId ,
          MeasureName AS MeasureName ,
          COUNT(UserId) AS PatientCount ,
          SUM(CASE Ranges
                WHEN 'NotDone' THEN 1
                ELSE 0
              END) AS NotDone ,
          SUM(CASE Ranges
                WHEN 'Done' THEN 1
                ELSE 0
              END) AS Done
      FROM
          #tblTypePatients
      WHERE
          SetType = 'Procedures'
      GROUP BY
          WhichType ,
          TypeID ,
          TypeName ,
          MeasureId ,
          MeasureName
      UNION ALL
      SELECT DISTINCT
          WhichType AS [Type] ,
          TypeID ,
          TypeName ,
          MeasureId AS MeasureId ,
          MeasureName AS MeasureName ,
          0 ,
          0 ,
          0
      FROM
          #tblTypePatients tblps
      WHERE
          SetType = 'Measures'
          AND NOT EXISTS ( SELECT TOP 1
                               1
                           FROM
                               #tblTypePatients
                           WHERE
                               SetType = 'Procedures'
                               AND MeasureId = tblps.MeasureId )
      GROUP BY
          WhichType ,
          TypeID ,
          TypeName ,
          MeasureId ,
          MeasureName

      SELECT DISTINCT
          MeasureName
      FROM
          #tblTypePatients
      SELECT DISTINCT
          TypeName
      FROM
          #tblTypePatients

      SELECT DISTINCT
          TypeID ,
          TypeName
      FROM
          #tblTypesList
END TRY  
-------------------------------------------------------------------------------------------------------------------------   
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH  



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_AggregateComparisonAnalytics_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

