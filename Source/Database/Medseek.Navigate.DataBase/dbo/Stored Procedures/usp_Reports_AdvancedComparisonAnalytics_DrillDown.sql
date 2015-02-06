/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_Reports_AdvancedComparisonAnalytics_DrillDown]            
Description   : This functionality shall enable the user to compare the performance and outcomes 
                of different Provider entities to find out the performance of each of them or as a 
                group as compared to their peers, the cohorts, the clinic or Organization as a benchmark  
Created By    : Rathnam            
Created Date  : 25-Aug-2011            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION   
26-Aug-2011 NagaBabu replaced age,gender fields by 'AgeAndGender' in procedure drilldown
19-Oct-2011 Rathnam changed the nextoffice visit column order by clause as ISNULL(ScheduledDate , DateDue)
20-Dec-2011 NagaBabu Added @i_DiseaseId as input parameter For filter the patients as per disease
26-Dec-2011 Rathnam added order by clause on PatientName
02-Apr-2012 NagaBabu Added @d_FromDate,@d_ToDate as Input Parameters						
------------------------------------------------------------------------------            
*/  --[usp_Reports_AdvancedComparisonAnalytics_DrillDown] 1,'Cohort-33,Organization-0','80','2008-07-19','2011-10-19',1,0,'Good',50
CREATE PROCEDURE [dbo].[usp_Reports_AdvancedComparisonAnalytics_DrillDown]
(  
  @i_AppUserId KeyID ,  
  @v_ComparisonList VARCHAR(MAX),  
  @v_MeasureIdList VARCHAR(50) ,
  @d_FromDate DATETIME ,
  @d_ToDate DATETIME ,
  @b_IsMeasureDrillDown ISINDICATOR = 0,
  @b_IsProcessDrillDown ISINDICATOR = 0,
  @v_Goal VARCHAR(20) ,
  @i_DiseaseId KeyId
)  
AS  
BEGIN TRY       
   SET NOCOUNT ON   
-- Check if valid Application User ID is passed      
  IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
    BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
    END
		CREATE TABLE #tblType
			(  
				UserId INT,
				DateTaken DATETIME,
				Ranges  VARCHAR(20),
				MeasureID INT,
				MeasureName VARCHAR(500),
				TypeID INT,
				TypeName VARCHAR(500) ,
				WhichType VARCHAR(30),
				SetType VARCHAR(30),
				ProcedureID INT,
				ProcedureName VARCHAR(500),
				ProcedureCompletedDate DATETIME
				
			)
		-- Getting @v_ComparisonList1 selected type of data from the following sp	
		INSERT INTO #tblType
        EXEC [dbo].[usp_Reports_AdvancedComparisonAnalytics]
		@i_AppUserId = @i_AppUserId,
		@v_ComparisonList = @v_ComparisonList,
		@v_MeasureIdList = @v_MeasureIdList,
		@d_FromDate  = @d_FromDate,
		@d_ToDate  = @d_ToDate,
		@b_IsMeasureDrillDown  = @b_IsMeasureDrillDown,
		@b_IsProcessDrillDown  = @b_IsProcessDrillDown,
		@v_Goal = @v_Goal,
		@i_DiseaseId = @i_DiseaseId
		
		SELECT
			UserId ,
			DateTaken ,
			Ranges  ,
			MeasureID ,
			MeasureName ,
			TypeID ,
			TypeName ,
			WhichType ,
			SetType ,
			ProcedureID ,
			ProcedureName ,
			ProcedureCompletedDate 
		INTO #tblTypePatients	
		FROM #tblType
		
		IF @b_IsMeasureDrillDown = 1
			BEGIN
				SELECT DISTINCT
					p.UserId ,
					tblMeasure.DateTaken,
					p.MemberNum ,
					tblMeasure.TypeName,
					COALESCE(ISNULL(p.LastName , '') + ', '   
					+ ISNULL(p.FirstName , '') + '. '   
					+ ISNULL(p.MiddleName , '') + ' '
					+ ISNULL(p.UserNameSuffix ,'')  
					,'') AS PatientName,
					p.PhoneNumberPrimary ,
					(
					  SELECT
						  CallTimeName
					  FROM
						  CallTimePreference
					  WHERE
						  CallTimePreferenceId = p.CallTimePreferenceId
					) AS CallTimePreference ,
					DATEDIFF(YEAR,P.DateOfBirth,GETDATE()) AS Age ,
					p.Gender ,
					(
					  SELECT  TOP 1
						  CONVERT(VARCHAR,ISNULL(ScheduledDate,DateDue),101) 
					  FROM
						  UserEncounters
					  WHERE
						  Userid = p.Userid
					  AND StatusCode = 'A'
					  AND EncounterDate IS NULL
					  ORDER BY ISNULL(ScheduledDate,DateDue) DESC
					) AS NextOfficeVisit ,
					(
					  SELECT  TOP 1
						  ISNULL(CONVERT(VARCHAR, EncounterDate,101),'') 
					  FROM
						  UserEncounters
					  WHERE
						  Userid = p.Userid
					  AND StatusCode = 'A'
					  AND EncounterDate IS NOT NULL
					  ORDER BY EncounterDate DESC
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
						  SELECT  TOP 2
							  ', ' + Name
						  FROM
							  Disease with (nolock)
						  INNER JOIN UserDisease with (nolock)
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
					( SELECT 
						  COUNT(ISNULL(CONVERT(VARCHAR,UserPrograms.EnrollmentStartDate,101),'') + ' - ' + ISNULL(Program.ProgramName,''))
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
					( SELECT
						  COUNT( Disease.DiseaseId)
  					  FROM
						  Disease with (nolock)
					  INNER JOIN UserDisease with (nolock)
						  ON UserDisease.DiseaseId = Disease.DiseaseId
					  WHERE
						  UserDisease.Userid = p.Userid
						  AND UserDisease.DiagnosedDate IS NOT NULL
						  AND UserDisease.StatusCode = 'A'
						  AND Disease.StatusCode = 'A' 
					) AS DiseaseCount,
					MeasureID,
					MeasureName
				INTO
					#OutComeDrillDown
				FROM
					#tblTypePatients tblMeasure
				INNER JOIN Users p
				ON  tblMeasure.UserId = p.UserID	
				WHERE MeasureID = @v_MeasureIdList
				
				DECLARE @v_Columns VARCHAR(4000)

				DECLARE @v_Query VARCHAR(4000)
				SELECT 
					  @v_Columns = COALESCE(@v_Columns + ',[' + CAST(MeasureName AS VARCHAR) + ']','[' + CAST(MeasureName AS VARCHAR)+ ']')
				FROM 
				   #OutComeDrillDown 
				WHERE MeasureName <> ''    
				GROUP BY MeasureName
				   
				SET @v_Query ='SELECT * FROM 
						(SELECT DISTINCT OCDD.UserId,SUBSTRING(CONVERT(VARCHAR,OCDD.DateTaken,106),3,LEN(DateTaken)) DateTaken,
						OCDD.MeasureName,
						  OCDD.MemberNum AS MemberNum,
						  OCDD.PatientName AS PatientName,
						  OCDD.TypeName,
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
						  FOR [Measurename] IN ('+@v_Columns+')) PivotTable ORDER BY PatientName' 
					  
					EXEC (@v_Query)
					SELECT 
					    REPLACE (REPLACE (KeyValue,']','') ,'[','') AS MeasureName
					FROM 
						dbo.udf_SplitStringToTable(@v_Columns,',')
				
			END		
		ELSE
			BEGIN
			/*
			CREATE TABLE #tblProcedures 
				(
					UserId INT,
					ProcedureID INT,
					FreqCount INT,
					DueDate DATETIME
				)				
				
				DECLARE @i_UserID INT
				
				DECLARE curProc CURSOR FOR
				SELECT DISTINCT UserID
				FROM #tblTypePatients
				OPEN curProc
				FETCH NEXT FROM curProc INTO @i_UserID
					WHILE @@FETCH_STATUS = 0
						BEGIN
						INSERT INTO #tblProcedures
						   SELECT TOP 1 
									UserId ,
									ProcedureId , 
									COUNT(*) Frequent,
									MAX(DateTaken) DateTaken
							FROM #tblTypePatients
							WHERE UserID = @i_UserID
							GROUP BY procedureid, Userid ORDER BY 3 DESC , 4 DESC
						FETCH NEXT FROM curProc INTO @i_UserID
						END
				CLOSE curProc
				DEALLOCATE curProc
			*/
				SELECT DISTINCT
					p.UserId ,
					(SELECT TOP 1 ttp.ProcedureName
					 FROM #tblTypePatients ttp
					 WHERE ttp.UserId = tblMeasure.UserId) ProcedureName,
					p.MemberNum ,
					tblMeasure.TypeName,
					COALESCE(ISNULL(p.LastName , '') + ', '   
					+ ISNULL(p.FirstName , '') + '. '   
					+ ISNULL(p.MiddleName , '') + ' '
					+ ISNULL(p.UserNameSuffix ,'')  
					,'') AS PatientName,
					p.PhoneNumberPrimary ,
					(
					  SELECT
						  CallTimeName
					  FROM
						  CallTimePreference
					  WHERE
						  CallTimePreferenceId = p.CallTimePreferenceId
					) AS CallTimePreference ,
					ISNULL(CONVERT(VARCHAR,DATEDIFF(YEAR,p.DateOfBirth,GETDATE())),'') + '/' + ISNULL(Gender,'') AS AgeAndGender,
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
						  ) , 1 , 2 , '') AS ProgramName,
					ISNULL(
					STUFF(( SELECT 
                          ' $$' + CONVERT(VARCHAR,upc.ProcedureCompletedDate,101) + ' : C' ---Procedurecompleted
                      FROM
                          UserProcedureCodes upc
                      INNER JOIN CodesetProcedure
					  ON CodesetProcedure.ProcedureId = upc.ProcedureId
					  INNER JOIN (SELECT TOP 1 ttp.ProcedureName
								 FROM #tblTypePatients ttp
								 WHERE ttp.UserId = tblMeasure.UserId)A
					  ON A.ProcedureName = CodesetProcedure.ProcedureName    
                      WHERE
                          upc.Userid = p.Userid
                          --AND upc.ProcedureId = tblMeasure.Procedureid
                          AND upc.ProcedureCompletedDate IS NOT NULL
                          --AND upc.StatusCode = 'A'
                          AND upc.ProcedureCompletedDate BETWEEN @d_FromDate AND @d_ToDate 
					  ORDER BY
                          upc.UserProcedureId DESC
                      FOR
                          XML PATH('') ) , 2 , 2 , ''),'') + '$$' +
					LTRIM(
					ISNULL(       
					STUFF(( SELECT 
						  ' $$' + CONVERT(VARCHAR,upc.DueDate,101) + ' : D' ----Duedates
					  FROM
						  UserProcedureCodes upc
					  INNER JOIN CodesetProcedure
					  ON CodesetProcedure.ProcedureId = upc.ProcedureId
					  INNER JOIN (SELECT TOP 1 ttp.ProcedureName
								 FROM #tblTypePatients ttp
								 WHERE ttp.UserId = tblMeasure.UserId)A
					  ON A.ProcedureName = CodesetProcedure.ProcedureName			 	  
					  WHERE
						  upc.Userid = p.Userid
						  --AND upc.ProcedureId = tblMeasure.Procedureid
						  AND upc.ProcedureCompletedDate IS NULL
						  AND upc.DueDate IS NOT NULL
						  --AND upc.StatusCode = 'A'
						  AND (upc.DueDate BETWEEN @d_FromDate AND @d_ToDate)
					  ORDER BY
						  upc.UserProcedureId DESC
					  FOR
						  XML PATH('') ) , 2 , 2 , '')+'$$' ,'') ) AS Summary  
				FROM
					#tblTypePatients tblMeasure
				INNER JOIN Users p
				ON  tblMeasure.UserId = p.UserID
				ORDER BY PatientName
				
				SELECT 1 --DEV REQUEST
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
    ON OBJECT::[dbo].[usp_Reports_AdvancedComparisonAnalytics_DrillDown] TO [FE_rohit.r-ext]
    AS [dbo];

