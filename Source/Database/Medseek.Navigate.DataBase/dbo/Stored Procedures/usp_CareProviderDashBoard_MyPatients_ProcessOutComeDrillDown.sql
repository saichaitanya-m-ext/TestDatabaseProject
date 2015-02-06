
/*  
\------------------------------------------------------------------------------          
Procedure Name: [usp_CareProvider_DashBoard_MyPatients_MeasureRange_ProcessOutComeDrillDown]
Description   : This procedure is used to retrive the Patient information as per Range and Disease wise
Created By    : NagaBabu
Created Date  : 28-Dec-2011
------------------------------------------------------------------------------   
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
01-Mar-2012 NagaBabu Added @d_FromDate,@d_ToDate,@v_InputType,@i_InputTypeId
22-Mar-2012 NagaBabu Modified the functionality to get the patients Adherent,NonAdherent List
05-Apr-2012 NagaBabu diseasepatients filtered condition changerd from 'AND DiagnosedDate BETWEEN @d_FromDate AND @d_ToDate' to 
						'AND DiagnosedDate <= @d_FromDate' 
-------------------------------------------------------------------------------          
*/   
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyPatients_ProcessOutComeDrillDown]
(
  @i_AppUserId KeyID ,
  @i_Disease KeyId ,
  @v_Range VARCHAR(15) ,
  @b_IsCareProvider BIT = 0 ,        --1 Means CareProvider, 0 Means Admin or SysAnalyst 
  @d_FromDate DATETIME ,   
  @d_ToDate DATETIME ,        
  @v_InputType VARCHAR(20) = NULL ,
  @i_InputTypeId KeyID = NULL  
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
	-------------------------------------------------------------------------------------------------------------------


		CREATE TABLE #tblUserDisease 
		(
			UserID INT,
			DiseaseID INT,
			Name VARCHAR(200),
			ProcedureCompletedDate DATETIME ,
			DueDate DATETIME
		)
		IF @b_IsCareProvider = 1
			BEGIN
				INSERT INTO #tblUserDisease 
				SELECT DISTINCT 
					UserProcedureCodes.UserID,
					Disease.DiseaseId,
					Disease.Name ,
					UserProcedureCodes.ProcedureCompletedDate ,
					UserProcedureCodes.DueDate
				FROM 
				    UserDisease 
				INNER JOIN UserPrograms 
					ON UserDisease.UserID = UserPrograms.UserId
					--AND UserDisease.DiagnosedDate BETWEEN @d_FromDate AND @d_ToDate
					AND UserDisease.DiagnosedDate <= @d_FromDate	
				INNER JOIN Disease
					ON  UserDisease.DiseaseId = Disease.DiseaseId
				INNER JOIN ProgramProcedureFrequency
					ON UserPrograms.ProgramId = ProgramProcedureFrequency.ProgramId
					AND ProgramProcedureFrequency.StatusCode = 'A'
				INNER JOIN UserProcedureCodes
					ON ProgramProcedureFrequency.ProcedureId = UserProcedureCodes.ProcedureId
					AND UserProcedureCodes.UserID = UserPrograms.UserId 	
				INNER JOIN Patients 
					on Patients.UserId = UserProcedureCodes.UserID	
				INNER JOIN CareTeamMembers
					ON Patients.CareTeamId = CareTeamMembers.CareTeamId
				INNER JOIN CareTeam
					ON CareTeam.CareTeamId = CareTeamMembers.CareTeamId	
				WHERE 
					  (CareTeamMembers.UserId = @i_AppUserId)
				  AND UserProcedureCodes.DueDate BETWEEN @d_FromDate AND @d_ToDate	  
				  AND UserDisease.DiseaseID = @i_Disease	  
				  AND CareTeam.StatusCode = 'A' 
				  AND CareTeamMembers.StatusCode =  'A' 		   
				  AND Patients.UserStatuscode = 'A' 
				  AND UserProcedureCodes.StatusCode = 'A'
				  		 
			END
		ELSE 
			BEGIN
				INSERT INTO #tblUserDisease 
				SELECT DISTINCT 
					UserProcedureCodes.UserID,
					Disease.DiseaseId,
					Disease.Name ,
					UserProcedureCodes.ProcedureCompletedDate ,
					UserProcedureCodes.DueDate
				FROM 
				    UserDisease 
				INNER JOIN UserPrograms 
					ON UserDisease.UserID = UserPrograms.UserId
					--AND UserDisease.DiagnosedDate BETWEEN @d_FromDate AND @d_ToDate	
					AND UserDisease.DiagnosedDate <= @d_FromDate 
				INNER JOIN Disease
					ON  UserDisease.DiseaseId = Disease.DiseaseId
				INNER JOIN ProgramProcedureFrequency
					ON UserPrograms.ProgramId = ProgramProcedureFrequency.ProgramId
					AND ProgramProcedureFrequency.StatusCode = 'A'
				INNER JOIN UserProcedureCodes
					ON ProgramProcedureFrequency.ProcedureId = UserProcedureCodes.ProcedureId
					AND UserProcedureCodes.UserID = UserPrograms.UserId 	
				INNER JOIN Patients 
					on Patients.UserId = UserProcedureCodes.UserID	
				WHERE 
					 UserDisease.DiseaseID = @i_Disease
				  AND UserProcedureCodes.DueDate BETWEEN @d_FromDate AND @d_ToDate	 
				  AND Patients.UserStatuscode = 'A' 
				  AND UserProcedureCodes.StatusCode = 'A'
				  	 
			END	  

		SELECT
			UserID ,
			DiseaseID ,
			Name ,
			CASE WHEN SUM((CASE  WHEN ProcedureCompletedDate IS NULL AND DueDate IS NOT NULL THEN 1 ELSE 0 END)) > 0 THEN 'NonAdherent' --AS AdherentPatientCount,
				      ELSE 'Adherent'
			END AS Ranges 	 
		INTO #tblUserRanges
		FROM 			      
			#tblUserDisease 
		GROUP BY UserID ,
			DiseaseID ,
			Name 
		
		SELECT 
			  Patients.UserId
			 ,Patients.MemberNum
			 ,Patients.FullName AS PatientName
			 ,Patients.PhoneNumberPrimary
			 ,(
				SELECT
					CallTimeName
				FROM
					CallTimePreference
				WHERE
					CallTimePreferenceId = Patients.CallTimePreferenceId
			  ) AS CallTimePreference
			 ,CONVERT(VARCHAR,Patients.Age) + '/' + Patients.Gender AS AgeAndGender
			 ,(SELECT  TOP 1
				   CONVERT(VARCHAR,ISNULL(ScheduledDate,DateDue),101) 
			   FROM
				   UserEncounters
			   WHERE
				   Userid = TUR.Userid
				   AND StatusCode = 'A'
				   AND EncounterDate IS NULL
			   ORDER BY EncounterDate DESC) AS NextOfficeVisit
			  ,(SELECT  TOP 1
				   ISNULL(CONVERT(VARCHAR, EncounterDate,101),'') 
			   FROM
				   UserEncounters
			   WHERE
				   Userid = TUR.Userid
				   AND StatusCode = 'A'
				   AND EncounterDate IS NOT NULL
			   ORDER BY EncounterDate DESC) AS LastOfficeVisit
			 ,STUFF((
					  SELECT TOP 2
						  ', ' + ProgramName
					  FROM
						  Program
					  INNER JOIN UserPrograms
						  ON UserPrograms.ProgramId = Program.ProgramId
					  WHERE
						  UserPrograms.Userid = TUR.Userid
						  AND UserPrograms.EnrollmentStartDate IS NOT NULL
						  AND UserPrograms.EnrollmentEndDate IS NULL
						  AND UserPrograms.IsPatientDeclinedEnrollment = 0
						  AND Program.StatusCode = 'A'
						  AND UserPrograms.StatusCode = 'A'
					  ORDER BY
						  UserPrograms.EnrollmentStartDate DESC
					  FOR
						  XML PATH('')
					) , 1 , 2 , '') AS ProgramName
			 ,STUFF((
					  SELECT  TOP 2
						  ', ' + Name
					  FROM
						  Disease
					  INNER JOIN UserDisease
						  ON UserDisease.DiseaseId = Disease.DiseaseId
					  WHERE
						  UserDisease.Userid = TUR.Userid
						  AND UserDisease.DiagnosedDate IS NOT NULL
						  AND UserDisease.StatusCode = 'A'
						  AND Disease.StatusCode = 'A'
					  ORDER BY
						  UserDisease.DiagnosedDate DESC
					  FOR
						  XML PATH('')
					) , 1 , 2 , '') AS DiseaseName
			 ,(SELECT 
				   COUNT(ISNULL(CONVERT(VARCHAR,UserPrograms.EnrollmentStartDate,101),'') + ' - ' + ISNULL(Program.ProgramName,'')) 
			   FROM
				   Program
			   INNER JOIN UserPrograms
				   ON UserPrograms.ProgramId = Program.ProgramId
			   WHERE
				   UserPrograms.Userid = TUR.Userid
				   AND UserPrograms.EnrollmentStartDate IS NOT NULL
				   AND UserPrograms.EnrollmentEndDate IS NULL
				   AND UserPrograms.IsPatientDeclinedEnrollment = 0
				   AND Program.StatusCode = 'A'
				   AND UserPrograms.StatusCode = 'A'
			  ) AS ProgramCount 
			 ,(SELECT 
				   COUNT(Disease.DiseaseId) 
			   FROM
				   Disease
			   INNER JOIN UserDisease
				   ON UserDisease.DiseaseId = Disease.DiseaseId
			   WHERE
				   UserDisease.Userid = TUR.Userid
				   AND UserDisease.DiagnosedDate IS NOT NULL
				   AND UserDisease.StatusCode = 'A'
				   AND Disease.StatusCode = 'A'
			  ) AS DiseaseCount
		FROM
			#tblUserRanges TUR
		INNER JOIN Patients
			ON TUR.UserID = Patients.UserId
		WHERE TUR.Ranges = @v_Range				
			
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyPatients_ProcessOutComeDrillDown] TO [FE_rohit.r-ext]
    AS [dbo];

