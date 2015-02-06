
/*      
--------------------------------------------------------------------------------------------------------------      
Procedure Name: [usp_CareProviderDashBoard_MyPatients_CategoryView_ByMeasure]226658,6,'1m',0  
Description   : This Procedre use to get Measures and Rangecounts For a Specific Cohort   
Created By    : 01-Aug-2011  
Created Date  : NagaBabu  
---------------------------------------------------------------------------------------------------------------      
Log History   :       
DD-Mon-YYYY  BY  DESCRIPTION   
03-Aug-2011 NagaBabu Deleted 'AND (ISNULL(Patients.IsDeceased,0) = 0 OR Patients.EndDate IS NULL)' condition from   
      first select statement and Return statement in Catch block    
10-Aug-2011 NagaBabu Added @b_IsDiseaseDistribution as input parameter for getting DiseaseDistribution details also  
11-Aug-2011 NagaBabu Added @i_NextOrPrevious for getting Next or Previous grids and Displaying GridCount for   
      DiseaseDistribution   
12-Aug-2011 NagaBabu Added Next or Previous grids Scenario and Displaying GridCount Resultset instead of Displaying   
      Measuregrid resultset  
17-Aug-2011 NagaBabu Modified Querry for getting the fields Good,Fair,Poor,Undefined  
18-Nov-2011 NagaBabu Added ISNULL condition for GridCount field in second resultset                    
18-Nov-2011 Pramod Changed the join to comment userdisease, disease and include userdiagnosis, Included Select 
distinct
15-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers	
---------------------------------------------------------------------------------------------------------------      
*/  -- PopulationDefinition 
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyPatients_CategoryView_ByMeasure]--263353,11,null,1,1  
(  
    @i_AppUserId KEYID ,  
    @i_PopulationDefinitionID KEYID ,  
    @v_DatePeriod VARCHAR(3) = NULL,  
    @b_IsDiseaseDistribution BIT = 1,  
    @i_NextOrPrevious INT = NULL      
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON      
-- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.'  
               ,17  
               ,1  
               ,@i_AppUserId )  
         END  
    
  IF @b_IsDiseaseDistribution = 1  
   BEGIN  
      
      
    --SELECT   
    -- Disease.DiseaseID ,  
    -- Disease.Name ,  
    -- CohortListUsers.UserId  
    --INTO   
    -- #DiseaseUsers   
    --FROM  
    -- CohortList  
    --INNER JOIN CohortListUsers  
    -- ON CohortList.CohortListId = CohortListUsers.CohortListId  
    --INNER JOIN UserDisease   
    -- ON UserDisease.UserID = CohortListUsers.UserId  
    --INNER JOIN Disease  
    -- ON UserDisease.DiseaseID = Disease.DiseaseID  
    --INNER JOIN Patients  
    -- ON Patients.UserId = CohortListUsers.UserId  
    --INNER JOIN CareTeamMembers   
    -- ON CareTeamMembers.CareTeamId = Patients.CareTeamId  
    --INNER JOIN CareTeam  
    -- ON CareTeamMembers.CareTeamId = CareTeam.CareTeamId  
    --WHERE  
    -- CareTeamMembers.UserId = @i_AppUserId  
    --AND CohortList.CohortListId = @i_CohortListId  
    --AND CareTeamMembers.StatusCode = 'A'  
    --AND CareTeam.StatusCode = 'A'  
    --AND CohortList.StatusCode = 'A'   
    --AND CohortListUsers.StatusCode = 'A'         
    --AND Patients.UserStatusCode = 'A'   
    --AND UserDisease.StatusCode = 'A'   
    --AND Disease.StatusCode = 'A'   

		SELECT DISTINCT  
			CodeSetICD.ICDCodeId AS DiseaseID,  
			CodeSetICD.ICDDescription AS Name,  
			PopulationDefinitionUsers.UserId  
		INTO   
			#DiseaseUsers   
		FROM  
			PopulationDefinition  WITH (NOLOCK)
		INNER JOIN PopulationDefinitionUsers  WITH (NOLOCK)
			ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionUsers.PopulationDefinitionID  
		INNER JOIN UserDiagnosisCodes  WITH (NOLOCK)
			ON UserDiagnosisCodes.UserId = PopulationDefinitionUsers.UserId
		INNER JOIN CodeSetICD WITH (NOLOCK)
			ON UserDiagnosisCodes.DiagnosisId = CodeSetICD.ICDCodeId
		INNER JOIN Patients  WITH (NOLOCK)
			ON Patients.UserId = PopulationDefinitionUsers.UserId  
		INNER JOIN CareTeamMembers WITH (NOLOCK)  
			ON CareTeamMembers.CareTeamId = Patients.CareTeamId  
		INNER JOIN CareTeam   WITH (NOLOCK)
			ON CareTeamMembers.CareTeamId = CareTeam.CareTeamId  
		WHERE  
			CareTeamMembers.UserId = @i_AppUserId  
		AND PopulationDefinition.PopulationDefinitionID = @i_PopulationDefinitionID
		AND CareTeamMembers.StatusCode = 'A'  
		AND CareTeam.StatusCode = 'A'  
		AND PopulationDefinition.StatusCode = 'A'   
		AND PopulationDefinitionUsers.StatusCode = 'A'         
		AND Patients.UserStatusCode = 'A'  
	          
		DECLARE @i_TotalPatients INT = ( SELECT COUNT(UserId) FROM #DiseaseUsers ),  
			 @i_MinNum INT = 10*@i_NextOrPrevious - 9 ,  
			 @i_MaxNum INT = 10*@i_NextOrPrevious  
		      
		CREATE TABLE #DiseaseCount  
		(  
		 DiseaseCountId INT IDENTITY(1,1),  
		 DiseaseID INT ,  
		 DiseaseName VARCHAR(500),  
		 PatientCount INT ,  
		 PatientPercentage DECIMAL(10,1)  
		)  
	      
		INSERT INTO #DiseaseCount  
		(  
		 DiseaseID ,  
		 DiseaseName,  
		 PatientCount,  
		 PatientPercentage  
		)    
		SELECT  
			 DiseaseID,  
			 Name AS DiseaseName,  
			 COUNT(UserId) AS PatientCount ,  
			 CONVERT(DECIMAL(10,1),(COUNT(UserId)*100.00)/@i_TotalPatients) AS PatientPercentage  
		FROM  
			 #DiseaseUsers  
		GROUP BY   
			 DiseaseID,  
			 Name  
		ORDER BY COUNT(UserId)DESC   
	      
		SELECT   
			 DiseaseID ,  
			 DiseaseName,  
			 PatientCount,  
			 PatientPercentage  
		FROM   
			#DiseaseCount   
		WHERE   
			DiseaseCountId BETWEEN @i_MinNum AND @i_MaxNum   
		ORDER BY PatientCount -- DESC  
	         
		SELECT ISNULL(CEILING(MAX(DiseaseCountId*1.00)/10),1) AS GridCount FROM #DiseaseCount   
   END  
ELSE  
   BEGIN  
		DECLARE @d_FromDate USERDATE ,  
		  @d_ToDate USERDATE = GETDATE()  
	      
		IF @v_DatePeriod = 'Max'   
		 SET @d_ToDate = NULL    
      
		SELECT @d_FromDate = CASE WHEN @v_DatePeriod = '1M' THEN GETDATE() - 180   
								  WHEN @v_DatePeriod = '3M' THEN GETDATE() - 180     
								  WHEN @v_DatePeriod = '6M' THEN GETDATE() - 180  
								  WHEN @v_DatePeriod = '1Y' THEN GETDATE() - 365    
								  ELSE NULL   
							 END      
        
    SELECT  
		 Measure.MeasureId ,  
		 ISNULL(Measure.ShortName,Measure.Name) AS MeasureName ,  
		 UserMeasure.PatientUserId ,  
		 UserMeasureRange.MeasureRange  
    INTO   
		#MeasureRanges   
    FROM   
		PopulationDefinition  
    INNER JOIN PopulationDefinitionUsers  
		ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionUsers.PopulationDefinitionID  
    INNER JOIN UserMeasure   
		ON UserMeasure.PatientUserId = PopulationDefinitionUsers.UserId  
    INNER JOIN Measure  
		ON UserMeasure.MeasureId = Measure.MeasureId  
    LEFT OUTER JOIN UserMeasureRange  
		ON UserMeasure.UserMeasureId = UserMeasureRange.UserMeasureId     
    INNER JOIN Patients  
		ON Patients.UserId = PopulationDefinitionUsers.UserId  
    INNER JOIN CareTeamMembers   
		ON CareTeamMembers.CareTeamId = Patients.CareTeamId  
    INNER JOIN CareTeam  
		ON CareTeamMembers.CareTeamId = CareTeam.CareTeamId  
    WHERE   
		CareTeamMembers.UserId = @i_AppUserId  
    AND PopulationDefinition.PopulationDefinitionID = @i_PopulationDefinitionID 
    AND ((UserMeasure.DateTaken BETWEEN @d_FromDate AND @d_ToDate) OR (@d_FromDate IS NULL AND @d_ToDate IS NULL))    
    AND CareTeamMembers.StatusCode = 'A'  
    AND CareTeam.StatusCode = 'A'  
    AND PopulationDefinition.StatusCode = 'A'   
    AND PopulationDefinitionUsers.StatusCode = 'A'         
    AND Patients.UserStatusCode = 'A'   
    AND UserMeasure.StatusCode = 'A'   
    AND Measure.StatusCode = 'A'  
      
    SELECT   
		 MeasureId ,  
		 COUNT(DISTINCT PatientUserId) AS MeasureRangeTotalCount  
    INTO  
		#Percentage   
    FROM  
		#MeasureRanges  
    GROUP BY    
		MeasureId  
      
    SELECT DISTINCT   
		 MR.MeasureId ,  
		 MR.MeasureName ,  
		 (SELECT COUNT(DISTINCT PatientUserId) FROM #MeasureRanges WHERE MeasureRange = 'Good' AND MeasureId = MR.MeasureId) AS Good ,  
		 (SELECT COUNT(DISTINCT PatientUserId) FROM #MeasureRanges WHERE MeasureRange = 'Fair' AND MeasureId = MR.MeasureId) AS Fair ,  
		 (SELECT COUNT(DISTINCT PatientUserId) FROM #MeasureRanges WHERE MeasureRange = 'Poor' AND MeasureId = MR.MeasureId) AS Poor ,  
		 (SELECT COUNT(DISTINCT PatientUserId) FROM #MeasureRanges WHERE MeasureRange = 'Undefined' AND MeasureId = MR.MeasureId) AS Undefined   
    INTO   
		 #MeasureRangeDetails     
    FROM   
		 #MeasureRanges MR   
    GROUP BY   
		 MeasureId ,  
		 MeasureName ,  
		 MeasureRange  
    ORDER BY   
		 MeasureName   
      
    SELECT DISTINCT MR.MeasureId,   
       CASE WHEN LabMeasure.TextValueForGoodControl IS NULL OR LabMeasure.TextValueForGoodControl = '' THEN  
        COALESCE      
        (( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')       
        + ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')      
          ),''      
         )       
			ELSE LabMeasure.TextValueForGoodControl  
       END AS DerivedGoodValue,  
      CASE WHEN LabMeasure.TextValueForFairControl IS NULL OR LabMeasure.TextValueForFairControl = '' THEN  
		  COALESCE      
		(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '       
		+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '       
		+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')       
		+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '       
		+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '       
		+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')      
		  ),''      
		 )   
	      ELSE LabMeasure.TextValueForFairControl   
	  END AS DerivedFairValue,  
      CASE WHEN LabMeasure.TextValueForPoorControl IS NULL OR LabMeasure.TextValueForPoorControl = '' THEN  
          COALESCE      
        (( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')       
        + ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '       
        + ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')      
          ),''      
         )         
          ELSE LabMeasure.TextValueForPoorControl   
      END AS DerivedPoorValue,  
      Measure.SortOrder   
      INTO  
		  #MeasureRangeControls     
      FROM #MeasureRanges MR  
      INNER JOIN Measure   
		  ON MR.MeasureId = Measure.MeasureId  
      LEFT OUTER JOIN LabMeasure  
		  ON LabMeasure.MeasureId = MR.MeasureId  
         AND LabMeasure.PatientUserID IS NULL  
         AND LabMeasure.ProgramId IS NULL  
      WHERE Measure.StatusCode = 'A'  
            
    DECLARE @t_MeasureCount TABLE   
    (  
     MeasureCountId KeyId IDENTITY(1,1),  
     MeasureId KeyId,  
     MeasureName ShortDescription,  
     MeasureRangeTotalCount INT,  
     RangeGood VARCHAR(4),  
     Good INT,  
     GoodPercentage DECIMAL(10,1),  
     RangePoor VARCHAR(4),  
     Poor INT,  
     PoorPercentage DECIMAL(10,1),  
     RangeFair VARCHAR(4),  
     Fair INT,  
     FairPercentage DECIMAL(10,1),  
     RangeUndefined VARCHAR(10),   
     Undefined INT,  
     UndefinedPercentage DECIMAL(10,1),  
     DerivedGoodValue VARCHAR(50),  
     DerivedFairValue VARCHAR(50),  
     DerivedPoorValue VARCHAR(50)  
    )  
      
    INSERT INTO @t_MeasureCount  
    (  
     MeasureId ,  
     MeasureName ,  
     MeasureRangeTotalCount ,  
     RangeGood ,  
     Good ,  
     GoodPercentage ,  
     RangePoor ,  
     Poor ,  
     PoorPercentage ,  
     RangeFair ,  
     Fair ,  
     FairPercentage ,  
     RangeUndefined ,   
     Undefined ,  
     UndefinedPercentage ,  
     DerivedGoodValue ,  
     DerivedFairValue ,  
     DerivedPoorValue   
    )   
    SELECT   
		 MRD.MeasureId ,  
		 MeasureName ,  
		 PER.MeasureRangeTotalCount ,  
		 'Good' AS RangeGood ,  
		 Good ,  
		 CONVERT(DECIMAL(10,1),((Good) * 100.00)/PER.MeasureRangeTotalCount) AS GoodPercentage,  
		 'Poor' AS RangePoor,  
		 Poor,  
		 CONVERT(DECIMAL(10,1),((Poor) * 100.00)/PER.MeasureRangeTotalCount) AS PoorPercentage,  
		 'Fair' AS RangeFair,  
		 Fair,  
		 CONVERT(DECIMAL(10,1),((Fair) * 100.00)/PER.MeasureRangeTotalCount) AS FairPercentage,  
		 'Undefined' AS RangeUndefined,  
		 Undefined,  
		 CONVERT(DECIMAL(10,1),((Undefined) * 100.00)/PER.MeasureRangeTotalCount) AS UndefinedPercentage,  
		 DerivedGoodValue,  
		 DerivedFairValue,  
		 DerivedPoorValue  
    FROM  
		#MeasureRangeDetails MRD   
    INNER JOIN #MeasureRangeControls MRC  
		ON MRD.MeasureId = MRC.MeasureId   
    INNER JOIN #Percentage PER  
		ON PER.MeasureId = MRC.MeasureId    
    ORDER BY MRC.SortOrder   
      
    DECLARE @i_Min INT = 10*@i_NextOrPrevious - 9 ,  
         @i_Max INT = 10*@i_NextOrPrevious  
           
    SELECT   
		 MeasureId,  
		 MeasureName ,  
		 MeasureRangeTotalCount ,  
		 RangeGood ,  
		 Good ,  
		 GoodPercentage ,  
		 RangePoor ,  
		 Poor ,  
		 PoorPercentage ,  
		 RangeFair ,  
		 Fair ,  
		 FairPercentage ,  
		 RangeUndefined ,   
		 Undefined ,  
		 UndefinedPercentage ,  
		 DerivedGoodValue ,  
		 DerivedFairValue ,  
		 DerivedPoorValue   
    FROM   
		@t_MeasureCount  
    WHERE   
		MeasureCountId BETWEEN @i_Min AND @i_Max         
                 
    --SELECT DISTINCT  
    -- MeasureId,  
    -- MeasureName  
    --FROM  
    -- #MeasureRanges   
    --ORDER BY   
    -- MeasureName   
      
		 SELECT ISNULL(CEILING(MAX(MeasureCountId*1.00)/10),1) AS GridCount FROM @t_MeasureCount   
   END  
          
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyPatients_CategoryView_ByMeasure] TO [FE_rohit.r-ext]
    AS [dbo];

