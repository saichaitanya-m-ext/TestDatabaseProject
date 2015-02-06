

/*                
------------------------------------------------------------------------------                
Procedure Name: [usp_UserMeasure_Patient_LongitudinalView_LV]2,4010
Description   : This procedure is used to get the details from PatientMeasure Table              
Created By    : NagaBabu                
Created Date  : 07-Oct-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION
08-Oct-2010   Rathnam	added isnull function to out put select statement.
11-Oct-2010 Nagababu Added New table variable @Headers  
12-Oct-2010 NagaBabu Added Two select Statements for getting Drug details and careprovider details  
12-Oct-10 Pramod Changed to Union statement
13-Oct-2010 NagaBabu Added StatusCode = 'A' forr getting all Details in Active status
14-Oct-2010 NagaBabu Converted date formates And order by clause to select statements
15-Oct-10 Pramod Modified the Durg code related query and also removed the userdrugcodes.statuscode = 'A' condition
26-Oct-2010 Rathnam added the dynamic measurename columns  for select statement. Also, modified the userdrug and 
			encounter query to include where clause for date fields
29-Oct-10 Pramod Included Not null criteria for @v_query
29-Nov-10 Pramod Removed the join of user claims and claim number query is changed
09-Mar-2011 NagaBabu Added #Measures and inserted 'CTE' Values to provide column name to that field
11-Mar-2011 NagaBabu Deleted #Measures 
18-Apr-2011 NagaBabu Changed Field order for 'No. Of Days','Date of Schedule','Due Date','Comments' fields in last
						ResultSet
22-Apr-2011 Pramod Included a special while loop for inserting a dummy measure A0SPEC which is going to be used in
			longitudinal view procedure
25-Apr-2011 NagaBabu Added MeasureRange field to #MeasureValue table and added new resultset 
29-Apr-2011 NagaBabu Modified last Resultset by taking values from labmeasure for Good,Fair,Poor
03-May-2011 Rathnam added PhonecallLog & Patientgoal select statements.	
04-May-2011 Rathnam added Subquerry to get CareProviderName in phonecalllog select statement.
05-May-2011 Rathnam added Task select statement.
06-May-2011 Rathnam added removed the hardcode values and implimented the logic for MeasureRange values
10-May-2011 Rathnam added MedicationTitration select statement & Added select statements 
                    from PatientEncounters and UserDrugCodes for getting Min and Max values
11-May-2011 Rathnam added Select statement related taskattempts for a particular patient. 
12-May-2011 Rathnam added case statement for encounter select statement IsEncounterdateMandatory=1 
16-May-2011 Rathnam added takstypename to the last select statement  
17-May-2011 Rathnam added CareGap condition in task select statement.                
23-May-11 Pramod Added ORDER BY Measure.SortOrder in few places. Also, changed the ;WITH ColumnList(i,j) query
			as it was giving recursion error : The maximum recursion 100 has been exhausted before statement completion
26-May-2011 Rathnam removed the not between condition in encounters select statement.
24-June-2011 NagaBabu Added TOP 10 for the variable @v_columns and MIN(MinDateTaken) as MIN(ISNULL(MinDateTaken,0))
						and MAX(MaxDateTaken) AS MAX(ISNULL(MaxDateTaken,0))			
28-June-2011 NagaBabu Added where clause for getting @d_MinDateTaken,@d_MaxDateTaken FROM @tblDatetaken
						and Added TOP 20 for the variable @v_columns
29-June-2011 NagaBabu Added AND EncounterType.Name IN ('Hospital','ER','Dr. Visit','Urgent Care','Clinic','Ambulance','Out of Office Service')
						 in where clause to filter encountertypes 		
16-Jul-2011 Pramod Modified the SP to include BETWEEN clause of GETDATE() - 730 and GETDATE() for default scenario
18-July-2011 NagaBabu replaced segment1 ,segment2 by '' as this field is is deleted from table LabelerCode,Productcode
19-July-2011 NagaBabu Added AND Measure.IsTextValueForControls = 0 conditon in insert into #MeasureValue table
05-Sep-2011 NagaBabu replaced BETWEEN clause of GETDATE() - 730 and GETDATE() by  '>= GETDATE() - 730' for default scenario
12-Oct-2011 Rathnam removed the case statement IsEncounterdateMandatory = 1 while retriving the encounters
29-Feb-2012 Rathnam Replaced PatientGoalProgressLogid with PatientGoadlID
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers
07-Feb-2013 Rathnam commented the lifestyle function as per sp optimization from Lyn            
-----------------------------------------------------------------------------                
*/  
CREATE PROCEDURE [dbo].[usp_UserMeasure_Patient_LongitudinalView_LV]--23,23
(
	@i_AppUserId KEYID ,
	@i_PatientUserId KEYID,
	@d_FromDate DATETIME = NULL ,
	@d_ToDate DATETIME = NULL,
	@t_MeasureName tbSourceName READONLY
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
      
      DECLARE @v_columns VARCHAR(8000),
	          @v_query VARCHAR(8000),
	          @i_Count INT,
	          @d_MinDateTaken DATETIME,
	          @d_MaxDateTaken DATETIME,
	          @d_CounterDateTaken DATETIME
	          
	  IF @d_FromDate IS NULL 
		SET @d_FromDate = DATEADD(YEAR,-2, CAST(GETDATE() AS DATE)) 
		SET @d_ToDate = DATEADD(YEAR,2, CAST(GETDATE() AS DATE)) 

	  SELECT @i_Count=COUNT(*) FROM @t_MeasureName 
	         
	  CREATE TABLE #MeasureValue 
	  (
		ID INT IDENTITY,
		Datetaken DATETIME ,
		MeasureValue DECIMAL(10,2),
		Name varchar(500),
		MeasureRange VARCHAR(15) ,
		MeasureID INT,
		SortOrder INT
	  )

	  
	  INSERT INTO  
	      #MeasureValue
		  (
			Datetaken ,
			MeasureValue,
			Name ,
			MeasureRange ,
			MeasureID,
			SortOrder
		  )
	  SELECT
		  BP.MeasurementTime ,
		  BP.SystolicValue ,
		  'BP Systolic' ,
		  NULL AS MeasureRange ,	
		  NULL AS MeasureID ,
		  0 AS SortOrder  
	  FROM 
		  PatientVitalSignBloodPressure BP
	  INNER JOIN (SELECT 
					  MIN(DiastolicValue)DiastolicValue ,
					  CAST(MeasurementTime AS DATE)MeasurementTime ,
					  PatientID
				  FROM 		 
					  PatientVitalSignBloodPressure
				  WHERE PatientID = @i_PatientUserId
				  AND CAST(MeasurementTime AS DATE) BETWEEN @d_FromDate AND @d_ToDate 
				  GROUP BY PatientID,CAST(MeasurementTime AS DATE))	DT
		  ON DT.DiastolicValue = BP.DiastolicValue			  
		  AND DT.MeasurementTime = BP.MeasurementTime		    	 
	  WHERE BP.PatientID = @i_PatientUserId	
	  
	  INSERT INTO  
	      #MeasureValue
		  (
			Datetaken ,
			MeasureValue,
			Name ,
			MeasureRange ,
			MeasureID,
			SortOrder
		  )
	  SELECT
		  BP.MeasurementTime ,
		  BP.DiastolicValue ,
		  'BP Diastolic' ,
		  NULL AS MeasureRange ,	
		  NULL AS MeasureID ,
		  0 AS SortOrder  
	  FROM 
		  PatientVitalSignBloodPressure BP
	  INNER JOIN (SELECT 
					  MIN(DiastolicValue)DiastolicValue ,
					  CAST(MeasurementTime AS DATE)MeasurementTime ,
					  PatientID
				  FROM 		 
					  PatientVitalSignBloodPressure
				  WHERE PatientID = @i_PatientUserId
				  AND CAST(MeasurementTime AS DATE) BETWEEN @d_FromDate AND @d_ToDate 
				  GROUP BY PatientID,CAST(MeasurementTime AS DATE))	DT
		  ON DT.DiastolicValue = BP.DiastolicValue			  
		  AND DT.MeasurementTime = BP.MeasurementTime		    	 
	  WHERE BP.PatientID = @i_PatientUserId	  	    	  
		  
	  INSERT INTO  
	      #MeasureValue
		  (
			Datetaken ,
			MeasureValue,
			Name ,
			MeasureRange ,
			MeasureID,
			SortOrder
		  )
       SELECT DISTINCT
		  PatientMeasure.DateTaken AS DateTaken
		 ,PatientMeasure.MeasureValueNumeric AS MeasureValue
		 ,CG.CodeGroupingName
		 ,NULL AS MeasureRange
		 ,CG.CodeGroupingID
		 ,0 AS SortOrder
	  FROM
		  PatientMeasure WITH(NOLOCK)
	  INNER JOIN PatientLabGroup PL WITH(NOLOCK)
		  ON PL.PatientMeasureID = PatientMeasure.PatientMeasureID		  
	  INNER JOIN CodeSetLoinc WITH(NOLOCK)
	      ON CodeSetLoinc.LoincCodeId = PatientMeasure.LOINCCodeID 
	  INNER JOIN CodeGrouping CG WITH(NOLOCK)	
		  ON CG.CodeGroupingID = PL.CodeGroupingID	  
	  WHERE
		  PatientMeasure.PatientID = @i_PatientUserId
	  AND PatientMeasure.StatusCode = 'A'
	  AND PatientMeasure.DateTaken IS NOT NULL
	  AND (PatientMeasure.DateTaken BETWEEN @d_FromDate AND @d_ToDate )
	  AND cg.CodeGroupingName IN ('A1C','LDL')
	 
	   
	  SELECT @d_MinDateTaken = @d_FromDate ,
			 @d_MaxDateTaken = @d_ToDate
	  	
	  SET @d_CounterDateTaken = DATEADD(D,-1,@d_MinDateTaken)

	  WHILE CONVERT(DATE,@d_MaxDateTaken) >= CONVERT(DATE,@d_CounterDateTaken)
	  BEGIN
		  INSERT INTO #MeasureValue ( Datetaken, MeasureValue, Name,MeasureID )
		  VALUES (@d_CounterDateTaken, 0, 'A0SPEC',0)

		  SET @d_CounterDateTaken = DATEADD(D,1,@d_CounterDateTaken)
	  END
	  
	  -- End of line of code for Special measure record entry which is going to be used in the Longitudinal view Flex component
	 
      SELECT TOP 20
          @v_columns = COALESCE(@v_columns + ',[' + CAST(NAME AS VARCHAR) + ']','[' + CAST(NAME AS VARCHAR)+ ']')
	  FROM 
	      #MeasureValue
	  GROUP BY NAME,SortOrder -- Included sortorder on 23-May-11
	  ORDER BY SortOrder -- Included on 23-May-11


      SELECT  'DateTaken'
      UNION ALL
	  SELECT REPLACE( replace(KeyValue,'[',''),']','') 
	    FROM dbo.udf_SplitStringToTable(@v_columns,',') 
	          
  	  SET @v_query = 'SELECT DateTaken,'+ @v_columns +' from  #MeasureValue
					  PIVOT
					  (SUM(MeasureValue)
					  FOR Name
					  IN (' + @v_columns + ')
					  )
					  AS p 
					  ORDER by Sortorder, Datetaken'  -- included sortorder on 23 May 11
	  IF @v_query IS NOT NULL
	 	 EXECUTE(@v_query)
	  ELSE 
		 SELECT '' AS DateTaken
		  WHERE 1 = 2

	;WITH RxC
	AS (
		SELECT DISTINCT NULL AS UserDrugId
			,ISNULL(CodeSetDrug.DrugName, '') DrugName
			,Rx.DateFilled AS DateFilled
			,CodeSetDrug.StrengthUnitNormalized 
			,CodeSetDrug.DosageName 
			,NULL AS FrequencyOfTitrationDays
			,CodeSetDrug.Strength
			,Rx.DaysSupply 
			,DBO.ufn_GetUserNameByID(Rx.PrescriberID) AS ProviderName
			,CodeSetCMSProviderSpecialty.ProviderSpecialtyName AS SpecialityName
			,Rx.DrugCodeId
		FROM RxClaim Rx WITH (NOLOCK)
		INNER JOIN (
			SELECT MAX(DateFilled) DateFilled
				,DrugCodeId
			FROM RxClaim
			WHERE PatientID = @i_PatientUserId
				AND DateFilled BETWEEN @d_FromDate AND @d_ToDate
			GROUP BY PatientID
				,DrugCodeId
			) DT
			ON DT.DrugCodeId = RX.DrugCodeId
				AND DT.DateFilled = RX.DateFilled
		INNER JOIN vw_CodeSetDrug CodeSetDrug WITH (NOLOCK)
			ON CodeSetDrug.DrugCodeId = Rx.DrugCodeId
		LEFT JOIN ProviderSpecialty WITH (NOLOCK)
			ON Rx.PrescriberID = ProviderSpecialty.ProviderID
		LEFT JOIN CodeSetCMSProviderSpecialty WITH (NOLOCK)
			ON CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
		WHERE Rx.PatientID = @i_PatientUserId
			AND Rx.StatusCode = 'A'
		)
	SELECT DrugCodeId UserDrugId
		,DrugName AS 'Drug Name' 
		,CONVERT(VARCHAR(10), DateFilled, 101) AS 'Date Filled'
		,StrengthUnitNormalized 'Strength Unit'
		,DosageName as 'Dosage Name'
		,DaysSupply AS 'Days Supply' 
		,ProviderName AS 'Provider Name' 
		,SpecialityName AS 'Speciality Name'
		,DateFilled As DateTaken
		,CONVERT(VARCHAR(10), DateFilled, 101) AS  Date 
	FROM RxC
	ORDER BY DateFilled DESC  

--SELECT DISTINCT Rx.RxClaimID AS UserDrugId  
--   ,ISNULL(CodeSetDrug.DrugName,'') AS 'Drug Name'  
--   ,(CONVERT(VARCHAR(10),Rx.DateFilled,101)) AS 'Date Filled'  
--   ,CodeSetDrug.StrengthUnitNormalized As 'Strength Unit'  
--   ,CodeSetDrug.DosageName as 'Dosage Name'
--   ,Rx.DaysSupply AS 'Days Supply'  
--   ,DBO.ufn_GetUserNameByID(Rx.PrescriberID) AS 'Provider Name'  
--   ,CodeSetCMSProviderSpecialty.ProviderSpecialtyName AS 'Speciality Name'
--   ,Rx.DateFilled As DateTaken
--   ,(CONVERT(VARCHAR(10),Rx.DateFilled,101)) AS Date  
--  FROM RxClaim Rx WITH (NOLOCK)  
--  INNER JOIN vw_CodeSetDrug CodeSetDrug WITH (NOLOCK)  
--   ON CodeSetDrug.DrugCodeId = Rx.DrugCodeId  
--  LEFT JOIN ProviderSpecialty WITH (NOLOCK)  
--   ON Rx.PrescriberID = ProviderSpecialty.ProviderID  
--  LEFT JOIN CodeSetCMSProviderSpecialty WITH (NOLOCK)  
--   ON CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID  
--  WHERE Rx.PatientID = @i_PatientUserId  
--   AND Rx.StatusCode = 'A'  
--  ORDER BY Rx.RxClaimID DESC  


	--  CREATE TABLE #CodeGrouping (
	--	CodeGroupingID INT
	--	,CodeGroupingName VARCHAR(1000)
	--	,IsOther BIT
	--	)

	--INSERT INTO #CodeGrouping
	--SELECT cg.CodeGroupingID
	--	,cg.CodeGroupingName
	--	,CASE 
	--		WHEN cg.CodeGroupingName IN (
	--				'Surgery'
	--				,'Anesthesia'
	--				,'Radiology'
	--				,'Laboratory'
	--				)
	--			THEN 1
	--		ELSE 0
	--		END
	--FROM CodeGrouping cg WITH (NOLOCK)
	--INNER JOIN CodeTypeGroupers ctg WITH (NOLOCK)
	--	ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
	--INNER JOIN CodeGroupingType cgt WITH (NOLOCK)
	--	ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
	--WHERE cgt.CodeGroupType = 'Utilization Groupers'
	--	AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'

	--CREATE TABLE #PatInternalProc (
	--	CodeGroupingID INT
	--	,CodeGroupingName VARCHAR(500)
	--	,DateOfService DATE
	--	,IsOther BIT
	--	);

	--INSERT INTO #PatInternalProc
	--SELECT DISTINCT cg.CodeGroupingID
	--	,cg.CodeGroupingName
	--	--,ppc.ClaimInfoId
	--	,ppc.DateOfService DateOfService
	--	,cg.IsOther
	--FROM PatientProcedureCode ppc WITH (NOLOCK)
	--INNER JOIN PatientProcedureCodeGroup ppcg WITH (NOLOCK)
	--	ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
	--INNER JOIN #CodeGrouping cg WITH (NOLOCK)
	--	ON cg.CodeGroupingID = ppcg.CodeGroupingID
	--WHERE ppc.PatientID = @i_PatientUserId
	--	AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))
	
	--UNION
	
	--SELECT DISTINCT cg.CodeGroupingID
	--	,cg.CodeGroupingName
	--	--,ppc.ClaimInfoId
	--	,ppc.DateOfService DateOfService
	--	,cg.IsOther
	--FROM PatientOtherCode ppc WITH (NOLOCK)
	--INNER JOIN PatientOtherCodeGroup ppcg WITH (NOLOCK)
	--	ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
	--INNER JOIN #CodeGrouping cg WITH (NOLOCK)
	--	ON cg.CodeGroupingID = ppcg.CodeGroupingID
	--WHERE ppc.PatientID = @i_PatientUserId
	--	AND (ppc.DateOfService > DATEADD(YEAR, - 1, GETDATE()))

	--CREATE TABLE #PatProc (
	--	CodeGroupingID INT
	--	,CodeGroupingName VARCHAR(1000)
	--	,DateOfService DATE
	--	);

	--INSERT INTO #PatProc
	--SELECT CodeGroupingID
	--	,CodeGroupingName
	--	,DateOfService
	--FROM (
	--	SELECT CodeGroupingID
	--		,CodeGroupingName
	--		,DateOfService
	--		,ROW_NUMBER() OVER (
	--			PARTITION BY DateOfService ORDER BY CASE 
	--					WHEN CodeGroupingName = 'Acute Inpatient'
	--						THEN 1
	--					WHEN CodeGroupingName = 'Observation Stay'
	--						THEN 2
	--					WHEN CodeGroupingName = 'Hospice'
	--						THEN 3
	--					ELSE 4
	--					END
	--			) sno
	--	FROM #PatInternalProc
	--	WHERE IsOther = 0 -- 17 Symphony Internal encounter groupers
		
	--	UNION ALL
		
	--	SELECT CodeGroupingID
	--		,CodeGroupingName
	--		,DateOfService
	--		,ROW_NUMBER() OVER (
	--			PARTITION BY DateOfService ORDER BY CASE 
	--					WHEN CodeGroupingName = 'Surgery'
	--						THEN 1
	--					WHEN CodeGroupingName = 'Anesthesia'
	--						THEN 2
	--					WHEN CodeGroupingName = 'Radiology'
	--						THEN 3
	--					WHEN CodeGroupingName = 'Laboratory'
	--						THEN 4
	--					ELSE 5
	--					END
	--			) sno
	--	FROM #PatInternalProc
	--	WHERE IsOther = 1
	--		AND NOT EXISTS (
	--			SELECT 1
	--			FROM #PatInternalProc P
	--			WHERE p.DateOfService = #PatInternalProc.DateOfService
	--				AND P.IsOther = 0
	--			) -- If above 17 encounters groupers doesnt satisfy it will go for Other 4 like Surgery,Anesthesia,Radiology,Laboratory
		
	--	UNION ALL
		
	--	SELECT DISTINCT 0 CodeGroupingID
	--		,'Other' CodeGroupingName
	--		,DateOfAdmit
	--		,1
	--	FROM ClaimInfo WITH (NOLOCK)
	--	WHERE IsOtherUtilizationGroup = 1
	--		AND DateOfAdmit > DATEADD(YEAR, - 1, GETDATE())
	--		AND PatientID = @i_PatientUserId
	--		AND NOT EXISTS (
	--			SELECT 1
	--			FROM #PatInternalProc p
	--			WHERE p.DateOfService = ClaimInfo.DateOfAdmit
	--			)
	--	) t
	--WHERE t.sno = 1

	--SELECT DISTINCT p.*
	--	,cp.ProviderID
	--	,ci.claiminfoid
	--INTO #x
	--FROM #PatProc p
	--INNER JOIN ClaimInfo ci
	--	ON p.DateOfService = ci.DateOfAdmit
	--LEFT JOIN ClaimProvider cp
	--	ON cp.ClaimInfoID = ci.ClaimInfoID
	--WHERE ci.PatientID = @i_PatientUserId
	--ORDER BY 3 DESC

	--SELECT ROW_NUMBER() OVER (
	--		ORDER BY (
	--				SELECT NULL
	--				)
	--		) AS UserEncounterID
	--    ,src.EncounterType AS Encounter
	--    ,CONVERT(VARCHAR(10), src.EncounterDate, 101) AS 'Date'	
	--	,COALESCE(ISNULL(P1.LastName, '') + ' ' + ISNULL(P1.FirstName, '') + ' ' + ISNULL(P1.MiddleName, ''), '') AS 'Provider Name'
	--	,CodesetCMSProviderSpecialty.ProviderSpecialtyName 'Provider Speciality'
	--	,src.EncounterDate AS DateTaken
	--	FROM (
	--	SELECT DISTINCT @i_PatientUserId AS UserId
	--		,CAST(p.DateOfService AS DATE) EncounterDate
	--		,p.CodeGroupingName AS EncounterType
	--		,p.ProviderID UserProviderID
	--		,'' CPTCode
	--		FROM #x p WITH (NOLOCK)
	--	) Src
	--LEFT JOIN Provider P1 WITH (NOLOCK)
	--	ON P1.ProviderID = Src.UserProviderId
	--LEFT JOIN ProviderSpecialty WITH (NOLOCK)
	--	ON ProviderSpecialty.ProviderID = P1.ProviderID
	--LEFT JOIN CodesetCMSProviderSpecialty WITH (NOLOCK)
	--	ON CodesetCMSProviderSpecialty.CMSProviderSpecialtyCodeID = ProviderSpecialty.CMSProviderSpecialtyCodeID
	--ORDER BY CAST(EncounterDate AS DATE) DESC
	   
	   DECLARE @i_UserId INT = @i_patientUserid,
	           @b_isLV ISINDICATOR = 1
	   EXEC [usp_DashBoard_PatientHomePage_ProgramEncounters] @i_AppUserId ,@i_UserId ,@b_isLV  
	   

	DECLARE @tblMeasureRange TABLE
	(
		LabMeasureId INT,
		MeasureId INT,
		ProgramId INT,
		PatientUserID INT,
		MinValue VARCHAR(50),
		MaxValue VARCHAR(50),
		MeasureRange VARCHAR(5),
		Name VARCHAR(50),
		StartDate DATETIME ,
		EndDate DATETIME
	)

	DECLARE @tblMeasureID ttypeKeyID
	INSERT INTO @tblMeasureID
	SELECT DISTINCT
	    MeasureID 
	FROM 
	    #MeasureValue 
	   
    INSERT INTO @tblMeasureRange
	EXEC [usp_LabMeasureRangeHierarchy_Select]
	@i_AppUserId = @i_AppUserId,
	@i_PatientUserID = @i_PatientUserId,
	@tblMeasureID = @tblMeasureID
	
	SELECT 
		StartDate,
		EndDate,
		MinValue,
		MaxValue,
		MeasureRange,
		Name
	FROM @tblMeasureRange
   ----------------------------------------------------------------- 
    
    SELECT 
        TaskId,
		TaskDueDate AS DateTaken,
		TaskTypeName  + ' : ' +
		CONVERT(VARCHAR , Dbo.ufn_GetTypeNamesByTypeId(TaskType.TaskTypeName , Task.TypeID)) AS Name ,
		TaskStatus.TaskStatusText AS 'Status',
		CONVERT(VARCHAR,TaskDueDate,101) AS 'Date',
		CONVERT(VARCHAR,Task.TaskCompletedDate,101) As 'TaskCompletionDate',
		TaskStatus.TaskStatusText AS 'Task Status',
		--[dbo].[ufn_GetUserNameByID] (AssignedCareProviderId) AS "Provider Name",
		(SELECT COUNT(TaskId) FROM TaskAttempts WHERE TaskId= Task.TaskId) AS 'No. of Attempts' 
    FROM 
        Task
    INNER JOIN TaskStatus
        ON TaskStatus.TaskStatusId = Task.TaskStatusId 
    INNER JOIN TaskType
        ON Task.TaskTypeId = TaskType.TaskTypeId       
    WHERE 
        PatientId = @i_PatientUserId
    AND TaskDueDate BETWEEN @d_MinDateTaken AND @d_MaxDateTaken
    AND TaskStatusText IN ('Scheduled','Open','Closed Complete') 
    UNION
    SELECT 
        TaskId,
		TaskDueDate AS DateTaken,
		TaskTypeName  + ' : ' +
		CONVERT(VARCHAR , Dbo.ufn_GetTypeNamesByTypeId(TaskType.TaskTypeName , Task.TypeID)) AS Name ,
		'Care Gap' AS 'Status',
		CONVERT(VARCHAR,TaskDueDate,101) AS 'Date'  ,
		CONVERT(VARCHAR,Task.TaskCompletedDate,101) As 'TaskCompletionDate',
	    TaskStatus.TaskStatusText + ' - ' + 'Care Gap' AS 'Task Status',
	    --[dbo].[ufn_GetUserNameByID] (AssignedCareProviderId) AS "Provider Name",
	    (SELECT COUNT(TaskId) FROM TaskAttempts WHERE TaskId= Task.TaskId) AS 'No.Of Attempts' 
    FROM 
        Task
    INNER JOIN TaskStatus
        ON TaskStatus.TaskStatusId = Task.TaskStatusId
    INNER JOIN TaskType
        ON TaskType.TaskTypeId = Task.TaskTypeId        
    WHERE 
        PatientId = @i_PatientUserId
    AND TaskDueDate BETWEEN @d_MinDateTaken AND @d_MaxDateTaken
    AND TaskStatusText IN ('Closed Incomplete') 
    
 --   SELECT 
	--	PatientQuestionaire.DateTaken,
	--	PatientQuestionaire.PreviousPatientQuestionaireId AS "Previous Questionaire",
	--	CASE WHEN QuestionaireTypeName = 'Medication Titration'
	--	     THEN 'Medication Titration : '+ Questionaire.QuestionaireName 
	--	     ELSE Questionaire.QuestionaireName 
	--	END AS Name,
		
		
		
	--			   COALESCE(ISNULL(Provider.LastName , '') + ' ' + 
	--						ISNULL(Provider.FirstName , '') + ' ' + 
	--						ISNULL(Provider.MiddleName , '') , ''
	--						)
				   
	--	AS "Provider Name" ,
	--	QDrugs.DrugCode AS "Drug Code",
	--	QDrugs.DrugName AS "Drug Name",
	--	QDrugs.Form AS Form,
	--	QDrugs.Dosage AS Dosage,
	--	QDrugs.TimesPerDay AS Frequency,
	--	QDrugs.[Route],
	--	QRecommendations.RecommendationName AS "Recommendation Name",
	--	CONVERT(VARCHAR,PatientQuestionaire.DateTaken,101) AS "Date"
	--FROM
	--	PatientQuestionaire
	--INNER JOIN Questionaire
	--	ON Questionaire.QuestionaireId = PatientQuestionaire.QuestionaireId
	--INNER JOIN QuestionaireType
	--	ON QuestionaireType.QuestionaireTypeId = Questionaire.QuestionaireTypeId
	--LEFT OUTER JOIN 
	--	   (SELECT 
	--			PatientQuestionaireDrugs.PatientQuestionaireID AS PatientQuestionaireID,
	--			CodeSetDrug.DrugCode AS DrugCode,
	--			CodeSetDrug.DrugName AS DrugName,
	--			CodeSetDrugLabeler.FirmName AS Form,
	--			CodeSetDrugLabeler.LabelerCode AS Dosage,
	--			PatientDrugCodes.TimesPerDay AS TimesPerDay,
	--			'' AS "Route",
	--			PatientDrugCodes.CareTeamUserID,
	--			PatientDrugCodes.ProviderID
	--		FROM 
	--			PatientQuestionaireDrugs
	--		INNER JOIN PatientDrugCodes 
	--			ON PatientDrugCodes.PatientDrugID = PatientQuestionaireDrugs.PatientDrugID
	--		INNER JOIN CodeSetDrug
	--			ON CodeSetDrug.DrugCodeId = PatientDrugCodes.DrugCodeId
	--		LEFT OUTER JOIN CodeSetDrugLabeler
	--			ON CodeSetDrugLabeler.LabelerID = CodeSetDrug.LabelerID
	--		WHERE PatientDrugCodes.PatientID = @i_PatientUserId	
	--	   ) QDrugs
	--ON PatientQuestionaire.PatientQuestionaireId = QDrugs.PatientQuestionaireID 	
	--LEFT OUTER JOIN
	--	   (SELECT 
	--			PatientQuestionaireRecommendations.PatientQuestionaireId,
	--			Recommendation.RecommendationName
	--		FROM 
	--			PatientQuestionaireRecommendations
	--		INNER JOIN Recommendation
	--			ON Recommendation.RecommendationId = PatientQuestionaireRecommendations.RecommendationId
	--	   ) QRecommendations
	--ON PatientQuestionaire.PatientQuestionaireId = QRecommendations.PatientQuestionaireID
	--LEFT OUTER JOIN
	--   Provider
	--ON Provider.ProviderID = ISNULL(QDrugs.ProviderID , QDrugs.CareTeamUserID)
	--WHERE PatientQuestionaire.PatientId = @i_PatientUserId  
	--	  AND QuestionaireType.QuestionaireTypeName = 'Medication Titration'
	--	  AND DateTaken BETWEEN @d_MinDateTaken AND @d_MaxDateTaken
    
    SELECT 
		Task.TaskId,
		TaskType.TaskTypeName + ' : ' + 
		ISNULL(dbo.ufn_GetTypeNamesByTypeId(TaskType.TaskTypeName , Task.TypeID),Task.ManualTaskName)AS "Task Name",
		TaskAttempts.AttemptedContactDate AS "Attempted ContactDate",
		CommunicationType.CommunicationType AS "Communication Type",
		(
			SELECT
			 COALESCE(ISNULL(Users.LastName , '') + ' ' + 
					ISNULL(Users.FirstName , '') + ' ' + 
					ISNULL(Users.MiddleName , '') , ''
					)
			FROM
			Provider  Users WHERE ProviderID = TaskAttempts.UserId
		) AS "Provider Name",
		TaskAttempts.Comments,
		CONVERT(VARCHAR,TaskAttempts.AttemptedContactDate,101) AS "Date"
    FROM 
        Task
    INNER JOIN TaskAttempts
		ON Task.TaskId = TaskAttempts.TaskId
	INNER JOIN TaskType 
	    ON TaskType.TaskTypeId = Task.TaskTypeId	
    INNER JOIN TaskTypeCommunications
		ON TaskTypeCommunications.TaskTypeCommunicationID = TaskAttempts.TasktypeCommunicationID
    INNER JOIN CommunicationType
		ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
    INNER JOIN TaskStatus
		ON TaskStatus.TaskStatusId =  Task.TaskStatusId
    WHERE 
        Task.PatientId = @i_PatientUserId
    AND TaskDueDate BETWEEN @d_MinDateTaken AND @d_MaxDateTaken
    AND TaskStatusText IN ('Scheduled','Open','Closed Complete')
 
    UNION
    SELECT 
		Task.TaskId,
		TaskType.TaskTypeName + ' : ' + 
		ISNULL(dbo.ufn_GetTypeNamesByTypeId(TaskType.TaskTypeName , Task.TypeID),Task.ManualTaskName)AS "Task Name",
		TaskAttempts.AttemptedContactDate AS "Attempted ContactDate",
		CommunicationType.CommunicationType AS "Communication Type",
		(
			SELECT
			 COALESCE(ISNULL(Users.LastName , '') + ' ' + 
					ISNULL(Users.FirstName , '') + ' ' + 
					ISNULL(Users.MiddleName , '') , ''
					)
			FROM
			Provider Users WHERE ProviderID = TaskAttempts.UserId
		) AS "Provider Name",
		TaskAttempts.Comments,
		CONVERT(VARCHAR,TaskAttempts.AttemptedContactDate,101) AS "Date"
    FROM 
        Task
    INNER JOIN TaskAttempts
		ON Task.TaskId = TaskAttempts.TaskId
	INNER JOIN TaskType 
	    ON TaskType.TaskTypeId = Task.TaskTypeId	
    INNER JOIN TaskTypeCommunications
		ON TaskTypeCommunications.TaskTypeCommunicationID = TaskAttempts.TasktypeCommunicationID
    INNER JOIN CommunicationType
		ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
    INNER JOIN TaskStatus
		ON TaskStatus.TaskStatusId =  Task.TaskStatusId
    WHERE 
        Task.PatientId = @i_PatientUserId
    AND TaskDueDate BETWEEN @d_MinDateTaken AND @d_MaxDateTaken
    AND TaskStatusText IN ('Closed Incomplete') 

	SELECT DISTINCT 
				cg.CodeGroupingName				
			FROM PatientProcedureCode ppc
			INNER JOIN PatientProcedureCodeGroup ppcg
				ON ppc.PatientProcedureCodeID = ppcg.PatientProcedureCodeID
			INNER JOIN CodeGrouping cg
				ON cg.CodeGroupingID = ppcg.CodeGroupingID
			INNER JOIN CodeTypeGroupers ctg
				ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
			INNER JOIN CodeGroupingType cgt
				ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
			WHERE
				ppc.StatusCode = 'A'
				AND ppcg.StatusCode = 'A'				
				AND cgt.CodeGroupType = 'Utilization Groupers'
				AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'
				AND ppc.PatientID = @i_PatientUserId
			UNION			
			SELECT DISTINCT 
				cg.CodeGroupingName				
			FROM PatientOtherCode ppc
			INNER JOIN PatientOtherCodeGroup ppcg
				ON ppc.PatientOtherCodeID = ppcg.PatientOtherCodeID
			INNER JOIN CodeGrouping cg
				ON cg.CodeGroupingID = ppcg.CodeGroupingID
			INNER JOIN CodeTypeGroupers ctg
				ON ctg.CodeTypeGroupersID = cg.CodeTypeGroupersID
			INNER JOIN CodeGroupingType cgt
				ON cgt.CodeGroupingTypeID = ctg.CodeGroupingTypeID
			WHERE ppc.StatusCode = 'A'
				AND ppcg.StatusCode = 'A'
				AND cgt.CodeGroupType = 'Utilization Groupers'
				AND ctg.CodeTypeGroupersName = 'Encounter Types(Internal)'
				AND ppc.PatientID = @i_PatientUserId
			UNION
			SELECT
				'Other' CodeGroupingName				
	
	  SELECT DISTINCT
		  MV.Name AS CodeGroupingName,
		  CSL.LoincCode ,
		  CSL.ShortDescription AS LoincName ,
		  PM.DateTaken
	  FROM #MeasureValue MV
	  INNER JOIN PatientLabGroup PLG
	  ON MV.MeasureID = PLG.CodeGroupingID
	  INNER JOIN PatientMeasure PM
	  ON PM.PatientMeasureID = PLG.PatientMeasureID
	  INNER JOIN CodeSetLoinc CSL
	  ON CSL.LoincCodeId = PM.LOINCCodeID
	  WHERE PM.PatientID = @i_PatientUserId
	  AND PM.DateTaken BETWEEN @d_FromDate AND @d_ToDate
		  	  		
			
    
 --   EXEC usp_UsersEpisode_Select
 --   @i_AppUserId = @i_AppUserId,
	--@i_PatientUserID = @i_PatientUserId 
	 
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
    ON OBJECT::[dbo].[usp_UserMeasure_Patient_LongitudinalView_LV] TO [FE_rohit.r-ext]
    AS [dbo];

