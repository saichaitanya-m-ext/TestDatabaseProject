/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_ACGMedicalServices_Select
Description   : This Procedure used to provide ACGMedicalServices details  
Created By    : NagaBabu
Created Date  : 28-Jan-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION  
07-Mar-2011 NagaBabu Added Cursor to shedule ACGInput files According to ACGSchedule Table 
08-Mar-2011 NagaBabu Replaced #ACGPatients by ACGMedicalServicesProcess in Cursor 
24-Oct-2011 NagaBabu Replaced Claim.CPTCode1 by '' for the field 'Procedure_Code' while Claim table Structure is changed              
21-Feb-2012 NagaBabu Replaced Claim Table by ClaimInfo,ClaimLineICD tables in join statements 
15-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers
------------------------------------------------------------------------------        
*/ -- SELECT * FROM ErrorLog ORDER BY 1 DESC
CREATE PROCEDURE [dbo].[usp_ACGMedicalServices_Select]
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
		DELETE FROM ACGMedicalServicesProcess
		
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
				@d_DateOfNextExport	USERDATE ,
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
		        										   WHEN 'M' THEN DATEADD(MONTH,1,@d_DateOfLastExport) 
		        										   WHEN 'Q' THEN DATEADD(MONTH,3,@d_DateOfLastExport)
		        										   WHEN 'A' THEN DATEADD(YEAR,1,@d_DateOfLastExport)
			        								   END	
			        				           				
				SET @vc_JoinQuerry = CASE @vc_ACGType 
										 WHEN 'F' THEN ''
										 WHEN 'T' THEN 'INNER JOIN CareTeam ON Patients.CareTeamId = CareTeam.CareTeamId INNER JOIN CareTeamMembers ON CareTeamMembers.CareTeamId = CareTeam.CareTeamId'
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
										  ACGMedicalServicesProcess
										  (
											patient_id ,
											ICD_Version_1 ,
											ICD_CD_1 ,
											ICD_Version_2 ,
											ICD_CD_2 ,
											ICD_Version_3 ,
											ICD_CD_3 ,
											ICD_Version_4 ,
											ICD_CD_4 ,
											ICD_Version_5 ,
											ICD_CD_5 ,
											Service_Begin_Date ,
											Service_End_Date ,
											Provider_ID ,
											Provider_Specialty ,
											Provider_Specialty_NPI ,
											Service_place ,
											Revenue_Code ,
											Procedure_Code ,
											Revenue_Code_type ,
											Procedure_Code_Type,
											ACGScheduleID ,
											CareTeamId ,
											ProgramId ,
											PopulationDefinitionId 
										)	
									  SELECT 
										  Patients.MemberNum AS ''patient_id'' ,
										  ''9'' AS ''ICD_Version_1'' ,
										  ClaimLineIcd.ICDCodeId AS ''ICD_CD_1'' ,
										  ''9'' AS ''ICD_Version_2'' ,
										  '''' AS ''ICD_CD_2'' ,
										  ''9'' AS ''ICD_Version_3'' ,
										  ''''AS ''ICD_CD_3'' ,
										  ''9'' AS ''ICD_Version_4'' ,
										  '''' AS ''ICD_CD_4'' ,
										  ''9'' AS ''ICD_Version_5'' ,
										  '''' AS ''ICD_CD_5'' ,
										  CONVERT(VARCHAR(10),ClaimInfo.DateOfAdmit,120) AS ''Service_Begin_Date'' ,
										  CONVERT(VARCHAR(10),ClaimInfo.DateOfDischarge,120) AS ''Service_End_Date'' ,
										  '''' AS ''Provider_ID'' ,
										  '''' AS ''Provider_Specialty'' ,
										  '''' AS ''Provider_Specialty_NPI'' ,
										  ClaimInfo.PlaceOfServiceID AS ''Service_place'' ,
										  ISNULL((SELECT TOP 1 RevenueCode FROM RevenueCode WHERE RevenueCodeID = ClaimLine.RevenueCodeID ),'''') AS ''Revenue_Code'','+ --,
										  --Claim.CPTCode1 AS ''Procedure_Code'' ,
										  '
										  ISNULL((SELECT TOP 1 ProcedureCode FROM CodeSetProcedure WHERE ProcedureId = ClaimLine.ProcedureId),'''') AS ''Procedure_Code'' , 
										  ''UR'' AS ''Revenue_Code_type'' ,
										  ''UM'' AS ''Procedure_Code_Type'' ,'''+ CAST(@i_ACGScheduleID AS VARCHAR(30)) +''',
										  '''+ CAST(@i_CareTeamID AS VARCHAR(30)) +''',	
										  '''+ CAST(@i_ProgramID AS VARCHAR(30)) + ''',
										  '''+ CAST(@i_PopulationDefinitionID AS VARCHAR(30)) + '''									  
									  FROM
										  Patients
									  INNER JOIN ClaimInfo
										  ON Patients.UserId = ClaimInfo.PatientUserID
									  INNER JOIN ClaimLine
										  ON ClaimLine.ClaimInfoID = ClaimInfo.ClaimInfoID 
									  INNER JOIN ClaimLineIcd
										  ON ClaimLineIcd.ClaimInfoID = ClaimInfo.ClaimInfoID 
									  INNER JOIN UserEncounters
										  ON UserEncounters.ClaimInfoID  = ClaimInfo.ClaimInfoID ' + CAST(@vc_JoinQuerry AS VARCHAR(MAX)) + '	
									  WHERE
										  UserStatusCode = ''A''
									  AND ClaimInfo.StatusCode = ''A''' + CAST(@vc_WhereClause AS VARCHAR(MAX)) + --'
									  --AND Claim.CPTCode1 NOT IN (SELECT CPTCode FROM CPTExcludeCodes )
									  --'AND Claim.PlaceOfServiceID NOT IN (11,23,24,25,26,27,28,41,44,45)
									  'AND (ClaimInfo.DateOfAdmit BETWEEN '''+ convert (varchar(10),DATEADD(MONTH,-12,@p_ParamDate),101)  +''' AND '''+ Convert(varchar(10),@p_ParamDate,101) + ''')
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
						print @vc_DynamicQSL
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
            
            UPDATE ACGMedicalServicesProcess
			   SET CareTeamId = NULL
			 WHERE CareTeamId = 0 
			
			UPDATE ACGMedicalServicesProcess
			   SET ProgramId = NULL
			 WHERE ProgramId = 0  
			
			UPDATE ACGMedicalServicesProcess
			   SET CohortListId = NULL
			 WHERE CohortListId = 0     
            
            --SELECT DISTINCT * FROM ACGMedicalServicesProcess
	
END TRY        
----------------------------------------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ACGMedicalServices_Select] TO [FE_rohit.r-ext]
    AS [dbo];

