  
/*        
--------------------------------------------------------------------------------------------------------------        
Procedure Name: usp_CareProviderDashBoard_MyPatients_PatientView 23    
Description   : This procedure is to be used for applying filter on care provider dashboard on MyPatients tab by Patientview    
Created By    : Rathnam    
Created Date  : 18-Dec-2010      
---------------------------------------------------------------------------------------------------------------        
Log History   :         
DD-Mon-YYYY  BY  DESCRIPTION      
---------------------------------------------------------------------------------------------------------------        
*/--exec [usp_CareProviderDashBoard_MyPatients_PatientView] @i_AppUserId = 23, @i_StartIndex = 1,@i_EndIndex = 10, @v_SortBy = 'FullName', @v_SortType = 'asc'    
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyPatients_PatientView] -- 2  
 (  
 @i_AppUserId KEYID  
 ,@i_CareTeamId KEYID = NULL  
 ,@v_PatientLastName LASTNAME = NULL  
 ,@v_AgeOperator1 SOURCENAME = NULL  
 ,@i_AgeValue1 SMALLINT = NULL  
 ,@v_AgeOperator2 SOURCENAME = NULL  
 ,@i_AgeValue2 SMALLINT = NULL  
 ,@v_City CITY = NULL  
 ,@i_InsuranceGroupId KEYID = NULL  
 ,@b_IsMedicare ISINDICATOR = NULL  
 ,@b_IsMedicaid ISINDICATOR = NULL  
 ,@t_tProgramID TTYPEKEYID READONLY  
 ,@t_tDiseaseID TTYPEKEYID READONLY  
 ,@t_tMedicalProblemID TTYPEKEYID READONLY  
 ,@i_MeasureID KEYID = NULL  
 ,@v_MeasureOperator1 SOURCENAME = NULL  
 ,@d_MeasureValue1 DECIMAL(10, 2) = NULL  
 ,@v_MeasureOperator2 SOURCENAME = NULL  
 ,@d_MeasureValue2 DECIMAL(10, 2) = NULL  
 ,@i_HealthStatusScoreId KEYID = 35  
 ,@b_IsFiltered ISINDICATOR = 0  
 ,@b_IsExport ISINDICATOR = 0  
 ,@v_SortBy VARCHAR(50) = NULL  
 ,@v_SortType VARCHAR(5) = NULL  
 ,@tblFilter Filter READONLY  
 )  
AS  
BEGIN TRY  
 SET NOCOUNT ON  
  
 -- Check if valid Application User ID is passed        
 IF (@i_AppUserId IS NULL)  
  OR (@i_AppUserId <= 0)  
 BEGIN  
  RAISERROR (  
    N'Invalid Application User ID %d passed.'  
    ,17  
    ,1  
    ,@i_AppUserId  
    )  
 END  
 
  
 DECLARE @v_SQLForAll VARCHAR(MAX)  
  ,@v_SQL VARCHAR(MAX)  
  ,@v_SQLJoins VARCHAR(MAX) = ''  
  ,@v_SQLWhereClause VARCHAR(MAX) = ''  
  ,@v_SQLCareTeam VARCHAR(MAX)  
  ,@v_SQLFiltered VARCHAR(MAX)  
  ,@v_SQLFilteredOnDB VARCHAR(MAX)  
  ,@v_SQLProgramList VARCHAR(MAX)  
  ,@v_SQLProgramList1 VARCHAR(MAX)  
  ,@v_SQLWhereClauseCareTeamParameter VARCHAR(MAX)  
  ,@v_SQLJoinClauseCareTeamParameter VARCHAR(MAX)  
  ,@v_CareTeam VARCHAR(MAX)  
  
 CREATE TABLE #tblPatients (  
  ID INT IDENTITY PRIMARY KEY  
  ,UserID INT  
  )  
  
  CREATE NONCLUSTERED INDEX [IX_#tblPatients_UserId] ON [dbo].[#tblPatients] 
(
	UserID ASC
)
  
 --MemberNum VARCHAR(50),    
 --FullName VARCHAR(152),    
 --PhoneNumberPrimary VARCHAR(50),    
 --CallTimePreference VARCHAR(50) ,    
 --Age INT,    
 --Gender CHAR(1)    
 CREATE TABLE #Mytemp (  
  ProgramID INT  
  ,DiseaseID INT  
  ,MedicalProblemID INT  
  )  
  
 INSERT INTO #Mytemp (ProgramID)  
 SELECT tKeyId  
 FROM @t_tProgramID  
  
 INSERT INTO #Mytemp (DiseaseID)  
 SELECT tkeyid  
 FROM @t_tDiseaseID  
  
 INSERT INTO #Mytemp (MedicalProblemID)  
 SELECT tkeyid  
 FROM @t_tMedicalProblemID  
  
 IF @i_CareTeamId IS NOT NULL  
  SET @v_CareTeam = + ' AND (ProgramCareTeam.CareTeamId = ' + CONVERT(VARCHAR, @i_CareTeamId) + ')'  
 SET @v_SQL = 'INSERT INTO    
     #tblPatients    
     (    
       UserId    
           
     )    
     SELECT    
      Patients.PatientID    
         
     FROM    
      Patients WITH(NOLOCK)    
      '  
  
 --LEFT JOIN CallTimePreference WITH(NOLOCK)    
 --ON CallTimePreference.CallTimePreferenceId = Patients.CallTimePreferenceId'    
 --'    
 DECLARE @v_ManagerRole VARCHAR(MAX) = ''  
  
 IF NOT EXISTS (  
   SELECT 1  
   FROM CareTeamMembers ctm  
   WHERE ctm.ProviderID = @i_AppUserId  
    AND IsCareTeamManager = 1  
   )  
 BEGIN  
  SET @v_ManagerRole = ' AND PatientProgram.ProviderID = CareTeamMembers.ProviderID '  
 END  
  
 IF EXISTS (  
   SELECT 1  
   FROM @t_tProgramID  
   )  
 BEGIN  
  SET @v_SQLCareTeam = ' INNER JOIN ( SELECT distinct PatientProgram.PatientID from PatientProgram WITH(NOLOCK)    
        INNER JOIN ProgramCareTeam WITH(NOLOCK)    
         ON ProgramCareTeam.ProgramID = PatientProgram.ProgramID    
        INNER JOIN CareTeamMembers  WITH(NOLOCK)      
         ON CareTeamMembers.CareTeamID = ProgramCareTeam.CareTeamID    
        INNER JOIN #MYTEMP TEMP1    
        ON PatientProgram.ProgramId = TEMP1.ProgramID    
        WHERE TEMP1.ProgramID IS NOT NULL     
        AND CareTeamMembers.ProviderID = ' + CONVERT(VARCHAR, @i_AppUserId) + '    
        AND PatientProgram.StatusCode = ''' + 'A' + '''    
        AND CareTeamMembers.StatusCode = ''' + 'A' + ''' ' + ISNULL(@v_CareTeam, '') + ISNULL(@v_ManagerRole, '') + '    
            
                   ) DerivedPatients    
        ON DerivedPatients.PatientID = Patients.PatientID     
        AND Patients.UserStatusCode = ''' + 'A' + ''''  
 END  
 ELSE  
 BEGIN  
  SET @v_SQLCareTeam = ' INNER JOIN ( SELECT distinct PatientProgram.PatientID from PatientProgram WITH(NOLOCK)    
        INNER JOIN ProgramCareTeam WITH(NOLOCK)    
         ON ProgramCareTeam.ProgramID = PatientProgram.ProgramID    
        INNER JOIN CareTeamMembers  WITH(NOLOCK)      
         ON CareTeamMembers.CareTeamID = ProgramCareTeam.CareTeamID    
        AND CareTeamMembers.ProviderID = ' + CONVERT(VARCHAR, @i_AppUserId) + '    
        AND PatientProgram.StatusCode = ''' + 'A' + '''    
        AND CareTeamMembers.StatusCode = ''' + 'A' + ''' ' + ISNULL(@v_CareTeam, '') + ISNULL(@v_ManagerRole, '') + '    
                   ) DerivedPatients    
        ON DerivedPatients.PatientID = Patients.PatientID     
        AND Patients.UserStatusCode = ''' + 'A' + ''''  
 END  
  
 /*              
       IF EXISTS ( SELECT 1 FROM @t_tProgramID )    
         SET    
             @v_SQLProgramList1 =    '   INNER JOIN UserPrograms WITH(NOLOCK)    
             ON Patients.UserID = UserPrograms.UserID    
            INNER JOIN  #MYTEMP TEMP1    
             ON UserPrograms.ProgramId = TEMP1.ProgramID    
            AND TEMP1.ProgramID IS NOT NULL    
                
           '     
 */  
 IF EXISTS (  
   SELECT 1  
   FROM @t_tDiseaseID  
   )  
  SET @v_SQLJoins = @v_SQLJoins + '  INNER JOIN PopulationDefinitionPatients WITH(NOLOCK)    
            ON PopulationDefinitionPatients.PatientID = Patients.PatientID    
           INNER JOIN  #MYTEMP TEMP2     
            ON PopulationDefinitionPatients.PopulationDefinitionID = TEMP2.DiseaseID    
           AND TEMP2.DiseaseID IS NOT NULL    
           AND PopulationDefinitionPatients.StatusCode = ''' + 'A' + '''      
             '  
  
 IF @i_InsuranceGroupId IS NOT NULL  
  SET @v_SQLJoins = @v_SQLJoins + '   INNER JOIN PatientInsurance WITH(NOLOCK)    
             ON PatientInsurance.PatientID=Patients.PatientID    
               INNER JOIN InsuranceGroupPlan WITH(NOLOCK)        
                   ON InsuranceGroupPlan.InsuranceGroupPlanID = PatientInsurance.InsuranceGroupPlanID    
            INNER JOIN InsuranceGroup WITH(NOLOCK)    
                ON InsuranceGroup.InsuranceGroupID = InsuranceGroupPlan.InsuranceGroupPlanID     
            AND InsuranceGroup.InsuranceGroupId = ' + CONVERT(VARCHAR, @i_InsuranceGroupId) + '    
            AND PatientInsurance.StatusCode = ''' + 'A' + '''    
             '  
  
 IF EXISTS (  
   SELECT 1  
   FROM @t_tMedicalProblemID  
   )  
  SET @v_SQLJoins = @v_SQLJoins + '  INNER JOIN PatientProblem WITH(NOLOCK)    
            ON PatientProblem.PatientID=Patients.PatientID    
           INNER JOIN #MYTEMP TEMP3     
            ON PatientProblem.MedicalProblemId = TEMP3.MedicalProblemId    
           AND TEMP3.MedicalProblemId IS NOT NULL    
           AND PatientProblem.StatusCode = ''' + 'A' + '''    
          '  
  
 IF @i_MeasureID IS NOT NULL  
  SET @v_SQLJoins = @v_SQLJoins + '   INNER JOIN PatientMeasure WITH(NOLOCK)    
             ON PatientMeasure.PatientID=Patients.PatientID    
            INNER JOIN Measure WITH(NOLOCK)    
             ON PatientMeasure.MeasureId = Measure.MeasureId    
            AND PatientMeasure.StatusCode =  ''' + 'A' + '''    
            AND Measure.StatusCode = ''' + 'A' + '''    
            AND PatientMeasure.MeasureId =' + CONVERT(VARCHAR, @i_MeasureID) + '    
                
      
             '  
 /*                 
     IF @i_CareTeamId IS NOT NULL    
         SET    
             @v_SQLJoinClauseCareTeamParameter =  + ' INNER JOIN UserCareTeam WITH(NOLOCK)    
                                                        ON UserCareTeam.PatientUserID = Patients.UserID    
              AND (UserCareTeam.CareTeamId = ' + CONVERT(VARCHAR , @i_CareTeamId) + ')  '     
  */  
 SET @v_SQLWhereClause = '  WHERE 1 = 1 '  
  
 ----- where     
 IF @v_PatientLastName IS NOT NULL  
  SET @v_SQLWhereClause = @v_SQLWhereClause + ' AND ( Patients.LastName LIKE ''' + @v_PatientLastName + '%''' + ' )'  
  
 IF @v_City IS NOT NULL  
  SET @v_SQLWhereClause = @v_SQLWhereClause + ' AND (Patients.StateCode = ''' + @v_City + ''')'  
  
 --IF @b_IsMedicare IS NOT NULL    
 --   SET    
 --       @v_SQLWhereClause = @v_SQLWhereClause + ' AND (IsMedicare = ' + CONVERT(VARCHAR , @b_IsMedicare) + ')'    
 --IF @b_IsMedicaid IS NOT NULL    
 --   SET    
 --       @v_SQLWhereClause = @v_SQLWhereClause + ' AND (IsMedicaid = ' + CONVERT(VARCHAR , @b_IsMedicare) + ')'    
 IF (  
   @i_AgeValue1 IS NOT NULL  
   OR @i_AgeValue2 IS NOT NULL  
   )  
 BEGIN  
  IF @v_AgeOperator1 IS NOT NULL  
   AND @v_AgeOperator2 IS NOT NULL  
   SET @v_SQLWhereClause = @v_SQLWhereClause + 'AND ( Patients.Age ' + @v_AgeOperator1 + '' + CAST(@i_AgeValue1 AS VARCHAR) + 'AND Patients.Age ' + '' + @v_AgeOperator2 + '' + CAST(@i_AgeValue2 AS VARCHAR) + ' )'  
  ELSE  
   IF @v_AgeOperator1 IS NOT NULL  
    AND @v_AgeOperator2 IS NULL  
    SET @v_SQLWhereClause = @v_SQLWhereClause + 'AND ( Patients.Age ' + @v_AgeOperator1 + CAST(@i_AgeValue1 AS VARCHAR) + ' ) '  
   ELSE  
    SET @v_SQLWhereClause = @v_SQLWhereClause + 'AND ( Patients.Age ' + @v_AgeOperator2 + CAST(@i_AgeValue2 AS VARCHAR) + ' ) '  
 END  
  
 IF (  
   @i_MeasureID IS NOT NULL  
   AND (  
    @d_MeasureValue1 IS NOT NULL  
    OR @d_MeasureValue2 IS NOT NULL  
    )  
   )  
 BEGIN  
  IF @v_MeasureOperator1 IS NOT NULL  
   AND @v_MeasureOperator2 IS NOT NULL  
   SET @v_SQLWhereClause = @v_SQLWhereClause + 'AND (' + 'PatientMeasure.MeasureValueNumeric ' + @v_MeasureOperator1 + '' + CAST(@d_MeasureValue1 AS VARCHAR) + 'AND PatientMeasure.MeasureValueNumeric ' + '' + @v_MeasureOperator2 + '' + CAST(@d_MeasureValue2 AS VARCHAR) + ' )'  
  ELSE  
   IF @v_MeasureOperator1 IS NOT NULL  
    AND @v_MeasureOperator2 IS NULL  
    SET @v_SQLWhereClause = @v_SQLWhereClause + 'AND (' + 'PatientMeasure.MeasureValueNumeric ' + @v_MeasureOperator1 + ' ' + CAST(@d_MeasureValue1 AS VARCHAR) + ' ) '  
   ELSE  
    SET @v_SQLWhereClause = @v_SQLWhereClause + 'AND (' + ' PatientMeasure.MeasureValueNumeric ' + @v_MeasureOperator2 + CAST(@d_MeasureValue2 AS VARCHAR) + ' ) '  
 END  
  
 IF EXISTS (  
   SELECT 1  
   FROM @tblFilter  
   )  
 BEGIN  
  DECLARE @v_MemberNum VARCHAR(15)  
   ,@v_FullName VARCHAR(50)  
   ,@v_PhoneNumberPrimary VARCHAR(10)  
   ,@v_CallTimePreference VARCHAR(50)  
   ,@v_Age VARCHAR(3)  
   ,@v_WhereClauseForGrid VARCHAR(MAX) = ''  
  
  SELECT @v_MemberNum = FilterValue  
  FROM @tblFilter  
  WHERE ColumnName = 'MemberNum'  
   AND sno = 1  
  
  SELECT @v_FullName = FilterValue  
  FROM @tblFilter  
  WHERE ColumnName = 'FullName'  
  
  SELECT @v_PhoneNumberPrimary = FilterValue  
  FROM @tblFilter  
  WHERE ColumnName = 'PhoneNumberPrimary'  
   AND sno = 1  
  
  SELECT @v_CallTimePreference = FilterValue  
  FROM @tblFilter  
  WHERE ColumnName = 'CallTimePreference'  
   AND sno = 1  
  
  SELECT @v_Age = FilterValue  
  FROM @tblFilter  
  WHERE ColumnName = 'Age'  
   AND sno = 1  
  
  IF @v_MemberNum <> ''  
   SET @v_WhereClauseForGrid = @v_SQLWhereClause + ' AND (Patients.MemberNum LIKE ''%' + @v_MemberNum + '%'') '  
  
  IF @v_FullName <> ''  
   SET @v_WhereClauseForGrid = @v_SQLWhereClause + ' AND (Patients.FullName LIKE ''%' + @v_FullName + '%'') '  
  
  IF @v_PhoneNumberPrimary <> ''  
   SET @v_WhereClauseForGrid = @v_SQLWhereClause + ' AND (Patients.PrimaryPhoneNumber LIKE ''%' + @v_PhoneNumberPrimary + '%'') '  
  
  IF @v_CallTimePreference <> ''  
   SET @v_WhereClauseForGrid = @v_SQLWhereClause + ' AND (Patients.CallTimeName LIKE ''%' + @v_CallTimePreference + '%'') '  
  
  IF @v_Age <> ''  
   SET @v_WhereClauseForGrid = @v_SQLWhereClause + ' AND (Patients.Age = ' + @v_Age + ') '  
 END  
  
 DECLARE @v_OrderByClause VARCHAR(4000)  
 --IF @v_SortBy IS NOT NULL    
 --BEGIN    
 --IF @v_SortBy = 'UserId'    
 --SET @v_OrderByClause = ' ORDER BY Patients.UserId ' + ISNULL(@v_SortType,'')    
 --IF @v_SortBy = 'MemberNum'    
 --SET @v_OrderByClause = ' ORDER BY MemberNum ' + ISNULL(@v_SortType,'')    
 --IF @v_SortBy = 'FullName'    
 --SET @v_OrderByClause = ' ORDER BY FullName ' + ISNULL(@v_SortType,'')    
 --IF @v_SortBy = 'Phone'    
 --SET @v_OrderByClause = ' ORDER BY ' + @v_SortBy + ' ' + ISNULL(@v_SortType,'')    
 --IF @v_SortBy = 'Preference'    
 --SET @v_OrderByClause = ' ORDER BY ' + @v_SortBy + ' ' + ISNULL(@v_SortType,'')    
 --IF @v_SortBy = 'Age'    
 --SET @v_OrderByClause = ' ORDER BY ' + @v_SortBy + ' ' + ISNULL(@v_SortType,'')    
 --END    
 --ELSE SET @v_OrderByClause = ' ORDER BY Patients.UserId ' + ISNULL(@v_SortType,'')    
 DECLARE @v_CntSQL VARCHAR(max) = ' INSERT INTO #tblCnt SELECT COUNT(Patients.PatientID) FROM    
      Patients WITH(NOLOCK)  '  
  --LEFT JOIN CallTimePreference WITH(NOLOCK)    
  --ON CallTimePreference.CallTimePreferenceId = Patients.CallTimePreferenceId   
  ,@i_Cnt INT  
  
 IF (@b_IsFiltered = 0)  
 BEGIN  
  SET @v_SQL = ISNULL(@v_SQL, '') + ISNULL(@v_SQLCareTeam, '') + ISNULL(@v_WhereClauseForGrid, '') + ISNULL(@v_OrderByClause, '')  
  SET @v_CntSQL = ISNULL(@v_CntSQL, '') + ISNULL(@v_SQLCareTeam, '') + ISNULL(@v_WhereClauseForGrid, '')  
 END  
  
 IF (@b_IsFiltered = 1)  
 BEGIN  
  SET @v_SQL = ISNULL(@v_SQL, '') + ISNULL(@v_SQLCareTeam, '') + ISNULL(@v_SQLProgramList, '') + ISNULL(@v_SQLJoins, '') + ISNULL(@v_SQLWhereClause, '') + ISNULL(@v_WhereClauseForGrid, '') + ISNULL(@v_SQLWhereClauseCareTeamParameter, '') + ISNULL(@v_OrderByClause, '')  
  SET @v_CntSQL = ISNULL(@v_CntSQL, '') + ISNULL(@v_SQLCareTeam, '') + ISNULL(@v_SQLProgramList, '') + ISNULL(@v_SQLJoins, '') + ISNULL(@v_SQLWhereClause, '') + ISNULL(@v_WhereClauseForGrid, '') + ISNULL(@v_SQLWhereClauseCareTeamParameter, '')  
 END  
  
 PRINT @v_SQL  
  
 CREATE TABLE #tblCnt (Cnt INT)  
  
 EXEC (@v_SQL)  
  
 PRINT @v_CntSQL  
  
 EXEC (@v_CntSQL)  
 
  
 SELECT PatientProgram.PatientID Userid  
  ,Program.ProgramId  
  ,program.ProgramName  
  ,PatientProgram.EnrollmentStartDate  
 INTO #ProgramName  
 FROM Program WITH (NOLOCK)  
 INNER JOIN PatientProgram WITH (NOLOCK)  
  ON PatientProgram.ProgramId = Program.ProgramId  
 INNER JOIN #tblPatients p  
  ON p.UserID = PatientProgram.PatientID  
 WHERE PatientProgram.EnrollmentStartDate IS NOT NULL  
  AND PatientProgram.EnrollmentEndDate IS NULL  
  AND PatientProgram.IsPatientDeclinedEnrollment = 0  
  AND Program.StatusCode = 'A'  
  AND PatientProgram.StatusCode = 'A'  
  
  
   CREATE NONCLUSTERED INDEX [IX_#ProgramName_UserId] ON [dbo].[#ProgramName] 
(
	UserID ASC
)
  
 --AND p.ID BETWEEN @i_StartIndex AND @i_EndIndex     
 SELECT cl.PopulationDefinitionName NAME  
  ,cl.PopulationDefinitionID  
  ,clu.PatientID  
    
 INTO #Condition  
 FROM PopulationDefinition cl WITH (NOLOCK)  
 INNER JOIN PopulationDefinitionPatients clu WITH (NOLOCK)  
  ON cl.PopulationDefinitionID = clu.PopulationDefinitionID  
 INNER JOIN #tblPatients t  
  ON t.UserID = clu.PatientID  
 WHERE cl.DefinitionType = 'C'  
  AND clu.StatusCode = 'A'  
  AND cl.StatusCode = 'A'  
  
  CREATE NONCLUSTERED INDEX [IX_#Condition_NAME] ON [dbo].[#Condition] 
(
	NAME ASC
)
  
  
  
 SELECT DISTINCT dis.ID  
  ,p.PatientID Userid  
  ,MemberNum  
  ,FullName AS PatientName  
  ,PrimaryPhoneNumber PhoneNumberPrimary  
  ,p.CallTimeName CallTimePreference  
  ,Age  
  ,Gender  
  ,'' AS NextOfficeVisit  
  ,
  (  
   SELECT CONVERT(VARCHAR(10),MAX(DateOfService),101)
   FROM vw_PatientEncounter e WITH (NOLOCK)  
   WHERE e.PatientID = dis.Userid  
   GROUP BY PatientID
   
   )
    AS LastOfficeVisit  
  
  ,STUFF((  
    SELECT  ', ' + ProgramName  
    FROM #ProgramName TPN  
    WHERE TPN.UserId = dis.Userid  
     AND (  
      EXISTS (  
       SELECT 1  
       FROM #MYTEMP tblprgs  
       WHERE tblprgs.ProgramID = TPN.ProgramID  
       )  
      OR NOT EXISTS (  
       SELECT 1  
       FROM @t_tProgramID  
       )  
      )  
     
    FOR XML PATH('')  
    ), 1, 2, '') AS ProgramName  
  ,STUFF((  
    SELECT  ', ' + NAME  
    FROM #Condition t  
    WHERE t.PatientId = dis.Userid  
     AND (  
      EXISTS (  
       SELECT 1  
       FROM #MYTEMP tblDes  
       WHERE tblDes.DiseaseID = t.PopulationDefinitionID  
       )  
      OR NOT EXISTS (  
       SELECT 1  
       FROM @t_tDiseaseID  
       )  
      )  
      
    FOR XML PATH('')  
    ), 1, 2, '') AS DiseaseName  
  ,'' AS RiskScore  
  ,(  
   SELECT COUNT(1)  
   FROM #ProgramName TPN  
   WHERE TPN.UserId = dis.Userid  
    AND (  
     EXISTS (  
      SELECT 1  
      FROM #MYTEMP tblprgs  
      WHERE tblprgs.ProgramID = TPN.ProgramID  
      )  
     OR NOT EXISTS (  
      SELECT 1  
      FROM @t_tProgramID  
      )  
     )  
   ) AS ProgramCount  
  ,(  
   SELECT COUNT(1)  
   FROM #Condition t  
   WHERE t.PatientID = dis.Userid  
    AND (  
     EXISTS (  
      SELECT 1  
      FROM #MYTEMP tblDes  
      WHERE tblDes.DiseaseID = t.PopulationDefinitionID  
      )  
     OR NOT EXISTS (  
      SELECT 1  
      FROM @t_tDiseaseID  
      )  
     )  
   ) AS DiseaseCount  
  ,'' AS DiseaseMarkerStatus  
  ,  
   
  NULL AS YTDUtilization  
 
 , NULL AS ERVisit  
  ,  
    NULL AS RxUtilization  
  ,(  
   SELECT SUM(CASE   
      WHEN t.TaskId IS NULL  
       THEN 0  
      ELSE 1  
      END)  
   FROM Task t  
   INNER JOIN TaskStatus ts  
    ON t.TaskStatusId = ts.TaskStatusId  
   WHERE ts.TaskStatusText = 'Closed Incomplete'  
    AND t.PatientID = dis.UserId  
   ) CareGaps  
 INTO #tmpPatientByData  
 FROM #tblPatients dis  
 INNER JOIN Patients p  
  ON p.PatientId = dis.UserID  
  
  
 
 SELECT  
  --COUNT(UDC.DiagnosisCodeID) ICDCodeCount ,   
  UDC.DiagnosisCodeID  
  ,UDC.PatientID UserId  
  ,UDC.DateOfService  
 INTO #ICDCodeId  
 FROM PatientDiagnosisCode UDC WITH (NOLOCK)  
 INNER JOIN CodeSetICDDiagnosis WITH (NOLOCK)  
  ON CodeSetICDDiagnosis.DiagnosisCodeID = UDC.DiagnosisCodeID  
 INNER JOIN #tmpPatientByData TMPP  
  ON TMPP.UserID = UDC.PatientID  
 WHERE UDC.StatusCode = 'A'  
  AND TMPP.LastOfficeVisit = UDC.DateOfService  

  
 --GROUP BY UDC.PatientID ,    
 -- UDC.DateOfService   
 SELECT  
  --COUNT(PPC.ProcedureCodeID) ProcedureCount ,   
  PPC.ProcedureCodeID  
  ,PPC.PatientID UserId  
  ,PPC.DateOfService  
 INTO #ProcedureId  
 FROM PatientProcedureCode PPC WITH (NOLOCK)  
 INNER JOIN CodeSetProcedure WITH (NOLOCK)  
  ON CodeSetProcedure.ProcedureCodeID = PPC.ProcedureCodeID  
 INNER JOIN #tmpPatientByData TMPP  
  ON TMPP.UserID = PPC.PatientID  
 WHERE PPC.PatientID = TMPP.Userid  
  AND PPC.DateOfService = TMPP.LastOfficeVisit  
  AND PPC.StatusCode = 'A'  
 
 --GROUP BY PPC.PatientID ,    
 -- PPC.DateOfService   
 SELECT TMPP.ID  
  ,TMPP.Userid  
  ,MemberNum  
  ,PatientName  
  --,ISNULL(PhoneNumberPrimary,'') + '$$' + ISNULL(CallTimePreference,'') AS PhonePreference    
  ,ISNULL(PhoneNumberPrimary, '') AS Phone  
  ,ISNULL(CallTimePreference, '') AS Preference  
  --,ISNULL(CONVERT(VARCHAR , Age),'') + '$$' + ISNULL(Gender,'') AS 'AgeAndGender'    
  ,ISNULL(CONVERT(VARCHAR, Age) + '/', '') + ISNULL(Gender, '') AS 'AgeAndGender'  
  ,NextOfficeVisit  
  ,LastOfficeVisit  
  --,('['+ CAST(ProgramCount AS VARCHAR) +']'+' '+ ProgramName) AS ProgramName    
  --,('['+ CAST(DiseaseCount AS VARCHAR) +']'+' '+ DiseaseName) AS DiseaseName    
  --,'['+ CAST(ProgramCount AS VARCHAR) +']' AS ProgramCount    
  --,'['+ CAST(DiseaseCount AS VARCHAR) +']' AS DiseaseCount    
  ,CASE   
   WHEN LEN(ProgramName) > 16  
    THEN SUBSTRING(ProgramName, 1, 16) + '...'  
   ELSE ProgramName  
   END + ' ' + CASE   
   WHEN ProgramCount > 0  
    THEN '[' + CAST(ProgramCount AS VARCHAR) + ']'  
   ELSE ''  
   END ProgramName 
    ,ProgramName AS ProgramName1
  ,CASE   
   WHEN LEN(DiseaseName) > 16  
    THEN SUBSTRING(DiseaseName, 1, 16) + '...'  
   ELSE DiseaseName  
   END + ' ' + CASE   
   WHEN DiseaseCount > 0  
    THEN '[' + CAST(DiseaseCount AS VARCHAR) + ']'  
   ELSE ''  
   END DiseaseName  
   ,DiseaseName AS DiseaseName1
  ,RiskScore  
  ,ISNULL((  
    SELECT TOP 1 1  
    FROM #ICDCodeId ticd  
    WHERE ticd.UserId = TMPP.Userid  
    ), 0) AS ICDCode  
  --,ISNULL(( SELECT TOP 1 1    
  --    FROM PatientProcedureCode WITH(NOLOCK)    
  --    INNER JOIN CodeSetProcedure  WITH(NOLOCK)    
  --    ON CodeSetProcedure.ProcedureCodeID = PatientProcedureCode.ProcedureCodeID    
  --  WHERE PatientID = TMPP.Userid    
  --  AND DateOfService = TMPP.LastOfficeVisit    
  --  --AND CodeSetProcedure.StatusCode = 'A'    
  --  AND PatientProcedureCode.StatusCode = 'A'),0) AS ProcedureCode     
  ,ISNULL((  
    SELECT TOP 1 1  
    FROM #ProcedureId TPC  
    WHERE TPC.UserId = TMPP.Userid  
    ), 0) AS ProcedureCode  
  --,DiseaseMarkerStatus    
  ,CONVERT(DECIMAL(10, 2), YTDUtilization) YTDUtilization  
  ,ERVisit  
  ,CONVERT(DECIMAL(10, 2), RxUtilization) RxUtilization  
  ,CareGaps  
  ,'Admit' AS ADTStatus
 FROM #tmpPatientByData TMPP  
  
END TRY  
  
BEGIN CATCH  
 ----------------------------------------------------------------------------------------------------------       
 -- Handle exception        
 DECLARE @i_ReturnedErrorID INT  
  
 EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
 RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyPatients_PatientView] TO [FE_rohit.r-ext]
    AS [dbo];

