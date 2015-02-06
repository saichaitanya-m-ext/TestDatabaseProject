


/*          
------------------------------------------------------------------------------          
Procedure Name: usp_Reports_CareCoordination
Description   : This procedure is used to give CareCoordination report data
Created By    : NagaBabu
Created Date  : 20-Sep-2011
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
15-Nov-2011  Sivakrishna Added Parameters @i_TypeId And @I_SubTypeId For admin carecoordination Report
21-Nov-2011  Sivakrishna Added Condition for Admin Report Purpose based on  Cohort and Program
23-Dec-2011 NagaBabu Modified by Applying join with UserEncounter table with ClaimLine 
27-Dec-2011 NagaBabu Created NONCLUSTERED INDEX [IX_#t_CareUserList] ON #t_CareUserList while it is consuming Morethan
						15min time 
29-Dec-2011 NagaBabu Added NULLIF for eliminating '0' Indenominator for Percentage,ActualPercentage fields. 
05-Jan-2012 NagaBabu Modified the script for getting Specialities instead of counting UserProviders counting ProviderId 
						as First preference
09-Jan-2011 NagaBabu Added Where clause for restrict the recorde with nocost or novisits						
------------------------------------------------------------------------------
exec usp_Reports_CareCoordination @i_AppUserId=10926,@d_FromDate='2008-07-17 00:00:00',@d_ToDate='2013-07-01 00:00:00',@i_PatientUserId=4010,@b_IsByCost=1,@I_Type =default,@I_SubTypeId =0

*/   --[usp_Reports_CareCoordination] 23,'2007-01-01','2012-06-28',245925,1,'COHORT',2
CREATE PROCEDURE [dbo].[usp_Reports_CareCoordination]
(
 @i_AppUserId KEYID ,
 @d_FromDate DATETIME ,
 @d_ToDate DATETIME ,
 @i_PatientUserId KEYID ,
 @b_IsByCost ISINDICATOR = 1 ,
 @i_Type VARCHAR(10) = NULL ,
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
---------------------------------------------------------------------------------------------------------

      DECLARE @t_Specialities TABLE
      (
        ID VARCHAR(12) ,
        Name VARCHAR(50) ,
        [Type] VARCHAR(50) ,
        Cost MONEY ,
        Visits INT ,
        LastVisit DATE ,
        DollarsPerVisit MONEY ,
        DiagnosisPerVisit INT ,
        OrderMaxVisit INT
      )	 
-----------------------------------------------------------------------------------------------------

      IF @i_Type IS NULL

         BEGIN
---------------------------------Last One Year Visists Of Care Providers-----------------------------
               SELECT
                   COUNT(DISTINCT CareTeamUserID) TotalCareProviders ,
                   SUM(CAST(ISNULL(Ue.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                   --COUNT(DISTINCT Ue.ProviderId)AS TotalNoofSpecialistVisits  ,	
                   (
                     SELECT
                         COUNT(DISTINCT ProviderId)
                     FROM
                         vw_ClaimEncounters
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                         AND SpecialityID IS NOT NULL
                         AND UserID = @i_PatientUserId
                   ) AS TotalNoofSpecialistVisits ,
                   SUM(CAST(ISNULL(Ue.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                   (
                     SELECT
                         CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                     FROM
                         ClaimInfo
                     WHERE
                         DateOfAdmit BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                         AND PatientID = @i_PatientUserId
                   ) AS TotalCostIn$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(Ues.ProviderId)
                     FROM
                         vw_ClaimEncounters Ues
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = Ues.ClaimInfoID
                     WHERE
                         Ues.EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                         AND Ues.UserId = @i_PatientUserId
                     GROUP BY
                         Ues.ProviderId
                     ORDER BY
                         SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                   ) AS CareProviderWithMax$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(Ues.ProviderId)
                     FROM
                         vw_ClaimEncounters Ues
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = Ues.ClaimInfoID
                     WHERE
                         Ues.EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                         AND Ues.UserId = @i_PatientUserId
                     GROUP BY
                         Ues.ProviderId
                     ORDER BY
                         COUNT(Ues.ProviderId) DESC
                   ) AS CareProviderWithMaxVisit
               FROM
                   vw_ClaimEncounters Ue
               INNER JOIN ClaimInfo CI WITH (NOLOCK)
                   ON CI.ClaimInfoId = UE.ClaimInfoID
               WHERE
                   Ue.UserId = @i_PatientUserId
                   AND EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                   AND GETDATE()
		     
	-----------------------------Last Two Years Visists Of Care Providers----------------------------------------	
               SELECT
                   COUNT(DISTINCT CareTeamUserID) TotalCareProviders ,
				--SUM(CASE WHEN CareTeamUserID IS NOT NULL THEN 1
				--		ELSE 0
				--	END) AS TotalCareProviders , 
                   SUM(CAST(ISNULL(Ue.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                   --SUM(CASE  WHEN Ue.ProviderId IS NOT NULL THEN 1 
                   --		ELSE 0
                   --	END) AS TotalNoofSpecialistVisits  ,	
                   (
                     SELECT
                         COUNT(DISTINCT ProviderId)
                     FROM
                         vw_ClaimEncounters
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                         AND SpecialityID IS NOT NULL
                         AND UserID = @i_PatientUserId
                   ) AS TotalNoofSpecialistVisits ,
                   SUM(CAST(ISNULL(Ue.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                   --SUM(ISNULL(CI.NetPaidAmount,0)) AS TotalCostIn$ ,
                   (
                     SELECT
                         CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                     FROM
                         ClaimInfo
                     WHERE
                         DateOfAdmit BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                         AND PatientID = @i_PatientUserId
                   ) AS TotalCostIn$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(Ues.ProviderId)
                     FROM
                         vw_ClaimEncounters Ues
                     INNER JOIN ClaimInfo CI
                         ON CI.ClaimInfoId = Ues.ClaimInfoID
                     WHERE
                         Ues.EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                         AND Ues.UserId = @i_PatientUserId
                     GROUP BY
                         Ues.ProviderId
                     ORDER BY
                         SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                   ) AS CareProviderWithMax$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(Ues.ProviderId)
                     FROM
                         vw_ClaimEncounters Ues
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = Ues.ClaimInfoID
                     WHERE
                         Ues.EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                         AND Ues.UserId = @i_PatientUserId
                     GROUP BY
                         Ues.ProviderId
                     ORDER BY
                         COUNT(Ues.ProviderId) DESC
                   ) AS CareProviderWithMaxVisit
               FROM
                   vw_ClaimEncounters Ue
               INNER JOIN ClaimInfo CI WITH (NOLOCK)
                   ON CI.ClaimInfoId = UE.ClaimInfoID
               WHERE
                   Ue.UserId = @i_PatientUserId
                   AND EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                   AND GETDATE()
		    
	-----------------------------Last Three Years Visists Of Care Providers----------------------------------------	
               SELECT
                   COUNT(DISTINCT CareTeamUserID) TotalCareProviders ,
				--SUM(CASE WHEN CareTeamUserID IS NOT NULL THEN 1
				--		ELSE 0
				--	END) AS TotalCareProviders , 
                   SUM(CAST(ISNULL(Ue.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                   --SUM(CASE  WHEN Ue.ProviderId IS NOT NULL THEN 1 
                   --		ELSE 0
                   --	END) AS TotalNoofSpecialistVisits  ,	
                   (
                     SELECT
                         COUNT(DISTINCT ProviderId)
                     FROM
                         vw_ClaimEncounters
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                         AND SpecialityID IS NOT NULL
                         AND UserID = @i_PatientUserId
                   ) AS TotalNoofSpecialistVisits ,
                   SUM(CAST(ISNULL(Ue.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                   --SUM(ISNULL(CI.NetPaidAmount,0)) AS TotalCostIn$ ,
                   (
                     SELECT
                         CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                     FROM
                         ClaimInfo
                     WHERE
                         DateOfAdmit BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                         AND PatientID = @i_PatientUserId
                   ) AS TotalCostIn$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(Ues.ProviderId)
                     FROM
                         vw_ClaimEncounters Ues
                     INNER JOIN ClaimInfo CI  WITH (NOLOCK)
                         ON CI.ClaimInfoId = Ues.ClaimInfoID
                     WHERE
                         Ues.EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                         AND Ues.UserId = @i_PatientUserId
                     GROUP BY
                         Ues.ProviderId
                     ORDER BY
                         SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                   ) AS CareProviderWithMax$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(Ues.ProviderId)
                     FROM
                         vw_ClaimEncounters Ues
                     INNER JOIN ClaimInfo CI  WITH (NOLOCK)
                         ON CI.ClaimInfoId = Ues.ClaimInfoID
                     WHERE
                         Ues.EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                         AND Ues.UserId = @i_PatientUserId
                     GROUP BY
                         Ues.ProviderId
                     ORDER BY
                         COUNT(Ues.ProviderId) DESC
                   ) AS CareProviderWithMaxVisit
               FROM
                   vw_ClaimEncounters Ue
               INNER JOIN ClaimInfo CI  WITH (NOLOCK)
                   ON CI.ClaimInfoId = UE.ClaimInfoID
               WHERE
                   Ue.UserId = @i_PatientUserId
                   AND EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                   AND GETDATE()
		   
---------------------------------------------------------------------------------------------
               IF @b_IsByCost = 0
                  BEGIN
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 1
                                'Pcp-' + CONVERT(VARCHAR(12) , Us.UserId) ,
                                dbo.ufn_GetPCPName(@i_PatientUserId) ,
                                'PCP' ,
                                --SUM(ISNULL(CI.NetPaidAmount,0)) ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   vw_ClaimEncounters
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserID = @i_PatientUserId
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = Ue.ProviderId ) ,
                                ( SELECT
                                      COUNT(IsEncounterwithPCP)
                                  FROM
                                      ClaimInfo WITH (NOLOCK)
                                  INNER JOIN vw_ClaimEncounters
                                      ON ClaimInfo.ClaimInfoId = vw_ClaimEncounters.ClaimInfoID
                                  WHERE
                                      DateOfAdmit BETWEEN @d_FromDate
                                      AND @d_ToDate
                                      AND PatientID = @i_PatientUserId
                                      AND IsEncounterwithPCP = 1
                                  GROUP BY
                                      PatientID ) ,
                                CONVERT(VARCHAR , MAX(Ue.EncounterDate) , 101) , 
                                --AVG(ISNULL(CI.NetPaidAmount,0)),
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo WITH (NOLOCK)
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   vw_ClaimEncounters
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserID = @i_PatientUserId
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = Ue.ProviderId ) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT patientDiagnosisCodeId)
                                         FROM
                                             vw_ClaimEncounters Ues
                                         INNER JOIN patientDiagnosisCode CLI
                                             ON Ues.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             Ues.IsEncounterwithPCP = 1
                                             AND Ues.ProviderId = Ue.ProviderId
                                             AND Ues.UserId = @i_PatientUserId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             Ues.UserId ,
                                             Ues.ProviderId ) / ( SELECT
                                                                      COUNT(IsEncounterwithPCP)
                                                                  FROM
                                                                      ClaimInfo
                                                                  INNER JOIN vw_ClaimEncounters
                                                                      ON ClaimInfo.ClaimInfoId = vw_ClaimEncounters.ClaimInfoID
                                                                  WHERE
                                                                      DateOfAdmit BETWEEN @d_FromDate
                                                                      AND @d_ToDate
                                                                      AND PatientID = @i_PatientUserId
                                                                      AND IsEncounterwithPCP = 1
                                                                  GROUP BY
                                                                      PatientID ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )
                            FROM
                                vw_ClaimEncounters Ue
                            INNER JOIN Users Us WITH (NOLOCK)
                                ON US.UserId = Ue.UserId
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = UE.ClaimInfoID
                            WHERE
                                Ue.UserId = @i_PatientUserId
                                AND Ue.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                                AND Ue.IsEncounterwithPCP = 1
                                AND 'Pcp-' + CONVERT(VARCHAR(12) , Us.UserId) IS NOT NULL
                            GROUP BY
                                'Pcp-' + CONVERT(VARCHAR(12) , Us.UserId) ,
                                Ue.ProviderId
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 5
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode) ,
                                Spe.ProviderSpecialtyName ,
                                'Speciality' ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.ProviderSpecialtyCode ) ,			  	  
                                --SUM(CASE  WHEN Ue.ProviderId IS NOT NULL THEN 1 
                                --		ELSE 0
                                --	END),
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   UserId = @i_PatientUserId
                                                   AND EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.SpecialityID = Spe.ProviderSpecialtyCode ) ,
                                CONVERT(VARCHAR , MAX(Ue.EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount,0)),
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.ProviderSpecialtyCode ) ,		
						--COUNT(CLI.IcdCodeId),
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeID)
                                         FROM
                                             vw_ClaimEncounters Ues
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON Ues.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             Ues.SpecialityId = Spe.ProviderSpecialtyCode
                                             AND Ues.UserId = @i_PatientUserId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             Ues.SpecialityId ,
                                             Ues.UserId ) / ( SELECT
                                                                  COUNT(ClaimInfo.ClaimInfoID)
                                                              FROM
                                                                  ClaimInfo
                                                              INNER JOIN ( SELECT DISTINCT
                                                                               ClaimInfoID ,
                                                                               Ue.SpecialityId
                                                                           FROM
                                                                               vw_ClaimEncounters Ue
                                                                           WHERE
                                                                               UserId = @i_PatientUserId
                                                                               AND EncounterDate BETWEEN @d_FromDate
                                                                               AND @d_ToDate ) CI
                                                                  ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                              WHERE
                                                                  CI.SpecialityID = Spe.ProviderSpecialtyCode ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(CI.ClaimInfoId) DESC )
                            FROM
                                vw_ClaimEncounters Ue
                            INNER JOIN CodeSetCMSProviderSpecialty Spe WITH (NOLOCK)
                                ON Spe.ProviderSpecialtyCode = Ue.SpecialityId
                            INNER JOIN ClaimInfo CI   WITH (NOLOCK)
                                ON CI.ClaimInfoId = UE.ClaimInfoID
                            WHERE
                                Ue.UserId = @i_PatientUserId
                                AND Ue.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                Spe.ProviderSpecialtyName ,
                                Spe.ProviderSpecialtyCode ,
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode)
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(CI.ClaimInfoId) DESC )
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                           SELECT TOP 4
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.Description ,
                                'Hospital' ,
                                --SUM(ISNULL(CI.NetPaidAmount,0)) ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Ue.OrganizationHospitalId ) ,	
                                --SUM(CASE  WHEN Ue.OrganizationHospitalID IS NOT NULL THEN 1 
                                --		ELSE 0
                                --	END),
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   UserId = @i_PatientUserId
                                                   AND EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.OrganizationHospitalId = Org.ProviderTypeCodeID
                                  GROUP BY
                                      CI.OrganizationHospitalId ) ,
                                CONVERT(VARCHAR , MAX(Ue.EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount,0)),
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeID)
                                         FROM
                                             vw_ClaimEncounters Ues
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON Ues.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             Ues.OrganizationHospitalId = Ue.OrganizationHospitalId
                                             AND Ues.UserId = @i_PatientUserId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             Ues.OrganizationHospitalId ,
                                             Ues.UserId ) / ( SELECT
                                                                  COUNT(ClaimInfo.ClaimInfoID)
                                                              FROM
                                                                  ClaimInfo
                                                              INNER JOIN ( SELECT DISTINCT
                                                                               ClaimInfoID ,
                                                                               OrganizationHospitalId
                                                                           FROM
                                                                               vw_ClaimEncounters Ue
                                                                           WHERE
                                                                               UserId = @i_PatientUserId
                                                                               AND EncounterDate BETWEEN @d_FromDate
                                                                               AND @d_ToDate ) CI
                                                                  ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                              WHERE
                                                                  CI.OrganizationHospitalId = Org.ProviderTypeCodeID
                                                              GROUP BY
                                                                  CI.OrganizationHospitalId ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(CI.ClaimInfoId) DESC ,
                                Org.description )
                            FROM
                                vw_ClaimEncounters Ue
                            INNER JOIN CodeSetProviderType Org WITH (NOLOCK)
                                ON Ue.OrganizationHospitalId = Org.ProviderTypeCodeID
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = UE.ClaimInfoID
                            WHERE
                                Ue.UserId = @i_PatientUserId
                                AND Ue.OrganizationHospitalId IS NOT NULL
                                AND Ue.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.ProviderTypeCodeID ,
                                Org.Description ,
                                Ue.UserId ,
                                Ue.OrganizationHospitalId
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(CI.ClaimInfoId) DESC ,
                                Org.description )
                  END
               ELSE
                  BEGIN
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 1
                                'Pcp-' + CONVERT(VARCHAR(12) , Us.UserId) ,
                                dbo.ufn_GetPCPName(@i_PatientUserId) ,
                                'PCP' ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   vw_ClaimEncounters
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserID = @i_PatientUserId
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = Ue.ProviderId ) ,
                                ( SELECT
                                      COUNT(IsEncounterwithPCP)
                                  FROM
                                      ClaimInfo WITH (NOLOCK)
                                  INNER JOIN vw_ClaimEncounters
                                      ON ClaimInfo.ClaimInfoId = vw_ClaimEncounters.ClaimInfoID
                                  WHERE
                                      DateOfAdmit BETWEEN @d_FromDate
                                      AND @d_ToDate
                                      AND PatientID = @i_PatientUserId
                                      AND IsEncounterwithPCP = 1
                                  GROUP BY
                                      PatientID ) ,
                                CONVERT(VARCHAR , MAX(EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount,0)),
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   vw_ClaimEncounters
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserID = @i_PatientUserId
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = Ue.ProviderId ) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeId)
                                         FROM
                                             vw_ClaimEncounters Ues
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON Ues.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             Ues.IsEncounterwithPCP = 1
                                             AND Ues.ProviderId = Ue.ProviderId
                                             AND Ues.UserId = @i_PatientUserId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             Ues.ProviderId ,
                                             Ues.UserId ) / ( SELECT
                                                                  COUNT(IsEncounterwithPCP)
                                                              FROM
                                                                  ClaimInfo
                                                              INNER JOIN vw_ClaimEncounters
                                                                  ON ClaimInfo.ClaimInfoId = vw_ClaimEncounters.ClaimInfoID
                                                              WHERE
                                                                  DateOfAdmit BETWEEN @d_FromDate
                                                                  AND @d_ToDate
                                                                  AND PatientID = @i_PatientUserId
                                                                  AND IsEncounterwithPCP = 1
                                                              GROUP BY
                                                                  PatientID ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   vw_ClaimEncounters
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserID = @i_PatientUserId
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = Ue.ProviderId ) DESC )
                            FROM
                                vw_ClaimEncounters Ue
                            INNER JOIN Users Us WITH (NOLOCK)
                                ON US.UserId = Ue.UserId
                            --INNER JOIN ClaimInfo CI WITH (NOLOCK)
                            --    ON CI.ClaimInfoId = UE.ClaimInfoID
                            WHERE
                                Ue.UserId = @i_PatientUserId
                                AND Ue.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                                AND Ue.IsEncounterwithPCP = 1
                                --AND us.UserStatusCode = 'A'
                                AND 'Pcp-' + CONVERT(VARCHAR(12) , Us.UserId) IS NOT NULL
                            GROUP BY
                                'Pcp-' + CONVERT(VARCHAR(12) , Us.UserId) ,
                                Ue.ProviderId
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   vw_ClaimEncounters
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserID = @i_PatientUserId
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = Ue.ProviderId ) DESC )
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 5
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode) ,
                                Spe.ProviderSpecialtyName ,
                                'Speciality' ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo WITH (NOLOCK)
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityID
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityID = Spe.ProviderSpecialtyCode ) ,
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo WITH (NOLOCK)
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   UserId = @i_PatientUserId
                                                   AND EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.SpecialityID = Spe.ProviderSpecialtyCode ) ,
                                CONVERT(VARCHAR , MAX(Ue.EncounterDate) , 101) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityID
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityID = Spe.ProviderSpecialtyCode ) ,	
						--COUNT(CLI.IcdCodeId),
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeID)
                                         FROM
                                             vw_ClaimEncounters Ues
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON Ues.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             Ues.SpecialityId = Spe.ProviderSpecialtyCode
                                             AND Ues.UserId = @i_PatientUserId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             Ues.SpecialityId ,
                                             Ues.UserId ) / ( SELECT
                                                                  COUNT(ClaimInfo.ClaimInfoID)
                                                              FROM
                                                                  ClaimInfo
                                                              INNER JOIN ( SELECT DISTINCT
                                                                               ClaimInfoID ,
                                                                               Ue.SpecialityId
                                                                           FROM
                                                                               vw_ClaimEncounters Ue
                                                                           WHERE
                                                                               UserId = @i_PatientUserId
                                                                               AND EncounterDate BETWEEN @d_FromDate
                                                                               AND @d_ToDate ) CI
                                                                  ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                              WHERE
                                                                  CI.SpecialityID = Spe.ProviderSpecialtyCode ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityID
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityID = Spe.ProviderSpecialtyCode ) DESC )
                            FROM
                                vw_ClaimEncounters Ue --INNER JOIN Users Us
					--	ON Ue.ProviderId = Us.UserId 
                            INNER JOIN CodeSetCMSProviderSpecialty Spe
                                ON Spe.ProviderSpecialtyCode = Ue.SpecialityId
                            --INNER JOIN ClaimInfo CI
                            --    ON CI.ClaimInfoId = UE.ClaimInfoID
                            WHERE
                                Ue.UserId = @i_PatientUserId
                                AND Ue.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                Spe.ProviderSpecialtyName ,
                                Spe.ProviderSpecialtyCode ,
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode)
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityID
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityID = Spe.ProviderSpecialtyCode ) DESC )
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 4
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.Description ,
                                'Hospital' ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                  WHERE
                                      CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) ,	
                                --SUM(CASE  WHEN Ue.OrganizationHospitalID IS NOT NULL THEN 1 
                                --		ELSE 0
                                --	END),
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   UserId = @i_PatientUserId
                                                   AND EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.OrganizationHospitalId = Ue.OrganizationHospitalId ) ,
                                CONVERT(VARCHAR , MAX(Ue.EncounterDate) , 101) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                  WHERE
                                      CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeID)
                                         FROM
                                             vw_ClaimEncounters Ues
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON Ues.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             Ues.OrganizationHospitalId = Ue.OrganizationHospitalId
                                             AND Ues.UserId = @i_PatientUserId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             Ues.OrganizationHospitalId ,
                                             Ues.UserId ) / ( SELECT
                                                                  COUNT(ClaimInfo.ClaimInfoID)
                                                              FROM
                                                                  ClaimInfo
                                                              INNER JOIN ( SELECT DISTINCT
                                                                               ClaimInfoID ,
                                                                               OrganizationHospitalId
                                                                           FROM
                                                                               vw_ClaimEncounters Ue
                                                                           WHERE
                                                                               UserId = @i_PatientUserId
                                                                               AND EncounterDate BETWEEN @d_FromDate
                                                                               AND @d_ToDate ) CI
                                                                  ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                              WHERE
                                                                  CI.OrganizationHospitalId = Ue.OrganizationHospitalId ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                  WHERE
                                      CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) DESC ,
                                Org.Description )
                            FROM
                                vw_ClaimEncounters Ue
                            INNER JOIN CodeSetProviderType Org WITH (NOLOCK)
                                ON Ue.OrganizationHospitalId = Org.ProviderTypeCodeID
                            --INNER JOIN ClaimInfo CI  WITH (NOLOCK)
                            --    ON CI.ClaimInfoId = UE.ClaimInfoID
                            WHERE
                                Ue.UserId = @i_PatientUserId
                                AND Ue.OrganizationHospitalId IS NOT NULL
                                AND Ue.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.ProviderTypeCodeID ,
                                Org.Description ,
                                Ue.UserId ,
                                Ue.OrganizationHospitalId
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   vw_ClaimEncounters Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND UserId = @i_PatientUserId ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                  WHERE
                                      CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) DESC ,
                                Org.Description )
                  END
         END
-----------Admin Level CareCoordination report for based on cohort and Program-----------
		
---------------------Last One Year Visists Of Care Providers ----------------------------------------
      IF @i_Type IS NOT NULL
      
         BEGIN


               CREATE TABLE #t_CareUserList
               (
                 UserId INT
               )

               IF @i_Type = 'Cohort'

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


               CREATE TABLE #EncounterUsers
               (
                 UserId INT ,
                 CareTeamUserID INT ,
                 IsEncounterwithPCP BIT ,
                 ProviderId INT ,
                 --UserProviderID INT ,
                 IsInpatient BIT ,
                 ClaimInfoID INT ,
                 EncounterDate DATETIME ,
                 OrganizationHospitalId INT ,
                 SpecialityId VARCHAR(5)
               )
               INSERT INTO
                   #EncounterUsers
                   SELECT DISTINCT
                       UES.UserId ,
                       CareTeamUserID ,
                       IsEncounterwithPCP ,
                       ProviderId ,
                       --UserProviderID ,
                       IsInpatient ,
                       ClaimInfoID ,
                       EncounterDate ,
                       OrganizationHospitalId ,
                       SpecialityId
                   FROM
                       vw_ClaimEncounters UES
                   INNER JOIN #t_CareUserList CUL
                       ON CUL.UserId = UES.UserId
                       
                     

               SELECT DISTINCT
                   COUNT(DISTINCT CareTeamUserID) TotalCareProviders ,
                   SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                   (
                     SELECT
                         COUNT(DISTINCT ProviderId)
                     FROM
                         #EncounterUsers
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                         AND SpecialityID IS NOT NULL
                   ) AS TotalNoofSpecialistVisits ,
                   SUM(CAST(ISNULL(TEU.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                   (
                     SELECT
                         CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                     FROM
                         ClaimInfo CI
                     INNER JOIN (
                                  SELECT DISTINCT
                                      ClaimInfoID
                                  FROM
                                      #EncounterUsers
                                ) TEU
                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                     WHERE
                         DateOfAdmit BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                   ) AS TotalCostIn$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(TE.ProviderId)
                     FROM
                         #EncounterUsers TE
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = TE.ClaimInfoID
                     WHERE
                         TE.EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                     GROUP BY
                         TE.ProviderId
                     ORDER BY
                         SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                   ) AS CareProviderWithMax$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(TE.ProviderId)
                     FROM
                         #EncounterUsers TE
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = TE.ClaimInfoID
                     WHERE
                         TE.EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                         AND GETDATE()
                     GROUP BY
                         TE.ProviderId
                     ORDER BY
                         COUNT(TE.ProviderId) DESC
                   ) AS CareProviderWithMaxVisit
               FROM
                   #EncounterUsers TEU
               INNER JOIN ClaimInfo CI WITH (NOLOCK)
                   ON CI.ClaimInfoId = TEU.ClaimInfoID
               WHERE
                   TEU.EncounterDate BETWEEN DATEADD(YEAR , -1 , GETDATE())
                   AND GETDATE() 
			    
			    
-------------------------Last 2 Years Visits Of Care Providers----------------------------	

               SELECT DISTINCT
                   COUNT(DISTINCT CareTeamUserID) TotalCareProviders ,
                   SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                   (
                     SELECT
                         COUNT(DISTINCT ProviderId)
                     FROM
                         #EncounterUsers
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                         AND SpecialityID IS NOT NULL
                   ) AS TotalNoofSpecialistVisits ,
                   SUM(CAST(ISNULL(TEU.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                   (
                     SELECT
                         CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                     FROM
                         ClaimInfo CI
                     INNER JOIN (
                                  SELECT DISTINCT
                                      ClaimInfoID
                                  FROM
                                      #EncounterUsers
                                ) TEU
                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                     WHERE
                         DateOfAdmit BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                   ) AS TotalCostIn$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(TE.ProviderId)
                     FROM
                         #EncounterUsers TE
                     INNER JOIN ClaimInfo CI
                         ON CI.ClaimInfoId = TE.ClaimInfoID
                     WHERE
                         TE.EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                     GROUP BY
                         TE.ProviderId
                     ORDER BY
                         SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                   ) AS CareProviderWithMax$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(TE.ProviderId)
                     FROM
                         #EncounterUsers TE
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = TE.ClaimInfoID
                     WHERE
                         TE.EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                         AND GETDATE()
                     GROUP BY
                         TE.ProviderId
                     ORDER BY
                         COUNT(TE.ProviderId) DESC
                   ) AS CareProviderWithMaxVisit
               FROM
                   #EncounterUsers TEU
               INNER JOIN ClaimInfo CI WITH (NOLOCK)
                   ON CI.ClaimInfoId = TEU.ClaimInfoID
               WHERE
                   TEU.EncounterDate BETWEEN DATEADD(YEAR , -2 , GETDATE())
                   AND GETDATE()
								
		-----------------------------Last 3 Years VIsits Of Care Providers-------------------------------

               SELECT DISTINCT
                   COUNT(DISTINCT CareTeamUserID) TotalCareProviders ,
                   SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) AS TotalNoofPCPVisits ,
                   (
                     SELECT
                         COUNT(DISTINCT ProviderId)
                     FROM
                         #EncounterUsers
                     WHERE
                         EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                         AND SpecialityID IS NOT NULL
                   ) AS TotalNoofSpecialistVisits ,
                   SUM(CAST(ISNULL(TEU.IsInpatient , 0) AS INT)) AS TotalNoofIPVisits ,
                   (
                     SELECT
                         CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                     FROM
                         ClaimInfo CI
                     INNER JOIN (
                                  SELECT DISTINCT
                                      ClaimInfoID
                                  FROM
                                      #EncounterUsers
                                ) TEU
                         ON CI.ClaimInfoId = TEU.ClaimInfoID
                     WHERE
                         DateOfAdmit BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                   ) AS TotalCostIn$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(TE.ProviderId)
                     FROM
                         #EncounterUsers TE
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = TE.ClaimInfoID
                     WHERE
                         TE.EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                     GROUP BY
                         TE.ProviderId
                     ORDER BY
                         SUM(ISNULL(CI.NetPaidAmount , 0)) DESC
                   ) AS CareProviderWithMax$ ,
                   (
                     SELECT TOP 1
                         dbo.ufn_GetUserNameByID(TE.ProviderId)
                     FROM
                         #EncounterUsers TE
                     INNER JOIN ClaimInfo CI WITH (NOLOCK)
                         ON CI.ClaimInfoId = TE.ClaimInfoID
                     WHERE
                         TE.EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                         AND GETDATE()
                     GROUP BY
                         TE.ProviderId
                     ORDER BY
                         COUNT(TE.ProviderId) DESC
                   ) AS CareProviderWithMaxVisit
               FROM
                   #EncounterUsers TEU
               INNER JOIN ClaimInfo CI
                   ON CI.ClaimInfoId = TEU.ClaimInfoID
               WHERE
                   TEU.EncounterDate BETWEEN DATEADD(YEAR , -3 , GETDATE())
                   AND GETDATE() 
				
				
	-----------------------------------------------------------------------------------------
               IF @b_IsByCost = 0
                  BEGIN

                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 1
                                'Pcp-' + CONVERT(VARCHAR(12) , P.UserId) ,
                                dbo.ufn_GetUserNameByID(P.UserId) ,
                                'PCP' ,
                                --SUM(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = TEU.ProviderId
                                         AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID ) ,
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoId)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoID
                                         AND CI.ProviderId = TEU.ProviderId ) ,
                                CONVERT(VARCHAR , MAX(TEU.EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = TEU.ProviderId
                                         AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID ) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeID)
                                         FROM
                                             #EncounterUsers TU
                                         INNER JOIN ClaimLine WITH (NOLOCK)
											 ON TU.ClaimInfoID = ClaimLine.ClaimInfoID    
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             TU.IsEncounterwithPCP = 1
                                             AND TU.ProviderId = TEU.ProviderId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             TU.ProviderId ) / ( SELECT
                                                                     COUNT(ClaimInfo.ClaimInfoId)
                                                                 FROM
                                                                     ClaimInfo
                                                                 INNER JOIN ( SELECT DISTINCT
                                                                                  ClaimInfoID ,
                                                                                  ProviderId
                                                                              FROM
                                                                                  #EncounterUsers TE
                                                                              WHERE
                                                                                  EncounterDate BETWEEN @d_FromDate
                                                                                  AND @d_ToDate
                                                                                  AND IsEncounterwithPCP = 1 ) CI
                                                                     ON CI.ClaimInfoID = ClaimInfo.ClaimInfoID
                                                                        AND CI.ProviderId = TEU.ProviderId ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN users P WITH (NOLOCK)
                                ON P.UserId = TEU.UserId
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                            WHERE
                                TEU.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                                AND TEU.IsEncounterwithPCP = 1
                                --AND p.UserStatusCode = 'A'
                                AND 'Pcp-' + CONVERT(VARCHAR(12) , P.UserId) IS NOT NULL
                            GROUP BY
                                'Pcp-' + CONVERT(VARCHAR(12) , P.UserId) ,
                                P.UserId ,
                                TEU.ProviderId
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )

                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 5
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode) ,
                                Spe.ProviderSpecialtyName ,
                                'Speciality' ,
                                --SUM(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.ProviderSpecialtyCode ) ,
                                --SUM(CASE
                                --         WHEN TEU.ProviderId  IS NOT NULL THEN 1
                                --         ELSE 0
                                --    END) ,
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.SpecialityID = Spe.ProviderSpecialtyCode ) ,
                                CONVERT(VARCHAR , MAX(TEU.EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.ProviderSpecialtyCode ) ,	
                              --COUNT(CLI.IcdCodeId) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeID)
                                         FROM
                                             #EncounterUsers TU
                                         INNER JOIN ClaimLine  WITH (NOLOCK)
											 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                                         INNER JOIN PatientDiagnosisCode CLI  WITH (NOLOCK)
                                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             TU.SpecialityId = TEU.SpecialityId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             TU.SpecialityId ) / ( SELECT
                                                                       COUNT(ClaimInfo.ClaimInfoID)
                                                                   FROM
                                                                       ClaimInfo
                                                                   INNER JOIN ( SELECT DISTINCT
                                                                                    ClaimInfoID ,
                                                                                    Ue.SpecialityId
                                                                                FROM
                                                                                    #EncounterUsers Ue
                                                                                WHERE
                                                                                    EncounterDate BETWEEN @d_FromDate
                                                                                    AND @d_ToDate ) CI
                                                                       ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                                   WHERE
                                                                       CI.SpecialityID = Spe.ProviderSpecialtyCode ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN CodeSetCMSProviderSpecialty Spe WITH (NOLOCK)
                                ON Spe.ProviderSpecialtyCode = TEU.SpecialityId
                            INNER JOIN ClaimInfo CI  WITH (NOLOCK)
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                            WHERE
                                TEU.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                Spe.ProviderSpecialtyName ,
                                Spe.ProviderSpecialtyCode ,
                                TEU.SpecialityId ,
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode)
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 4
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.Description ,
                                'Hospital' ,
                                --SUM(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) ,	
                                --SUM(CASE
                                --	  WHEN TEU.OrganizationHospitalId IS NOT NULL THEN 1
                                --	  ELSE 0
                                -- END) ,
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Org.ProviderTypeCodeID
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.ProviderTypeCodeID = Org.ProviderTypeCodeID
                                  GROUP BY
                                      CI.ProviderTypeCodeID ) ,
                                CONVERT(VARCHAR , MAX(TEU.EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) ,	
								 --COUNT(CLI.IcdCodeId) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeId)
                                         FROM
                                             #EncounterUsers TU
                                         INNER JOIN ClaimLine WITH (NOLOCK)
											 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON ClaimLine.ClaimLineID = CLI.ClaiminfoID
                                         WHERE
                                             TU.OrganizationHospitalId = TEU.OrganizationHospitalId
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                         GROUP BY
                                             TU.OrganizationHospitalId ) / ( SELECT
                                                                                 COUNT(ClaimInfo.ClaimInfoID)
                                                                             FROM
                                                                                 ClaimInfo
                                                                             INNER JOIN ( SELECT DISTINCT
                                                                                              ClaimInfoID ,
                                                                                              Ue.OrganizationHospitalId
                                                                                          FROM
                                                                                              #EncounterUsers Ue
                                                                                          WHERE
                                                                                              EncounterDate BETWEEN @d_FromDate
                                                                                              AND @d_ToDate ) CI
                                                                                 ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                                             WHERE
                                                                                 CI.OrganizationHospitalId = Org.ProviderTypeCodeID
                                                                             GROUP BY
                                                                                 CI.OrganizationHospitalId ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN CodeSetProviderType Org WITH (NOLOCK)
                                ON TEU.OrganizationHospitalId = Org.ProviderTypeCodeID
                                   AND Org.StatusCode = 'A'
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                            WHERE
                                TEU.OrganizationHospitalId IS NOT NULL
                                AND TEU.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.ProviderTypeCodeID ,
                                Org.Description ,
                                TEU.OrganizationHospitalId
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                COUNT(DISTINCT CI.ClaimInfoid) DESC )
                  END
               ELSE
                  BEGIN

                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 1
                                'Pcp-' + CONVERT(VARCHAR(12) , P.UserId) ,
                                dbo.ufn_GetUserNameByID(P.UserId) ,
                                'PCP' ,
                                --SUM(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = TEU.ProviderId
                                         AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID ) ,
                                --SUM(CAST(ISNULL(TEU.IsEncounterwithPCP , 0) AS INT)) ,
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoId)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoID
                                         AND CI.ProviderId = TEU.ProviderId ) ,
                                CONVERT(VARCHAR , MAX(TEU.EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = TEU.ProviderId
                                         AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID ) ,
                                --COUNT(CLI.IcdCodeId) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeId)
                                         FROM
                                             #EncounterUsers TU
                                         INNER JOIN ClaimLine WITH (NOLOCK)
											 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON ClaimLine.ClaimInfoID = CLI.ClaimInfoID
                                         WHERE
                                             TU.IsEncounterwithPCP = 1
                                             AND EncounterDate BETWEEN @d_FromDate
                                             AND @d_ToDate
                                             AND TU.ProviderId = TEU.ProviderId
                                         GROUP BY
                                             TU.ProviderId ) / ( SELECT
                                                                     AVG(ISNULL(NetPaidAmount , 0))
                                                                 FROM
                                                                     ClaimInfo
                                                                 INNER JOIN ( SELECT DISTINCT
                                                                                  ClaimInfoID ,
                                                                                  ProviderId
                                                                              FROM
                                                                                  #EncounterUsers TE
                                                                              WHERE
                                                                                  EncounterDate BETWEEN @d_FromDate
                                                                                  AND @d_ToDate
                                                                                  AND IsEncounterwithPCP = 1 ) CI
                                                                     ON CI.ProviderId = TEU.ProviderId
                                                                        AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = TEU.ProviderId
                                         AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID ) DESC )
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN Users P WITH (NOLOCK)
                                ON P.UserId = TEU.UserId
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                            WHERE
                                TEU.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                                AND TEU.IsEncounterwithPCP = 1
                               -- AND p.UserStatusCode = 'A'
                                AND 'Pcp-' + CONVERT(VARCHAR(12) , P.UserId) IS NOT NULL
                            GROUP BY
                                'Pcp-' + CONVERT(VARCHAR(12) , P.UserId) ,
                                P.UserId ,
                                TEU.ProviderId  	  
                            --ORDER BY DENSE_RANK() OVER (ORDER BY SUM(ISNULL(CI.NetPaidAmount , 0)) DESC )  
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   ProviderId
                                               FROM
                                                   #EncounterUsers TE
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate
                                                   AND IsEncounterwithPCP = 1 ) CI
                                      ON CI.ProviderId = TEU.ProviderId
                                         AND ClaimInfo.ClaimInfoID = CI.ClaimInfoID ) DESC )

                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 5
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode) ,
                                Spe.ProviderSpecialtyName ,
                                'Speciality' ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.ProviderSpecialtyCode ) ,
                                --SUM(CASE
                                --         WHEN TEU.ProviderId IS NOT NULL THEN 1
                                --         ELSE 0
                                --    END) ,
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.SpecialityID = Spe.ProviderSpecialtyCode ) ,
                                CONVERT(VARCHAR , MAX(TEU.EncounterDate) , 101) ,
                                --AVG(ISNULL(CI.NetPaidAmount , 0)) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.ProviderSpecialtyCode ) ,
                                  --COUNT(CLI.IcdCodeId) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeId)
                                         FROM
                                             #EncounterUsers TU
                                         INNER JOIN ClaimLine WITH (NOLOCK)
											 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON ClaimLine.ClaimLineID = CLI.ClaiminfoID
                                         WHERE
                                             TU.SpecialityId = TEU.SpecialityId
                                         GROUP BY
                                             TU.SpecialityId ) / ( SELECT
                                                                       COUNT(ClaimInfo.ClaimInfoID)
                                                                   FROM
                                                                       ClaimInfo
                                                                   INNER JOIN ( SELECT DISTINCT
                                                                                    ClaimInfoID ,
                                                                                    Ue.SpecialityId
                                                                                FROM
                                                                                    #EncounterUsers Ue
                                                                                WHERE
                                                                                    EncounterDate BETWEEN @d_FromDate
                                                                                    AND @d_ToDate ) CI
                                                                       ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                                   WHERE
                                                                       CI.SpecialityID = Spe.ProviderSpecialtyCode ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.SpecialityId ) DESC )
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN CodeSetCMSProviderSpecialty Spe WITH (NOLOCK)
                                ON Spe.ProviderSpecialtyCode = TEU.SpecialityId
                            INNER JOIN ClaimInfo CI  WITH (NOLOCK)
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                            WHERE
                                TEU.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                Spe.ProviderSpecialtyName ,
                                Spe.ProviderSpecialtyCode ,
                                TEU.SpecialityId ,
                                'Spe-' + CONVERT(VARCHAR(12) , Spe.ProviderSpecialtyCode)
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.SpecialityId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.SpecialityId = Spe.SpecialityId ) DESC )
                        INSERT INTO
                            @t_Specialities
                            (
                              ID ,
                              Name ,
                              [Type] ,
                              Cost ,
                              Visits ,
                              LastVisit ,
                              DollarsPerVisit ,
                              DiagnosisPerVisit ,
                              OrderMaxVisit
                            )
                            SELECT TOP 4
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.Description,
                                'Hospital' ,
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) ,	
                                --SUM(CASE
                                --         WHEN TEU.OrganizationHospitalId IS NOT NULL THEN 1
                                --         ELSE 0
                                --    END) ,
                                ( SELECT
                                      COUNT(ClaimInfo.ClaimInfoID)
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                  WHERE
                                      CI.OrganizationHospitalId = Org.ProviderTypeCodeID
                                  GROUP BY
                                      CI.OrganizationHospitalId ) ,
                                CONVERT(VARCHAR , MAX(TEU.EncounterDate) , 101) ,
                                ( SELECT
                                      CAST(AVG(ISNULL(NetPaidAmount , 0)) AS DECIMAL(10,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   Ue.OrganizationHospitalId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Org.ProviderTypeCodeID ) ,
                                 --COUNT(CLI.IcdCodeId) ,
                                ISNULL(( SELECT
                                             COUNT(DISTINCT PatientDiagnosisCodeID)
                                         FROM
                                             #EncounterUsers TU
                                         INNER JOIN ClaimLine WITH (NOLOCK)
											 ON ClaimLine.ClaimInfoID = TU.ClaimInfoID    
                                         INNER JOIN PatientDiagnosisCode CLI WITH (NOLOCK)
                                             ON ClaimLine.ClaimLineID = CLI.ClaiminfoID
                                         WHERE
                                             TU.OrganizationHospitalId = TEU.OrganizationHospitalId
                                         GROUP BY
                                             TU.OrganizationHospitalId ) / ( SELECT
                                                                                 COUNT(ClaimInfo.ClaimInfoID)
                                                                             FROM
                                                                                 ClaimInfo
                                                                             INNER JOIN ( SELECT DISTINCT
                                                                                              ClaimInfoID ,
                                                                                              Ue.OrganizationHospitalId
                                                                                          FROM
                                                                                              #EncounterUsers Ue
                                                                                          WHERE
                                                                                              EncounterDate BETWEEN @d_FromDate
                                                                                              AND @d_ToDate ) CI
                                                                                 ON CI.ClaimInfoID = ClaimInfo.ClaimInfoId
                                                                             WHERE
                                                                                 CI.OrganizationHospitalId = Org.ProviderTypeCodeID
                                                                             GROUP BY
                                                                                 CI.OrganizationHospitalId ) , 0) ,
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   UE.OrganizationHospitalId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Org.OrganizationId ) DESC )
                            FROM
                                #EncounterUsers TEU
                            INNER JOIN CodeSetProviderType Org WITH (NOLOCK)
                                ON TEU.OrganizationHospitalId = Org.ProviderTypeCodeID
                                   AND Org.StatusCode = 'A'
                            INNER JOIN ClaimInfo CI WITH (NOLOCK)
                                ON CI.ClaimInfoId = TEU.ClaimInfoID
                             --LEFT JOIN ClaimLineIcd CLI
                             --    ON CI.ClaimInfoId = CLI.ClaimInfoId
                            WHERE
                                TEU.OrganizationHospitalId IS NOT NULL
                                AND TEU.EncounterDate BETWEEN @d_FromDate
                                AND @d_ToDate
                            GROUP BY
                                'Hos-' + CONVERT(VARCHAR(12) , Org.ProviderTypeCodeID) ,
                                Org.ProviderTypeCodeID ,
                                Org.Description ,
                                TEU.OrganizationHospitalId
                            ORDER BY
                                DENSE_RANK() OVER (
                                ORDER BY
                                ( SELECT
                                      CAST(SUM(ISNULL(NetPaidAmount , 0)) AS DECIMAL(20,2))
                                  FROM
                                      ClaimInfo
                                  INNER JOIN ( SELECT DISTINCT
                                                   ClaimInfoID ,
                                                   UE.OrganizationHospitalId
                                               FROM
                                                   #EncounterUsers Ue
                                               WHERE
                                                   EncounterDate BETWEEN @d_FromDate
                                                   AND @d_ToDate ) CI
                                      ON ClaimInfo.ClaimInfoID = CI.ClaimInfoID
                                         AND CI.OrganizationHospitalId = Org.OrganizationId ) DESC )
                  END
         END

      DECLARE
              @i_Totalcost MONEY = ( SELECT
                                         SUM(Cost)
                                     FROM
                                         @t_Specialities ) ,
              @i_TotalVisits MONEY = ( SELECT
                                           SUM(Visits)
                                       FROM
                                           @t_Specialities )


      IF @b_IsByCost = 1
         BEGIN
         --SELECT * FROM @t_Specialities

               SELECT
                   ID ,
                   Name ,
                   [Type] ,
                   Cost ,
                   Visits ,
                   CASE DENSE_RANK() OVER (
                   ORDER BY Cost DESC )
                   --CONVERT(DECIMAL(10,2) , ( SUM(Cost) * 100.00 ) / NULLIF(@i_Totalcost , 0)) DESC )
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
                   CONVERT(DECIMAL(10,2) , ( SUM(Cost) * 100.00 ) / NULLIF(@i_Totalcost , 0)) AS ActualPercentage ,
                   LastVisit ,
                   DollarsPerVisit ,
                   DiagnosisPerVisit
               FROM
                   @t_Specialities
               --WHERE
               --    Cost <> 0
               GROUP BY
                   Name ,
                   ID ,
                   [Type] ,
                   Cost ,
                   LastVisit ,
                   DollarsPerVisit ,
                   DiagnosisPerVisit ,
                   Visits
               ORDER BY
                   Percentage DESC
                 
         END
         
         
         
      ELSE
         BEGIN

               SELECT
                   ID ,
                   Name ,
                   Type ,
                   Cost ,
                   Visits ,
                   CASE DENSE_RANK() OVER (
                   ORDER BY Visits DESC )
                   --CONVERT(DECIMAL(10,2) , ( SUM(Visits) * 100.00 ) / @i_TotalVisits) DESC )
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
                   CONVERT(DECIMAL(10,2) , ( SUM(Visits) * 100.00 ) / @i_TotalVisits) AS ActualPercentage ,
                   LastVisit ,
                   DollarsPerVisit ,
                   DiagnosisPerVisit
               FROM
                   @t_Specialities
               WHERE
                   Visits <> 0
               GROUP BY
                   ID ,
                   Name ,
                   Type ,
                   Cost ,
                   Visits ,
                   LastVisit ,
                   DollarsPerVisit ,
                   DiagnosisPerVisit
               ORDER BY
                   Percentage DESC
         END END TRY
------------------------------------------------------------------------------------------------------------------------- 
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Reports_CareCoordination] TO [FE_rohit.r-ext]
    AS [dbo];

