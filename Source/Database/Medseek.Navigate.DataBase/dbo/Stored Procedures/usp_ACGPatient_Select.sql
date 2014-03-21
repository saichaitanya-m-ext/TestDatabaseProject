/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_ACGPatient_Select]
Description   : This Procedure used to provide ACGPatient details  
Created By    : NagaBabu
Created Date  : 28-Jan-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
16-Feb-2011 Rathnam Removed the age caliculation part and kept directly as age column from patient view.
07-Mar-2011 NagaBabu Added Cursor to shedule ACGInput files According to ACGSchedule Table
08-Mar-2011 NagaBabu Replaced #ACGPatients by ACGPatientsProcess 
24-OCT-2011 NagaBabu Added Distinct Keyword in select statement 
23-Nov-2011 NagaBabu Added field names for PCP_ID,PCP_Name Fields    
15-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers         
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_ACGPatient_Select]
(  
   @i_AppUserId KEYID
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
--------------------------------------------------------------------
		DELETE FROM ACGPatientsProcess
		
		DECLARE @i_ACGScheduleID KeyID ,
				@vc_ACGType VARCHAR(1) ,
				@i_ACGSubTypeID KeyID ,
				@vc_Frequency VARCHAR(1) ,
				@d_StartDate USERDATE ,
				@d_DateOfLastExport USERDATE ,
				@d_DateOfLastImport USERDATE ,
				@p_ParamDate DATE = GETDATE() ,
				@vc_DynamicQSL VARCHAR(MAX) ,
				@vc_JoinQuerry VARCHAR(MAX) ,
				@vc_WhereClause VARCHAR(MAX),
				@d_DateOfNextExport	USERDATE,
				@i_CareTeamID VARCHAR(10) ,
				@i_PopulationDefinitionID VARCHAR(10) ,
				@i_ProgramID VARCHAR(10) 
				
		DECLARE CurACGSchedule CURSOR
			FOR SELECT 
					ACGScheduleID ,
					ACGType ,
					ACGSubTypeID ,
					Frequency ,
					CONVERT(VARCHAR(10),StartDate,101) ,
					CONVERT(VARCHAR(10),DateOfLastExport,101) ,
					DateOfLastImport
				FROM
					ACGSchedule	
				WHERE
					StatusCode = 'A'
		
		OPEN CurACGSchedule
		FETCH NEXT FROM CurACGSchedule
					INTO @i_ACGScheduleID ,
						 @vc_ACGType ,
						 @i_ACGSubTypeID ,
						 @vc_Frequency ,
						 @d_StartDate ,
						 @d_DateOfLastExport ,
					 	 @d_DateOfLastImport 
					 	 
			 	 
		WHILE @@FETCH_STATUS = 0
			BEGIN
			    
						 	 
				SET @d_DateOfNextExport	= CASE  @vc_Frequency 
														   WHEN 'O' THEN NULL
														   WHEN 'W' THEN DATEADD(DAY,7,@d_DateOfLastExport)
		        										   WHEN 'M' THEN DATEADD(MONTH,1,@d_DateOfLastExport) 
		        										   WHEN 'Q' THEN DATEADD(MONTH,3,@d_DateOfLastExport)
		        										   WHEN 'A' THEN DATEADD(YEAR,1,@d_DateOfLastExport)
			        								   END	
			    
			    SET @vc_JoinQuerry = CASE @vc_ACGType 
										 WHEN 'F' THEN ''
										 WHEN 'T' THEN 'INNER JOIN CareTeam ON Patients.CareTeamId = CareTeam.CareTeamId INNER JOIN CareTeamMembers ON CareTeamMembers.CareTeamId = CareTeam.CareTeamId '
										 WHEN 'C' THEN 'INNER JOIN CohortListUsers ON Patients.UserId = CohortListUsers.UserId ' 
										 WHEN 'P' THEN 'INNER JOIN UserPrograms ON Patients.UserId = UserPrograms.UserId '
									 END
									 
				SET @vc_WhereClause = CASE @vc_ACGType 
										  WHEN 'F' THEN ''
										  WHEN 'T' THEN 'AND CareTeamMembers.StatusCode = ''A'' AND CareTeam.StatusCode = ''A'' AND CareTeamMembers.CareTeamId = ' + CAST(@i_ACGSubTypeID AS VARCHAR(10)) 
										  WHEN 'C' THEN 'AND CohortListUsers.StatusCode = ''A'' AND PopulationDefinitionUsers.PopulationDefinitionId = ' + CAST(@i_ACGSubTypeID AS VARCHAR(10)) 
										  WHEN 'P' THEN 'AND UserPrograms.StatusCode = ''A'' AND UserPrograms.ProgramId = ' + CAST(@i_ACGSubTypeID AS VARCHAR(10))
									  END
    			
    			SET @i_CareTeamID = CASE @vc_ACGType
										WHEN 'T' THEN @i_ACGSubTypeID
										ELSE ''
									END
				
				SET @i_PopulationDefinitionID = CASE @vc_ACGType
										WHEN 'C' THEN @i_ACGSubTypeID
										ELSE ''
									END
							
				SET @i_ProgramID = CASE @vc_ACGType
										WHEN 'P' THEN @i_ACGSubTypeID
										ELSE ''
									END										
    				           				
				SET @vc_DynamicQSL = 'INSERT INTO	
										  ACGPatientsProcess
										  (
											patient_id ,
											Age ,
											Sex ,
											Line_of_Business ,
											Company ,
											Product ,
											Employer_Group_ID ,
											Employer_Group_Name ,
											Benefit_Plan ,
											Health_System ,
											PCP_ID ,
											PCP_Name ,
											PCP_Group_Name ,
											Pregnant ,
											Delivered ,
											Low_Birthweight ,
											Total_Cost ,
											Pharmacy_Cost ,
											Inpatient_hospitalization_Count ,
											Emergency_Visit_Count ,
											OutPatient_Visit_Count ,
											Dialysis_Service ,
											Nursing_Service ,
											Major_Procedure ,
											ACGScheduleID ,
											CareTeamId ,
											ProgramId ,
											PopulationDefinitionId 
										)	
									  SELECT DISTINCT
										  MemberNum AS ''patient_id'' ,
										  Age AS ''Age'' ,
										  Gender AS ''Sex'' ,
										  ''''AS ''Line_of_Business'' ,
										  ''''AS ''Company'' ,
										  ''''AS ''Product'' ,
										  ''''AS ''Employer_Group_ID'' ,
										  ''''AS ''Employer_Group_Name'' ,
										  ''''AS ''Benefit_Plan'' ,
										  ''''AS ''Health_System'' ,
										  Patients.PCPId AS ''PCP_ID'' ,
										  dbo.ufn_GetPCPName(Patients.PCPId) AS ''PCP_Name'' ,
										  ''''AS ''PCP_Group_Name'' ,
										  ''0''AS ''Pregnant'' ,
										  ''0''AS ''Delivered'' ,
										  ''0''AS ''Low_Birthweight'' ,
										  ''''AS ''Total_Cost'' ,
										  ''''AS ''Pharmacy_Cost'' ,
										  ''''AS ''Inpatient_hospitalization_Count'' ,
										  ''''AS ''Emergency_Visit_Count'' ,
										  ''''AS ''OutPatient_Visit_Count'' ,
										  ''''AS ''Dialysis_Service'' ,
										  ''''AS ''Nursing_Service'' ,
										  ''''AS ''Major_Procedure'','''+ CAST(@i_ACGScheduleID AS VARCHAR(30)) +''',
										  '''+ CAST(@i_CareTeamID AS VARCHAR(30)) +''',	
										  '''+ CAST(@i_ProgramID AS VARCHAR(30)) + ''',
										  '''+ CAST(@i_PopulationDefinitionID AS VARCHAR(30)) + '''									  
									  FROM
										  Patients ' + CAST(@vc_JoinQuerry AS VARCHAR(MAX)) + '	
									  WHERE
										  UserStatusCode = ''A''
									  AND MemberNum <> ''''' + CAST(@vc_WhereClause AS VARCHAR(MAX)) + '
									  ORDER BY 
										  Patients.MemberNum'	
								  
  
				IF ((@d_StartDate IS NOT NULL 
					 AND @d_StartDate <= GETDATE()
					 AND @d_DateOfLastExport IS NULL 
					) 
					OR 
				    (@d_DateOfLastExport IS NOT NULL 
					 AND @d_DateOfNextExport <= GETDATE()
					) 
				   )
				  BEGIN
				
					  EXEC (@vc_DynamicQSL)	  
				  END
				 
				FETCH NEXT FROM CurACGSchedule
					INTO @i_ACGScheduleID ,
						 @vc_ACGType ,
						 @i_ACGSubTypeID ,
						 @vc_Frequency ,
						 @d_StartDate ,
						 @d_DateOfLastExport ,
					 	 @d_DateOfLastImport  
			
			END	 	
            CLOSE CurACGSchedule
            DEALLOCATE CurACGSchedule
            
            UPDATE ACGPatientsProcess
			   SET CareTeamId = NULL
			 WHERE CareTeamId = 0 
			
			UPDATE ACGPatientsProcess
			   SET ProgramId = NULL
			 WHERE ProgramId = 0  
			
			UPDATE ACGPatientsProcess
			   SET CohortListId = NULL
			 WHERE CohortListId = 0     
            
            --SELECT DISTINCT * FROM ACGPatientsProcess 	
    
END TRY        
----------------------------------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ACGPatient_Select] TO [FE_rohit.r-ext]
    AS [dbo];

