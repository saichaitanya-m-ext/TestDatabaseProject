
/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_Reports_AdvancedComparisonAnalytics_Wrapper]            
Description   : This functionality shall enable the user to compare the performance and outcomes 
                of different Provider entities to find out the performance of each of them or as a 
                group as compared to their peers, the cohorts, the clinic or Organization as a benchmark  
Created By    : Rathnam            
Created Date  : 14-July-2011            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION 
20-Dec-2011 NagaBabu Added @i_DiseaseId as input parameter For filter the patients as per disease 
04-Jan-2012 NagaBabu Replaced 'set1' as 'Aggregated Group 1' and 'set2' as 'Aggregated Group 2'
19-Jan-2012 NagaBabu Replaced ' , ' by ',' and replaced  XML PATH('') ) , 1 , 4 , '' by  XML PATH('') ) , 1 , 1 , ''
						for TypeName in third result set
02-Apr-2012 NagaBabu Added @d_FromDate,@d_ToDate as Input Parameters						
------------------------------------------------------------------------------           
*/
CREATE PROCEDURE [dbo].[usp_Reports_AdvancedComparisonAnalytics_Wrapper]
(
 @i_AppUserId KEYID ,
 @v_ComparisonList1 VARCHAR(MAX) ,
 @v_ComparisonList2 VARCHAR(MAX) = NULL ,
 @v_MeasureIdList VARCHAR(MAX) = NULL ,
 @b_Aggregate1 BIT = 0 ,
 @b_Aggregate2 BIT = 0 ,
 @c_BenchMarkCode CHAR(2) = NULL ,----Related to Benchmarks like StateCode only
 @i_BenchMarkSubTypeID INT = NULL , ----In state seperate Regions Need to implement
 @i_DiseaseId KEYID ,
 @d_FromDate USERDATE ,
 @d_ToDate USERDATE )
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

      CREATE TABLE #tblTypePatient
      (
        UserId INT ,
        DateTaken DATETIME ,
        Ranges VARCHAR(20) ,
        MeasureId INT ,
        MeasureName VARCHAR(500) ,
        TypeID INT ,
        TypeName VARCHAR(500) ,
        WhichType VARCHAR(30) ,
        SetType VARCHAR(30) )
		
				---- Getting @v_ComparisonList1 selected type of data from the following sp	
      INSERT INTO
          #tblTypePatient
          EXEC [dbo].[usp_Reports_AdvancedComparisonAnalytics] @i_AppUserId = @i_AppUserId , @v_ComparisonList = @v_ComparisonList1 , @v_MeasureIdList = @v_MeasureIdList , @c_BenchMarkCode = @c_BenchMarkCode , @i_BenchMarkSubTypeID = @i_BenchMarkSubTypeID , @i_DiseaseId = @i_DiseaseId , @d_FromDate = @d_FromDate , @d_ToDate = @d_ToDate

      SELECT DISTINCT
          UserId ,
          Ranges ,
          MeasureId ,
          MeasureName ,
          TypeID ,
          TypeName ,
          WhichType ,
          SetType
      INTO
          #tblTypePatients
      FROM
          #tblTypePatient

      IF @b_Aggregate1 = 0 ---None of the aggregates
         BEGIN
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
                   WhichType AS [Type] ,
                   TypeID ,
                   TypeName ,
                   MeasureId AS MeasureId ,
                   MeasureName AS MeasureName ,
                   COUNT(DISTINCT UserId) AS PatientCount ,
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
                   MeasureName--,MONTH(DateTaken),YEAR(DateTaken)               


               SELECT
                   1
               WHERE
                   1 = 2 --Dev Request Dont remove			               
         END
      ELSE
         BEGIN
               IF ( @b_Aggregate1 = 1
                    AND @v_ComparisonList2 IS NOT NULL ) ---Aggregate started here
                  BEGIN
                        CREATE TABLE #tblTypePatientsList
                        (
                          UserId INT ,
                          DateTaken DATETIME ,
                          Ranges VARCHAR(20) ,
                          MeasureId INT ,
                          MeasureName VARCHAR(500) ,
                          TypeID INT ,
                          TypeName VARCHAR(500) ,
                          WhichType VARCHAR(30) ,
                          SetType VARCHAR(30) )
					-- Getting @v_ComparisonList2 selected type of data from the following sp		
                        INSERT INTO
                            #tblTypePatientsList
                            EXEC [dbo].[usp_Reports_AdvancedComparisonAnalytics] @i_AppUserId = @i_AppUserId , @v_ComparisonList = @v_ComparisonList2 , @v_MeasureIdList = @v_MeasureIdList , @i_DiseaseId = @i_DiseaseId , @d_FromDate = @d_FromDate , @d_ToDate = @d_ToDate

                        SELECT DISTINCT
                            UserId ,
                            Ranges ,
                            MeasureId ,
                            MeasureName ,
                            TypeID ,
                            TypeName ,
                            WhichType ,
                            SetType
                        INTO
                            #tblTypePatientsList2
                        FROM
                            #tblTypePatient

                        IF ( @b_Aggregate1 = 1
                             AND @b_Aggregate2 = 1 ) --Both are aggregating started here
                           BEGIN
                                 CREATE TABLE #tblOutPutSet
                                 (
                                   SetList VARCHAR(30) ,
                                   MeasureId INT ,
                                   MeasureName VARCHAR(150) ,
                                   PatientCount INT ,
                                   GoodCount INT ,
                                   FairCount INT ,
                                   PoorCount INT ,
                                   UndefinedCount INT )
                                 INSERT INTO
                                     #tblOutPutSet
                                     SELECT
                                         'Aggregated Group 1' AS SetList ,
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
                                     FROM
                                         #tblTypePatients
                                     WHERE
                                         SetType = 'Measures'
                                         AND WhichType <> 'BENCHMARK'
                                     GROUP BY
                                         MeasureId ,
                                         MeasureName
                                     UNION ALL
                                     SELECT
                                         'Aggregated Group 2' AS SetList ,
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
                                     FROM
                                         #tblTypePatientsList2
                                     WHERE
                                         SetType = 'Measures'
                                     GROUP BY
                                         MeasureId ,
                                         MeasureName
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL TypeID ,
                                     SetList TypeName ,
                                     MeasureId ,
                                     MeasureName ,
                                     PatientCount ,
                                     GoodCount ,
                                     FairCount ,
                                     PoorCount ,
                                     UndefinedCount
                                 FROM
                                     #tblOutPutSet
                                 UNION ALL
                                 SELECT
                                     'BENCHMARK' AS [Type] ,
                                     NULL TypeID ,
                                     'BENCHMARK' AS TypeName ,
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
                                 FROM
                                     #tblTypePatients
                                 WHERE
                                     SetType = 'Measures'
                                     AND WhichType = 'BENCHMARK'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL TypeID ,
                                     'Aggregated Group 1' TypeName ,
                                     MeasureId AS MeasureId ,
                                     MeasureName AS MeasureName ,
                                     COUNT(DISTINCT UserId) AS PatientCount ,
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
                                     AND WhichType <> 'BENCHMARK'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName--,MONTH(DateTaken),YEAR(DateTaken)

                                 UNION ALL
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL TypeID ,
                                     SetList TypeName ,
                                     MeasureId ,
                                     MeasureName ,
                                     0 ,
                                     0 ,
                                     0
                                 FROM
                                     #tblOutPutSet
                                 WHERE
                                     SetList = 'Aggregated Group 1'
                                     AND EXISTS ( SELECT
                                                      1
                                                  FROM
                                                      #tblTypePatients
                                                  WHERE
                                                      MeasureId = MeasureId )--

                                 UNION ALL
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL TypeID ,
                                     'Aggregated Group 2' TypeName ,
                                     MeasureId AS MeasureId ,
                                     MeasureName AS MeasureName ,
                                     COUNT(DISTINCT UserId) AS PatientCount ,
                                     SUM(CASE Ranges
                                           WHEN 'NotDone' THEN 1
                                           ELSE 0
                                         END) AS NotDone ,
                                     SUM(CASE Ranges
                                           WHEN 'Done' THEN 1
                                           ELSE 0
                                         END) AS Done
                                 FROM
                                     #tblTypePatientsList2
                                 WHERE
                                     SetType = 'Procedures'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName--,MONTH(DateTaken),YEAR(DateTaken)

                                 UNION ALL
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL TypeID ,
                                     SetList TypeName ,
                                     MeasureId ,
                                     MeasureName ,
                                     0 ,
                                     0 ,
                                     0
                                 FROM
                                     #tblOutPutSet
                                 WHERE
                                     SetList = 'Aggregated Group 2'
                                     AND EXISTS ( SELECT
                                                      1
                                                  FROM
                                                      #tblTypePatientsList2
                                                  WHERE
                                                      MeasureId = MeasureId )
                                 UNION ALL
                                 SELECT
                                     'BENCHMARK' AS [Type] ,
                                     NULL TypeID ,
                                     'BENCHMARK' TypeName ,
                                     MeasureId AS MeasureId ,
                                     MeasureName AS MeasureName ,
                                     COUNT(DISTINCT UserId) AS PatientCount ,
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
                                     AND WhichType = 'BENCHMARK'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName--,MONTH(DateTaken),YEAR(DateTaken)
                                 SELECT
                                     'Aggregated Group 1' AS SetType ,
                                     STUFF(( SELECT DISTINCT
                                                 ', ' + t.TypeName
                                             FROM
                                                 #tblTypePatients t
                                             WHERE
                                                 WhichType <> 'BENCHMARK'
                                             FOR
                                                 XML PATH('') ) , 1 , 4 , '') AS TypeName ,
                                     STUFF(( SELECT DISTINCT
                                                 ',' + t.WhichType + '-' + CONVERT(VARCHAR , t.TypeID)
                                             FROM
                                                 #tblTypePatients t
                                             WHERE
                                                 WhichType <> 'BENCHMARK'
                                             FOR
                                                 XML PATH('') ) , 1 , 1 , '') AS TypeID
                                 UNION ALL
                                 SELECT
                                     'Aggregated Group 2' AS SetType ,
                                     STUFF(( SELECT DISTINCT
                                                 ',' + t.TypeName
                                             FROM
                                                 #tblTypePatientsList2 t
                                             FOR
                                                 XML PATH('') ) , 1 , 1 , '') AS TypeName ,
                                     STUFF(( SELECT DISTINCT
                                                 ',' + t.WhichType + '-' + CONVERT(VARCHAR , t.TypeID)
                                             FROM
                                                 #tblTypePatientsList2 t
                                             FOR
                                                 XML PATH('') ) , 1 , 1 , '') AS TypeID

                           END
                        ELSE--List1 one is aggregated  and List2 is not aggregated
                           BEGIN
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL AS TypeID ,
                                     'Aggregated Group 1' AS TypeName ,
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
                                 FROM
                                     #tblTypePatients
                                 WHERE
                                     SetType = 'Measures'
                                     AND WhichType <> 'BENCHMARK'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName
                                 UNION ALL
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
                                 FROM
                                     #tblTypePatientsList2
                                 WHERE
                                     SetType = 'Measures'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName ,
                                     TypeID ,
                                     TypeName ,
                                     WhichType
                                 UNION ALL
                                 SELECT
                                     'BENCHMARK' AS [Type] ,
                                     NULL AS TypeID ,
                                     'BENCHMARK' AS TypeName ,
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
                                 FROM
                                     #tblTypePatients
                                 WHERE
                                     SetType = 'Measures'
                                     AND WhichType = 'BENCHMARK'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL AS TypeID ,
                                     'Aggregated Group 1' AS TypeName ,
                                     MeasureId AS MeasureId ,
                                     MeasureName AS MeasureName ,
                                     COUNT(DISTINCT UserId) AS PatientCount ,
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
                                     AND WhichType <> 'BENCHMARK'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName--,MONTH(DateTaken),YEAR(DateTaken)

                                 UNION ALL
                                 SELECT
                                     NULL AS [Type] ,
                                     NULL AS TypeID ,
                                     'Aggregated Group 1' AS TypeName ,
                                     MeasureId AS MeasureId ,
                                     MeasureName AS MeasureName ,
                                     0 ,
                                     0 ,
                                     0
                                 FROM
                                     #tblTypePatients ttp
                                 WHERE
                                     SetType = 'Measures'
                                     AND NOT EXISTS ( SELECT
                                                          1
                                                      FROM
                                                          #tblTypePatients ttp1
                                                      WHERE
                                                          SetType = 'Procedures'
                                                          AND ttp.MeasureId = ttp1.MeasureId )
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName
                                 UNION ALL
                                 SELECT
                                     WhichType AS [Type] ,
                                     TypeID ,
                                     TypeName ,
                                     MeasureId AS MeasureId ,
                                     MeasureName AS MeasureName ,
                                     COUNT(DISTINCT UserId) AS PatientCount ,
                                     SUM(CASE Ranges
                                           WHEN 'NotDone' THEN 1
                                           ELSE 0
                                         END) AS NotDone ,
                                     SUM(CASE Ranges
                                           WHEN 'Done' THEN 1
                                           ELSE 0
                                         END) AS Done
                                 FROM
                                     #tblTypePatientsList2
                                 WHERE
                                     SetType = 'Procedures'
                                 GROUP BY
                                     WhichType ,
                                     TypeID ,
                                     TypeName ,
                                     MeasureId ,
                                     MeasureName--,MONTH(DateTaken),YEAR(DateTaken) 

                                 UNION ALL
                                 SELECT
                                     WhichType AS [Type] ,
                                     TypeID ,
                                     TypeName ,
                                     MeasureId AS MeasureId ,
                                     MeasureName AS MeasureName ,
                                     0 ,
                                     0 ,
                                     0
                                 FROM
                                     #tblTypePatientsList2 ttp
                                 WHERE
                                     SetType = 'Measures'
                                     AND NOT EXISTS ( SELECT
                                                          1
                                                      FROM
                                                          #tblTypePatientsList2 ttp1
                                                      WHERE
                                                          SetType = 'Procedures'
                                                          AND ttp.MeasureId = ttp1.MeasureId )
                                 GROUP BY
                                     WhichType ,
                                     TypeID ,
                                     TypeName ,
                                     MeasureId ,
                                     MeasureName--,MONTH(DateTaken),YEAR(DateTaken) 

                                 UNION ALL
                                 SELECT
                                     'BENCHMARK' AS [Type] ,
                                     NULL AS TypeID ,
                                     'BENCHMARK' AS TypeName ,
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
                                     AND WhichType = 'BENCHMARK'
                                 GROUP BY
                                     MeasureId ,
                                     MeasureName--,MONTH(DateTaken),YEAR(DateTaken)



                                 SELECT
                                     'Aggregated Group 1' AS SetType ,
                                     STUFF(( SELECT DISTINCT
                                                 ',' + t.TypeName
                                             FROM
                                                 #tblTypePatients t
                                             WHERE
                                                 WhichType <> 'BENCHMARK'
                                             FOR
                                                 XML PATH('') ) , 1 , 1 , '') AS TypeName ,
                                     STUFF(( SELECT DISTINCT
                                                 ',' + t.WhichType + '-' + CONVERT(VARCHAR , t.TypeID)
                                             FROM
                                                 #tblTypePatients t
                                             WHERE
                                                 WhichType <> 'BENCHMARK'
                                             FOR
                                                 XML PATH('') ) , 1 , 1 , '') AS TypeID
                           END
                  END
         END

      SELECT DISTINCT
          MeasureName
      FROM
          #tblTypePatients

      IF @v_ComparisonList2 IS NULL
         BEGIN

               SELECT DISTINCT
                   TypeName
               FROM
                   #tblTypePatients
         END
      ELSE
         BEGIN
               SELECT DISTINCT
                   TypeName
               FROM
                   #tblTypePatients
               UNION
               SELECT DISTINCT
                   TypeName
               FROM
                   #tblTypePatientsList2
         END
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
    ON OBJECT::[dbo].[usp_Reports_AdvancedComparisonAnalytics_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

