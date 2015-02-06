/*
---------------------------------------------------------------------------------
Procedure Name: [usp_UserSpeciality_SelectByPatientUserId]
Description	  : This procedure is used to select all the Provider Details based on SpecialityId. 
Created By    :	NagaBabu 
Created Date  : 22-Sep-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
23-Dec-2011 NagaBabu Differenciated script according to @i_Type
02-Jan-2011 NagaBabu Added Order By clause and added TOP 10 Key word for first select statement
06-Jan-2011 NagaBabu Modified Getting Providers list as ISNULL(Ue.ProviderId,ISNULL(Up.ProviderUserId,Up.ExternalProviderId))
10-Jan-2011 NagaBabu Added where clause for resultset querry for restrict the data of Cost or vists values are 0 
						And replaced all table variables as TempTables on part of performence tuning
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers  
---------------------------------------------------------------------------------
*/   --usp_UserSpeciality_SelectByPatientUserId @i_AppUserId=10926,@d_FromDate='2008-07-17 23:57:27.103',@d_ToDate='2013-07-01 00:00:00',@i_PatientUserId=4010,@i_SpecialityId=N'Spe-37',@b_IsByCost=0,@I_Type =default,@I_SubTypeId =0
CREATE PROCEDURE [dbo].[usp_UserSpeciality_SelectByPatientUserId]
(
 @i_AppUserId KEYID ,
 @i_PatientUserId KEYID ,
 @i_SpecialityId VARCHAR(12) ,
 @d_FromDate DATETIME ,
 @d_ToDate DATETIME ,
 @b_IsByCost ISINDICATOR = 1 ,
 @i_Type VARCHAR(10) = NULL ,
 @i_SubTypeId KEYID = NULL
)
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
      
  ---------------Getting data from UserSpeciality table----------------------

      CREATE TABLE #tSpecialistDoctors
      (
        ID VARCHAR(20) ,
        Name VARCHAR(50) ,
        SpecialityName VARCHAR(150) ,
        TypeId INT ,
        Cost decimal(10,2) ,
        Visits INT ,
        LastVisit DATE ,
				--ProviderName VARCHAR(50),
        TotalVisits INT ,
        TotalCost decimal(10,2) ,
        DollarsPerVisit INT ,
        DiagnosisPerProviders INT ,
        OrderMax INT
      )

      CREATE TABLE #tSpecialist
      (
        SpecialityId INT ,
        SpecialityName VARCHAR(150) ,
        UserProviderID INT ,
        SpecialistName VARCHAR(150)
      )

      IF @i_Type IS NULL
         BEGIN
               INSERT INTO
                   #tSpecialistDoctors
                   (
                     ID ,
                     Name ,
                     TypeId ,
                     SpecialityName ,
                     Cost ,
                     Visits ,
                     LastVisit ,
						--ProviderName ,
                     TotalVisits ,
                     --TotalCost ,
                     DollarsPerVisit ,
                     DiagnosisPerProviders
                   )
                   SELECT
                       'Spe-' + CONVERT(VARCHAR(12) , 
                       vw_ClaimEncounters.ProviderId) + '*' + SUBSTRING(@i_SpecialityId , CHARINDEX('-' , @i_SpecialityId) + 1 , Len(@i_SpecialityId)) ,
                       COALESCE(ISNULL(P.LastName , '') + ', ' 
                       --+ ISNULL(Users.FirstName , '') + '. ' 
                       + ISNULL(P.MiddleName , '') + ' ' + ISNULL(P.NameSuffix , '') , '') AS SpecialistName ,
                       vw_ClaimEncounters.SpecialityId ,
                       [dbo].[ufn_GetSpecialityById](vw_ClaimEncounters.SpecialityId) SpecialityName,
                       (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId,Ue.ProviderId 
									  FROM vw_ClaimEncounters Ue
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
									  AND UserId = @i_PatientUserId )CI
						    ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
						    AND CI.SpecialityId = vw_ClaimEncounters.SpecialityId 
						    AND CI.ProviderId = vw_ClaimEncounters.ProviderId ) ,
					   COUNT(DISTINCT vw_ClaimEncounters.ClaimInfoId) ,	
					   MAX(EncounterDate) AS LastVisit ,
					   COUNT(DISTINCT vw_ClaimEncounters.ClaimInfoId)AS TotalVisits ,
	                  (SELECT CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
						  FROM ClaimInfo
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ue.SpecialityId,Ue.ProviderId 
									  FROM vw_ClaimEncounters Ue
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate
									  AND UserId = @i_PatientUserId )CI
						    ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
						    AND CI.SpecialityId = vw_ClaimEncounters.SpecialityId 
						    AND CI.ProviderId = vw_ClaimEncounters.ProviderId ) ,
                       --COUNT(vw_ClaimEncounters.UserProviderID) AS 'DollarsPerVisit' ,
                       (SELECT COUNT(DISTINCT PatientDiagnosisCodeID)
                         FROM vw_ClaimEncounters Ues
						 INNER JOIN PatientDiagnosisCode  CLI WITH(NOLOCK)
						    ON Ues.ClaimInfoID = CLI.ClaimInfoID   	  
					     WHERE Ues.SpecialityId = vw_ClaimEncounters.SpecialityId
						   AND Ues.UserId = @i_PatientUserId
						   AND Ues.ProviderId = vw_ClaimEncounters.ProviderId
						 GROUP BY Ues.SpecialityId,Ues.UserId,Ues.ProviderId )
                   FROM
                       vw_ClaimEncounters
                   	INNER JOIN Provider P
					 on P.ProviderID = vw_ClaimEncounters.ProviderId 
					LEFT JOIN Users 
					 ON Users.UserId = P.ProviderId  
                   WHERE
                       vw_ClaimEncounters.SpecialityId = CONVERT(INT , SUBSTRING(@i_SpecialityId , CHARINDEX('-' , @i_SpecialityId) + 1 , Len(@i_SpecialityId)))
                       AND (@i_PatientUserId IS NULL OR vw_ClaimEncounters.UserId = @i_PatientUserId)
                       AND vw_ClaimEncounters.EncounterDate BETWEEN @d_FromDate
                       AND @d_ToDate 
				   GROUP BY
                       vw_ClaimEncounters.SpecialityId ,
                       [dbo].[ufn_GetSpecialityById](vw_ClaimEncounters.SpecialityId) ,
                       P.LastName ,
                       P.FirstName ,
                       P.MiddleName ,
                       P.NameSuffix ,
                       vw_ClaimEncounters.ProviderId ,
                       Users.UserId
					--ORDER BY 'Spe-'+  CONVERT(VARCHAR(12),(UserEncounters.ProviderId)+ '*' + SUBSTRING(@i_SpecialityId,CHARINDEX('-',@i_SpecialityId)+1,Len(@i_SpecialityId))

               INSERT INTO
                   #tSpecialist
                   (
                     SpecialityId ,
                     SpecialityName ,
                     UserProviderID ,
                     SpecialistName
                   )
                   SELECT DISTINCT
                       vw_ClaimEncounters.SpecialityId ,
                       [dbo].[ufn_GetSpecialityById](vw_ClaimEncounters.SpecialityId) SpecialityName,
                       Users.UserId ,
                       COALESCE(ISNULL(P.LastName , '') + ', ' 
                       +-- ISNULL(Users.FirstName , '') + '. ' 
                       + ISNULL(P.MiddleName , '') + ' ' + ISNULL(P.NameSuffix , '') , '') AS SpecialistName
                   FROM
                       vw_ClaimEncounters 
				 	INNER JOIN Provider P
					 on P.ProviderID = vw_ClaimEncounters.ProviderId 
					LEFT JOIN Users 
					 ON Users.UserId = P.ProviderId  
                   WHERE
                       vw_ClaimEncounters.SpecialityId = CONVERT(INT , SUBSTRING(@i_SpecialityId , CHARINDEX('-' , @i_SpecialityId) + 1 , Len(@i_SpecialityId)))
                       AND (@i_PatientUserId IS NULL OR vw_ClaimEncounters.UserId = @i_PatientUserId)
                       AND vw_ClaimEncounters.EncounterDate BETWEEN @d_FromDate
                       AND @d_ToDate
         END

      IF @i_Type IS NOT NULL
         BEGIN

               CREATE TABLE #tCareUserList
               (
                 UserId INT
               )

               IF @i_Type = 'Cohort'

                  INSERT INTO
                      #tCareUserList
                      SELECT
                          PatientID
                      FROM
                          PopulationDefinitionPatients
                      WHERE
                          (
                          PopulationDefinitionId = @i_SubTypeId
                          OR @i_SubTypeId IS NULL
                          )
                          AND StatusCode = 'A'
               ELSE
                  IF @i_Type = 'Program'

                     INSERT INTO
                         #tCareUserList
                         SELECT distinct
                            PatientID
                         FROM
                             PatientProgram
                         WHERE
                             (
                             ProgramId = @i_SubTypeId
                             OR @i_SubTypeId IS NULL
                             )
                             AND StatusCode = 'A'
		
               INSERT INTO
                   #tSpecialistDoctors
                   (
                     ID ,
                     Name ,
                     TypeId ,
                     SpecialityName ,
                     Cost ,
                     Visits ,
                     LastVisit ,
					--ProviderName ,
                     TotalVisits ,
                     --TotalCost ,
                     DollarsPerVisit ,
                     DiagnosisPerProviders
                   )
                   SELECT
                       'Spe-' + CONVERT(VARCHAR(12) , Ue.ProviderId) + '*' + SUBSTRING(@i_SpecialityId , CHARINDEX('-' , @i_SpecialityId) + 1 , Len(@i_SpecialityId)) ,
                       COALESCE(ISNULL(P.LastName , '') + ', ' + 
                       --ISNULL(Us.FirstName , '') + '. ' +
                        ISNULL(P.MiddleName , '') + ' ' + ISNULL(P.NameSuffix , '') , '') AS SpecialistName ,
                       UE.SpecialityId ,
                       [dbo].[ufn_GetSpecialityById](UE.SpecialityId) SpecialityName ,
                       (SELECT CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo WITH(NOLOCK)
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ues.SpecialityId,Ues.providerId 
									  FROM vw_ClaimEncounters Ues
									  INNER JOIN #tCareUserList TCUL
										  ON Ues.UserId = TCUL.UserId
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate)CI
							ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
							AND CI.SpecialityId = Ue.SpecialityId
							AND CI.ProviderId = Ue.ProviderId),
	                   COUNT(DISTINCT Ue.ClaimInfoId) ,
                       MAX(Ue.EncounterDate) AS LastVisit ,
                       COUNT(DISTINCT Ue.ClaimInfoId)AS TotalVisits ,
					   (SELECT CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
						  FROM ClaimInfo WITH(NOLOCK)
						  INNER JOIN (SELECT DISTINCT ClaimInfoID,Ues.SpecialityId,Ues.providerId  
									  FROM vw_ClaimEncounters Ues
									  INNER JOIN #tCareUserList TCUL
										  ON Ues.UserId = TCUL.UserId
									  WHERE EncounterDate BETWEEN @d_FromDate AND @d_ToDate)CI
							ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
							AND CI.SpecialityId = Ue.SpecialityId 
							AND CI.ProviderId = Ue.ProviderId) AS 'DollarsPerVisit' ,
                       (SELECT COUNT(DISTINCT PatientDiagnosisCodeID)
						 FROM vw_ClaimEncounters TU
						 INNER JOIN PatientDiagnosisCode  CLI
							ON TU.ClaimInfoID = CLI.ClaimInfoID 
						 WHERE TU.SpecialityId = Ue.SpecialityId  
						 AND TU.ProviderId = UE.ProviderId	  
						 GROUP BY TU.SpecialityId,TU.ProviderId)
                   FROM
                       #tCareUserList U
                   INNER JOIN vw_ClaimEncounters Ue
                       ON U.UserId = Ue.UserId
                   INNER JOIN Users US WITH(NOLOCK)
					   ON US.UserId = UE.ProviderId
				   INNER JOIN Provider P
				       ON P.ProviderID = US.UserId		
                   WHERE
                       Ue.SpecialityId = CONVERT(INT , SUBSTRING(@i_SpecialityId , CHARINDEX('-' , @i_SpecialityId) + 1 , Len(@i_SpecialityId)))
                       AND Ue.EncounterDate BETWEEN @d_FromDate
                       AND @d_ToDate 
				   GROUP BY
                       UE.SpecialityId ,
                       [dbo].[ufn_GetSpecialityById](UE.SpecialityId) ,
                       P.LastName ,
                       P.FirstName ,
                       P.MiddleName ,
                       P.NameSuffix ,
                       Ue.ProviderId 
                   ORDER BY
                       'Spe-' + CONVERT(VARCHAR(12) , Ue.ProviderId) + '*' + SUBSTRING(@i_SpecialityId , CHARINDEX('-' , @i_SpecialityId) + 1 , Len(@i_SpecialityId))

               INSERT INTO
                   #tSpecialist
                   (
                     SpecialityId ,
                     SpecialityName ,
                     UserProviderID ,
                     SpecialistName
                   )
                   SELECT DISTINCT
                       UE.SpecialityId ,
                       [dbo].[ufn_GetSpecialityById](UE.SpecialityId)SpecialityName ,
                       Users.UserId ,
                       COALESCE(ISNULL(P.LastName , '') + ', ' + 
                       --ISNULL(Users.FirstName , '') + '. ' +
                        ISNULL(P.MiddleName , '') + ' ' + ISNULL(P.NameSuffix , '') , '') AS SpecialistName
                   FROM
                       #tCareUserList U
                   INNER JOIN vw_ClaimEncounters Ue
                       ON U.UserId = Ue.UserId 
				   INNER JOIN Users WITH(NOLOCK)
                       ON Users.UserId = Ue.ProviderId
                   INNER JOIN Provider P
                       ON P.ProviderID = Users.UserId    
                   WHERE
                       Ue.SpecialityId = CONVERT(INT , SUBSTRING(@i_SpecialityId , CHARINDEX('-' , @i_SpecialityId) + 1 , Len(@i_SpecialityId)))
                       AND Ue.EncounterDate BETWEEN @d_FromDate
                       AND @d_ToDate

         END

      DECLARE
              @i_Totalcost DECIMAL(30,2) = ( SELECT
                                       SUM(Cost)
                                   FROM
                                       #tSpecialistDoctors ) ,
              @i_TotalVisits INT = ( SELECT
                                         SUM(Visits)
                                     FROM
                                     #tSpecialistDoctors )
                                     

      IF @b_IsByCost = 1
         BEGIN
         
               SELECT DISTINCT TOP 10
                   ID ,
                   Name ,
                   'Speciality' AS Type ,
                   SpecialityName ,
                   TypeId ,
                   Cost ,
                   Visits ,
                   CASE DENSE_RANK() OVER (
                   ORDER BY
                   CONVERT(DECIMAL(10,2) , ( Cost * 100.00 ) / @i_Totalcost) DESC )
                     WHEN 1 THEN 100
                     WHEN 2 THEN 90
                     WHEN 3 THEN 80
                     WHEN 4 THEN 70
                     WHEN 5 THEN 60
                     WHEN 6 THEN 50
                     WHEN 7 THEN 45
                     WHEN 8 THEN 40
                     WHEN 9 THEN 35
                     WHEN 10 THEN 30
                   END AS Percentage ,
                   CONVERT(DECIMAL(10,2) , ( Cost * 100.00 ) / @i_Totalcost) AS ActualPercentage ,
                   LastVisit ,
				--ProviderName ,
                   TotalVisits ,
                   Cost AS TotalCost ,
                   DollarsPerVisit ,
                   DiagnosisPerProviders
               FROM
                   #tSpecialistDoctors
               WHERE
                   Cost <> 0
               GROUP BY
                   ID ,
                   Name ,
                   SpecialityName ,
                   TypeId ,
                   Cost ,
                   Visits ,
                   LastVisit ,
                   TotalVisits ,
                   --TotalCost ,
                   DollarsPerVisit ,
                   DiagnosisPerProviders
               ORDER BY
                   Percentage DESC

               SELECT DISTINCT
                   SpecialityId ,
                   SpecialityName ,
                   SpecialistName
               FROM
                   #tSpecialist
         END

      IF @b_IsByCost <> 1
         BEGIN
       
               SELECT DISTINCT TOP 10
                   ID ,
                   Name ,
                   'Speciality' AS Type ,
                   SpecialityName ,
                   TypeId ,
                   Cost ,
                   Visits ,
                   CASE DENSE_RANK() OVER (
                   ORDER BY
                   CONVERT(DECIMAL(10,2) , ( Visits * 100.00 ) / @i_TotalVisits) DESC )
                     WHEN 1 THEN 100
                     WHEN 2 THEN 90
                     WHEN 3 THEN 80
                     WHEN 4 THEN 70
                     WHEN 5 THEN 60
                     WHEN 6 THEN 50
                     WHEN 7 THEN 45
                     WHEN 8 THEN 40
                     WHEN 9 THEN 35
                     WHEN 10 THEN 30
                   END AS Percentage ,
                   CONVERT(DECIMAL(10,2) , ( Visits * 100.00 ) / @i_TotalVisits) AS ActualPercentage ,
                   LastVisit ,
			--ProviderName ,
                   TotalVisits ,
                   Cost AS TotalCost ,
                   DollarsPerVisit ,
                   DiagnosisPerProviders
               FROM
                   #tSpecialistDoctors
               WHERE
                   Visits <> 0
               GROUP BY
                   ID ,
                   Name ,
                   SpecialityName ,
                   TypeId ,
                   Cost ,
                   Visits ,
                   LastVisit ,
                   TotalVisits ,
                   --TotalCost ,
                   DollarsPerVisit ,
                   DiagnosisPerProviders
               ORDER BY
                   Percentage DESC

               SELECT DISTINCT
                   SpecialityId ,
                   SpecialityName ,
                   SpecialistName
               FROM
                   #tSpecialist
          
         END 
END TRY
------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      RETURN @i_ReturnedErrorID 
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserSpeciality_SelectByPatientUserId] TO [FE_rohit.r-ext]
    AS [dbo];

