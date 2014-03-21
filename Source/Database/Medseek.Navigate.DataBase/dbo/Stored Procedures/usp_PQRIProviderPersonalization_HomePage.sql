/*    
------------------------------------------------------------------------------    
Procedure Name: usp_PQRIProviderPersonalization_HomePage
Description   : This procedure is used to get the patients of a Particular Provider Personalization
Created By    : Rathnam
Created Date  : 08-Jan-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
10-Feb-2011 Rathnam Replaced the Claimnum by claimid from PqriproviderUserencounter table according the sp modified 
15-Feb-2011 Rathnam added update statements and transactions 
15-Dec-2011 NagaBabu 'IF EXISTS ( SELECT 1 FROM @tblPQRIQMGID )' Condition taken out of Cursor while reducing execution time
27-Dec-2011 Rathnam added order by clause on ORDER BY 'Patient Name'	
30-dec-2011 Sivakrishna added join conditions with the claim tables (ClaimInfo,ClaimLine) 
12-Mar-2012 NagaBabu Added JOIN Statement with ClaimLineIcd table in dynamic Sqls  
14-June-2012 Rathnam modified the stored procedure as per new claim structure
------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[usp_PQRIProviderPersonalization_HomePage]
       (
        @i_AppUserId KEYID
       ,@i_ProviderUserID INT 
       ,@i_ReportingYear SMALLINT
       ,@v_EncounterStatus VARCHAR(10) = NULL
       ,@d_DateOfServiceTo DATETIME = NULL
       ,@d_DateOfServiceFrom DATETIME = NULL
       ,@v_PatientName VARCHAR(50) = NULL
       ,@v_MemberNum VARCHAR(50) = NULL
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

      IF NOT EXISTS ( SELECT
                          1
                      FROM
                          PQRIProviderUserEncounter
                      INNER JOIN PQRIProviderPersonalization
                          ON PQRIProviderUserEncounter.PQRIProviderPersonalizationID = PQRIProviderPersonalization.PQRIProviderPersonalizationID
                      WHERE
                          PQRIProviderPersonalization.ProviderUserID = @i_ProviderUserID
                          AND PQRIProviderPersonalization.ReportingYear = @i_ReportingYear 
                    )

         BEGIN
			    DECLARE
                       @v_MeasureGroupList VARCHAR(MAX) = ''
                      ,@i_MeasureID KEYID
                      ,@v_SQL NVARCHAR(MAX) = ''
                      ,@v_DenominatorsCriteriaSQL NVARCHAR(MAX) = ''
                      ,@i_MeasureGroupID KEYID
                      ,@v_MeasureList NVARCHAR(MAX) = ''
                      ,@i_PQRIQualityMeasureID KEYID
                      ,@v_PQRIQualityMeasureCorrelateIDList VARCHAR(MAX) = ''
                      ,@i_PQRIProviderPersonalizationID KEYID
                      ,@l_TranStarted BIT = 0  
                      
               IF(@@TRANCOUNT = 0)  
				 BEGIN  
					BEGIN TRANSACTION  
					SET @l_TranStarted = 1  
				 END  
			   ELSE 
				 BEGIN  
					SET @l_TranStarted = 0
				 END         

				   SELECT
					   @i_PQRIProviderPersonalizationID = PQRIProviderPersonalizationID
				   FROM
					   PQRIProviderPersonalization
				   WHERE
					   ProviderUserID = @i_ProviderUserID
					   AND ReportingYear = @i_ReportingYear

				   DECLARE @tblQMID TABLE
						 (
							PQRIQualityMeasureID KEYID
						 )
				   INSERT
					   @tblQMID
					   SELECT DISTINCT
						   PQRIProviderQualityMeasure.PQRIQualityMeasureID
					   FROM
						   PQRIProviderPersonalization
					   INNER JOIN PQRIProviderQualityMeasure
						   ON PQRIProviderQualityMeasure.PQRIProviderPersonalizationid = PQRIProviderPersonalization.PQRIProviderPersonalizationid
					   INNER JOIN PQRIQualityMeasure
						   ON PQRIQualityMeasure.PQRIQualityMeasureID = PQRIProviderQualityMeasure.PQRIQualityMeasureID
						  AND PQRIQualityMeasure.ReportingYear = PQRIProviderPersonalization.ReportingYear  
					   WHERE
						   ProviderUserID = @i_ProviderUserID
						   AND PQRIProviderPersonalization.StatusCode = 'A'
						   AND PQRIQualityMeasure.StatusCode = 'A'
						   AND PQRIProviderPersonalization.ReportingYear = @i_ReportingYear
	                       

				   DECLARE @tblQMGID TTYPEKEYID
	                    
				   INSERT
					   @tblQMGID
					   SELECT DISTINCT
						   PQRIProviderQualityMeasureGroup.PQRIQualityMeasureGroupID
					   FROM
						   PQRIProviderPersonalization
					   INNER JOIN PQRIProviderQualityMeasureGroup
						   ON PQRIProviderQualityMeasureGroup.PQRIProviderPersonalizationid = PQRIProviderPersonalization.PQRIProviderPersonalizationid
					   INNER JOIN PQRIQualityMeasureGroup
						   ON PQRIQualityMeasureGroup.PQRIQualityMeasureGroupID = PQRIProviderQualityMeasureGroup.PQRIQualityMeasureGroupID
						  AND PQRIQualityMeasureGroup.ReportingYear = PQRIProviderPersonalization.ReportingYear 
					   WHERE
						   ProviderUserID = @i_ProviderUserID
						   AND PQRIProviderPersonalization.StatusCode = 'A'
						   AND PQRIQualityMeasureGroup.StatusCode = 'A'
						   AND PQRIProviderPersonalization.ReportingYear = @i_ReportingYear 
	                       

	-------------------- FOR SINGLE MEASURE ID FIND OUT QMGS  ------------------------------------
	
				   CREATE TABLE #tblQMGPatientList
						 (
							PatientUserID INT
						   ,ClaimNum VARCHAR(50)
						   ,DateOfService DATETIME
						   ,MeasureID INT
						   ,ClaimInfoID INT
						 )

				   CREATE TABLE #tblQMPatientList
						 (
							PatientUserID INT
						   ,ClaimNum VARCHAR(50)
						   ,DateOfService DATETIME
						   ,MeasureID VARCHAR(100)
						   ,ClaimInfoID INT
						 )
					
										
				   DECLARE @tblPQRIQMGID TTYPEKEYID
	                    
				   INSERT INTO
						@tblPQRIQMGID
					SELECT DISTINCT
						PQRIQualityMeasureGroupId
					FROM
						PQRIQualityMeasureGroupToMeasure PQRIMGM
					INNER JOIN @tblQMID TQMID
						ON TQMID.PQRIQualityMeasureID = PQRIMGM.PQRIQualityMeasureID 

					IF EXISTS ( SELECT 1 FROM @tblPQRIQMGID )
					   BEGIN
							 INSERT INTO
								 #tblQMPatientList
								 (
								  PatientUserID
								 ,ClaimNum
								 ,DateOfService
								 ,MeasureID
								 ,ClaimInfoID
								 )
								 EXEC [usp_PQRIProviderPersonalization_DenominatorQualifiedPatientsByQMGID] 
									  @i_AppUserId = @i_AppUserId , 
									  @i_ProviderUserID = @i_ProviderUserID,
									  @i_ReportingYear = @i_ReportingYear , 
									  @t_PQRIQualityMeasureGroupID = @tblPQRIQMGID
	                            
					   END
					ELSE
					   BEGIN
	                         
							 DECLARE curQM CURSOR
									FOR SELECT
											PQRIQualityMeasureID
										FROM
											@tblQMID
							OPEN curQM
							FETCH NEXT FROM curQM INTO @i_MeasureID
							WHILE @@FETCH_STATUS = 0
								 BEGIN
									 SELECT
										 @v_DenominatorsCriteriaSQL = dbo.ufn_GetPQRIQMDenominatorByQMID(CONVERT(VARCHAR , @i_MeasureID))
			
									 SET @v_SQL = 'INSERT INTO #tblQMPatientList
													(
													PatientUserID , 
													ClaimNum ,
													DateOfService,
													ClaimInfoID ,
													MeasureID  
													)
												SELECT DISTINCT
													P.UserID,
													ci.ClaimNumber,
													ci.DateOfDischarge,
													ci.ClaimInfoID ,'
													+ CONVERT(VARCHAR , @i_MeasureID) + ' 
												FROM 
													Patients p
												INNER JOIN ClaimInfo ci
													ON ci.PatientUserId = p.UserId
												INNER JOIN UserProviders up
													ON up.PatientUserId = p.UserId
												INNER JOIN PQRIProviderPersonalization
													ON PQRIProviderPersonalization.ProviderUserID = up.ProviderUserId
												AND up.ProviderUserId = ' + CONVERT(VARCHAR , @i_ProviderUserID) + '
												AND DATEPART(YEAR,ci.DateOfDischarge) =  ' + CONVERT(VARCHAR , @i_ReportingYear) + '
												WHERE 1 = 1 ' + ISNULL(@v_DenominatorsCriteriaSQL , '')
		
		

									 IF @v_DenominatorsCriteriaSQL IS NOT NULL
										BEGIN
												
											  EXEC ( @v_SQL )
										END
									 FETCH NEXT FROM curQM INTO @i_MeasureID
								 END
							CLOSE curQM
							DEALLOCATE curQM
	                                    
					   END

				   IF EXISTS ( SELECT 1 FROM @tblQMGID )
					  BEGIN
							
							INSERT INTO
								#tblQMGPatientList
								(
								 PatientUserID
								,ClaimNum
								,DateOfService
								,MeasureID
								)
								EXEC [dbo].[usp_PQRIProviderPersonalization_DenominatorQualifiedPatientsByQMGID] 
									 @i_AppUserId = @i_AppUserId , 
									 @i_ProviderUserID = @i_ProviderUserID,
									 @i_ReportingYear = @i_ReportingYear , 
									 @t_PQRIQualityMeasureGroupID = @tblQMGID
	                            
					  END
				   CREATE TABLE #tblPatients
						 (
							PatientUserID INT
						   ,ClaimNum VARCHAR(50)
						   ,DateOfService DATETIME
						   ,MeasureId INT
						   ,CPTCodes VARCHAR(MAX)
						   ,ICDCodes VARCHAR(MAX)
						   ,Encounters VARCHAR(MAX)
						 )

				   INSERT INTO
					   #tblPatients
					   (
						PatientUserID
					   ,ClaimNum
					   ,DateOfService
					   ,MeasureId
					   ,CPTCodes
					   ,ICDCodes
					   ,Encounters
					   )
					   SELECT
						   PatientUserID
						  ,ClaimNum
						  ,DateOfService
						  ,MeasureId
						  ,STUFF(( SELECT DISTINCT
									   ',' + CONVERT(VARCHAR , ISNULL(UserProcedureId , ''))
								   FROM
									   UserProcedureCodes
								   INNER JOIN ClaimLine
									   ON UserProcedureCodes.ClaimLineID = ClaimLine.ClaimLineID
								   WHERE
									   UserProcedureCodes.Userid = QMPatientList.PatientUserID
									   AND ClaimLine.ClaimInfoID = QMPatientList.ClaimInfoID
									   AND DATEPART(YEAR , UserProcedureCodes.ProcedureCompletedDate) = @i_ReportingYear
								   FOR
									   XML PATH('') ) , 1 , 1 , '') AS CPTCodes
						  ,STUFF(( SELECT DISTINCT
									   ',' + CONVERT(VARCHAR , UserDiagnosisId)
								   FROM
									   UserDiagnosisCodes
								   WHERE
									   UserDiagnosisCodes.Userid = QMPatientList.PatientUserID
									   AND DATEPART(YEAR , UserDiagnosisCodes.DateDiagnosed) = @i_ReportingYear
									   AND UserDiagnosisCodes.ClaimInfoID = QMPatientList.ClaimInfoID
								   FOR
									   XML PATH('') ) , 1 , 1 , '') AS ICDCodes
						  ,STUFF(( SELECT DISTINCT
									   ',' + CONVERT(VARCHAR , UserEncounterID)
								   FROM
									   UserEncounters
								   WHERE
									   UserEncounters.Userid = QMPatientList.PatientUserID
									   AND UserEncounters.ClaimInfoID = QMPatientList.ClaimInfoID
									   AND DATEPART(YEAR , UserEncounters.EncounterDate) = @i_ReportingYear
								   FOR
									   XML PATH('') ) , 1 , 1 , '') AS Encounters
					   FROM
						   #tblQMPatientList QMPatientList
					   UNION
					   SELECT
						   PatientUserID
						  ,ClaimNum
						  ,DateOfService
						  ,MeasureID
						  ,STUFF(( SELECT DISTINCT
									   ',' + CONVERT(VARCHAR , ISNULL(UserProcedureId , ''))
								   FROM
									   UserProcedureCodes
								   INNER JOIN ClaimLine
									   ON UserProcedureCodes.ClaimLineID = ClaimLine.ClaimLineID
								   WHERE
									   UserProcedureCodes.Userid = QMGPatientList.PatientUserID
									   AND ClaimLine.ClaimInfoID = QMGPatientList.ClaimInfoID
									   AND DATEPART(YEAR , UserProcedureCodes.ProcedureCompletedDate) = @i_ReportingYear
								   FOR
									   XML PATH('') ) , 1 , 1 , '') AS CPTCodes
						  ,STUFF(( SELECT DISTINCT
									   ',' + CONVERT(VARCHAR , UserDiagnosisId)
								   FROM
									   UserDiagnosisCodes
								   WHERE
									   UserDiagnosisCodes.Userid = QMGPatientList.PatientUserID
									   AND DATEPART(YEAR , UserDiagnosisCodes.DateDiagnosed) = @i_ReportingYear
									   AND UserDiagnosisCodes.ClaimInfoID = QMGPatientList.ClaimInfoID
								   FOR
									   XML PATH('') ) , 1 , 1 , '') AS ICDCodes
						  ,STUFF(( SELECT DISTINCT
									   ',' + CONVERT(VARCHAR , UserEncounterID)
								   FROM
									   UserEncounters
								   WHERE
									   UserEncounters.Userid = QMGPatientList.PatientUserID
									   AND UserEncounters.ClaimInfoID = QMGPatientList.ClaimInfoID
									   AND DATEPART(YEAR , UserEncounters.EncounterDate) = @i_ReportingYear
								   FOR
									   XML PATH('') ) , 1 , 1 , '') AS Encounters
					   FROM
						   #tblQMGPatientList QMGPatientList

				   INSERT INTO
					   PQRIProviderUserEncounter
					   (
						PQRIProviderPersonalizationID
					   ,PatientUserId
					   ,ClaimNum
					   ,DateOfService
					   ,PQRIMeasureIDList
					   ,UserEncounterIDList
					   ,UserDiagnosisIDList
					   ,UserProcedureIDList
					   ,TransactionStatus
					   ,CreatedByUserId
					   )
					   SELECT
						   @i_PQRIProviderPersonalizationID
						  ,PatientUserID
						  ,ClaimNum
						  ,DateOfService
						  ,STUFF(( SELECT DISTINCT
									   ',' + CONVERT(VARCHAR , tblMeasureList.MeasureId)
								   FROM
									   #tblPatients tblMeasureList
								   WHERE
									   tblMeasureList.PatientUserID = tblPatients.PatientUserID
									   AND tblMeasureList.ClaimNum = tblPatients.ClaimNum
									   AND tblMeasureList.DateOfService = tblPatients.DateOfService
								   FOR
									   XML PATH('') ) , 1 , 1 , '') AS MeasureIdList
						  ,Encounters
						  ,ICDCodes
						  ,CPTCodes
						  ,'Open'
						  ,@i_AppUserId
					   FROM
						   #tblPatients tblPatients
					   GROUP BY
						  PatientUserID
						 ,ClaimNum
						 ,DateOfService
						 ,CPTCodes
						 ,ICDCodes
						 ,Encounters
	                     
				   IF (@@ROWCOUNT > 0)
					   BEGIN
						   UPDATE
							   PQRIProviderPersonalization
						   SET
							   IsAllowEdit = 0
							  ,LastModifiedByUserId = @i_AppUserId
							  ,LastModifiedDate = GETDATE()
						   WHERE PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
						   
						   UPDATE PQRIQualityMeasure
						   SET IsAllowEdit = 0
							  ,LastModifiedByUserId = @i_AppUserId
							  ,LastModifiedDate = GETDATE()
						   FROM PQRIQualityMeasure
						   INNER JOIN PQRIProviderQualityMeasure
								ON PQRIProviderQualityMeasure.PQRIQualityMeasureID = PQRIQualityMeasure.PQRIQualityMeasureID   
						   WHERE 
								PQRIProviderQualityMeasure.PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID  
			       
						   UPDATE PQRIQualityMeasureGroup
						   SET IsAllowEdit = 0
							  ,LastModifiedByUserId = @i_AppUserId
							  ,LastModifiedDate = GETDATE()
						   FROM PQRIQualityMeasureGroup
						   INNER JOIN PQRIProviderQualityMeasureGroup
								ON PQRIProviderQualityMeasureGroup.PQRIQualityMeasureGroupID = PQRIQualityMeasureGroup.PQRIQualityMeasureGroupID
						   WHERE 
								PQRIProviderQualityMeasureGroup.PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID 
						   
						   INSERT INTO
							   PQRIProviderReporting
							   (
								PQRIProviderUserEncounterID
							   ,PQRIQualityMeasureID
							   ,CreatedByUserId
							   )
							   SELECT
								   PQRIProviderUserEncounterID
								  ,tblPatients.MeasureId
								  ,@i_AppUserId
							   FROM
								   PQRIProviderUserEncounter
							   INNER JOIN #tblPatients tblPatients
								   ON tblPatients.PatientUserID = PQRIProviderUserEncounter.PatientUserId
									  AND tblPatients.ClaimNum = PQRIProviderUserEncounter.ClaimNum
									  AND tblPatients.DateOfService = PQRIProviderUserEncounter.DateOfService
									  AND PQRIProviderPersonalizationID = @i_PQRIProviderPersonalizationID
					   END
	                   
				   SELECT
					   PQRIProviderUserEncounter.PQRIProviderUserEncounterID
					  ,PQRIProviderUserEncounter.PQRIProviderPersonalizationID
					  ,PQRIProviderUserEncounter.PatientUserId
					  ,Patients.FullName AS 'Patient Name'
					  ,ISNULL(Gender , '') + ' / ' + ISNULL(CONVERT(VARCHAR , Age) , '') AS 'GenderAge'
					  ,CONVERT(VARCHAR , Patients.Dateofbirth , 101) AS DOB
					  ,Patients.MemberNum AS 'MRNNo'
					  ,PQRIProviderUserEncounter.ClaimNum
					  --,(SELECT ClaimNum FROM Claim WHERE ClaimId = PQRIProviderUserEncounter.ClaimId) AS ClaimNum
					  ,CONVERT(VARCHAR , PQRIProviderUserEncounter.DateOfService , 101) AS DateOfService
					  ,PQRIProviderUserEncounter.PQRIMeasureIDList
					  ,PQRIProviderUserEncounter.UserEncounterIDList
					  ,PQRIProviderUserEncounter.UserDiagnosisIDList
					  ,PQRIProviderUserEncounter.UserProcedureIDList
					  ,PQRIProviderUserEncounter.TransactionStatus
					  ,PQRIProviderUserEncounter.CreatedByUserId
					  ,CASE
							WHEN UserEncounterIDList IS NOT NULL THEN 1
							WHEN UserEncounterIDList IS NULL THEN 0
					   END AS EncounterStatus
					  ,CASE
							WHEN UserDiagnosisIDList IS NOT NULL THEN 1
							WHEN UserDiagnosisIDList IS NULL THEN 0
					   END AS DiagnosisStatus
					  ,CASE
							WHEN UserProcedureIDList IS NOT NULL THEN 1
							WHEN UserProcedureIDList IS NULL THEN 0
					   END AS ProcedureStatus
					  ,CASE
							WHEN (
								   Gender IS NOT NULL
								   AND Age IS NOT NULL
								 ) THEN 1
							ELSE 0
					   END AS DemographicStatus
				   FROM
					   PQRIProviderUserEncounter
				   INNER JOIN PQRIProviderPersonalization
					   ON PQRIProviderUserEncounter.PQRIProviderPersonalizationID = PQRIProviderPersonalization.PQRIProviderPersonalizationID
				   INNER JOIN Patients
					   ON Patients.UserID = PQRIProviderUserEncounter.PatientUserId
				   WHERE
					   PQRIProviderPersonalization.ProviderUserID = @i_ProviderUserID
					   AND PQRIProviderPersonalization.ReportingYear = @i_ReportingYear
					   AND (
							 PQRIProviderUserEncounter.TransactionStatus = @v_EncounterStatus
							 OR @v_EncounterStatus IS NULL
						   )
					   AND (
							 Patients.FullName LIKE '%' + @v_PatientName + '%'
							 OR @v_PatientName IS NULL
						   )
					   AND (
							 (
							 ( CONVERT(VARCHAR , PQRIProviderUserEncounter.DateOfService , 101) BETWEEN CONVERT(VARCHAR , @d_DateOfServiceFrom , 101)
							 AND CONVERT(VARCHAR , @d_DateOfServiceTo , 101) )
							 AND (
								   @d_DateOfServiceFrom IS NOT NULL
								   AND @d_DateOfServiceTo IS NOT NULL
								 )
							 )
							 OR (
								  @d_DateOfServiceFrom IS NULL
								  AND @d_DateOfServiceTo IS NULL
								)
						   )
					   AND (
							 Patients.MemberNum = @v_MemberNum
							 OR @v_MemberNum IS NULL
						   )
					ORDER BY 'Patient Name'		   
                       
			 IF @l_TranStarted = 1  
			   BEGIN  
					SET @l_TranStarted = 0  
					COMMIT TRANSACTION  
			   END  
			 ELSE 
			   BEGIN 
					ROLLBACK TRANSACTION 
			   END		           

         END
      ELSE
         BEGIN
               SELECT
                   PQRIProviderUserEncounter.PQRIProviderUserEncounterID
                  ,PQRIProviderUserEncounter.PQRIProviderPersonalizationID
                  ,PQRIProviderUserEncounter.PatientUserId
                  ,Patients.FullName AS 'Patient Name'
                  ,ISNULL(Gender , '') + ' / ' + ISNULL(CONVERT(VARCHAR , Age) , '') AS 'GenderAge'
                  ,CONVERT(VARCHAR , Patients.Dateofbirth , 101) AS DOB
                  ,Patients.MemberNum AS 'MRNNo'
                  ,PQRIProviderUserEncounter.ClaimNum
                  --,(SELECT ClaimNum FROM Claim WHERE ClaimId = PQRIProviderUserEncounter.ClaimId) AS ClaimNum
                  ,CONVERT(VARCHAR , PQRIProviderUserEncounter.DateOfService , 101) AS DateOfService
                  ,PQRIProviderUserEncounter.PQRIMeasureIDList
                  ,PQRIProviderUserEncounter.UserEncounterIDList
                  ,PQRIProviderUserEncounter.UserDiagnosisIDList
                  ,PQRIProviderUserEncounter.UserProcedureIDList
                  ,PQRIProviderUserEncounter.TransactionStatus
                  ,PQRIProviderUserEncounter.CreatedByUserId
                  ,CASE
                        WHEN UserEncounterIDList IS NOT NULL THEN 1
                        WHEN UserEncounterIDList IS NULL THEN 0
                   END AS EncounterStatus
                  ,CASE
                        WHEN UserDiagnosisIDList IS NOT NULL THEN 1
                        WHEN UserDiagnosisIDList IS NULL THEN 0
                   END AS DiagnosisStatus
                  ,CASE
                        WHEN UserProcedureIDList IS NOT NULL THEN 1
                        WHEN UserProcedureIDList IS NULL THEN 0
                   END AS ProcedureStatus
                  ,CASE
                        WHEN (
                               Gender IS NOT NULL
                               AND Age IS NOT NULL
                             ) THEN 1
                        ELSE 0
                   END AS DemographicStatus
               FROM
                   PQRIProviderUserEncounter
               INNER JOIN PQRIProviderPersonalization
                   ON PQRIProviderUserEncounter.PQRIProviderPersonalizationID = PQRIProviderPersonalization.PQRIProviderPersonalizationID
               INNER JOIN Patients
                   ON Patients.UserID = PQRIProviderUserEncounter.PatientUserId
               WHERE
                   PQRIProviderPersonalization.ProviderUserID = @i_ProviderUserID
                   AND PQRIProviderPersonalization.ReportingYear = @i_ReportingYear
                   AND (
                         PQRIProviderUserEncounter.TransactionStatus = @v_EncounterStatus
                         OR @v_EncounterStatus IS NULL
                       )
                   AND (
                         Patients.FullName LIKE '%' + @v_PatientName + '%'
                         OR @v_PatientName IS NULL
                       )
                   AND (
                         (
                         ( CONVERT(VARCHAR , PQRIProviderUserEncounter.DateOfService , 101) BETWEEN CONVERT(VARCHAR , @d_DateOfServiceFrom , 101)
                         AND CONVERT(VARCHAR , @d_DateOfServiceTo , 101) )
                         AND (
                               @d_DateOfServiceFrom IS NOT NULL
                               AND @d_DateOfServiceTo IS NOT NULL
                             )
                         )
                         OR (
                              @d_DateOfServiceFrom IS NULL
                              AND @d_DateOfServiceTo IS NULL
                            )
                       )
                   AND (
                         Patients.MemberNum = @v_MemberNum
                         OR @v_MemberNum IS NULL
                       )
                  ORDER BY 'Patient Name'	     
         END
         
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
    ON OBJECT::[dbo].[usp_PQRIProviderPersonalization_HomePage] TO [FE_rohit.r-ext]
    AS [dbo];

