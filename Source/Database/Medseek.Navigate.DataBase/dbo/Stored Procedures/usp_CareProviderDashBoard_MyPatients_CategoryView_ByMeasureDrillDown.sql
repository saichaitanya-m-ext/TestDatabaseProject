
/*      
--------------------------------------------------------------------------------------------------------------      
Procedure Name: [usp_CareProviderDashBoard_MyPatients_CategoryView_ByMeasureDrillDown]226658,6,4,'1M',Undefined,0  
Description   : This Procedre use to get Patient Information For a Specific Range of Specific Measure  
Created By    : 02-Aug-2011  
Created Date  : NagaBabu  
---------------------------------------------------------------------------------------------------------------      
Log History   :       
DD-Mon-YYYY  BY  DESCRIPTION    
03-Aug-2011 NagaBabu Deleted 'AND (ISNULL(Patients.IsDeceased,0) = 0 OR Patients.EndDate IS NULL)' condition from   
      first select statement and Return statement in Catch block and Added Measure field in resultset  
10-Aug-2011 NagaBabu Added @b_IsDiseaseDistribution Parameter and replaced @i_MeasureId as @i_DiseaseMeasureId for   
      getting DiseaseDistribution also        
16-Aug-2011 NagaBabu Added ProcedureCode,ICDCode fields to the resultset   
18-Nov-2011 Pramod Changed the join to comment userdisease, disease and included userdiagnosis, Included TOP 50 for the select queries
for #DiseaseMembers MR, Included SELECT DISTINCT into the Insert INTO #DiseaseMembers
27-Feb-2012 NagaBabu Added CASE Condition for PhoneNumberPrimary field as per demo purpose nedd to remove later 
15-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers 
11-Dec-2012 Mohan Removed statuscodes
---------------------------------------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyPatients_CategoryView_ByMeasureDrillDown]  
(  
    @i_AppUserId KEYID ,  
    @i_PopulationDefinitionID KEYID ,  
    @i_DiseaseMeasureId KEYID ,  
    @v_DatePeriod VARCHAR(3) ,  
    @v_Range VARCHAR(10) ,  
    @b_IsDiseaseDistribution BIT   
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
    SELECT DISTINCT 
		 Patients.UserId ,  
		 Patients.MemberNum ,  
		 Patients.FullName ,  
		 Patients.Age ,  
		 Patients.Gender AS Sex ,  
		 Patients.PhoneNumberPrimary ,  
		 Patients.CallTimePreferenceId ,  
		 --Disease.DiseaseId ,  
		 --Disease.Name AS DiseaseName  
		 CodeSetICD.ICDCodeId AS DiseaseId,
		 CodeSetICD.ICDDescription AS DiseaseName
    INTO   
		 #DiseaseMembers   
    FROM   
		PopulationDefinition  
    INNER JOIN PopulationDefinitionUsers  
		ON PopulationDefinition.PopulationDefinitionID = PopulationDefinitionUsers.PopulationDefinitionID  
    INNER JOIN UserDiagnosisCodes
		ON UserDiagnosisCodes.UserId = PopulationDefinitionUsers.UserId
	INNER JOIN CodeSetICD
		ON CodeSetICD.ICDCodeId = UserDiagnosisCodes.DiagnosisId
    INNER JOIN Patients  
		ON Patients.UserId = PopulationDefinitionUsers.UserId  
    INNER JOIN CareTeamMembers   
		ON CareTeamMembers.CareTeamId = Patients.CareTeamId  
    INNER JOIN CareTeam  
		ON CareTeamMembers.CareTeamId = CareTeam.CareTeamId  
    WHERE   
		CareTeamMembers.UserId = @i_AppUserId  
    AND PopulationDefinition.PopulationDefinitionID = @i_PopulationDefinitionID 
    --AND UserDisease.DiseaseId = @i_DiseaseMeasureId  
    AND UserDiagnosisCodes.DiagnosisId = @i_DiseaseMeasureId  
    AND CareTeamMembers.StatusCode = 'A'  
    AND CareTeam.StatusCode = 'A'  
    AND PopulationDefinitionUsers.StatusCode = 'A'         
    AND Patients.UserStatusCode = 'A'   
    --AND UserDisease.StatusCode = 'A'  
      
    SELECT TOP 50 
		 UserId ,  
		 MemberNum ,  
		 FullName ,  
		 Age ,  
		 Sex ,  
		 CASE WHEN PhoneNumberPrimary IS NOT NULL THEN PhoneNumberPrimary
			  WHEN PhoneNumberPrimary = '' THEN '0'
			  ELSE '0'
		 END AS PhoneNumberPrimary ,	      
		 --PhoneNumberPrimary,  
		 ( SELECT  
			CallTimeName  
		   FROM  
			CallTimePreference  
		   WHERE  
			CallTimePreferenceId = MR.CallTimePreferenceId  
		 ) AS CallTimePreference ,  
		 (SELECT  TOP 1  
		   CONVERT(VARCHAR,ISNULL(ScheduledDate,DateDue),101)   
		  FROM  
		   UserEncounters  
		  WHERE  
		   Userid = MR.Userid  
		   AND StatusCode = 'A'  
		   AND EncounterDate IS NULL  
		  ORDER BY EncounterDate DESC) AS NextOfficeVisit ,  
		 (SELECT  TOP 1  
		   ISNULL(CONVERT(VARCHAR, EncounterDate,101),'')   
		  FROM  
		   UserEncounters  
		  WHERE  
		   Userid = MR.Userid  
		  AND StatusCode = 'A'  
		  AND EncounterDate IS NOT NULL  
		  ORDER BY EncounterDate DESC) AS LastOfficeVisit ,  
		  STUFF(( SELECT TOP 2  
			 ', ' + ProgramName  
			FROM  
			 Program  
			INNER JOIN UserPrograms  
			 ON UserPrograms.ProgramId = Program.ProgramId  
			WHERE  
			 UserPrograms.Userid = MR.Userid  
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
		  STUFF(( SELECT  TOP 2  
			 ', ' + Name  
			FROM  
			 Disease  
			INNER JOIN UserDisease  
			 ON UserDisease.DiseaseId = Disease.DiseaseId  
			WHERE  
			 UserDisease.Userid = MR.Userid  
			 AND UserDisease.DiagnosedDate IS NOT NULL  
			 AND UserDisease.StatusCode = 'A'  
			 AND Disease.StatusCode = 'A'  
			ORDER BY  
			 UserDisease.DiagnosedDate DESC  
			FOR  
			 XML PATH('')  
			 ) , 1 , 2 , '') AS DiseaseName ,  
		  (SELECT  
			COUNT(DISTINCT Program.ProgramId)  
		   FROM  
			Program  
		   INNER JOIN UserPrograms  
			ON UserPrograms.ProgramId = Program.ProgramId  
		   WHERE  
			UserPrograms.Userid = MR.Userid  
			AND UserPrograms.EnrollmentStartDate IS NOT NULL  
			AND UserPrograms.EnrollmentEndDate IS NULL  
			AND UserPrograms.IsPatientDeclinedEnrollment = 0  
			AND Program.StatusCode = 'A'  
			AND UserPrograms.StatusCode = 'A'  
		  ) AS ProgramCount ,  
		  ( SELECT  
			 COUNT(DISTINCT Disease.DiseaseId)  
			FROM  
			 Disease  
			INNER JOIN UserDisease  
			 ON UserDisease.DiseaseId = Disease.DiseaseId  
			WHERE  
			 UserDisease.Userid = MR.Userid  
			 AND UserDisease.DiagnosedDate IS NOT NULL  
			 AND UserDisease.StatusCode = 'A'  
			 AND Disease.StatusCode = 'A'   
		  ) AS DiseaseCount   
		INTO   
		    #DiseseDetails     
		FROM   
		    #DiseaseMembers MR   
	       
		 SELECT
			 UserId ,  
			 MemberNum ,  
			 FullName ,  
			 CAST(Age AS VARCHAR) + '/' + Sex AS AgeAndGender ,
			 CASE WHEN PhoneNumberPrimary IS NOT NULL THEN PhoneNumberPrimary
				  WHEN PhoneNumberPrimary = '' THEN '0'
				  ELSE '0' 
			 END AS PhoneNumberPrimary ,  
			 --PhoneNumberPrimary,  
			 CallTimePreference ,  
			 NextOfficeVisit ,  
			 LastOfficeVisit ,  
			 ProgramName + '[' + CAST(ProgramCount AS VARCHAR) + ']' AS ProgramName ,  
			 DiseaseName + '[' + CAST(DiseaseCount AS VARCHAR) + ']' AS DiseaseName ,   
			   (SELECT   
			  TOP 1 ICDCodeId   
			 FROM   
			  UserDiagnosisCodes  
			 INNER JOIN CodeSetICD   
			  ON CodeSetICD.ICDCodeId = UserDiagnosisCodes.DiagnosisId  
			 WHERE UserId = DID.Userid  
			   AND DateDiagnosed = DID.LastOfficeVisit  
			   --AND CodeSetICD.StatusCode = 'A'  
			   AND UserDiagnosisCodes.StatusCode = 'A') AS ICDCode ,  
			   (SELECT   
			  TOP 1 CodeSetProcedure.ProcedureId   
		 FROM   
			UserProcedureCodes   
		 INNER JOIN CodeSetProcedure   
			ON CodeSetProcedure.ProcedureId = UserProcedureCodes.ProcedureId  
		 WHERE UserId = DID.Userid  
		   AND ProcedureCompletedDate = DID.LastOfficeVisit  
		   --AND CodeSetProcedure.StatusCode = 'A'  
		   AND UserProcedureCodes.StatusCode = 'A') AS ProcedureCode    
		FROM  
			#DiseseDetails DID   
		ORDER BY   
			FullName   
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
		 Patients.UserId ,  
		 Patients.MemberNum ,  
		 Patients.FullName ,  
		 Patients.Age ,  
		 Patients.Gender AS Sex ,  
		 Patients.PhoneNumberPrimary ,  
		 Patients.CallTimePreferenceId ,  
		 Measure.MeasureId ,  
		 Measure.Name AS MeasureName ,  
		 UserMeasureRange.MeasureRange ,  
		 ISNULL(CAST(UserMeasure.MeasureValueNumeric AS VARCHAR),UserMeasure.MeasureValueText) AS Measure  
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
    AND UserMeasureRange.MeasureRange = @v_Range  
    AND UserMeasure.MeasureId = @i_DiseaseMeasureId  
    AND ((UserMeasure.DateTaken BETWEEN @d_FromDate AND @d_ToDate) OR (@d_FromDate IS NULL AND @d_ToDate IS NULL))    
    AND CareTeamMembers.StatusCode = 'A'  
    AND CareTeam.StatusCode = 'A'  
    AND PopulationDefinitionUsers.StatusCode = 'A'         
    AND Patients.UserStatusCode = 'A'   
    AND UserMeasure.StatusCode = 'A'   
      
    SELECT  
		 UserId ,  
		 MemberNum ,  
		 FullName ,  
		 Age ,  
		 Sex ,  
		 CASE WHEN PhoneNumberPrimary IS NOT NULL THEN PhoneNumberPrimary
			  WHEN PhoneNumberPrimary = '' THEN '0'
			  ELSE '0' 
		 END AS PhoneNumberPrimary ,  
		 --PhoneNumberPrimary ,  
		 ( SELECT  
			CallTimeName  
		   FROM  
			CallTimePreference  
		   WHERE  
			CallTimePreferenceId = MR.CallTimePreferenceId  
		 ) AS CallTimePreference ,  
		 (SELECT  TOP 1  
		   CONVERT(VARCHAR,ISNULL(ScheduledDate,DateDue),101)   
		  FROM  
		   UserEncounters  
		  WHERE  
		   Userid = MR.Userid  
		   AND StatusCode = 'A'  
		   AND EncounterDate IS NULL  
		  ORDER BY EncounterDate DESC) AS NextOfficeVisit ,  
		 (SELECT  TOP 1  
		   ISNULL(CONVERT(VARCHAR, EncounterDate,101),'')   
		  FROM  
		   UserEncounters  
		  WHERE  
		   Userid = MR.Userid  
		  AND StatusCode = 'A'  
		  AND EncounterDate IS NOT NULL  
		  ORDER BY EncounterDate DESC) AS LastOfficeVisit ,  
		  STUFF(( SELECT TOP 2  
			 ', ' + ProgramName  
			FROM  
			 Program  
			INNER JOIN UserPrograms  
			 ON UserPrograms.ProgramId = Program.ProgramId  
			WHERE  
			 UserPrograms.Userid = MR.Userid  
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
		  STUFF(( SELECT  TOP 2  
			 ', ' + Name  
			FROM  
			 Disease  
			INNER JOIN UserDisease  
			 ON UserDisease.DiseaseId = Disease.DiseaseId  
			WHERE  
			 UserDisease.Userid = MR.Userid  
			 AND UserDisease.DiagnosedDate IS NOT NULL  
			 AND UserDisease.StatusCode = 'A'  
			 AND Disease.StatusCode = 'A'  
			ORDER BY  
			 UserDisease.DiagnosedDate DESC  
			FOR  
			 XML PATH('')  
			 ) , 1 , 2 , '') AS DiseaseName ,  
		  (SELECT  
			COUNT(DISTINCT Program.ProgramId)  
		   FROM  
			Program  
		   INNER JOIN UserPrograms  
			ON UserPrograms.ProgramId = Program.ProgramId  
		   WHERE  
			UserPrograms.Userid = MR.Userid  
			AND UserPrograms.EnrollmentStartDate IS NOT NULL  
			AND UserPrograms.EnrollmentEndDate IS NULL  
			AND UserPrograms.IsPatientDeclinedEnrollment = 0  
			AND Program.StatusCode = 'A'  
			AND UserPrograms.StatusCode = 'A'  
		  ) AS ProgramCount ,  
		  ( SELECT  
			 COUNT(DISTINCT Disease.DiseaseId)  
			FROM  
			 Disease  
			INNER JOIN UserDisease  
			 ON UserDisease.DiseaseId = Disease.DiseaseId  
			WHERE  
			 UserDisease.Userid = MR.Userid  
			 AND UserDisease.DiagnosedDate IS NOT NULL  
			 AND UserDisease.StatusCode = 'A'  
			 AND Disease.StatusCode = 'A'   
		  ) AS DiseaseCount ,  
		  CASE Measure  
		  WHEN '' THEN 'NoResult'  
		  ELSE Measure  
		  END AS Measure    
    INTO   
		 #PatientDetails               
    FROM   
		 #MeasureRanges MR   
      
    SELECT  
		 UserId ,  
		 MemberNum ,  
		 FullName ,  
		 CAST(Age AS VARCHAR) + '/' + Sex AS AgeAndGender , 
		 CASE WHEN PhoneNumberPrimary IS NOT NULL THEN PhoneNumberPrimary
			  WHEN PhoneNumberPrimary = '' THEN '0'
			  ELSE '0' 
		 END AS PhoneNumberPrimary ,  
		 --PhoneNumberPrimary ,  
		 CallTimePreference ,  
		 NextOfficeVisit ,  
		 LastOfficeVisit ,  
		 ProgramName + '[' + CAST(ProgramCount AS VARCHAR) + ']' AS ProgramName ,  
		 DiseaseName + '[' + CAST(DiseaseCount AS VARCHAR) + ']' AS DiseaseName ,  
		 Measure ,  
		 (SELECT   
		  TOP 1 ICDCodeId   
		 FROM   
		  UserDiagnosisCodes  
		 INNER JOIN CodeSetICD   
		  ON CodeSetICD.ICDCodeId = UserDiagnosisCodes.DiagnosisId  
		 WHERE UserId = PD.Userid  
		   AND DateDiagnosed = PD.LastOfficeVisit  
		   --AND CodeSetICD.StatusCode = 'A'  
		   AND UserDiagnosisCodes.StatusCode = 'A') AS ICDCode ,  
		   (SELECT   
		  TOP 1 CodeSetProcedure.ProcedureId   
		 FROM   
		  UserProcedureCodes   
		 INNER JOIN CodeSetProcedure   
		  ON CodeSetProcedure.ProcedureId = UserProcedureCodes.ProcedureId  
		 WHERE UserId = PD.Userid  
		   AND ProcedureCompletedDate = PD.LastOfficeVisit  
		   --AND CodeSetProcedure.StatusCode = 'A'  
		   AND UserProcedureCodes.StatusCode = 'A') AS ProcedureCode    
    FROM  
		#PatientDetails PD  
    ORDER BY   
		FullName  
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyPatients_CategoryView_ByMeasureDrillDown] TO [FE_rohit.r-ext]
    AS [dbo];

