/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_Reports_FilterAndCompareTrinityMeasure]
Description   : 
Created By    : NagaBabu
Created Date  : 25-Jan-2012
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION 
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_Reports_FilterAndCompareTrinityMeasure]
(
 @i_AppUserId KEYID ,
 @t_QualityMeasureIDList TBSOURCENAME READONLY ,
 @t_ProviderList1 TBSOURCENAME READONLY ,
 @t_ProviderList2 TBSOURCENAME READONLY, --- For Second list
 @t_CohortList1 TBSOURCENAME READONLY ,
 @t_CohortList2 TBSOURCENAME READONLY ,
 @b_IsAggregate1 BIT = 0, --FirstAggregate
 @b_IsAggregate2 BIT = 0, --FirstAggregate
 @d_FromYear INT = NULL ,
 @d_ToYear INT = NULL
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


      SELECT
          CAST(SUBSTRING(SourceName , 1 , CHARINDEX('-' , SourceName , 1) - 1) AS INT) AS DiseaseId ,
          CAST(SUBSTRING(SourceName , CHARINDEX('-' , SourceName , 1) + 1 , LEN(SourceName)) AS INT) AS HealthCareQualityMeasureID
      INTO
          #QualityMeasureID
      FROM
          @t_QualityMeasureIDList

      CREATE TABLE #Types1
      (
        TypeName VARCHAR(20) ,
        TypeId INT
      )

      INSERT INTO
          #Types1
          (
            TypeName ,
            TypeId
          )
          SELECT
              SUBSTRING(SourceName , 1 , CHARINDEX('-' , SourceName , 1) - 1) AS TypeName ,
              CAST(SUBSTRING(SourceName , CHARINDEX('-' , SourceName , 1) + 1 , LEN(SourceName)) AS INT) AS TypeId
          FROM
              @t_ProviderList1
          UNION
          SELECT
              SUBSTRING(SourceName , 1 , CHARINDEX('-' , SourceName , 1) - 1) AS TypeName ,
              CAST(SUBSTRING(SourceName , CHARINDEX('-' , SourceName , 1) + 1 , LEN(SourceName)) AS INT) AS TypeId
          FROM
              @t_CohortList1

      CREATE TABLE #Types2
      (
        TypeName VARCHAR(20) ,
        TypeId INT
      )

      INSERT INTO
          #Types2
          (
            TypeName ,
            TypeId
          )
          SELECT
              SUBSTRING(SourceName , 1 , CHARINDEX('-' , SourceName , 1) - 1) AS TypeName ,
              CAST(SUBSTRING(SourceName , CHARINDEX('-' , SourceName , 1) + 1 , LEN(SourceName)) AS INT) AS TypeId
          FROM
              @t_ProviderList2
          UNION
          SELECT
              SUBSTRING(SourceName , 1 , CHARINDEX('-' , SourceName , 1) - 1) AS TypeName ,
              CAST(SUBSTRING(SourceName , CHARINDEX('-' , SourceName , 1) + 1 , LEN(SourceName)) AS INT) AS TypeId
          FROM
              @t_CohortList2

      CREATE TABLE #tblCriteriaText
      (
        MeasureID INT ,
        DenominatorCriteriaText VARCHAR(MAX) ,
        NumeratorCriteriaText VARCHAR(MAX)
      )
      INSERT INTO
          #tblCriteriaText
          SELECT
              QMID.HealthCareQualityMeasureID ,
              STUFF(( SELECT
                          ' ' + SUBSTRING(CriteriaText , 1 , 100) + ' \n ' + SUBSTRING(CriteriaText , 101 , 100) + ' \n ' + SUBSTRING(CriteriaText , 201 , 100) + ' \n ' + SUBSTRING(CriteriaText , 301 , 100) + ' \n ' + SUBSTRING(CriteriaText , 401 , 100)
                      FROM
                          HealthCareQualityMeasureNrDrDefinition hcqmd
                      WHERE
                          hcqmd.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                          AND hcqmd.NrDrIndicator = 'D'
                      FOR
                          XML PATH('') ) , 1 , 1 , '') AS DenominatorCriteriaText ,
              STUFF(( SELECT
                          ' ' + SUBSTRING(CriteriaText , 1 , 100) + ' \n ' + SUBSTRING(CriteriaText , 101 , 100) + ' \n ' + SUBSTRING(CriteriaText , 201 , 100) + ' \n ' + SUBSTRING(CriteriaText , 301 , 100) + ' \n ' + SUBSTRING(CriteriaText , 401 , 100)
                      FROM
                          HealthCareQualityMeasureNrDrDefinition hcqmd
                      WHERE
                          hcqmd.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                          AND hcqmd.NrDrIndicator = 'N'
                      FOR
                          XML PATH('') ) , 1 , 1 , '') AS NumeratorCriteriaText
          FROM
              #QualityMeasureID QMID


      IF @b_IsAggregate1 = 0
         BEGIN
               CREATE TABLE #tblCustomMeasure
               (
                 WhichType VARCHAR(30) ,
                 ProviderUserID INT ,
                 HealthCareQualityMeasureID VARCHAR(20) ,
                 HealthCareQualityMeasureName VARCHAR(400) ,
                 DenominatorCount INT ,
                 NumeratorCount INT
               )
               IF EXISTS ( SELECT
                               1
                           FROM
                               @t_ProviderList1 )
                  BEGIN
                        INSERT INTO
                            #tblCustomMeasure
                            SELECT
                                'Provider' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID 
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'Prov'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'Organization' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN Organization ORG WITH (NOLOCK)
                                ON ORG.OrganizationId = ORWT.OrganizationId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = ORG.OrganizationId
                            WHERE
                                Type1.TypeName = 'Org'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'Facility' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = OUF.OrganizationFacilityID
                            WHERE
                                Type1.TypeName = 'Fac'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'OrganizationType' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = ORWT.OrganizationWiseTypeID
                            WHERE
                                Type1.TypeName = 'OrgType'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'OrganizationGroup' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme  WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK) 
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = ORWT.OrganizationWiseTypeID
                            WHERE
                                Type1.TypeName = 'OrgGroup'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'Cohort' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN PopulationDefinitionUsers WITH (NOLOCK)
                                ON PopulationDefinitionUsers.UserId = hcqmdu.PatientUserID
                            INNER JOIN PopulationDefinition WITH (NOLOCK)
                                ON PopulationDefinition.PopulationDefinitionId = PopulationDefinitionUsers.PopulationDefinitionId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = PopulationDefinition.PopulationDefinitionId
                            WHERE
                                Type1.TypeName = 'Cohort'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'Program' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN UserPrograms WITH (NOLOCK)
                                ON UserPrograms.UserId = hcqmdu.PatientUserID
                            INNER JOIN Program WITH (NOLOCK)
                                ON Program.ProgramId = UserPrograms.ProgramId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = Program.ProgramId
                            WHERE
                                Type1.TypeName = 'Program'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'CareTeam' ,
                                hcqmdu.ProviderUserID ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                ( SELECT
                                      COUNT(PatientUserID)
                                  FROM
                                      HealthCareQualityMeasureNumeratorUser hcqmnu
                                  WHERE
                                      hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                      AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN Patients
                                ON Patients.UserId = hcqmdu.PatientUserID
                            INNER JOIN CareTeam
                                ON CareTeam.CareTeamId = Patients.CareTeamId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = CareTeam.CareTeamId
                            WHERE
                                Type1.TypeName = 'CareTeam'
                            GROUP BY
                                hcqmdu.ProviderUserID ,
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                  END
               SELECT
                   WhichType ,
                   ProviderUserID AS TypeID ,
                   CASE
                        WHEN ProviderUserID > 0 THEN dbo.ufn_GetUserNameByID(ProviderUserID)
                        ELSE 'Org'
                   END AS TypeName ,
                   HealthCareQualityMeasureID ,
                   HealthCareQualityMeasureName ,
                   DenominatorCount ,
                   NumeratorCount ,
                   CONVERT(DECIMAL(10,2) , ( ( DenominatorCount ) * 100.00 ) / ( DenominatorCount + NumeratorCount )) AS DenominatorPercentage ,
                   CONVERT(DECIMAL(10,2) , ( ( NumeratorCount ) * 100.00 ) / ( DenominatorCount + NumeratorCount )) AS NumeratorPercentage ,
                   ISNULL(ct.DenominatorCriteriaText , 'No Criteria') DenominatorCriteriaText ,
                   ISNULL(ct.NumeratorCriteriaText , 'No Criteria') NumeratorCriteriaText
               FROM
                   #tblCustomMeasure TCM
               INNER JOIN #tblCriteriaText ct
                   ON ct.MeasureID = CAST(SUBSTRING(TCM.HealthCareQualityMeasureID , CHARINDEX('-' , TCM.HealthCareQualityMeasureID , 1) + 1 , LEN(TCM.HealthCareQualityMeasureID)) AS INT)
               UNION ALL
               SELECT
                   'Provider' ,
                   t1.TypeId AS TypeID ,
                   dbo.ufn_GetUserNameByID(t1.TypeId) AS TypeName ,
                   CAST(hcqm.DiseaseId AS VARCHAR) + '-' + CAST(hcqm.HealthCareQualityMeasureID AS VARCHAR) AS HealthCareQualityMeasureID ,
                   NULL ,
                   0 ,
                   0 ,
                   0 AS DenominatorPercentage ,
                   0 AS NumeratorPercentage ,
                   'No Criteria' ,
                   'No Criteria'
               FROM
                   #QualityMeasureID hcqm ,
                   #Types1 t1
               WHERE
                   NOT EXISTS ( SELECT
                                    1
                                FROM
                                    #tblCustomMeasure m
                                WHERE
                                    t1.TypeId = m.ProviderUserID
                                    AND t1.TypeName = 'Prov'
                                    AND CAST(SUBSTRING(M.HealthCareQualityMeasureID , CHARINDEX('-' , M.HealthCareQualityMeasureID , 1) + 1 , LEN(M.HealthCareQualityMeasureID)) AS INT) = hcqm.HealthCareQualityMeasureID )
         END

      IF @b_IsAggregate1 = 1
         BEGIN
               CREATE TABLE #tblCustomMeasure1
               (
                 SetType VARCHAR(20) ,
                 WhichType VARCHAR(20) ,
                 ProviderUserID INT ,
                 HealthCareQualityMeasureID VARCHAR(20) ,
                 HealthCareQualityMeasureName VARCHAR(400) ,
                 DenominatorCount INT ,
                 NumeratorCount INT
               )


               IF EXISTS ( SELECT
                               1
                           FROM
                               @t_ProviderList1 )
                  BEGIN
                        INSERT INTO
                            #tblCustomMeasure1
                            (
                              SetType ,
                              WhichType ,
                              ProviderUserID ,
                              HealthCareQualityMeasureID ,
                              HealthCareQualityMeasureName ,
                              DenominatorCount ,
                              NumeratorCount
                            )
                            SELECT
                                'SET1' ,
                                'Provider' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = hcqmdu.ProviderUserID
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'Prov'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'SET1' ,
                                'Organization' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN Organization ORG WITH (NOLOCK)
                                ON ORG.OrganizationId = ORWT.OrganizationId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = ORG.OrganizationId
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'Org'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'SET1' ,
                                'Facility' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = OUF.OrganizationFacilityID
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'Fac'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'SET1' ,
                                'OrganizationType' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = ORWT.OrganizationWiseTypeID
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'OrgType'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'SET1' ,
                                'OrganizationGroup' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                            INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                            INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = ORWT.OrganizationWiseTypeID
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'OrgGroup'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'SET1' ,
                                'Cohort' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN CohortListUsers WITH (NOLOCK)
                                ON PopulationDefinitionUsers.UserId = hcqmdu.PatientUserID
                            INNER JOIN PopulationDefinition WITH (NOLOCK)
                                ON PopulationDefinition.PopulationDefinitionId = PopulationDefinitionUsers.PopulationDefinitionId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = PopulationDefinition.PopulationDefinitionId
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'Cohort'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'SET1' ,
                                'Program' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN UserPrograms WITH (NOLOCK)
                                ON UserPrograms.UserId = hcqmdu.PatientUserID
                            INNER JOIN Program WITH (NOLOCK)
                                ON Program.ProgramId = UserPrograms.ProgramId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = Program.ProgramId
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'Program'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                            UNION
                            SELECT
                                'SET1' ,
                                'CareTeam' ,
                                NULL ,
                                CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                            FROM
                                HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                            INNER JOIN #QualityMeasureID QMID
                                ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                            INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                            INNER JOIN Patients WITH (NOLOCK)
                                ON Patients.UserId = hcqmdu.PatientUserID
                            INNER JOIN CareTeam WITH (NOLOCK)
                                ON CareTeam.CareTeamId = Patients.CareTeamId
                            INNER JOIN #Types1 Type1
                                ON Type1.TypeId = CareTeam.CareTeamId
                            LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                   AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                            WHERE
                                Type1.TypeName = 'CareTeam'
                            GROUP BY
                                hcqmdu.HealthCareQualityMeasureID ,
                                hcqme.HealthCareQualityMeasureName ,
                                hcqme.DiseaseID
                  END

               IF @b_IsAggregate2 = 0
                  BEGIN
                        IF EXISTS ( SELECT
                                        1
                                    FROM
                                        @t_ProviderList2 )
                           BEGIN
                                 INSERT INTO
                                     #tblCustomMeasure1
                                     SELECT
                                         'SET2' ,
                                         'Provider' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'Prov'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Organization' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN Organization ORG WITH (NOLOCK)
                                         ON ORG.OrganizationId = ORWT.OrganizationId
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = ORG.OrganizationId
                                     WHERE
                                         Type2.TypeName = 'Org'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Facility' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = OUF.OrganizationFacilityID
                                     WHERE
                                         Type2.TypeName = 'Fac'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'OrganizationType' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = ORWT.OrganizationWiseTypeID
                                     WHERE
                                         Type2.TypeName = 'OrgType'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'OrganizationGroup' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = ORWT.OrganizationWiseTypeID
                                     WHERE
                                         Type2.TypeName = 'OrgGroup'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Cohort' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN CohortListUsers WITH (NOLOCK)
                                         ON CohortListUsers.UserId = hcqmdu.PatientUserID
                                     INNER JOIN Cohortlist WITH (NOLOCK)
                                         ON PopulationDefinition.PopulationDefinitionId = PopulationDefinitionUsers.PopulationDefinitionId
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = PopulationDefinition.PopulationDefinitionId
                                     WHERE
                                         Type2.TypeName = 'Cohort'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Program' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN UserPrograms WITH (NOLOCK)
                                         ON UserPrograms.UserId = hcqmdu.PatientUserID
                                     INNER JOIN Program WITH (NOLOCK)
                                         ON Program.ProgramId = UserPrograms.ProgramId
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = Program.ProgramId
                                     WHERE
                                         Type2.TypeName = 'Program'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'CareTeam' ,
                                         hcqmdu.ProviderUserID ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         ( SELECT
                                               COUNT(PatientUserID)
                                           FROM
                                               HealthCareQualityMeasureNumeratorUser hcqmnu
                                           WHERE
                                               hcqmnu.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                               AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID ) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN Patients WITH (NOLOCK)
                                         ON Patients.UserId = hcqmdu.PatientUserID
                                     INNER JOIN CareTeam WITH (NOLOCK)
                                         ON CareTeam.CareTeamId = Patients.CareTeamId
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = CareTeam.CareTeamId
                                     WHERE
                                         Type2.TypeName = 'CareTeam'
                                     GROUP BY
                                         hcqmdu.ProviderUserID ,
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                           END
                        SELECT
                            SetType ,
                            NULL AS WhichType ,
                            0 AS TypeID ,
                            'SET1' AS TypeName ,
                            HealthCareQualityMeasureID ,
                            HealthCareQualityMeasureName ,
                            SUM(DenominatorCount) AS DenominatorCount ,
                            SUM(NumeratorCount) AS NumeratorCount ,
                            CONVERT(DECIMAL(10,2) , ( SUM(DenominatorCount) * 100.00 ) / ( SUM(DenominatorCount) + SUM(NumeratorCount) )) AS DenominatorPercentage ,
                            CONVERT(DECIMAL(10,2) , ( SUM(NumeratorCount) * 100.00 ) / ( SUM(DenominatorCount) + SUM(NumeratorCount) )) AS NumeratorPercentage ,
                            ISNULL(ct.DenominatorCriteriaText , 'No Criteria') DenominatorCriteriaText ,
                            ISNULL(ct.NumeratorCriteriaText , 'No Criteria') NumeratorCriteriaText ,
                            STUFF((
                                    SELECT DISTINCT
                                        ', ' + dbo.ufn_GetUserNameByID(Types1.TypeId)
                                    FROM
                                        #Types1 Types1
                                    WHERE
                                        Types1.TypeName = 'Prov'
                                    FOR
                                        XML PATH('')
                                  ) , 1 , 2 , '') ProviderList ,
                            STUFF((
                                    SELECT DISTINCT
                                        ', ' + CONVERT(VARCHAR , ISNULL(Types1.TypeId , ''))
                                    FROM
                                        #Types1 Types1
                                    WHERE
                                        Types1.TypeName = 'Prov'
                                    FOR
                                        XML PATH('')
                                  ) , 1 , 2 , '') ProviderIDList
                        FROM
                            #tblCustomMeasure1
                        INNER JOIN #tblCriteriaText ct
                            ON ct.MeasureID = CAST(SUBSTRING(#tblCustomMeasure1.HealthCareQualityMeasureID , CHARINDEX('-' , #tblCustomMeasure1.HealthCareQualityMeasureID , 1) + 1 , LEN(#tblCustomMeasure1.HealthCareQualityMeasureID)) AS INT)
                        WHERE
                            SetType = 'SET1'
                        GROUP BY
                            SetType ,
                            HealthCareQualityMeasureID ,
                            HealthCareQualityMeasureName ,
                            ct.DenominatorCriteriaText ,
                            ct.NumeratorCriteriaText
                        UNION
                        SELECT
                            SetType ,
                            WhichType ,
                            ISNULL(ProviderUserID , 0) TypeID ,
                            CASE
                                 WHEN ProviderUserID > 0 THEN dbo.ufn_GetUserNameByID(ProviderUserID)
                                 ELSE 'Org'
                            END AS TypeName ,
                            HealthCareQualityMeasureID ,
                            HealthCareQualityMeasureName ,
                            DenominatorCount ,
                            NumeratorCount ,
                            CONVERT(DECIMAL(10,2) , ( ( DenominatorCount ) * 100.00 ) / ( DenominatorCount + NumeratorCount )) AS DenominatorPercentage ,
                            CONVERT(DECIMAL(10,2) , ( ( NumeratorCount ) * 100.00 ) / ( DenominatorCount + NumeratorCount )) AS NumeratorPercentage ,
                            ISNULL(ct.DenominatorCriteriaText , 'No Criteria') DenominatorCriteriaText ,
                            ISNULL(ct.NumeratorCriteriaText , 'No Criteria') NumeratorCriteriaText ,
                            NULL AS ProviderList ,
                            NULL AS ProviderIDList
                        FROM
                            #tblCustomMeasure1
                        INNER JOIN #tblCriteriaText ct
                            ON ct.MeasureID = CAST(SUBSTRING(#tblCustomMeasure1.HealthCareQualityMeasureID , CHARINDEX('-' , #tblCustomMeasure1.HealthCareQualityMeasureID , 1) + 1 , LEN(#tblCustomMeasure1.HealthCareQualityMeasureID)) AS INT)
                        WHERE
                            SetType = 'SET2'
                        UNION
                        SELECT
                            'SET2' ,
                            'Provider' ,
                            Types2.TypeId AS TypeID ,
                            dbo.ufn_GetUserNameByID(Types2.TypeId) AS TypeName ,
                            CAST(QMID.DiseaseId AS VARCHAR) + '-' + CAST(QMID.HealthCareQualityMeasureID AS VARCHAR) AS HealthCareQualityMeasureID ,
                            NULL ,
                            0 ,
                            0 ,
                            0 AS DenominatorPercentage ,
                            0 AS NumeratorPercentage ,
                            'No Criteria' ,
                            'No Criteria' ,
                            NULL AS ProviderList ,
                            NULL AS ProviderIDList
                        FROM
                            #QualityMeasureID QMID ,
                            #Types2 Types2
                        WHERE
                            NOT EXISTS ( SELECT
                                             1
                                         FROM
                                             #tblCustomMeasure1 m
                                         WHERE
                                             Types2.TypeId = m.ProviderUserID
                                             AND CAST(SUBSTRING(M.HealthCareQualityMeasureID , CHARINDEX('-' , M.HealthCareQualityMeasureID , 1) + 1 , LEN(M.HealthCareQualityMeasureID)) AS INT) = QMID.HealthCareQualityMeasureID
                                             AND Types2.TypeName = 'Prov' )
                  END

               IF @b_IsAggregate2 = 1
                  BEGIN
                        IF EXISTS ( SELECT
                                        1
                                    FROM
                                        @t_ProviderList2 )
                           BEGIN
                                 INSERT INTO
                                     #tblCustomMeasure1
                                     SELECT
                                         'SET2' ,
                                         'Provider' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = hcqmdu.ProviderUserID
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'Prov'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Organization' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN Organization ORG WITH (NOLOCK)
                                         ON ORG.OrganizationId = ORWT.OrganizationId
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = ORG.OrganizationId
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'Org'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Facility' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID 
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = OUF.OrganizationFacilityID
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'Fac'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'OrganizationType' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = ORWT.OrganizationWiseTypeID
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'OrgType'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'OrganizationGroup' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN OrganizationFacilityProvider ORFP WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityProviderID = hcqmdu.ProviderUserID
                                     INNER JOIN OrganizationFacility OUF WITH (NOLOCK)
                                         ON ORFP.OrganizationFacilityID = OUF.OrganizationFacilityID
                                     INNER JOIN OrganizationWiseType ORWT WITH (NOLOCK)
                                         ON OUF.OrganizationWiseTypeID = ORWT.OrganizationWiseTypeID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = ORWT.OrganizationWiseTypeID
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'OrgGroup'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Cohort' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN CohortListUsers WITH (NOLOCK)
                                         ON CohortListUsers.UserId = hcqmdu.PatientUserID
                                     INNER JOIN Cohortlist WITH (NOLOCK)
                                         ON PopulationDefinition.PopulationDefinitionId = PopulationDefinitionUsers.PopulationDefinitionID
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = PopulationDefinition.PopulationDefinitionId
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'Cohort'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'Program' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM 
                                         HealthCareQualityMeasureDenominatorUser hcqmdu WITH (NOLOCK)
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN UserPrograms WITH (NOLOCK)
                                         ON UserPrograms.UserId = hcqmdu.PatientUserID
                                     INNER JOIN Program WITH (NOLOCK)
                                         ON Program.ProgramId = UserPrograms.ProgramId
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = Program.ProgramId
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'Program'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                     UNION
                                     SELECT
                                         'SET2' ,
                                         'CareTeam' ,
                                         NULL ,
                                         CAST(hcqme.DiseaseID AS VARCHAR(10)) + '-' + CAST(hcqmdu.HealthCareQualityMeasureID AS VARCHAR(10)) AS HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         COUNT(DISTINCT hcqmdu.PatientUserId) DenominatorCount ,
                                         COUNT(DISTINCT hcqmnu.PatientUserID) NumeratorCount
                                     FROM
                                         HealthCareQualityMeasureDenominatorUser hcqmdu
                                     INNER JOIN #QualityMeasureID QMID
                                         ON QMID.HealthCareQualityMeasureID = hcqmdu.HealthCareQualityMeasureID
                                     INNER JOIN HealthCareQualityMeasure hcqme WITH (NOLOCK)
                                         ON hcqme.HealthCareQualityMeasureID = QMID.HealthCareQualityMeasureID
                                     INNER JOIN Patients WITH (NOLOCK)
                                         ON Patients.UserId = hcqmdu.PatientUserID
                                     INNER JOIN CareTeam WITH (NOLOCK)
                                         ON CareTeam.CareTeamId = Patients.CareTeamId
                                     INNER JOIN #Types2 Type2
                                         ON Type2.TypeId = CareTeam.CareTeamId
                                     LEFT OUTER JOIN HealthCareQualityMeasureNumeratorUser hcqmnu WITH (NOLOCK)
                                         ON hcqmnu.HealthCareQualityMeasureID = hcqme.HealthCareQualityMeasureID
                                            AND hcqmnu.ProviderUserID = hcqmdu.ProviderUserID
                                     WHERE
                                         Type2.TypeName = 'CareTeam'
                                     GROUP BY
                                         hcqmdu.HealthCareQualityMeasureID ,
                                         hcqme.HealthCareQualityMeasureName ,
                                         hcqme.DiseaseID
                                 SELECT
                                     SetType ,
                                     NULL AS WhichType ,
                                     0 AS TypeID ,
                                     'SET1' AS TypeName ,
                                     HealthCareQualityMeasureID ,
                                     HealthCareQualityMeasureName ,
                                     SUM(DenominatorCount) DenominatorCount ,
                                     SUM(NumeratorCount) NumeratorCount ,
                                     CONVERT(DECIMAL(10,2) , ( SUM(DenominatorCount) * 100.00 ) / ( SUM(DenominatorCount) + SUM(NumeratorCount) )) AS DenominatorPercentage ,
                                     CONVERT(DECIMAL(10,2) , ( SUM(NumeratorCount) * 100.00 ) / ( SUM(DenominatorCount) + SUM(NumeratorCount) )) AS NumeratorPercentage ,
                                     ISNULL(ct.DenominatorCriteriaText , 'No Criteria') DenominatorCriteriaText ,
                                     ISNULL(ct.NumeratorCriteriaText , 'No Criteria') NumeratorCriteriaText ,
                                     STUFF((
                                             SELECT DISTINCT
                                                 ', ' + dbo.ufn_GetUserNameByID(Type1.TypeId)
                                             FROM
                                                 #Types1 Type1
                                             WHERE
                                                 Type1.TypeName = 'Prov'
                                             FOR
                                                 XML PATH('')
                                           ) , 1 , 2 , '') ProviderList ,
                                     STUFF((
                                             SELECT DISTINCT
                                                 ', ' + CONVERT(VARCHAR , ISNULL(Type1.TypeId , ''))
                                             FROM
                                                 #Types1 Type1
                                             WHERE
                                                 Type1.TypeName = 'Prov'
                                             FOR
                                                 XML PATH('')
                                           ) , 1 , 2 , '') ProviderIDList
                                 FROM
                                     #tblCustomMeasure1
                                 INNER JOIN #tblCriteriaText ct
                                     ON ct.MeasureID = CAST(SUBSTRING(#tblCustomMeasure1.HealthCareQualityMeasureID , CHARINDEX('-' , #tblCustomMeasure1.HealthCareQualityMeasureID , 1) + 1 , LEN(#tblCustomMeasure1.HealthCareQualityMeasureID)) AS INT)
                                 WHERE
                                     SetType = 'SET1'
                                 GROUP BY
                                     SetType ,
                                     HealthCareQualityMeasureID ,
                                     HealthCareQualityMeasureName ,
                                     ct.DenominatorCriteriaText ,
                                     ct.NumeratorCriteriaText
                                 UNION
                                 SELECT
                                     SetType ,
                                     NULL AS WhichType ,
                                     0 AS TypeID ,
                                     'SET2' AS TypeName ,
                                     HealthCareQualityMeasureID ,
                                     HealthCareQualityMeasureName ,
                                     SUM(DenominatorCount) DenominatorCount ,
                                     SUM(NumeratorCount) NumeratorCount ,
                                     CONVERT(DECIMAL(10,2) , ( SUM(DenominatorCount) * 100.00 ) / ( SUM(DenominatorCount) + SUM(NumeratorCount) )) AS DenominatorPercentage ,
                                     CONVERT(DECIMAL(10,2) , ( SUM(NumeratorCount) * 100.00 ) / ( SUM(DenominatorCount) + SUM(NumeratorCount) )) AS NumeratorPercentage ,
                                     ISNULL(ct.DenominatorCriteriaText , 'No Criteria') DenominatorCriteriaText ,
                                     ISNULL(ct.NumeratorCriteriaText , 'No Criteria') NumeratorCriteriaText ,
                                     STUFF((
                                             SELECT DISTINCT
                                                 ', ' + dbo.ufn_GetUserNameByID(Type2.TypeId)
                                             FROM
                                                 #Types2 Type2
                                             WHERE
                                                 Type2.TypeName = 'Prov'
                                             FOR
                                                 XML PATH('')
                                           ) , 1 , 2 , '') ProviderList ,
                                     STUFF((
                                             SELECT DISTINCT
                                                 ', ' + CONVERT(VARCHAR , ISNULL(Type2.TypeId , ''))
                                             FROM
                                                 #Types2 Type2
                                             WHERE
                                                 Type2.TypeName = 'Prov'
                                             FOR
                                                 XML PATH('')
                                           ) , 1 , 2 , '') ProviderIDList
                                 FROM
                                     #tblCustomMeasure1
                                 INNER JOIN #tblCriteriaText ct
                                     ON ct.MeasureID = CAST(SUBSTRING(#tblCustomMeasure1.HealthCareQualityMeasureID , CHARINDEX('-' , #tblCustomMeasure1.HealthCareQualityMeasureID , 1) + 1 , LEN(#tblCustomMeasure1.HealthCareQualityMeasureID)) AS INT)
                                 WHERE
                                     SetType = 'SET2'
                                 GROUP BY
                                     SetType ,
                                     HealthCareQualityMeasureID ,
                                     HealthCareQualityMeasureName ,
                                     ct.DenominatorCriteriaText ,
                                     ct.NumeratorCriteriaText

                           END


                  END
         END
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
    ON OBJECT::[dbo].[usp_Reports_FilterAndCompareTrinityMeasure] TO [FE_rohit.r-ext]
    AS [dbo];

