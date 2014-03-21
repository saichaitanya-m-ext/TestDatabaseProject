
/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_Reports_ProviderConditionalReport_DrillDown]            
Description   : This functionality shall enable the user to compare the performance and outcomes 
                of different Provider entities to find out the performance of each of them or as a 
                group as compared to their peers, the cohorts, the clinic or Organization as a benchmark  
Created By    : Rathnam            
Created Date  : 21-OCT-2011            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION   
26-Dec-2011 Rathnam added order by clause on PatientName
18-Jan-2012 NagaBabu Changed datatypes of WhichType,SetType fields as VARCHAR(30) in #tblTypePatients table
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_Reports_ProviderConditionalReport_DrillDown]
(
 @i_AppUserId KEYID ,
 @v_ComparisonList VARCHAR(MAX) ,
 @v_MeasureIdList VARCHAR(50) ,
 @i_DiseaseID KEYID ,
 @b_IsMeasureDrillDown ISINDICATOR = 0 ,
 @b_IsProcessDrillDown ISINDICATOR = 0 ,
 @v_Goal VARCHAR(20) ,
 @v_TypeNamewithCondition VARCHAR(500)
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

      CREATE TABLE #tblTypePatients
      (
        UserId INT ,
        DateTaken DATETIME ,
        Ranges VARCHAR(20) ,
        MeasureID INT ,
        MeasureName VARCHAR(500) ,
        TypeID INT ,
        TypeName VARCHAR(500) ,
        WhichType VARCHAR(30) ,
        SetType VARCHAR(30) ,
        ProcedureId INT ,
        ProcedureName VARCHAR(500)
      )
		-- Getting @v_ComparisonList1 selected type of data from the following sp	
      INSERT INTO
          #tblTypePatients
          EXEC [dbo].[usp_Reports_ProviderConditionalReport] @i_AppUserId = @i_AppUserId , @v_ComparisonList = @v_ComparisonList , @v_MeasureIdList = @v_MeasureIdList , @i_DiseaseID = @i_DiseaseID , @b_IsMeasureDrillDown = @b_IsMeasureDrillDown , @b_IsProcessDrillDown = @b_IsProcessDrillDown , @v_Goal = @v_Goal

      IF @b_IsMeasureDrillDown = 1
         BEGIN
               SELECT DISTINCT
                   p.UserId ,
                   tblMeasure.DateTaken ,
                   p.MemberNum ,
                   p.FullName AS PatientName ,
                   p.PhoneNumberPrimary ,
                   (
                     SELECT
                         CallTimeName
                     FROM
                         CallTimePreference
                     WHERE
                         CallTimePreferenceId = p.CallTimePreferenceId
                   ) AS CallTimePreference ,
                   p.Age ,
                   p.Gender ,
                   (
                     SELECT TOP 1
                         CONVERT(VARCHAR , ISNULL(ScheduledDate , DateDue) , 101)
                     FROM
                         UserEncounters
                     WHERE
                         Userid = p.Userid
                         AND StatusCode = 'A'
                         AND EncounterDate IS NULL
                     ORDER BY
                         ISNULL(ScheduledDate , DateDue) DESC
                   ) AS NextOfficeVisit ,
                   (
                     SELECT TOP 1
                         ISNULL(CONVERT(VARCHAR , EncounterDate , 101) , '')
                     FROM
                         UserEncounters
                     WHERE
                         Userid = p.Userid
                         AND StatusCode = 'A'
                         AND EncounterDate IS NOT NULL
                     ORDER BY
                         EncounterDate DESC
                   ) AS LastOfficeVisit ,
                   STUFF((
                           SELECT TOP 2
                               ', ' + ProgramName
                           FROM
                               Program with (nolock)
                           INNER JOIN UserPrograms with (nolock)
                               ON UserPrograms.ProgramId = Program.ProgramId
                           WHERE
                               UserPrograms.Userid = p.Userid
                               AND UserPrograms.EnrollmentStartDate IS NOT NULL
                               AND UserPrograms.EnrollmentEndDate IS NULL
                               AND UserPrograms.IsPatientDeclinedEnrollment = 0
                               AND Program.StatusCode = 'A'
                               AND UserPrograms.StatusCode = 'A'
                           ORDER BY
                               UserPrograms.EnrollmentStartDate DESC
                           FOR
                               XML PATH('')
                         ) , 1 , 2 , '') AS ProgramName ,
                   STUFF((
                           SELECT TOP 2
                               ', ' + Name
                           FROM
                               Disease
                           INNER JOIN UserDisease
                               ON UserDisease.DiseaseId = Disease.DiseaseId
                           WHERE
                               UserDisease.Userid = p.Userid
                               AND UserDisease.DiagnosedDate IS NOT NULL
                               AND UserDisease.StatusCode = 'A'
                               AND Disease.StatusCode = 'A'
                           ORDER BY
                               UserDisease.DiagnosedDate DESC
                           FOR
                               XML PATH('')
                         ) , 1 , 2 , '') AS DiseaseName ,
                   (
                     SELECT
                         COUNT(ISNULL(CONVERT(VARCHAR , UserPrograms.EnrollmentStartDate , 101) , '') + ' - ' + ISNULL(Program.ProgramName , ''))
                     FROM
                         Program with (nolock)
                     INNER JOIN UserPrograms with (nolock)
                         ON UserPrograms.ProgramId = Program.ProgramId
                     WHERE
                         UserPrograms.Userid = p.Userid
                         AND UserPrograms.EnrollmentStartDate IS NOT NULL
                         AND UserPrograms.EnrollmentEndDate IS NULL
                         AND UserPrograms.IsPatientDeclinedEnrollment = 0
                         AND Program.StatusCode = 'A'
                         AND UserPrograms.StatusCode = 'A'
                   ) AS ProgramCount ,
                   (
                     SELECT
                         COUNT(Disease.DiseaseId)
                     FROM
                         Disease with (nolock)
                     INNER JOIN UserDisease with (nolock)
                         ON UserDisease.DiseaseId = Disease.DiseaseId
                     WHERE
                         UserDisease.Userid = p.Userid
                         AND UserDisease.DiagnosedDate IS NOT NULL
                         AND UserDisease.StatusCode = 'A'
                         AND Disease.StatusCode = 'A'
                   ) AS DiseaseCount ,
                   MeasureID ,
                   MeasureName
               INTO
                   #OutComeDrillDown
               FROM
                   #tblTypePatients tblMeasure
               INNER JOIN Patients p
                   ON tblMeasure.UserId = p.UserID



               DECLARE @v_Columns VARCHAR(4000)

               DECLARE @v_Query VARCHAR(4000)
               SELECT
                   @v_Columns = COALESCE(@v_Columns + ',[' + CAST(MeasureName AS VARCHAR) + ']' , '[' + CAST(MeasureName AS VARCHAR) + ']')
               FROM
                   #OutComeDrillDown
               WHERE
                   MeasureName <> ''
               GROUP BY
                   MeasureName

               SET @v_Query = 'SELECT * FROM 
						(SELECT DISTINCT OCDD.UserId,SUBSTRING(CONVERT(VARCHAR,OCDD.DateTaken,106),3,LEN(DateTaken)) DateTaken,OCDD.MeasureName,
						  OCDD.MemberNum AS MemberNum,
						  OCDD.PatientName AS PatientName,
						  ISNULL(OCDD.PhoneNumberPrimary,'''') AS PhoneNumberPrimary, 
						  ISNULL(OCDD.CallTimePreference,'''') AS CallTimePreference,
						  CONVERT(VARCHAR,(OCDD.Age)) + ''/''+ISNULL(OCDD.Gender,'''') AS ''AgeAndGender'',  
						  OCDD.NextOfficeVisit AS NextOfficeVisit,  
						  OCDD.LastOfficeVisit AS LastOfficeVisit,
						  ProgramName + '' '' + ''[''+ CAST(ProgramCount AS VARCHAR) + '']'' AS Programs,
						  DiseaseName + '' '' + ''[''+ CAST(DiseaseCount AS VARCHAR) + '']'' AS Disease,
						  (SELECT dbo.ufn_GetPatientMeasureLatestValueAndDateTaken_Drill(OCDD.Userid , OCDD.MeasureId,OCDD.DateTaken )) AS Measure 
						  FROM #OutComeDrillDown OCDD
						  )TableData
						  PIVOT (
						  MAX(Measure)
						  FOR [Measurename] IN (' + @v_Columns + ')) PivotTable ORDER BY PatientName'
               EXEC ( @v_Query )
               SELECT
                   REPLACE(REPLACE(KeyValue , ']' , '') , '[' , '') AS MeasureName
               FROM
                   dbo.udf_SplitStringToTable(@v_Columns , ',')

         END
      ELSE
         BEGIN

               CREATE TABLE #tblProcedures
               (
                 UserId INT ,
                 ProcedureID INT ,
                 FreqCount INT ,
                 DueDate DATETIME
               )

               DECLARE @i_UserID INT

               DECLARE curProc CURSOR
                       FOR SELECT DISTINCT
                               UserID
                           FROM
                               #tblTypePatients
               OPEN curProc
               FETCH NEXT FROM curProc INTO @i_UserID
               WHILE @@FETCH_STATUS = 0
                     BEGIN
                           INSERT INTO
                               #tblProcedures
                               SELECT TOP 1
                                   UserId ,
                                   ProcedureId ,
                                   COUNT(*) Frequent ,
                                   MAX(DateTaken) DateTaken
                               FROM
                                   #tblTypePatients
                               WHERE
                                   UserID = @i_UserID
                               GROUP BY
                                   procedureid ,
                                   Userid
                           FETCH NEXT FROM curProc INTO @i_UserID
                     END
               CLOSE curProc
               DEALLOCATE curProc

               SELECT DISTINCT
                   p.UserId ,
                   tblMeasure.ProcedureName ,
                   p.MemberNum ,
                   p.FullName AS PatientName ,
                   p.PhoneNumberPrimary ,
                   (
                     SELECT
                         CallTimeName
                     FROM
                         CallTimePreference
                     WHERE
                         CallTimePreferenceId = p.CallTimePreferenceId
                   ) AS CallTimePreference ,
                   ISNULL(CONVERT(VARCHAR , Age) , '') + '/' + ISNULL(Gender , '') AS AgeAndGender ,
                   STUFF((
                           SELECT TOP 2
                               ', ' + ProgramName
                           FROM
                               Program
                           INNER JOIN UserPrograms
                               ON UserPrograms.ProgramId = Program.ProgramId
                           WHERE
                               UserPrograms.Userid = p.Userid
                               AND UserPrograms.EnrollmentStartDate IS NOT NULL
                               AND UserPrograms.EnrollmentEndDate IS NULL
                               AND UserPrograms.IsPatientDeclinedEnrollment = 0
                               AND Program.StatusCode = 'A'
                               AND UserPrograms.StatusCode = 'A'
                           ORDER BY
                               UserPrograms.EnrollmentStartDate DESC
                           FOR
                               XML PATH('')
                         ) , 1 , 2 , '') AS ProgramName ,
                   ISNULL(STUFF((
                                  SELECT
                                      ' $$' + CONVERT(VARCHAR , upc.ProcedureCompletedDate , 101) + ' : C' ---Procedurecompleted
                                  FROM
                                      UserProcedureCodes upc
                                  WHERE
                                      upc.Userid = p.Userid
                                      AND upc.ProcedureId = tblMeasure.Procedureid
                                      AND upc.ProcedureCompletedDate IS NOT NULL
                                      AND upc.StatusCode = 'A'
                                  ORDER BY
                                      upc.UserProcedureId DESC
                                  FOR
                                      XML PATH('')
                                ) , 2 , 2 , '') , '') + '$$' + LTRIM(ISNULL(STUFF((
                                                                                    SELECT
                                                                                        ' $$' + CONVERT(VARCHAR , upc.DueDate , 101) + ' : D' ----Duedates
                                                                                    FROM
                                                                                        UserProcedureCodes upc
                                                                                    WHERE
                                                                                        upc.Userid = p.Userid
                                                                                        AND upc.ProcedureId = tblMeasure.Procedureid
                                                                                        AND upc.ProcedureCompletedDate IS NULL
                                                                                        AND upc.DueDate IS NOT NULL
                                                                                        AND upc.StatusCode = 'A'
                                                                                    ORDER BY
                                                                                        upc.UserProcedureId DESC
                                                                                    FOR
                                                                                        XML PATH('')
                                                                                  ) , 2 , 2 , '') + '$$' , '')) AS Summary
               FROM
                   #tblTypePatients tblMeasure
               INNER JOIN Patients p
                   ON tblMeasure.UserId = p.UserID
               INNER JOIN #tblProcedures tblproc
                   ON tblProc.UserID = p.UserID
                      AND tblProc.DueDate = tblMeasure.Datetaken
                      AND tblProc.ProcedureID = tblMeasure.ProcedureID
               WHERE
                   tblMeasure.TypeName = @v_TypeNamewithCondition
               ORDER BY
                   PatientName

               SELECT
                   1
               WHERE
                   1 = 2

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
    ON OBJECT::[dbo].[usp_Reports_ProviderConditionalReport_DrillDown] TO [FE_rohit.r-ext]
    AS [dbo];

