
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_Reports_CareCoordination_Compare 
Description   : This procedure is used to give CareCoordination comparision report data
Created By    : NagaBabu
Created Date  : 20-Sep-2011
------------------------------------------------------------------------------          
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
18-Oct-2011 Sivakrishna Added select Statement for getting report of Carecordination graph.        
27-Oct-2011 Rathnam added Tree structure data as a last select statement
06-dec-2011 Sivakrishna Added Tree view select statement with the cohort and program condition based 
23-Dec-2011 NagaBabu Modified by Applying join with UserEncounter table with ClaimLine
29-Dec-2011 NagaBabu Added top KeyWord to last select statement for filter Tree view Results
30-Dec-2011 NagaBabu Modified the querry for getting Totalcost in third result set for both Patient,Admin levels 
02-Jan-2011 NagaBabu Added CurSpeciality cursor for getting top 10 providers for each speciality
06-Jan-2011 NagaBabu Modified Getting Providers list as ISNULL(Ue.ProviderId,ISNULL(Up.ProviderUserId,Up.ExternalProviderId))
10-Jan-2011 NagaBabu Added CASE statement in HAVING clause to restruct the records with cost or visits with 0 cost or 
						0 visits for Tree structure AND Added created #tSpeciality and #tSpeciality1 to differenciate 
						cost and visits 
27-Jan-2012 NagaBabu Modified JOIN with UserEncounters with ClaimInfo insteed of ClaimLine whiloe table structure is changed  											  
-----------------------------------------------------------------------------------------------------
*/--[usp_Reports_CareCoordination_Compare]64,'2007-01-01','2011-07-27',1,'Pcp-263309',1,'Spe-22','COHORT',139
--usp_Reports_CareCoordination_Compare 64,'1/1/2007 12:07:46 AM','6/23/2012 2:35:34 AM',245925,'Spe-265873*23',1,'Spe-23','Cohort',2
CREATE PROCEDURE [dbo].[usp_Reports_CareCoordination_Compare]
(
 @i_AppUserId KEYID ,
 @d_FromDate DATETIME ,
 @d_ToDate DATETIME ,
 @i_PatientUserId KEYID = 0 ,
 @v_ComparisonUsersList VARCHAR(1000) ,
 @b_IsByCost ISINDICATOR = 1 ,
 @v_TypeId VARCHAR(10) = NULL ,
 @I_Type VARCHAR(10) = NULL ,
 @I_SubTypeId KEYID = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON           
	-- Check if valid Application User ID is passed          
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END    
		---------------------------------------------------------------------------------------------
		IF @i_PatientUserId = 0 
		BEGIN
		SET @i_PatientUserId = NULL
		END 
		
      DECLARE @t_ProvidersList TABLE
      (
        PListId VARCHAR(15) ,
        Ptype VARCHAR(10)
      )

      DECLARE @FinalGraphData TABLE
      (
        ProviderId VARCHAR(30) ,
        ProviderName VARCHAR(150) ,
        EncounterDate DATE ,
        TotalNoofVisits INT ,
        TotalCost MONEY
      )

      CREATE TABLE #SpecialityProvider
      (
        ID VARCHAR(15) ,
        TypeID VARCHAR(15) ,
        TypeName VARCHAR(200) ,
        Type VARCHAR(15) ,
        SpecialityProviderID VARCHAR(20) ,
        SpecialityProviderName VARCHAR(200) ,
        OrderMax INT
      )

      CREATE TABLE #t_CareUserList
      (
        UserId INT
      )

      IF @I_Type = 'Cohort'
         INSERT INTO
             #t_CareUserList
             SELECT
                 PatientID
             FROM
                 PopulationDefinitionPatients
             WHERE
                 (
                 PopulationDefinitionId = @I_SubTypeId
                 OR @I_SubTypeId IS NULL
                 )
                 AND StatusCode = 'A'
      ELSE
         IF @I_Type = 'Program'
            BEGIN
                  INSERT INTO
                      #t_CareUserList
                      SELECT
                          PatientID
                      FROM
                          PatientProgram
                      WHERE
                          (
                          ProgramId = @I_SubTypeId
                          OR @I_SubTypeId IS NULL
                          )
                          AND StatusCode = 'A'
            END

      CREATE TABLE #tblType
      (
        TypeID VARCHAR(15) ,
        TypeName VARCHAR(200) ,
        Type VARCHAR(15) ,
        SpecialityProviderID VARCHAR(20) ,
        SpecialityProviderName VARCHAR(200) ,
        OrderMax INT
      )

      INSERT INTO
          @t_ProvidersList
          (
            PListId ,
            ptype
          )
          SELECT DISTINCT
              Keyvalue ,
              SUBSTRING(KeyValue , 1 , 3)
          FROM
              udf_SplitStringToTable(@v_ComparisonUsersList , ',')

      DECLARE
              @v_Id VARCHAR(30) ,
              @i_Cnt INT ,
              @v_Name VARCHAR(150)

      DECLARE
              --@d_Startdate DATETIME = DATEADD(MM , 1 , DATEADD(YEAR , -1 , GETDATE())) ,
              @d_Startdate DATETIME = DATEADD(MM , 1 , DATEADD(YEAR , -1 , @d_ToDate)) ,
              @d_EndDate DATETIME = @d_ToDate ,
              @d_DateTaken DATE ,
              @i_SpecialityId INT ,
              @b_IsCAostOrVisit BIT

      DECLARE @t_EncounterDatetaken TABLE
      (
        Encounterdate DATE
      )

      CREATE NONCLUSTERED INDEX [IX_#t_CareUserList] ON #t_CareUserList ( UserId ASC )
	
---------------------------------Patient Level---------------------------------------------------------------
      IF @I_Type IS NULL

         BEGIN
			-----Last 1 Year Provider encounters data set-------
               SELECT
                   *
               FROM
                   (
					SELECT 
						COUNT(DISTINCT CareTeamUserID) TotalCareProviders,
						SUM(CAST(ISNULL(Ue.IsEncounterwithPCP,0)AS INT)) AS TotalNoofPCPVisits ,
						(SELECT COUNT(DISTINCT ProviderId)
						  FROM vw_ClaimEncounters
						  WHERE EncounterDate BETWEEN DATEADD(YEAR,-1,GETDATE()) AND GETDATE()
						  AND SpecialityID IS NOT NULL
						  AND UserID = @i_PatientUserId)AS TotalNoofSpecialistVisits  ,	 
						SUM(CAST(ISNULL(Ue.IsInpatient,0)AS INT))AS TotalNoofIPVisits,
						(SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo
						  WHERE DateOfAdmit BETWEEN DATEADD(YEAR,-1,GETDATE()) AND GETDATE()
						  AND PatientID = @i_PatientUserId )AS TotalCostIn$ ,
						( SELECT TOP 1
							  dbo.ufn_GetUserNameByID(Ues.ProviderId)
						  FROM
							  vw_ClaimEncounters Ues
						  INNER JOIN ClaimInfo CI WITH (NOLOCK)
							  ON CI.ClaimInfoId = Ues.ClaimInfoID
						  WHERE 
							  Ues.EncounterDate BETWEEN DATEADD(YEAR,-1,GETDATE()) AND GETDATE() 
							  AND Ues.UserId = @i_PatientUserId
						  GROUP BY Ues.ProviderId	   
						  ORDER BY SUM(ISNULL(CI.NetPaidAmount,0)) DESC
						  )AS CareProviderWithMax$ , 
						( SELECT TOP 1
							  dbo.ufn_GetUserNameByID(Ues.ProviderId)
						  FROM
							  vw_ClaimEncounters Ues
						  INNER JOIN ClaimInfo CI WITH (NOLOCK)
							  ON CI.ClaimInfoId = Ues.ClaimInfoID
						  WHERE 
							  Ues.EncounterDate BETWEEN DATEADD(YEAR,-1,GETDATE()) AND GETDATE() 
							  AND Ues.UserId = @i_PatientUserId
						  GROUP BY Ues.ProviderId	   
						  ORDER BY COUNT(Ues.ProviderId) DESC
						  )AS CareProviderWithMaxVisit   
					FROM
						vw_ClaimEncounters Ue
					INNER JOIN ClaimInfo CI
						ON CI.ClaimInfoId = UE.ClaimInfoID 	  
					WHERE Ue.UserId = @i_PatientUserId 
					  AND EncounterDate BETWEEN DATEADD(YEAR,-1,GETDATE()) AND GETDATE()
                   ) Z
                  
	
			-----Last 2 Years patient encounters data set----------	
               SELECT
                   *
               FROM
                   (
 					SELECT 
						COUNT(DISTINCT CareTeamUserID) TotalCareProviders,
						SUM(CAST(ISNULL(Ue.IsEncounterwithPCP,0)AS INT)) AS TotalNoofPCPVisits ,
						(SELECT COUNT(DISTINCT ProviderId)
						  FROM vw_ClaimEncounters
						  WHERE EncounterDate BETWEEN DATEADD(YEAR,-2,GETDATE()) AND GETDATE()
						  AND SpecialityID IS NOT NULL
						  AND UserID = @i_PatientUserId)AS TotalNoofSpecialistVisits  ,	 
						SUM(CAST(ISNULL(Ue.IsInpatient,0)AS INT))AS TotalNoofIPVisits,
						(SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo
						  WHERE DateOfAdmit BETWEEN DATEADD(YEAR,-2,GETDATE()) AND GETDATE()
						  AND PatientID = @i_PatientUserId )AS TotalCostIn$ ,
						( SELECT TOP 1
							  dbo.ufn_GetUserNameByID(Ues.ProviderId)
						  FROM
							  vw_ClaimEncounters Ues
						  INNER JOIN ClaimInfo CI WITH (NOLOCK)
							  ON CI.ClaimInfoId = Ues.ClaimInfoID
						  WHERE 
							  Ues.EncounterDate BETWEEN DATEADD(YEAR,-2,GETDATE()) AND GETDATE() 
							  AND Ues.UserId = @i_PatientUserId
						  GROUP BY Ues.ProviderId	   
						  ORDER BY SUM(ISNULL(CI.NetPaidAmount,0)) DESC
						  )AS CareProviderWithMax$ , 
						( SELECT TOP 1
							  dbo.ufn_GetUserNameByID(Ues.ProviderId)
						  FROM
							  vw_ClaimEncounters Ues
						  INNER JOIN ClaimInfo CI WITH (NOLOCK)
							  ON CI.ClaimInfoId = Ues.ClaimInfoID
						  WHERE 
							  Ues.EncounterDate BETWEEN DATEADD(YEAR,-2,GETDATE()) AND GETDATE() 
							  AND Ues.UserId = @i_PatientUserId
						  GROUP BY Ues.ProviderId	   
						  ORDER BY COUNT(Ues.ProviderId) DESC
						  )AS CareProviderWithMaxVisit   
					FROM
						vw_ClaimEncounters Ue
					INNER JOIN ClaimInfo CI
						ON CI.ClaimInfoId = UE.ClaimInfoID 	  
					WHERE Ue.UserId = @i_PatientUserId 
					  AND EncounterDate BETWEEN DATEADD(YEAR,-2,GETDATE()) AND GETDATE()
                   ) Z
                   
		     
               -------------------------------------------Selected ProviderList-------------------------------------
               SELECT
                   *
               FROM
                   (
                     SELECT
                         'Pcp-' + CONVERT(VARCHAR(12) , Ue.ProviderId) ProviderId ,
                         dbo.ufn_GetUserNameByID(Ue.ProviderId) ProviderName ,
                         (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo 
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,ProviderId
									  FROM vw_ClaimEncounters
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate 
										AND UserID = @i_PatientUserId 
										AND IsEncounterwithPCP = 1 )CI
						      ON CI.ProviderId = Ue.ProviderId)	 AS TotalCost ,
                         --SUM(CAST(ISNULL(Ue.IsEncounterwithPCP , 0) AS INT)) AS TotalVisits ,
                         COUNT(DISTINCT Ue.ClaimInfoID) AS TotalVisits ,
                         --COUNT(DISTINCT CLI.IcdcodeId) AS TotalDiagnosis ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
                         FROM vw_ClaimEncounters Ues
						 INNER JOIN PatientDiagnosisCode  CLI WITH (NOLOCK)
						    ON Ues.ClaimInfoID = CLI.ClaimInfoID 
						 WHERE Ues.IsEncounterwithPCP = 1
						   AND Ues.ProviderId = Ue.ProviderId  	  
						   AND Ues.UserId = @i_PatientUserId
						 GROUP BY Ues.UserId,Ues.ProviderId) AS TotalDiagnosis ,
                         COUNT(DISTINCT CI.ClaimInfoId) AS TotalNoOfClaims ,
                         --COUNT(DISTINCT CI.ClaimInfoId) / SUM(CAST(ISNULL(Ue.IsEncounterwithPCP , 0) AS INT)) AS 'Claims/Visit' ,
                         COUNT(DISTINCT CI.ClaimInfoId) / COUNT(DISTINCT Ue.ClaimInfoID) AS 'Claims/Visit' ,
                         --SUM(ISNULL(CI.NetPaidAmount , 0)) / SUM(CAST(ISNULL(Ue.IsEncounterwithPCP , 0) AS INT)) AS 'Dollars/Visit' ,
                         CAST((SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo 
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,ProviderId
									  FROM vw_ClaimEncounters
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate 
										AND UserID = @i_PatientUserId 
										AND IsEncounterwithPCP = 1 )CI
						      ON CI.ProviderId = Ue.ProviderId)/COUNT(DISTINCT Ue.ClaimInfoID)AS DECIMAL(10,2)) AS 'Dollars/Visit' ,
                         ISNULL((SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
                         FROM vw_ClaimEncounters Ues
						 INNER JOIN PatientDiagnosisCode  CLI WITH (NOLOCK)
						    ON Ues.ClaimInfoID = CLI.ClaimInfoID
						 WHERE Ues.IsEncounterwithPCP = 1
						   AND Ues.ProviderId = Ue.ProviderId  	  
						   AND Ues.UserId = @i_PatientUserId
						 GROUP BY Ues.UserId,Ues.ProviderId) / COUNT(DISTINCT Ue.ClaimInfoID),0) AS 'Diagnosis/Visit' ,
                         'PCP' AS Type
                     FROM
                         vw_ClaimEncounters Ue
                     INNER JOIN Users Us WITH (NOLOCK)
                         ON Ue.UserId = Us.UserId
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = UE.ClaimInfoID
                     --LEFT JOIN ClaimLineICD CLI
                     --    ON CI.ClaimInfoId = CLI.ClaimInfoId
                     WHERE
                         (Ue.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                         AND Ue.IsEncounterwithPCP = 1
                         AND EncounterDate BETWEEN @d_Startdate
                         AND @d_EndDate
                         AND Us.UserId = (
                                          SELECT
                                              CONVERT(INT , SUBSTRING(PListId , CHARINDEX('-' , PListId) + 1 , Len(PListId)))
                                          FROM
                                              @t_ProvidersList
                                          WHERE
                                              ptype = 'PCP'
                                        )
                     GROUP BY
                         Ue.ProviderId
                     UNION 
                     SELECT DISTINCT
                         'Spe-' + CONVERT(VARCHAR(12) , Ue.ProviderId) ,
                         COALESCE(ISNULL(Us.LastName , '') + ', ' + ISNULL(Us.FirstName , '') + '. ' + ISNULL(Us.MiddleName , '') , '') AS ProviderName ,
                         --SUM(ISNULL(CI.NetPaidAmount , 0)) AS TotalCost ,
                         (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ues.SpecialityId,Ues.ProviderId 
									  FROM vw_ClaimEncounters Ues
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
									  AND UserId = @i_PatientUserId )CI
						    ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
						    AND CI.SpecialityId = Ue.SpecialityID
						    AND CI.ProviderId = Ue.ProviderId ) AS TotalCost,
                         --SUM(CASE
                         --         WHEN Ue.ProviderId IS NOT NULL THEN 1
                         --         ELSE 0
                         --    END) AS TotalVisits ,
                         COUNT(DISTINCT Ue.ClaimInfoId) AS TotalVisits , 
                         --COUNT(CLI.IcdcodeId) AS TotalDiagnosis ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
						   FROM vw_ClaimEncounters TE
						   INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
							  ON TE.ClaimInfoID = CLI.ClaimInfoID
						   WHERE Ue.ProviderId = TE.ProviderId
						   AND TE.UserId = @i_PatientUserId
						   AND TE.SpecialityID = Ue.SpecialityID
						   GROUP BY TE.ProviderId,TE.UserId,TE.SpecialityID ) AS TotalDiagnosis,
                         COUNT(DISTINCT CI.ClaimInfoId) AS TotalNoOfClaims ,
                         COUNT(DISTINCT CI.ClaimInfoId) / COUNT(DISTINCT Ue.ClaimInfoId) AS 'Claims/Visit' ,
                         CAST((SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ues.SpecialityId,Ues.ProviderId 
									  FROM vw_ClaimEncounters Ues
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
									  AND UserId = @i_PatientUserId )CI
						    ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
						    AND CI.SpecialityId = Ue.SpecialityID
						    AND CI.ProviderId = Ue.ProviderId ) / COUNT(DISTINCT Ue.ClaimInfoId)AS DECIMAL(10,2)) AS 'Dollars/Visit' ,
                         (SELECT COUNT(DISTINCT patientDiagnosisCodeId)
						   FROM vw_ClaimEncounters TE
						   INNER JOIN patientDiagnosisCode CLI WITH (NOLOCK)
							  ON TE.ClaimInfoID = CLI.ClaimInfoID
						   WHERE Ue.ProviderId = TE.ProviderId
						   AND te.UserId = @i_PatientUserId
						   AND TE.SpecialityID = Ue.SpecialityID
						   GROUP BY TE.ProviderId,te.UserId,TE.SpecialityID ) / COUNT(DISTINCT Ue.ClaimInfoId) AS 'Diagnosis/Visit' ,
                         'Specialist' AS Type
                     FROM
                         vw_ClaimEncounters Ue 
                     INNER JOIN @t_ProvidersList PL 
                         ON CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , ( CHARINDEX('*' , PL.PListId) - 1 ) - CHARINDEX('-' , PL.PListId)) )) = Ue.ProviderId
                     INNER JOIN Provider Us WITH (NOLOCK)
                         ON Us.ProviderID = Ue.ProviderId
                     LEFT JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = UE.ClaimInfoID
                     WHERE
                         (Ue.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                         AND EncounterDate BETWEEN @d_Startdate
                         AND @d_EndDate
                         AND PL.ptype = 'Spe'
                         AND CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)))) = Ue.SpecialityID
                     GROUP BY
                         Ue.ProviderId ,
                         Us.LastName ,
                         Us.FirstName ,
                         Us.MiddleName ,
                         --Us.UserNameSuffix ,
                         Ue.SpecialityID
                     UNION 
                     SELECT DISTINCT
                         'Hos-' + CONVERT(VARCHAR(12) , Ue.OrganizationHospitalId) ,
                         Dbo.ufn_OrganizationName(Ue.OrganizationHospitalId) AS ProviderName ,
                         --SUM(ISNULL(CI.NetPaidAmount , 0)) AS TotalCost ,
                         (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,OrganizationHospitalId
									  FROM vw_ClaimEncounters Ue
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
									  AND UserId = @i_PatientUserId )CI
						    ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
						    AND CI.OrganizationHospitalId = Ue.OrganizationHospitalId)AS TotalCost ,
                         --SUM(CASE
                         --         WHEN Ue.OrganizationHospitalID IS NOT NULL THEN 1
                         --         ELSE 0
                         --    END) TotalVisits ,
                         COUNT(DISTINCT UE.ClaimInfoID)AS TotalVisits ,
                         --COUNT(CLI.ICDCodeId) TotalDiagnosis ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
                         FROM vw_ClaimEncounters Ues
						 INNER JOIN PatientDiagnosisCode  CLI
						    ON Ues.ClaimInfoID = CLI.ClaimInfoID   	  
					     WHERE Ues.OrganizationHospitalId = Ue.OrganizationHospitalId
						   AND Ues.UserId = @i_PatientUserId
						 GROUP BY Ues.OrganizationHospitalId,Ues.UserId ),
                         COUNT(DISTINCT CI.ClaimInfoId) AS TotalNoofClaims ,
                         COUNT(DISTINCT CI.ClaimInfoId) /COUNT(DISTINCT UE.ClaimInfoID) AS 'Claims/Visit' ,
                         CAST((SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,OrganizationHospitalId
									  FROM vw_ClaimEncounters Ue
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
									  AND UserId = @i_PatientUserId )CI
						    ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
						    AND CI.OrganizationHospitalId = Ue.OrganizationHospitalId) / COUNT(DISTINCT UE.ClaimInfoID)AS DECIMAL(10,2)) AS 'Dollars/Visit' ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
                         FROM vw_ClaimEncounters Ues
						 INNER JOIN PatientDiagnosisCode  CLI WITH (NOLOCK)
						    ON Ues.ClaimInfoID = CLI.ClaimInfoID   	  
					     WHERE Ues.OrganizationHospitalId = Ue.OrganizationHospitalId
						   AND Ues.UserId = @i_PatientUserId
						 GROUP BY Ues.OrganizationHospitalId,Ues.UserId ) /COUNT(DISTINCT UE.ClaimInfoID) AS 'Diagnosis/Visit' ,
                         'Hospital' AS Type
                     FROM
                         @t_ProvidersList PL
                     INNER JOIN vw_ClaimEncounters Ue
                         ON CONVERT(INT , SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , Len(PL.PListId))) = Ue.OrganizationHospitalId
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = UE.ClaimInfoID
                     WHERE
                         (Ue.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                         AND Ue.EncounterDate BETWEEN @d_Startdate
                         AND @d_EndDate
                         AND PL.ptype = 'Hos'
                         AND Ue.OrganizationHospitalId IS NOT NULL
                     GROUP BY
                         Ue.OrganizationHospitalId
                   ) Z
		
 -------------------------Comparision Graph Data For care Providers --------------------------------

               INSERT
                   @FinalGraphData
                   (
                     ProviderId ,
                     ProviderName ,
                     Encounterdate ,
                     TotalNoofVisits ,
                     TotalCost
                   )
                   SELECT
                       'Pcp-' + CONVERT(VARCHAR(12) , Ue.ProviderId) ,
                       dbo.ufn_GetUserNameByID(Ue.ProviderId) ,
                       CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' ,
                       --SUM(CAST(ISNULL(IsEncounterwithPCP , 0) AS INT)) ,
                       COUNT(DISTINCT UE.ClaimInfoID) ,
                       --SUM(ISNULL(CI.NetPaidAmount , 0))
                       (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo 
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,ProviderId,CAST(YEAR(EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , EncounterDate) + '/01' AS EncounterDate
									  FROM vw_ClaimEncounters
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate 
										AND UserID = @i_PatientUserId 
										AND IsEncounterwithPCP = 1 )CI
						      ON CI.ProviderId = Ue.ProviderId
						      AND CI.ClaimInfoID = ClaimInfo.ClaimInfoID
						      AND EncounterDate = CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' )
                   FROM
                       vw_ClaimEncounters Ue
                   INNER JOIN Users Us WITH (NOLOCK)
                       ON Ue.UserId = Us.UserId
                   INNER JOIN ClaimInfo CI WITH (NOLOCK)
                       ON CI.ClaimInfoId = UE.ClaimInfoID
                   WHERE
                       (Ue.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                       AND Ue.IsEncounterwithPCP = 1
                       AND Ue.EncounterDate BETWEEN @d_Startdate
                       AND @d_EndDate
                       AND Us.UserId = ( SELECT
                                            CONVERT(INT , SUBSTRING(PListId , CHARINDEX('-' , PListId) + 1 , Len(PListId)))
                                        FROM
                                            @t_ProvidersList
                                        WHERE
                                            ptype = 'PCP' )
                   GROUP BY
                       'Pcp-' + CONVERT(VARCHAR(12) , Ue.ProviderId) ,Ue.ProviderId,
                       CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' 
                   UNION 
                       SELECT
							'Spe-' + CONVERT(VARCHAR(12) , Ue.ProviderId) + '*' + CONVERT(VARCHAR , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)- CHARINDEX('*' , PL.PListId)))),
							dbo.ufn_GetUserNameByID(Ue.ProviderId)+ '*' + CONVERT(VARCHAR , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)- CHARINDEX('*' , PL.PListId)))) ,
							CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' ,
							--SUM(CASE
							--		 WHEN Ue.ProviderId IS NOT NULL THEN 1
							--		 ELSE 0
							--	END) ,
							COUNT(UE.ClaimInfoID) ,
							--SUM(ISNULL(CI.NetPaidAmount , 0))
							(SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
							  FROM ClaimInfo WITH (NOLOCK)
							  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId ,UE.ProviderId,CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' AS EncounterDate
										  FROM vw_ClaimEncounters Ue
										  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
										  AND UserId = @i_PatientUserId )CI
								ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
								AND CI.SpecialityId = Ue.SpecialityID
								AND CI.ProviderId = Ue.ProviderId
								AND CI.EncounterDate = CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01')
						FROM
							vw_ClaimEncounters Ue 
						INNER JOIN @t_ProvidersList PL
							ON CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , ( CHARINDEX('*' , PL.PListId) - 1 ) - CHARINDEX('-' , PL.PListId)) )) = Ue.ProviderId
						INNER JOIN Users Us WITH (NOLOCK)
							ON Us.UserId = Ue.ProviderId
						INNER JOIN ClaimInfo CI WITH (NOLOCK)
							ON CI.ClaimInfoId = UE.ClaimInfoID
						WHERE
							(Ue.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
							AND Ue.EncounterDate BETWEEN @d_Startdate
							AND @d_EndDate
							AND PL.ptype = 'Spe'
							AND CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)))) = Ue.SpecialityID
							AND dbo.ufn_GetUserNameByID(Ue.ProviderId)  IS NOT NULL
						GROUP BY
							'Spe-' + CONVERT(VARCHAR(12) , Ue.ProviderId) ,CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)))),
							CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' ,
							Ue.ProviderId,PL.PListId,Ue.SpecialityID
						UNION 
						SELECT
							'Hos-' + CONVERT(VARCHAR(12) , Ue.OrganizationHospitalId) ,
							Dbo.ufn_OrganizationName(Ue.OrganizationHospitalId) ,
							CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' ,
							--SUM(CASE
							--		 WHEN Ue.OrganizationHospitalId IS NOT NULL THEN 1
							--		 ELSE 0
							--	END) ,
							COUNT(DISTINCT UE.ClaimInfoID),
							--SUM(ISNULL(CI.NetPaidAmount , 0))
							(SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
							  FROM ClaimInfo
							  INNER JOIN (SELECT DISTINCT ClaimInfoID,OrganizationHospitalId,CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' AS EncounterDate
										  FROM vw_ClaimEncounters Ue
										  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
										  AND UserId = @i_PatientUserId )CI
								ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
								AND CI.OrganizationHospitalId = Ue.OrganizationHospitalId
								AND CI.EncounterDate = CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01')
						FROM
							@t_ProvidersList PL
						INNER JOIN vw_ClaimEncounters Ue
							ON CONVERT(INT , SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , LEN(PL.PListId))) = Ue.OrganizationHospitalId
						INNER JOIN ClaimInfo CI WITH (NOLOCK)
							ON CI.ClaimInfoId = UE.ClaimInfoID
						WHERE
							--Ue.StatusCode = 'A'
							(Ue.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
							AND Ue.EncounterDate BETWEEN @d_Startdate
							AND @d_EndDate
							AND PL.ptype = 'Hos'
							AND Ue.OrganizationHospitalId = CONVERT(INT , SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , LEN(PL.PListId)))
							AND Ue.OrganizationHospitalId IS NOT NULL
						GROUP BY
							'Hos-' + CONVERT(VARCHAR(12) , Ue.OrganizationHospitalId) ,
							Ue.OrganizationHospitalId ,
							CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01'

               INSERT
                   @FinalGraphData
                   (
                     ProviderId ,
                     ProviderName ,
                     Encounterdate ,
                     TotalNoofVisits ,
                     TotalCost
                   )
                   SELECT
                       PListId ,
                       NULL ,
                       CAST(YEAR(@d_Startdate) AS VARCHAR) + '/' + DATENAME(MONTH , @d_Startdate) + '/01' ,
                       0 ,
                       00.00
                   FROM
                       @t_ProvidersList TPL
                   WHERE
                       NOT EXISTS ( SELECT
                                        1
                                    FROM
                                        @FinalGraphData TFGD
                                    WHERE
                                        CASE SUBSTRING(TPL.PListId , 1 , 3)
                                          WHEN 'Spe' THEN SUBSTRING(TPL.PListId , 1 , ( CHARINDEX('*' , TPL.PListId) - 1 ))
                                          ELSE TPL.PListId
                                        END = TFGD.ProviderId )




               SET @d_DateTaken = CAST(YEAR(@d_Startdate) AS VARCHAR) + '/' + DATENAME(MONTH , @d_Startdate) + '/01'
               WHILE @d_DateTaken <= CAST(YEAR(@d_EndDate) AS VARCHAR) + '/' + DATENAME(MONTH , @d_EndDate) + '/01'
                     BEGIN
                           INSERT INTO
                               @t_EncounterDatetaken
                               (
                                 Encounterdate
                               )
                               SELECT
                                   @d_DateTaken

                           SET @d_DateTaken = ( SELECT
                                                    DATEADD(MONTH , 1 , @d_DateTaken) )
                     END


               DECLARE GetMonths_Cursor CURSOR
                       FOR SELECT
                               ProviderId ,
                               COUNT(1) ,
                               ProviderName
                           FROM
                               @FinalGraphData
                           GROUP BY
                               ProviderId ,
                               ProviderName

               OPEN GetMonths_Cursor
               FETCH NEXT FROM GetMonths_Cursor INTO @v_Id,@i_Cnt,@v_Name
               WHILE @@FETCH_STATUS = 0
               AND @i_Cnt < 12
                     BEGIN
                           INSERT INTO
                               @FinalGraphData
                               (
                                 ProviderId ,
                                 ProviderName ,
                                 Encounterdate ,
                                 TotalNoofVisits ,
                                 TotalCost
                               )
                               SELECT
                                   @v_Id ,
                                   @v_Name ,
                                   Encounterdate ,
                                   0 ,
                                   00.00
                               FROM
                                   @t_EncounterDatetaken EncounterDateTaken
                               WHERE
                                   EncounterDateTaken.Encounterdate NOT IN ( SELECT
                                                                                 Encounterdate
                                                                             FROM
                                                                                 @FinalGraphData
                                                                             WHERE
                                                                                 Providerid = @v_Id )

                           FETCH NEXT FROM GetMonths_Cursor INTO @v_Id,@i_Cnt,@v_Name
                     END
               CLOSE GetMonths_Cursor
               DEALLOCATE GetMonths_Cursor

               IF @b_IsByCost = 1
                  SELECT
                      ProviderId ,
                      ProviderName ,
                      SUBSTRING(CONVERT(VARCHAR(10) , DATENAME(MM , EncounterDate)) , 1 , 3) + ' ' + CONVERT(VARCHAR(4) , DATEPART(YEAR , EncounterDate)) AS EncounterMonth ,
                      ISNULL(TotalCost,0.0)AS TotalCost,
                      Encounterdate
                  FROM
                      @FinalGraphData
                  ORDER BY
                      ProviderId ,
                      EncounterDate
               ELSE
                  SELECT
                      ProviderId ,
                      ProviderName ,
                      SUBSTRING(CONVERT(VARCHAR(10) , DATENAME(MM , EncounterDate)) , 1 , 3) + ' ' + CONVERT(VARCHAR(4) , DATEPART(YEAR , EncounterDate)) AS EncounterMonth ,
                      TotalNoofVisits ,
                      Encounterdate
                  FROM
                      @FinalGraphData
                  ORDER BY
                      ProviderId ,
                      EncounterDate		
			
				
----------------------------------------Tree View For Care Providers---------------------------------------

               IF
               ( SELECT
                     COUNT(*)
                 FROM
                     @t_ProvidersList ) = 1
                  BEGIN
                      
                        CREATE TABLE #tSpeciality
                        (
                          ID INT IDENTITY(1,1),
                          SpecialityId INT
                        )
                        IF @b_IsByCost = 0
                           BEGIN
                                 INSERT INTO
                                     #tSpeciality
                                     (
                                       SpecialityId
                                     )
                                     SELECT TOP 5
                                         ues.SpecialityId
                                     FROM
                                         vw_ClaimEncounters ues 
                                     INNER JOIN ClaimInfo CI
                                         ON CI.ClaimInfoId = UES.ClaimInfoID
                                     --LEFT JOIN ClaimLine CL
                                     --    ON CI.ClaimInfoId = CL.ClaimInfoId    
                                     WHERE
                                         (ues.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                                         AND EncounterDate BETWEEN @d_FromDate
                                         AND @d_ToDate
                                         AND  ues.SpecialityId IS NOT NULL
                                         --AND ues.StatusCode = 'A'
                                     GROUP BY
                                         ues.SpecialityId
                                     --HAVING
                                     --    COUNT(UeS.ProviderId) <> 0
                                     --ORDER BY
                                     --    COUNT(UeS.ProviderId) DESC
                                     HAVING
                                         COUNT(DISTINCT UES.ClaimInfoID) <> 0
                                     ORDER BY
                                         COUNT(DISTINCT UES.ClaimInfoID) DESC
                           END
                        ELSE
                           BEGIN
                           
                                 INSERT INTO
                                     #tSpeciality
                                     (
                                       SpecialityId
                                     )
                                     SELECT TOP 5
                                         ues.SpecialityId
                                     FROM
                                         vw_ClaimEncounters ues
                                     LEFT JOIN ClaimInfo CI WITH (NOLOCK)
                                         ON CI.ClaimInfoId = UES.ClaimInfoID
                                     --LEFT JOIN ClaimLine CL WITH (NOLOCK)
                                     --    ON CI.ClaimInfoId = CL.ClaimInfoId    
                                     WHERE
                                         (ues.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                                         AND EncounterDate BETWEEN @d_FromDate
                                         AND @d_ToDate
                                         AND  ues.SpecialityId IS NOT NULL
                                         --AND ues.StatusCode = 'A'
                                     GROUP BY
                                         ues.SpecialityId
                                     HAVING
                                         (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
										  FROM ClaimInfo WITH (NOLOCK)
										  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId 
													  FROM vw_ClaimEncounters Ue
													  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
													  AND UserId = @i_PatientUserId )CI
											ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
											AND CI.SpecialityId = ues.SpecialityId ) <> 0
                                     ORDER BY
                                         (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
										  FROM ClaimInfo
										  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId 
													  FROM vw_ClaimEncounters Ue
													  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
													  AND UserId = @i_PatientUserId )CI
											ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
											AND CI.SpecialityId = ues.SpecialityId ) DESC
                           END
    	
                        --DECLARE CurSpeciality CURSOR
                        --        FOR SELECT TOP 5
                        --                SpecialityId
                        --            FROM
                        --                #tSpeciality

                        --OPEN CurSpeciality
                        --FETCH NEXT FROM CurSpeciality INTO @i_SpecialityId
                        --WHILE @@FETCH_STATUS = 0
                        
 declare @id int = 1
  WHILE @id <= 5  
  BEGIN
 SET @i_SpecialityId = (SELECT SpecialityId FROM #tSpeciality WHERE ID = @ID)
                              --BEGIN
                                    INSERT INTO
                                        #SpecialityProvider
                                        (
                                          ID ,
                                          TypeID ,
                                          TypeName ,
                                          Type ,
                                          SpecialityProviderID ,
                                          SpecialityProviderName ,
                                          OrderMax
                                        )
                                        SELECT DISTINCT TOP 10
                                            'Spe-' + CONVERT(VARCHAR(12) , ues.ProviderId) + '*' + CONVERT(VARCHAR(12) , @i_SpecialityId) ,
                                            'Spe-' + CONVERT(VARCHAR(12) , @i_SpecialityId) ,
                                            --ues.SpecialityId,
                                            [dbo].[ufn_GetSpecialityById](ues.SpecialityID) SpecialityName ,
                                            'Speciality' ,
                                            'Spe-' + CONVERT(VARCHAR(12) , ues.ProviderId) + '*' + CONVERT(VARCHAR(12) , @i_SpecialityId) ,
                                            dbo.ufn_GetUserNameByID(ues.ProviderId) SpecialityProviderName ,
                                            CASE
                                                 WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT UES.ClaimInfoID) DESC )
                                                 ELSE DENSE_RANK() OVER ( ORDER BY (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
																					  FROM ClaimInfo
																					  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId ,UE.ProviderId
																								  FROM vw_ClaimEncounters Ue
																								  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
																								  AND UserId = @i_PatientUserId )CI
																						ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
																						AND CI.SpecialityId = Ues.SpecialityID
																						AND CI.ProviderId = Ues.ProviderId) DESC )
                                            END
                                        FROM
                                            vw_ClaimEncounters ues 
                                        INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                            ON CI.ClaimInfoId = UES.ClaimInfoID
                                        WHERE
                                            (ues.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                                            AND EncounterDate BETWEEN @d_FromDate
                                            AND @d_ToDate
                                            AND ues.SpecialityId = @i_SpecialityId
                                        GROUP BY
                                            'Spe-' + CONVERT(VARCHAR(12) , ues.SpecialityId) ,
                                            [dbo].[ufn_GetSpecialityById](ues.SpecialityID)  ,
                                            ues.ProviderId,Ues.SpecialityID
                                        HAVING
                                            ( CASE
                                                   WHEN @b_IsByCost = 0 THEN COUNT(ues.ProviderId)
                                                   ELSE SUM(ISNULL(CI.NetPaidAmount , 0))
                                              END ) <> 0
                                    --FETCH NEXT FROM CurSpeciality INTO @i_SpecialityId
                                     SET @id = @id + 1
                              END
                        --CLOSE CurSpeciality
                        --DEALLOCATE CurSpeciality	

                        INSERT INTO
                            #tblType
                            (
                              TypeID ,
                              TypeName ,
                              Type ,
                              SpecialityProviderID ,
                              SpecialityProviderName ,
                              OrderMax
                            )
                            SELECT TOP 1
                                'Pcp-' + CONVERT(VARCHAR(12) , ues.ProviderId) ,
                                dbo.ufn_GetUserNameByID(ues.ProviderId) ,
                                'PCP' ,
                                NULL ,
                                NULL ,
                                CASE
                                     WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT UES.ClaimInfoID) DESC )
                                     ELSE DENSE_RANK() OVER (ORDER BY (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
																		  FROM ClaimInfo 
																		  INNER JOIN (SELECT DISTINCT ClaimInfoID,ProviderId
																					  FROM vw_ClaimEncounters
																					  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate 
																						AND UserID = @i_PatientUserId 
																						AND IsEncounterwithPCP = 1 )CI
																			  ON CI.ProviderId = Ues.ProviderId
																			  AND CI.ClaimInfoID = ClaimInfo.ClaimInfoID) DESC )
                                END
                            FROM
                                vw_ClaimEncounters ues
                            INNER JOIN Users u WITH (NOLOCK)
                                ON ues.UserId = u.UserId
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = UES.ClaimInfoID
								--AND u.UserStatusCode = 'A'
                            WHERE
                                (u.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                                AND EncounterDate BETWEEN @d_Startdate
                                AND @d_EndDate
                                AND ues.IsEncounterwithPCP = 1
                            GROUP BY
                                'Pcp-' + CONVERT(VARCHAR(12) , ues.ProviderId) ,
                                ues.ProviderId
                            HAVING
                                ( CASE @b_IsByCost
                                    WHEN 0 THEN SUM(CAST(ISNULL(ues.IsEncounterwithPCP , 0) AS INT))
                                    ELSE SUM(ISNULL(CI.NetPaidAmount , 0))
                                  END ) <> 0 
                            UNION 
                            SELECT
                                TypeID ,
                                TypeName ,
                                Type ,
                                SpecialityProviderID ,
                                SpecialityProviderName ,
                                OrderMax
                            FROM
                               #SpecialityProvider	 
					
                        INSERT INTO
                            #tblType
                            (
                              TypeID ,
                              TypeName ,
                              Type ,
                              SpecialityProviderID ,
                              SpecialityProviderName ,
                              OrderMax
                            )
                            SELECT TOP 4
                                'Hos-' + CONVERT(VARCHAR(12) , org.ProviderTypeCodeID) ,
                                org.Description ,
                                'Hospital' ,
                                NULL ,
                                NULL ,
                                CASE
                                     WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER (ORDER BY COUNT (DISTINCT UES.ClaimInfoID) DESC )
                                     ELSE DENSE_RANK() OVER (ORDER BY (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
																	  FROM ClaimInfo
																	  INNER JOIN (SELECT DISTINCT ClaimInfoID,OrganizationHospitalId
																				  FROM vw_ClaimEncounters Ue
																				  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
																				  AND UserId = @i_PatientUserId )CI
																		ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
																		AND CI.OrganizationHospitalId = Ues.OrganizationHospitalId) DESC )
                                END
                            FROM
                                vw_ClaimEncounters ues
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = UES.ClaimInfoID
                            INNER JOIN CodeSetProviderType org WITH (NOLOCK)
                                ON ues.OrganizationHospitalId = org.ProviderTypeCodeID
                                   --AND org.OrganizationStatusCode = 'A'
                            WHERE
                                (ues.UserId = @i_PatientUserId OR @i_PatientUserId IS NULL)
                                AND ues.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                'Hos-' + CONVERT(VARCHAR(12) , org.ProviderTypeCodeID) ,
                                org.Description,Ues.OrganizationHospitalId
                            HAVING
                                ( CASE
                                       WHEN @b_IsByCost = 0 THEN SUM(CASE
                                                                          WHEN ues.OrganizationHospitalId IS NOT NULL THEN 1
                                                                          ELSE 0
                                                                     END)
                                       ELSE SUM(ISNULL(CI.NetPaidAmount , 0))
                                  END ) <> 0
                            ORDER BY
                                CASE
                                     WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER (ORDER BY SUM(CASE WHEN ues.OrganizationHospitalId IS NOT NULL THEN 1
																									  ELSE 0
																								 END) DESC,org.description )
                                     ELSE DENSE_RANK() OVER (ORDER BY (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
																	  FROM ClaimInfo
																	  INNER JOIN (SELECT DISTINCT ClaimInfoID,OrganizationHospitalId
																				  FROM vw_ClaimEncounters Ue
																				  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
																				  AND UserId = @i_PatientUserId )CI
																		ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
																		AND CI.OrganizationHospitalId = Ues.OrganizationHospitalId) DESC ,org.description )
                                END
                        
                        SELECT
                            TypeID ,
                            Type ,
                            SpecialityProviderID ,
                            CASE
                                 WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN TypeID
                                 ELSE '0'
                            END AS ParentId ,
                            CASE
                                 WHEN SpecialityProviderID IS NOT NULL THEN SpecialityProviderID
                                 ELSE TypeID
                            END AS ChildId ,
                            CASE
                                 WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN SpecialityProviderName
                                 ELSE TypeName
                            END AS ChildName ,
                            '1' AS IsParent
                        FROM
                            #tblType
                        WHERE
                            ( CASE
                                   WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN ISNULL(SpecialityProviderId , 0)
                                   ELSE typeid
                              END ) NOT IN ( SELECT TOP 1
                                                 PListId
                                             FROM
                                                 @t_ProvidersList )
                            OR TypeID <> @v_TypeId
                        UNION
                        SELECT DISTINCT
                            TypeID ,
                            [Type] ,
                            NULL AS SpecialityProviderID ,
                            '0' AS ParentId ,
                            TypeID AS ChildId ,
                            TypeName AS ChildName ,
                            CASE
                                 WHEN [Type] = 'Speciality' THEN '0'
                                 ELSE '1'
                            END AS IsParent
                        FROM
                            #tblType
                        WHERE
                            ( CASE
                                   WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN ISNULL(SpecialityProviderId , 0)
                                   ELSE typeid
                              END ) NOT IN ( SELECT TOP 1
                                                 PListId
                                             FROM
                                                 @t_ProvidersList )
                            OR TypeID <> @v_TypeId
                  END
         END					
							
---------------------------------------- Admin Level-----------------------------------------

      IF @I_Type IS NOT NULL
  
         BEGIN

               CREATE TABLE #EncounterUsers
               (
                 UserId INT ,
                 CareTeamUserID INT ,
                 IsEncounterwithPCP BIT ,
                 ProviderId INT ,
                 IsInpatient BIT ,
                 ClaimInfoID INT ,
                 EncounterDate DATETIME ,
                 OrganizationHospitalId INT,
                 SpecialityID INT
               )
               INSERT INTO
                   #EncounterUsers
                   SELECT DISTINCT
                       CUL.UserId ,
                       CareTeamUserID ,
                       IsEncounterwithPCP ,
                       ProviderId ,
                       IsInpatient ,
                       ClaimInfoID ,
                       EncounterDate ,
                       OrganizationHospitalId,
                       SpecialityID
                   FROM
                       vw_ClaimEncounters UES
                   INNER JOIN #t_CareUserList CUL
                       ON CUL.UserId = UES.UserId
                   
 ----------------------Last 1 Year ENCOUNTERS(Visits) Data List Based On Admin----------

               SELECT
                   *
               FROM
                   (
                     SELECT
						 COUNT(DISTINCT CareTeamUserID) AS TotalCareProviders ,
                         SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                         (SELECT COUNT(DISTINCT ProviderId)
						  FROM #EncounterUsers
						  WHERE EncounterDate BETWEEN DATEADD(YEAR,-1,GETDATE()) AND GETDATE()
						  AND SpecialityID IS NOT NULL)AS TotalNoofSpecialistVisits  ,	 
                         SUM(CAST(ISNULL(TEU.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                         --SUM(ISNULL(CI.NetPaidAmount , 0)) AS TotalCostIn$ ,
                         (SELECT SUM(ISNULL(CI.NetPaidAmount , 0))
                          FROM ClaimInfo CI
                          INNER JOIN (SELECT DISTINCT ClaimInfoID
									 FROM #EncounterUsers)TEU
                               ON CI.ClaimInfoId = TEU.ClaimInfoID
                          WHERE DateOfAdmit BETWEEN DATEADD(YEAR , -1 , GETDATE()) AND GETDATE() ) AS TotalCostIn$ ,
                         (
                           SELECT TOP 1
                               dbo.ufn_GetUserNameByID(TEU.ProviderId)
                           FROM
                               #EncounterUsers TEU
                           LEFT JOIN ClaimInfo CI WITH (NOLOCK)
                               ON CI.ClaimInfoId = TEU.ClaimInfoID
                           WHERE
                               TEU.EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                               AND GETDATE()
                           GROUP BY
                               TEU.ProviderId
                           ORDER BY
                               SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                         ) AS CareProviderWithMax$ ,
                         (
                           SELECT TOP 1
                               dbo.ufn_GetUserNameByID(TEU.ProviderId)
                           FROM
                               #EncounterUsers TEU
                           LEFT JOIN ClaimInfo CI
                               ON CI.ClaimInfoId = TEU.ClaimInfoID
                           WHERE
                               TEU.EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                               AND GETDATE()
                           GROUP BY
                               TEU.ProviderId
                           ORDER BY
                               COUNT(TEU.ProviderId) DESC
                         ) AS CareProviderWithMaxVisit
                     FROM
                         #EncounterUsers TEU
                     LEFT JOIN ClaimInfo CI
                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                   ) z
		    

----------------------Last 2 Year ENCOUNTERS(Visits) Data List Based On Admin----------	

               SELECT
                   *
               FROM
                   (
                     SELECT
                         COUNT(DISTINCT CareTeamUserID) AS TotalCareProviders ,
                         SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                         (SELECT COUNT(DISTINCT ProviderId)
						  FROM #EncounterUsers
						  WHERE EncounterDate BETWEEN DATEADD(YEAR,-2,GETDATE()) AND GETDATE()
						  AND SpecialityID IS NOT NULL)AS TotalNoofSpecialistVisits  ,	 
                         SUM(CAST(ISNULL(TEU.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                         --SUM(ISNULL(CI.NetPaidAmount , 0)) AS TotalCostIn$ ,
                         (SELECT SUM(ISNULL(CI.NetPaidAmount , 0))
                          FROM ClaimInfo CI
                          INNER JOIN (SELECT DISTINCT ClaimInfoID
									 FROM #EncounterUsers)TEU
                               ON CI.ClaimInfoId = TEU.ClaimInfoID
                          WHERE DateOfAdmit BETWEEN DATEADD(YEAR , -2 , GETDATE()) AND GETDATE() ) AS TotalCostIn$ ,
                         (
                           SELECT TOP 1
                               dbo.ufn_GetUserNameByID(TEU.ProviderId)
                           FROM
                               #EncounterUsers TEU
                           LEFT JOIN ClaimInfo CI WITH (NOLOCK)
                               ON CI.ClaimInfoId = TEU.ClaimInfoID
                           WHERE
                               TEU.EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                               AND GETDATE()
                           GROUP BY
                               TEU.ProviderId
                           ORDER BY
                               SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                         ) AS CareProviderWithMax$ ,
                         (
                           SELECT TOP 1
                               dbo.ufn_GetUserNameByID(TEU.ProviderId)
                           FROM
                               #EncounterUsers TEU
                           LEFT JOIN ClaimInfo CI WITH (NOLOCK)
                               ON CI.ClaimInfoId = TEU.ClaimInfoID
                           WHERE
							   TEU.EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE()) AND GETDATE()
                           GROUP BY
                               TEU.ProviderId
                           ORDER BY
                               COUNT(TEU.ProviderId) DESC
                         ) AS CareProviderWithMaxVisit
                     FROM
                         #EncounterUsers TEU
                     LEFT JOIN ClaimInfo CI
                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                   ) z
		      
               ------------------------------Providers List view data set based on sending providerlist to compare--------------------------

                SELECT
                   *
               FROM
                   (
                     SELECT
                         'Pcp-' + CONVERT(VARCHAR(12) , TEU.ProviderId) ProviderId ,
                         dbo.ufn_GetUserNameByID(TEU.ProviderId) ProviderName ,
                         (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
								  FROM ClaimInfo 
								  INNER JOIN (SELECT DISTINCT ClaimInfoID,ProviderId
											  FROM #EncounterUsers TE
											  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate 
											  AND IsEncounterwithPCP = 1 )CI
									 ON CI.ProviderId = TEU.ProviderId
									 AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID) AS TotalCost ,
                         --SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) AS TotalVisits ,
                         COUNT(DISTINCT TEU.ClaimInfoID) AS TotalVisits ,
                         --COUNT(DISTINCT CLI.IcdcodeId) AS TotalDiagnosis ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
						 FROM #EncounterUsers TU
						 INNER JOIN ClaimLine WITH (NOLOCK)
							 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
						 WHERE TU.IsEncounterwithPCP = 1
						   AND TU.ProviderId = TEU.ProviderId 
						   AND EncounterDate BETWEEN @d_FromDate AND @d_ToDate 	  
						 GROUP BY TU.ProviderId) AS TotalDiagnosis ,
                         COUNT(DISTINCT CI.ClaimInfoID) AS TotalNoOfClaims ,
                         COUNT(DISTINCT CI.ClaimInfoID) / COUNT(DISTINCT TEU.ClaimInfoID) AS 'Claims/Visit' ,
                         CAST((SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
								  FROM ClaimInfo 
								  INNER JOIN (SELECT DISTINCT ClaimInfoID,ProviderId
											  FROM #EncounterUsers TE
											  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate 
											  AND IsEncounterwithPCP = 1 )CI
									 ON CI.ProviderId = TEU.ProviderId
									 AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID) / COUNT(DISTINCT TEU.ClaimInfoID)AS DECIMAL(10,2)) AS 'Dollars/Visit' ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
						 FROM #EncounterUsers TU
						 INNER JOIN ClaimLine
							 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                         INNER JOIN PatientDiagnosisCode CLI
                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
						 WHERE TU.IsEncounterwithPCP = 1
						   AND TU.ProviderId = TEU.ProviderId  
						   AND EncounterDate BETWEEN @d_FromDate AND @d_ToDate	  
						 GROUP BY TU.ProviderId) / COUNT(DISTINCT TEU.ClaimInfoID) AS 'Diagnosis/Visit' ,
						 'PCP' AS Type
                     FROM
                         #EncounterUsers TEU
                     INNER JOIN Users Us WITH (NOLOCK)
                         ON TEU.UserId = Us.UserId
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                     --LEFT JOIN ClaimLineICD CLI
                     --    ON CI.ClaimInfoId = CLI.ClaimInfoId
                     WHERE
                         TEU.IsEncounterwithPCP = 1
                         AND EncounterDate BETWEEN @d_Startdate
                         AND @d_EndDate
                         AND TEU.ProviderId = (
                                          SELECT
                                              CONVERT(INT , SUBSTRING(PListId , CHARINDEX('-' , PListId) + 1 , Len(PListId)))
                                          FROM
                                              @t_ProvidersList
                                          WHERE
                                              ptype = 'PCP'
                                        )
                     GROUP BY
                         TEU.ProviderId 
                     UNION 
                     SELECT DISTINCT
                        'Spe-' + CONVERT(VARCHAR(12) , TEU.ProviderId) ProviderId ,
                        dbo.ufn_GetUserNameByID(TEU.ProviderId) AS ProviderName ,
                        --SUM(ISNULL(CI.NetPaidAmount , 0)) AS TotalCost ,
                        (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
							  FROM ClaimInfo
							  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId,Ue.ProviderId 
										  FROM #EncounterUsers Ue
										  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate)CI
								ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
								AND CI.SpecialityId = TEU.SpecialityID 
								AND CI.ProviderId = TEU.ProviderId )AS TotalCost ,
                        COUNT(DISTINCT TEU.ClaimInfoID) AS TotalVisits ,
                        --COUNT(CLI.IcdcodeId) AS TotalDiagnosis ,
                        (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
						   FROM #EncounterUsers TE
						   INNER JOIN ClaimLine WITH (NOLOCK)
							 ON ClaimLine.ClaimInfoID = TE.ClaimInfoID    
                           INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
						   WHERE TEU.ProviderId = TE.ProviderId
						   AND TE.SpecialityID = TEU.SpecialityID
						   AND EncounterDate BETWEEN @d_FromDate AND @d_ToDate
						   GROUP BY TE.ProviderId,TE.SpecialityID ) AS TotalDiagnosis,
                        COUNT(DISTINCT CI.ClaimInfoId) AS TotalNoOfClaims ,
                        COUNT(DISTINCT CI.ClaimInfoId) / COUNT(DISTINCT TEU.ClaimInfoID) AS 'Claims/Visit' ,
                        CAST((SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
							  FROM ClaimInfo
							  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId,Ue.ProviderId 
										  FROM #EncounterUsers Ue
										  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate)CI
								ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
								AND CI.SpecialityId = TEU.SpecialityID 
								AND CI.ProviderId = TEU.ProviderId ) / COUNT(DISTINCT TEU.ClaimInfoID)AS DECIMAL(10,2)) AS 'Dollars/Visit' ,
                        (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
						   FROM #EncounterUsers TE
						   INNER JOIN ClaimLine WITH (NOLOCK)
							 ON ClaimLine.ClaimInfoID = TE.ClaimInfoID    
                           INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
						   WHERE TEU.ProviderId = TE.ProviderId
						   AND TEU.SpecialityID = TE.SpecialityID
						   AND EncounterDate BETWEEN @d_FromDate AND @d_ToDate
						   GROUP BY TE.ProviderId,TE.SpecialityID ) / COUNT(DISTINCT TEU.ClaimInfoID) AS 'Diagnosis/Visit' ,
                        'Specialist' AS Type
                    FROM
                        #EncounterUsers TEU 
                    INNER JOIN @t_ProvidersList PL
                        ON CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , ( CHARINDEX('*' , PL.PListId) - 1 ) - CHARINDEX('-' , PL.PListId)) )) = TEU.ProviderId
                    INNER JOIN ClaimInfo CI WITH (NOLOCK)
                        ON CI.ClaimInfoId = TEU.ClaimInfoID
                    WHERE
                        EncounterDate BETWEEN @d_Startdate
                        AND @d_EndDate
                        AND PL.ptype = 'Spe'
                        AND CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)))) = TEU.SpecialityID
                    GROUP BY
                        TEU.ProviderId,TEU.SpecialityID 
               UNION 
                    SELECT DISTINCT
                         'Hos-' + CONVERT(VARCHAR(12) , TEU.OrganizationHospitalId) ProviderId,
                         Dbo.ufn_OrganizationName(TEU.OrganizationHospitalId) AS ProviderName ,
                         --SUM(ISNULL(CI.NetPaidAmount , 0)) AS TotalCost ,
                         (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
								  FROM ClaimInfo
								  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.OrganizationHospitalId
											  FROM #EncounterUsers Ue
											  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate )CI
									ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
									AND CI.OrganizationHospitalId = TEU.OrganizationHospitalId) AS TotalCost ,
                         COUNT(DISTINCT TEU.ClaimInfoID) AS TotalVisits ,
                         --COUNT(CLI.ICDCodeId) TotalDiagnosis ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
							 FROM #EncounterUsers TU
							 INNER JOIN ClaimLine WITH (NOLOCK)
							 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                           INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
							 WHERE TU.OrganizationHospitalId = TEU.OrganizationHospitalId
							 AND EncounterDate BETWEEN @d_FromDate AND @d_ToDate  	  
							 GROUP BY TU.OrganizationHospitalId) AS TotalDiagnosis ,
                         COUNT(DISTINCT CI.ClaimInfoId) AS TotalNoofClaims ,
                         COUNT(DISTINCT CI.ClaimInfoId) /COUNT(DISTINCT TEU.ClaimInfoID) AS 'Claims/Visit' ,
                         CAST((SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
								  FROM ClaimInfo
								  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.OrganizationHospitalId
											  FROM #EncounterUsers Ue
											  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate )CI
									ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
									AND CI.OrganizationHospitalId = TEU.OrganizationHospitalId)/ COUNT(DISTINCT TEU.ClaimInfoID)AS DECIMAL(10,2)) AS 'Dollars/Visit' ,
                         (SELECT COUNT(DISTINCT PatientDiagnosisCodeId)
							 FROM #EncounterUsers TU
							 INNER JOIN ClaimLine WITH (NOLOCK)
							 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                           INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
							 WHERE TU.OrganizationHospitalId = TEU.OrganizationHospitalId 
							 AND EncounterDate BETWEEN @d_FromDate AND @d_ToDate 	  
							 GROUP BY TU.OrganizationHospitalId) / COUNT(DISTINCT TEU.ClaimInfoID) AS 'Diagnosis/Visit' ,
                         'Hospital' AS Type
                     FROM
                         #EncounterUsers TEU
                     INNER JOIN @t_ProvidersList PL
                         ON CONVERT(INT , SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , Len(PL.PListId))) = TEU.OrganizationHospitalId
                     INNER JOIN CodeSetProviderType Org WITH (NOLOCK)
                         ON TEU.OrganizationHospitalId = Org.ProviderTypeCodeID
                            AND Org.StatusCode = 'A'
                     INNER JOIN ClaimInfo CI
                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                     --LEFT JOIN ClaimLineICD CLI
                     --    ON CI.ClaimInfoId = CLI.ClaimInfoId
                     WHERE
                         TEU.EncounterDate BETWEEN @d_Startdate
                         AND @d_EndDate
                         AND PL.ptype = 'Hos'
                         AND TEU.OrganizationHospitalId IS NOT NULL
                     GROUP BY
                         TEU.OrganizationHospitalId,Org.ProviderTypeCodeID
                   ) Z	
                   
                   
                   	
 -------------------------Comparision Graph Data For care Providers --------------------------------

               INSERT
                   @FinalGraphData
                   (
                     ProviderId ,
                     ProviderName ,
                     Encounterdate ,
                     TotalNoofVisits ,
                     TotalCost
                   )
                   SELECT
                       'Pcp-' + CONVERT(VARCHAR(12) , TEU.ProviderId) ,
                       dbo.ufn_GetUserNameByID(TEU.ProviderId) ,
                       CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01' ,
                       SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) ,
                       --SUM(ISNULL(CI.NetPaidAmount , 0))
                       (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo 
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,ProviderId,CAST(YEAR(EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , EncounterDate) + '/01' AS EncounterDate
									  FROM #EncounterUsers
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate 
										AND IsEncounterwithPCP = 1 )CI
						      ON CI.ProviderId = TEU.ProviderId
						      and CI.claiminfoId = ClaimInfo.ClaimInfoid
						      AND EncounterDate = CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01' )
                   FROM
                       #EncounterUsers TEU
                   --INNER JOIN Users Us
                   --    ON TEU.UserId = Us.UserId
                   INNER JOIN ClaimInfo CI WITH (NOLOCK)
                       ON CI.ClaimInfoId = TEU.ClaimInfoID
                   --LEFT JOIN ClaimLineICD CLI
                   --    ON CI.ClaimInfoId = CLI.ClaimInfoId
                   WHERE
                       TEU.IsEncounterwithPCP = 1
                       AND TEU.EncounterDate BETWEEN @d_Startdate
                       AND @d_EndDate
                       AND TEU.ProviderId = ( SELECT
													CONVERT(INT , SUBSTRING(PListId , CHARINDEX('-' , PListId) + 1 , Len(PListId)))
												FROM
													@t_ProvidersList
												WHERE
													ptype = 'PCP' )
                   GROUP BY
                       'Pcp-' + CONVERT(VARCHAR(12) , TEU.ProviderId) ,
                       CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01' ,
                       TEU.ProviderId 
                   UNION 
                   SELECT
                      'Spe-' + CONVERT(VARCHAR(12) , TEU.ProviderId) + '*' + CONVERT(VARCHAR , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)- CHARINDEX('*' , PL.PListId)))),
                      dbo.ufn_GetUserNameByID(TEU.ProviderId)+ '*' + CONVERT(VARCHAR , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)- CHARINDEX('*' , PL.PListId)))) ,
                      CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01' ,
                      SUM(CASE
                               WHEN TEU.ProviderId IS NOT NULL THEN 1
                               ELSE 0
                          END) ,
                      --SUM(ISNULL(CI.NetPaidAmount , 0))
                      (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
							  FROM ClaimInfo
							  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId ,UE.ProviderId,CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' AS EncounterDate
										  FROM #EncounterUsers Ue
										  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate )CI
								ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
								AND CI.SpecialityId = TEU.SpecialityID
								AND CI.ProviderId = TEU.ProviderId
								AND CI.EncounterDate = CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01')
                  FROM
                      #EncounterUsers TEU --LEFT JOIN UserProviders Up
                  --ON Up.UserProviderID = TEU.UserProviderID
                  INNER JOIN @t_ProvidersList PL
                      ON CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , ( CHARINDEX('*' , PL.PListId) - 1 ) - CHARINDEX('-' , PL.PListId)) )) = TEU.ProviderId
				  INNER JOIN ClaimInfo CI WITH (NOLOCK)
                      ON CI.ClaimInfoId = TEU.ClaimInfoID
                  --LEFT JOIN ClaimLine CL
                  --    ON CI.ClaimInfoId = CL.ClaimInfoId
                  WHERE
                      TEU.EncounterDate BETWEEN @d_Startdate
                      AND @d_EndDate
                      AND PL.ptype = 'Spe'
                      AND CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)))) = TEU.SpecialityID
                      AND dbo.ufn_GetUserNameByID(TEU.ProviderId) IS NOT NULL
                  GROUP BY
                      'Spe-' + CONVERT(VARCHAR(12) , TEU.ProviderId) ,CONVERT(INT , ( SUBSTRING(PL.PListId , CHARINDEX('*' , PL.PListId) + 1  , LEN(PL.PListId)))),
                      CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01', TEU.ProviderId ,PL.PListId ,TEU.SpecialityID
                  UNION 
                  SELECT
                       'Hos-' + CONVERT(VARCHAR(12) , TEU.OrganizationHospitalId) ,
                       Dbo.ufn_OrganizationName(TEU.OrganizationHospitalId) ,
                       CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01' ,
                       SUM(CASE
                                WHEN TEU.OrganizationHospitalId IS NOT NULL THEN 1
                                ELSE 0
                           END) ,
                       --SUM(ISNULL(CI.NetPaidAmount , 0))
                       (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
							  FROM ClaimInfo
							  INNER JOIN (SELECT DISTINCT ClaimInfoID,OrganizationHospitalId,CAST(YEAR(Ue.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , Ue.EncounterDate) + '/01' AS EncounterDate
										  FROM #EncounterUsers Ue
										  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate)CI
								ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
								AND CI.OrganizationHospitalId = TEU.OrganizationHospitalId
								AND CI.EncounterDate = CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01')
                   FROM
                       #EncounterUsers TEU
                   INNER JOIN @t_ProvidersList PL
                       ON CONVERT(INT , SUBSTRING(PL.PListId , CHARINDEX('-' , PL.PListId) + 1 , LEN(PL.PListId))) = TEU.OrganizationHospitalId
                   INNER JOIN CodeSetProviderType Org WITH (NOLOCK)
                       ON TEU.OrganizationHospitalId = Org.ProviderTypeCodeID
                          AND Org.StatusCode = 'A'
                   INNER JOIN ClaimInfo CI WITH (NOLOCK)
                       ON CI.ClaimInfoId = TEU.ClaimInfoID
                   --LEFT JOIN ClaimLineICD CLI
                   --    ON CI.ClaimInfoId = CLI.ClaimInfoId
                   WHERE
                       TEU.EncounterDate BETWEEN @d_Startdate
                       AND @d_EndDate
                       AND PL.ptype = 'Hos'
                       AND TEU.OrganizationHospitalId IS NOT NULL
                   GROUP BY
                       'Hos-' + CONVERT(VARCHAR(12) , TEU.OrganizationHospitalId) ,
                       TEU.OrganizationHospitalId ,
                       CAST(YEAR(TEU.EncounterDate) AS VARCHAR) + '/' + DATENAME(MONTH , TEU.EncounterDate) + '/01'

               INSERT
                   @FinalGraphData
                   (
                     ProviderId ,
                     ProviderName ,
                     Encounterdate ,
                     TotalNoofVisits ,
                     TotalCost
                   )
                   SELECT
                       PListId ,
                       NULL ,
                       CAST(YEAR(@d_Startdate) AS VARCHAR) + '/' + DATENAME(MONTH , @d_Startdate) + '/01' ,
                       0 ,
                       00.00
                   FROM
                       @t_ProvidersList TPL
                   WHERE
                       NOT EXISTS ( SELECT
                                        1
                                    FROM
                                        @FinalGraphData TFGD
                                    WHERE
                                        CASE SUBSTRING(TPL.PListId , 1 , 3)
                                          WHEN 'Spe' THEN SUBSTRING(TPL.PListId , 1 , ( CHARINDEX('*' , TPL.PListId) - 1 ))
                                          ELSE TPL.PListId
                                        END = TFGD.ProviderId )
                       AND (
                             PListId IS NOT NULL
                             OR PListId <> ''
                           )


               SET @d_DateTaken = CAST(YEAR(@d_Startdate) AS VARCHAR) + '/' + DATENAME(MONTH , @d_Startdate) + '/01'
               WHILE @d_DateTaken <= CAST(YEAR(@d_EndDate) AS VARCHAR) + '/' + DATENAME(MONTH , @d_EndDate) + '/01'
                     BEGIN
                           INSERT INTO
                               @t_EncounterDatetaken
                               (
                                 Encounterdate
                               )
                               SELECT
                                   @d_DateTaken

                           SET @d_DateTaken = ( SELECT
                                                    DATEADD(MONTH , 1 , @d_DateTaken) )
                     END

               DECLARE GetMonths_Cursor CURSOR
                       FOR SELECT
                               ProviderId ,
                               COUNT(1) ,
                               ProviderName
                           FROM
                               @FinalGraphData
                           GROUP BY
                               ProviderId ,
                               ProviderName

               OPEN GetMonths_Cursor
               FETCH NEXT FROM GetMonths_Cursor INTO @v_Id,@i_Cnt,@v_Name
               
               WHILE @@FETCH_STATUS = 0
               AND @i_Cnt < 12
                     BEGIN
                           INSERT INTO
                               @FinalGraphData
                               (
                                 ProviderId ,
                                 ProviderName ,
                                 Encounterdate ,
                                 TotalNoofVisits ,
                                 TotalCost
                               )
                               SELECT
                                   @v_Id ,
                                   @v_Name ,
                                   Encounterdate ,
                                   0 ,
                                   00.00
                               FROM
                                   @t_EncounterDatetaken EncounterDateTaken
                               WHERE
                                   EncounterDateTaken.Encounterdate NOT IN ( SELECT
                                                                                 Encounterdate
                                                                             FROM
                                                                                 @FinalGraphData
                                                                             WHERE
                                                                                 Providerid = @v_Id )

                           FETCH NEXT FROM GetMonths_Cursor INTO @v_Id,@i_Cnt,@v_Name
                     END
                    
               CLOSE GetMonths_Cursor
               DEALLOCATE GetMonths_Cursor

               IF @b_IsByCost = 0
                  SELECT
                      ProviderId ,
                      ProviderName ,
                      SUBSTRING(CONVERT(VARCHAR(10) , DATENAME(MM , EncounterDate)) , 1 , 3) + ' ' + CONVERT(VARCHAR(4) , DATEPART(YEAR , EncounterDate)) AS EncounterMonth ,
                      TotalNoofVisits ,
                      Encounterdate
                  FROM
                      @FinalGraphData
                  ORDER BY
                      ProviderId ,
                      EncounterDate
               ELSE
                  SELECT
                      ProviderId ,
                      ProviderName ,
                      SUBSTRING(CONVERT(VARCHAR(10) , DATENAME(MM , EncounterDate)) , 1 , 3) + ' ' + CONVERT(VARCHAR(4) , DATEPART(YEAR , EncounterDate)) AS EncounterMonth ,
                      ISNULL(TotalCost,0.0) AS TotalCost,
                      Encounterdate
                  FROM
                      @FinalGraphData
                  ORDER BY
                      ProviderId ,
                      EncounterDate		
	           
----------------------------------------Tree View For Care Providers---------------------------------------
               IF
               ( SELECT
                     COUNT(*)
                 FROM
                     @t_ProvidersList ) = 1
                  BEGIN

                        CREATE TABLE #tSpeciality1
                        (
                          SpecialityId INT
                        )
                        IF @b_IsByCost = 0
                           BEGIN
                                 INSERT INTO
                                     #tSpeciality1
                                     (
                                       SpecialityId
                                     )
                                     SELECT TOP 5
                                         TEU.SpecialityId
                                     FROM
                                         #EncounterUsers TEU 
                                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                                     --LEFT JOIN ClaimLine CL
                                     --    ON CI.ClaimInfoId = CL.ClaimInfoId
                                     WHERE
                                         TEU.EncounterDate BETWEEN @d_FromDate
                                         AND @d_ToDate
                                         AND  TEU.SpecialityId IS NOT NULL
                                     GROUP BY
                                         TEU.SpecialityId
                                     HAVING
                                         COUNT(TEU.ProviderId) <> 0
                                     ORDER BY
                                         DENSE_RANK() OVER (ORDER BY SUM(CASE WHEN TEU.ProviderId IS NOT NULL THEN 1
																			  ELSE 0
																		 END) DESC )
                           END
                        ELSE
                           BEGIN
                                 INSERT INTO
                                     #tSpeciality1
                                     (
                                       SpecialityId
                                     )
                                     SELECT TOP 5
                                         TEU.SpecialityId
                                     FROM
                                         #EncounterUsers TEU 
                                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                                     --LEFT JOIN ClaimLine CL
                                     --    ON CI.ClaimInfoId = CL.ClaimInfoId
                                     WHERE
                                         TEU.EncounterDate BETWEEN @d_FromDate
                                         AND @d_ToDate
                                         AND  TEU.SpecialityId IS NOT NULL
                                     GROUP BY
                                         TEU.SpecialityId
                                     HAVING
                                         SUM(ISNULL(CI.NetPaidAmount , 0)) <> 0
                                     ORDER BY DENSE_RANK() OVER (ORDER BY SUM(ISNULL(CI.NetPaidAmount , 0)) DESC)
                           END
                                   
                                  
		

                        DECLARE CurSpeciality CURSOR
                                FOR SELECT
                                        SpecialityId
                                    FROM
                                        #tSpeciality1

                        OPEN CurSpeciality
                        FETCH NEXT FROM CurSpeciality INTO @i_SpecialityId
                        WHILE @@FETCH_STATUS = 0
                              BEGIN
                                    INSERT INTO
                                        #SpecialityProvider
                                        (
                                          ID ,
                                          TypeID ,
                                          TypeName ,
                                          Type ,
                                          SpecialityProviderID ,
                                          SpecialityProviderName ,
                                          OrderMax
                                        )
                                        SELECT DISTINCT TOP 10
                                            'Spe-' + CONVERT(VARCHAR(12) , TEU.ProviderId) + '*' + CONVERT(VARCHAR(12) , @i_SpecialityId) ,
                                            'Spe-' + CONVERT(VARCHAR(12) , @i_SpecialityId) ,
                                            [dbo].[ufn_GetSpecialityById](TEU.SpecialityID) SpecialityName,
                                            --spy.SpecialityName ,
                                            'Speciality' ,
                                            'Spe-' + CONVERT(VARCHAR(12) , TEU.ProviderId) + '*' + CONVERT(VARCHAR(12) , @i_SpecialityId) ,
                                            dbo.ufn_GetUserNameByID(TEU.ProviderId) ,
                                            CASE
                                                 WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER (ORDER BY COUNT(TEU.ProviderId) DESC )
                                                 ELSE DENSE_RANK() OVER (ORDER BY SUM(ISNULL(CI.NetPaidAmount , 0)) DESC )
                                            END
                                        FROM
                                            #EncounterUsers TEU
                                        LEFT JOIN ClaimInfo CI WITH (NOLOCK)
                                            ON CI.ClaimInfoId = TEU.ClaimInfoID
                                        WHERE
                                            EncounterDate BETWEEN @d_FromDate
                                            AND @d_ToDate
                                            AND TEU.SpecialityId = @i_SpecialityId
                                        GROUP BY
                                            'Spe-' + CONVERT(VARCHAR(12) , TEU.SpecialityId) ,
                                           [dbo].[ufn_GetSpecialityById](TEU.SpecialityID) ,
                                           TEU.ProviderId--,
                                        HAVING
                                            ( CASE
                                                   WHEN @b_IsByCost = 0 THEN COUNT(TEU.ProviderId)
                                                   ELSE SUM(ISNULL(CI.NetPaidAmount , 0))
                                              END ) <> 0
                                    FETCH NEXT FROM CurSpeciality INTO @i_SpecialityId

                              END
                        CLOSE CurSpeciality
                        DEALLOCATE CurSpeciality		

 --select * from #SpecialityProvider

                        INSERT INTO
                            #tblType
                            SELECT TOP 1
                                'Pcp-' + CONVERT(VARCHAR(12) , TEU.ProviderId) ,
                                dbo.ufn_GetUserNameByID(TEU.ProviderId) ,
                                'PCP' ,
                                NULL ,
                                NULL ,
                                CASE
                                     WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER ( ORDER BY SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) DESC )
                                     ELSE DENSE_RANK() OVER (ORDER BY SUM(ISNULL(CI.NetPaidAmount , 0)) DESC )
                                END
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN Users u
                                ON TEU.UserId = u.UserId
                            LEFT JOIN ClaimInfo CI
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                                   --AND u.UserStatusCode = 'A'
                            WHERE
                                EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                                AND TEU.IsEncounterwithPCP = 1
                                AND 'Pcp-' + CONVERT(VARCHAR(12) , TEU.ProviderId) IS NOT NULL
                            GROUP BY
                                'Pcp-' + CONVERT(VARCHAR(12) , TEU.ProviderId) ,
                                TEU.ProviderId
                            HAVING
                                ( CASE
                                       WHEN @b_IsByCost = 0 THEN SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT))
                                       ELSE SUM(ISNULL(CI.NetPaidAmount , 0))
                                  END ) <> 0 
                            UNION 
                            SELECT
                               TypeID ,
                               TypeName ,
                               Type ,
                               SpecialityProviderID ,
                               SpecialityProviderName ,
                               OrderMax
                            FROM
                               #SpecialityProvider

                        INSERT INTO
                            #tblType
                            (
                              TypeID ,
                              TypeName ,
                              Type ,
                              SpecialityProviderID ,
                              SpecialityProviderName ,
                              OrderMax
                            )
                            SELECT TOP 4
                                'Hos-' + CONVERT(VARCHAR(12) , org.ProviderTypeCodeID) ,
                                org.Description ,
                                'Hospital' ,
                                NULL ,
                                NULL ,
                                CASE
                                     WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER (ORDER BY SUM(CASE WHEN TEU.OrganizationHospitalId IS NOT NULL THEN 1
																									  ELSE 0
																								 END) DESC )
                                     ELSE DENSE_RANK() OVER ( ORDER BY SUM(ISNULL(CI.NetPaidAmount , 0)) DESC )
                                END
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN CodesetProviderType org WITH (NOLOCK)
                                ON TEU.OrganizationHospitalId = org.ProviderTypeCodeID
                                   AND org.StatusCode = 'A'
                            LEFT JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                            WHERE
                                TEU.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                                AND TEU.OrganizationHospitalId IS NOT NULL
                            GROUP BY
                                'Hos-' + CONVERT(VARCHAR(12) , org.ProviderTypeCodeID) ,
                                org.Description
                            HAVING
                                ( CASE
                                       WHEN @b_IsByCost = 0 THEN SUM(CASE
                                                                          WHEN TEU.OrganizationHospitalId IS NOT NULL THEN 1
                                                                          ELSE 0
                                                                     END)
                                       ELSE SUM(ISNULL(CI.NetPaidAmount , 0))
                                  END ) <> 0
                            ORDER BY CASE WHEN @b_IsByCost = 0 THEN DENSE_RANK() OVER (ORDER BY SUM(CASE WHEN TEU.OrganizationHospitalId IS NOT NULL THEN 1
																										  ELSE 0
																									 END) DESC )
                                     ELSE DENSE_RANK() OVER ( ORDER BY SUM(ISNULL(CI.NetPaidAmount , 0)) DESC )
                                END
                        
                        SELECT
                            TypeID ,
                            Type ,
                            SpecialityProviderID ,
                            CASE
                                 WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN TypeID
                                 ELSE '0'
                            END AS ParentId ,
                            CASE
                                 WHEN SpecialityProviderID IS NOT NULL THEN SpecialityProviderID
                                 ELSE TypeID
                            END AS ChildId ,
                            CASE
                                 WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN SpecialityProviderName
                                 ELSE TypeName
                            END AS ChildName ,
                            '1' IsParent
                        FROM
                            #tblType
                        WHERE
                            ( CASE
                                   WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN ISNULL(SpecialityProviderId , 0)
                                   ELSE typeid
                              END ) NOT IN ( SELECT TOP 1
                                                 PListId
                                             FROM
                                                 @t_ProvidersList )
                            OR TypeID <> @v_TypeId
                        UNION
                        SELECT DISTINCT
                            TypeID ,
                            [Type] ,
                            NULL AS SpecialityProviderID ,
                            '0' AS ParentId ,
                            TypeID AS ChildId ,
                            TypeName AS ChildName ,
                            CASE
                                 WHEN [Type] = 'Speciality' THEN '0'
                                 ELSE '1'
                            END AS IsParent
                        FROM
                            #tblType
                        WHERE
                            ( CASE
                                   WHEN SUBSTRING(TypeID , 1 , 3) = 'Spe' THEN ISNULL(SpecialityProviderId , 0)
                                   ELSE typeid
                              END ) NOT IN ( SELECT TOP 1
                                                 PListId
                                             FROM
                                                 @t_ProvidersList )
                            OR TypeID <> @v_TypeId
                  END
   
         END END TRY
------------------------------------------------------------------------------------------------------------------------- 
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_CareCoordination_Compare] TO [FE_rohit.r-ext]
    AS [dbo];

