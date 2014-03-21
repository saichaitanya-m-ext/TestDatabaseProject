/*  
\------------------------------------------------------------------------------          
Procedure Name: [usp_CareProvider_DashBoard_MyPatients_MeasureRange_ProcessOutCome]
Description   : This proc is used to retrive the Disease Wise adherent and nonadherent percentages of patients
Created By    : Sivakrishna
Created Date  : 26-dec-2011
------------------------------------------------------------------------------   
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
01-Mar-2012 NagaBabu Added @d_FromDate,@d_ToDate,@v_InputType,@i_InputTypeId
22-Mar-2012 NagaBabu Modified the functionality to get the patients Adherent,NonAdherent List
05-Apr-2012 NagaBabu diseasepatients filtered condition changerd from 'AND DiagnosedDate BETWEEN @d_FromDate AND @d_ToDate' to 
						'AND DiagnosedDate <= @d_FromDate' 
-------------------------------------------------------------------------------

DECLARE @tDisease AS tDisease

Insert INTO @tDisease(SerialId,DiseaseId) SELECT 1,21
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 2,16
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 3,6
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 4,35
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 5,20
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 6,8
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 7,26
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 8,19
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 9,34
Insert INTO @tDisease(SerialId,DiseaseId) SELECT 10,25
Exec usp_CareProviderDashBoard_MyPatients_ProcessOutCome @i_AppUserId = 23,@t_Disease =  @tDisease,@b_IsCareProvider = 1
*/
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyPatients_ProcessOutCome] 
(
  @i_AppUserId KeyID ,
  @t_Disease tDisease  READONLY,
  @b_IsCareProvider BIT = 0 ,  --1 Means CareProvider, 0 Means Admin or SysAnalyst 
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


	DECLARE @i_NoOfPatientsForUser INT
    CREATE TABLE #tblUserDisease 
		(
		UserID INT,
		DiseaseID INT,
		Name VARCHAR(200),
		ProcedureCompletedDate DATETIME,
		DueDate DATETIME
		)
		IF @b_IsCareProvider = 1
			BEGIN
				INSERT INTO #tblUserDisease 
				SELECT DISTINCT 
					UserProcedureCodes.UserID,
					tDisease.DiseaseId,
					Disease.Name,
					UserProcedureCodes.ProcedureCompletedDate,
					UserProcedureCodes.DueDate 
				FROM 
				    @t_Disease tDisease
				INNER JOIN UserDisease 
					ON UserDisease.DiseaseID = tDisease.DiseaseId
					--AND UserDisease.DiagnosedDate BETWEEN @d_FromDate AND @d_ToDate	
					AND UserDisease.DiagnosedDate <= @d_FromDate 
				INNER JOIN UserPrograms 
					ON UserDisease.UserID = UserPrograms.UserId
				INNER JOIN Disease
					ON  tDisease.DiseaseId = Disease.DiseaseId
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
				  AND CareTeam.StatusCode = 'A' 
				  AND CareTeamMembers.StatusCode =  'A' 		   
				  AND Patients.UserStatuscode = 'A' 
				  AND UserProcedureCodes.StatusCode = 'A'
				  AND Disease.StatusCode = 'A'		 
				 
			END
		ELSE 
			BEGIN
				INSERT INTO #tblUserDisease 
				SELECT DISTINCT 
					UserProcedureCodes.UserID,
					tDisease.DiseaseId,
					Disease.Name,
					UserProcedureCodes.ProcedureCompletedDate,
					UserProcedureCodes.DueDate 
				FROM 
				    @t_Disease tDisease
				INNER JOIN UserDisease 
					ON UserDisease.DiseaseID = tDisease.DiseaseId
					--AND UserDisease.DiagnosedDate BETWEEN @d_FromDate AND @d_ToDate
					AND UserDisease.DiagnosedDate <= @d_FromDate	
				INNER JOIN UserPrograms 
					ON UserDisease.UserID = UserPrograms.UserId
				INNER JOIN Disease
					ON  tDisease.DiseaseId = Disease.DiseaseId
				INNER JOIN ProgramProcedureFrequency
					ON UserPrograms.ProgramId = ProgramProcedureFrequency.ProgramId
					AND ProgramProcedureFrequency.StatusCode = 'A'
				INNER JOIN UserProcedureCodes
					ON ProgramProcedureFrequency.ProcedureId = UserProcedureCodes.ProcedureId
					AND UserProcedureCodes.UserID = UserPrograms.UserId 	
				INNER JOIN Patients 
					on Patients.UserId = UserProcedureCodes.UserID	
				WHERE UserProcedureCodes.DueDate BETWEEN @d_FromDate AND @d_ToDate	
				  AND Patients.UserStatuscode = 'A' 
				  AND UserProcedureCodes.StatusCode = 'A'
				  AND Disease.StatusCode = 'A'		 
				  
			END	  
		
			CREATE TABLE #tblUserDisease1 
			(
				DiseaseId INT,
				DiseaseName VARChar(150),
				UserID INT,
				ProcessRange VARCHAR(15) ,
				--AdherentPatientCount INT,
				--NonAdherentPatientCount INT,
				SerialId INT
			)
			
			INSERT INTO #tblUserDisease1
			SELECT 
				  td.DiseaseId,
				  dm.Name,
				  UserID,
				  CASE WHEN SUM((CASE  WHEN dm.ProcedureCompletedDate IS NULL AND dm.DueDate IS NOT NULL THEN 1 ELSE 0 END)) > 0 THEN 'NonAdherent' --AS AdherentPatientCount,
				      ELSE 'Adherent'
				  END AS ProcessRange ,    
				  td.SerialId
			FROM 			 
				 @t_Disease td   
			INNER JOIN  #tblUserDisease Dm
				 ON  td.DiseaseID = dm.DiseaseID
			GROUP BY  dm.Name,td.DiseaseID,
			          td.SerialId,UserID

			CREATE TABLE #tblProcessDisease
			(
				DiseaseId INT,
				DiseaseName VARChar(150),
				--UserID INT ,
				AdherentPatientCount INT,
				NonAdherentPatientCount INT,
				SerialId INT
			)
			
			INSERT INTO #tblProcessDisease
			SELECT
				DiseaseId ,
				DiseaseName ,
				--UserID ,
				SUM(CASE ProcessRange WHEN 'Adherent' THEN 1 ELSE 0 END) AS AdherentPatientCount ,
				SUM(CASE ProcessRange WHEN 'NonAdherent' THEN 1 ELSE 0 END) AS NonAdherentPatientCount ,
				SerialId
			FROM 
				#tblUserDisease1
			GROUP BY 
				DiseaseId ,
				DiseaseName	,
				SerialId 			
			
			INSERT INTO #tblProcessDisease
			SELECT 	
				td.DiseaseId,
				ds.Name,    
				----0,
				0,
				0,
				td.SerialId
			FROM 			 
				@t_Disease td 
			INNER JOIN Disease ds
				ON td.DiseaseId = ds.DiseaseId  
			WHERE NOT EXISTS(SELECT 1 
							 FROM #tblUserDisease1 tud 
							 WHERE tud.DiseaseId = td.DiseaseId
							 )
							 
										 
			
			SELECT td1.DiseaseId,
					td1.DiseaseName,
				   DCount.PatientCount,
				   td1.AdherentPatientCount,
				   CONVERT(VARCHAR,CONVERT(DECIMAL(10,1),ISNULL(((ISNULL(td1.AdherentPatientCount,0))*100.0/NULLIF(DCount.PatientCount,0)),0))) AS AdherentPercentage,
				   td1.NonAdherentPatientCount,
				  CONVERT(VARCHAR,CONVERT(DECIMAL(10,1),ISNULL(((ISNULL(td1.NonAdherentPatientCount,0))*100.0/NULLIF(DCount.PatientCount,0)),0))) AS NonAdherentPercentage
			  FROM 
				  #tblProcessDisease td1
			  INNER JOIN (SELECT COUNT(DiseaseId)AS PatientCount,
								 DiseaseId
						  FROM #tblUserDisease1
						  GROUP BY DiseaseId ) DCount
			  ON DCount.DiseaseId = td1.DiseaseId			  
			ORDER BY td1.SerialId 

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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyPatients_ProcessOutCome] TO [FE_rohit.r-ext]
    AS [dbo];

