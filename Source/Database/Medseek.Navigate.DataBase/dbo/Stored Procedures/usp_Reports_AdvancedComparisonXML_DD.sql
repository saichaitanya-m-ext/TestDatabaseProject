
/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_Reports_AdvancedComparisonXML_DD] 1  
Description   : This procedure gives the XML result set for the Advanced & Report Comparison dropdowns 
Created By    : Rathnam
Created Date  : 02-Jan-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
05-Jan-2012 NagaBabu Modified organization related querry as per discussion with Rohith
09-Jan-2012 NagaBabu Added 'OrganizationGroup' node to the XML quary
10-Jan-2012 NagaBabu Replaced Provider.ProviderId by Provider.OrganizationFacilityProviderID for Provider type
17-Jan-2012 NagaBabu Added @b_IsConditional as Input Parameter and applied Conditional querries.
23-Jan-2012 NagaBabu Replaced OrganizationType.OrganizationType by OrganizationType.[Description] 
24-Jan-2012 NagaBabu Changed all Lables into Capital Letters 
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers 
------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Reports_AdvancedComparisonXML_DD]
(
 @i_AppUserId KEYID ,
 @b_IsConditional BIT = 0 ----0---> With Out Conditional 1---> With conditional
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
-------------------------------------------------------------------------------------


      IF @b_IsConditional = 0
         BEGIN
               SELECT
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               1 "@Id" ,
                               'SYMPHONY CARE SOLUTIONS' "@label" ,
                               0 "@checked" ,
                               'OrganizationGroup' "@type" ,
                               'true' "@isBranch" ,
                               ( SELECT
                                     org.Organizationid "@Id" ,
                                     org.OrganizationName "@label" ,
                                     1 "@ParentID" ,
                                     0 "@checked" ,
                                     'Organizations' "@Type" ,
                                     'true' "@isBranch1" ,
                                     ( SELECT
                                           owt.OrganizationWiseTypeId "@Id" ,
                                           OrganizationType.[Description] "@label" ,
                                           Organization.OrganizationId "@ParentID" ,
                                           0 "@checked" ,
                                           'OrganizationType' "@Type" ,
                                           'true' "@isBranch2" ,
                                           ( SELECT
                                                 OrganizationFacility.OrganizationFacilityid "@Id" ,
                                                 OrganizationFacility.FacilityName "@label" ,
                                                 OrganizationWiseType.OrganizationWiseTypeId "@ParentID" ,
                                                 0 "@checked" ,
                                                 'Facility' "@Type" ,
                                                 'true' "@isBranch3" ,
                                                 ( SELECT
                                                       Provider.OrganizationFacilityProviderID "node/@Id" ,
                                                       [dbo].[ufn_GetUserNameByID](Provider.ProviderId) "node/@label" ,
                                                       Provider.OrganizationFacilityID "node/@ParentID" ,
                                                       0 "node/@checked" ,
                                                       'Provider' "node/@Type" ,
                                                       'false' "node/@isBranch"
                                                   FROM
                                                       OrganizationFacilityProvider Provider
                                                   WHERE
                                                       Provider.OrganizationFacilityID = OrganizationFacility.OrganizationFacilityID
                                                   FOR
                                                       XML PATH('') ,
                                                           TYPE )
                                             FROM
                                                 OrganizationFacility with (nolock)
                                                 INNER JOIN OrganizationWiseType with (nolock)
                                                 ON OrganizationFacility.OrganizationWiseTypeID = OrganizationWiseType.OrganizationWiseTypeID
                                                 INNER JOIN OrganizationType with (nolock)
                                                 ON OrganizationType.OrganizationTypeId = OrganizationWiseType.OrganizationTypeId
                                             WHERE
                                                 OrganizationFacility.StatusCode = 'A'
                                                 AND OrganizationFacility.OrganizationWiseTypeID = owt.OrganizationWiseTypeID
                                             FOR
                                                 XML PATH('node') ,
                                                     TYPE )
                                       FROM
                                           OrganizationWiseType owt
                                           INNER JOIN OrganizationType with (nolock)
                                           ON OrganizationType.OrganizationTypeId = owt.OrganizationTypeId
                                           INNER JOIN Organization with (nolock)
                                           ON Organization.OrganizationId = owt.OrganizationId
                                       WHERE
                                           owt.StatusCode = 'A'
                                           AND owt.OrganizationId = org.OrganizationId
                                       FOR
                                           XML PATH('node') ,
                                               TYPE )
                                 FROM
                                     Organization org
                                 WHERE
                                     org.OrganizationStatusCode = 'A'
                                     AND org.ParentOrganizationId IS NULL
                                 FOR
                                     XML PATH('node') ,
                                         TYPE
                                 
                               )
                               FOR
                                   XML PATH('node') )
                         FOR
                             XML PATH('node') ) ,
------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               'COHORTS' "@label" ,
                               0 "@checked" ,
                               'PopulationDefinition' "@type" ,
                               ( SELECT
                                     coh.PopulationDefinitionID "@id" ,
                                     coh.PopulationDefinitionName "@label" ,
                                     0 "@checked" ,
                                     'Cohort' "@type"
                                 FROM
                                     PopulationDefinition coh
                                 WHERE
                                     coh.StatusCode = 'A' --and  coh.CohortListId = coho.CohortListId
                                 FOR
                                     XML PATH('node') ,
                                         TYPE )
                               FOR
                                   XML PATH('node')
                           --,ROOT ( 'node' )
                         )
                         FOR
                             XML PATH('node') ) ,   
------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               'PROGRAMS' "@label" ,
                               0 "@checked" ,
                               'Program' "@type" ,
                               ( SELECT
                                     Program.ProgramId "@id" ,
                                     Program.ProgramName "@label" ,
                                     0 "@checked" ,
                                     'Program' "@type"
                                 FROM
                                     Program
                                 WHERE
                                     Program.StatusCode = 'A'
                                 FOR
                                     XML PATH('node') ,
                                         TYPE )
                               FOR
                                   XML PATH('node') )
                         FOR
                             XML PATH('node') ) ,
			
--------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               'CARE TEAMS' "@label" ,
                               0 "@checked" ,
                               'CareTeam' "@type" ,
                               ( SELECT
                                     CareTeam.CareTeamId "@id" ,
                                     CareTeam.CareTeamName "@label" ,
                                     0 "@checked" ,
                                     'CareTeam' "@type"
                                 FROM
                                     CareTeam
                                 WHERE
                                     CareTeam.StatusCode = 'A'
                                 FOR
                                     XML PATH('node') ,
                                         TYPE )
                               FOR
                                   XML PATH('node') )
                         FOR
                             XML PATH('node') ) ,
			
--------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         ( SELECT
                               Parent.DiseaseId "@id" ,
                               Parent.Name "@label" ,
                               'true' "@isBranch" ,
                               'true' "@first" ,
                               'unchecked' "@state" ,
                               ( SELECT
                                     Measure.MeasureId "node/@Id" ,
                                     Measure.Name "node/@label" ,
                                     Parent.DiseaseId "node/@ParentID" ,
                                     'false' "node/@isBranch" ,
                                     'false' "node/@first" ,
                                     'unchecked' "node/@state"
                                 FROM
                                     DiseaseMeasure
                                     INNER JOIN Measure
                                     ON DiseaseMeasure.MeasureId = Measure.MeasureId
                                 WHERE
                                     DiseaseMeasure.DiseaseId = Parent.DiseaseId
                                     AND DiseaseMeasure.StatusCode = 'A'
                                     AND Measure.StatusCode = 'A'
                                 FOR
                                     XML PATH('') ,
                                         TYPE )
                           FROM
                               Disease Parent
                               INNER JOIN ( SELECT DISTINCT
                                                DiseaseId
                                            FROM
                                                DiseaseMeasure
                                            WHERE
                                                DiseaseMeasure.StatusCode = 'A' ) D
                               ON D.DiseaseId = Parent.DiseaseId
                           WHERE
                               Parent.StatusCode = 'A'
                           FOR
                               XML PATH('folder') )
                         FOR
                             XML PATH('folderTop') )
                   FOR
                       XML PATH('ParentNode')
         END
      ELSE
         BEGIN
               SELECT
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               1 "@Id" ,
                               'SYMPHONY CARE SOLUTIONS' "@label" ,
                               0 "@checked" ,
                               'OrganizationGroup' "@type" ,
                               'true' "@isBranch" ,
                               ( SELECT
                                     org.Organizationid "@Id" ,
                                     org.OrganizationName "@label" ,
                                     1 "@ParentID" ,
                                     0 "@checked" ,
                                     'Organization' "@Type" ,
                                     'true' "@isBranch1" ,
                                     ( SELECT
                                           owt.OrganizationWiseTypeId "@id" ,
                                           OrganizationType.OrganizationType "@label" ,
                                           Organization.OrganizationId "@ParentID" ,
                                           0 "@checked" ,
                                           'OrganizationType' "@Type" ,
                                           'true' "@isBranch2" ,
                                           ( SELECT
                                                 OrganizationFacility.OrganizationFacilityid "@id" ,
                                                 OrganizationFacility.FacilityName "@label" ,
                                                 OrganizationWiseType.OrganizationWiseTypeId "@ParentID" ,
                                                 0 "@checked" ,
                                                 'Facility' "@Type" ,
                                                 'true' "@isBranch3" ,
                                                 ( SELECT
                                                       Provider.OrganizationFacilityProviderID "node/@Id" ,
                                                       [dbo].[ufn_GetUserNameByID](Provider.ProviderId) "node/@label" ,
                                                       Provider.OrganizationFacilityID "node/@ParentID" ,
                                                       0 "node/@checked" ,
                                                       'Provider' "node/@Type" ,
                                                       'false' "node/@isBranch"
                                                   FROM
                                                       OrganizationFacilityProvider Provider
                                                   WHERE
                                                       Provider.OrganizationFacilityID = OrganizationFacility.OrganizationFacilityID
                                                   FOR
                                                       XML PATH('') ,
                                                           TYPE )
                                             FROM
                                                 OrganizationFacility
                                                 INNER JOIN OrganizationWiseType
                                                 ON OrganizationFacility.OrganizationWiseTypeID = OrganizationWiseType.OrganizationWiseTypeID
                                                 INNER JOIN OrganizationType
                                                 ON OrganizationType.OrganizationTypeId = OrganizationWiseType.OrganizationTypeId
                                             WHERE
                                                 OrganizationFacility.StatusCode = 'A'
                                                 AND OrganizationFacility.OrganizationWiseTypeID = owt.OrganizationWiseTypeID
                                             FOR
                                                 XML PATH('node') ,
                                                     TYPE )
                                       FROM
                                           OrganizationWiseType owt
                                           INNER JOIN OrganizationType
                                           ON OrganizationType.OrganizationTypeId = owt.OrganizationTypeId
                                           INNER JOIN Organization
                                           ON Organization.OrganizationId = owt.OrganizationId
                                       WHERE
                                           owt.StatusCode = 'A'
                                           AND owt.OrganizationId = org.OrganizationId
                                       FOR
                                           XML PATH('node') ,
                                               TYPE )
                                 FROM
                                     Organization org
                                 WHERE
                                     org.OrganizationStatusCode = 'A'
                                     AND org.ParentOrganizationId IS NULL
                                 FOR
                                     XML PATH('node') ,
                                         TYPE )
                               FOR
                                   XML PATH('node') )
                         FOR
                             XML PATH('node') ) ,
------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               'COHORTS' "@label" ,
                               0 "@checked" ,
                               'PopulationDefinition' "@type" ,
                               ( SELECT
                                     coh.PopulationDefinitionID "@id" ,
                                     coh.PopulationDefinitionName "@label" ,
                                     0 "@checked" ,
                                     'Cohort' "@type"
                                 FROM
                                     PopulationDefinition coh
                                 WHERE
                                     coh.StatusCode = 'A' --and  coh.CohortListId = coho.CohortListId
                                 FOR
                                     XML PATH('node') ,
                                         TYPE )
                               FOR
                                   XML PATH('node') )
                         FOR
                             XML PATH('node') ) ,   
------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               'PROGRAMS' "@label" ,
                               0 "@checked" ,
                               'Program' "@type" ,
                               ( SELECT
                                     Program.ProgramId "@id" ,
                                     Program.ProgramName "@label" ,
                                     0 "@checked" ,
                                     'Program' "@type"
                                 FROM
                                     Program
                                 WHERE
                                     Program.StatusCode = 'A'
                                 FOR
                                     XML PATH('node') ,
                                         TYPE )
                               FOR
                                   XML PATH('node') )
                         FOR
                             XML PATH('node') ) ,
			
--------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         'home' "@label" ,
                         0 "@checked" ,
                         ( SELECT
                               'CARE TEAMS' "@label" ,
                               0 "@checked" ,
                               'CareTeam' "@type" ,
                               ( SELECT
                                     CareTeam.CareTeamId "@id" ,
                                     CareTeam.CareTeamName "@label" ,
                                     0 "@checked" ,
                                     'CareTeam' "@type"
                                 FROM
                                     CareTeam
                                 WHERE
                                     CareTeam.StatusCode = 'A'
                                 FOR
                                     XML PATH('node') ,
                                         TYPE )
                               FOR
                                   XML PATH('node') )
                         FOR
                             XML PATH('node') ) ,
			
--------------------------------------------------------------------------------------------------------------------
                   ( SELECT
                         ( SELECT
                               Parent.DiseaseId "@id" ,
                               Parent.Name "@label" ,
                               'true' "@isBranch" ,
                               'true' "@first" ,
                               'unchecked' "@state" ,
                               ( SELECT
                                     Measure.MeasureId "node/@Id" ,
                                     Measure.Name "node/@label" ,
                                     Parent.DiseaseId "node/@ParentID" ,
                                     'false' "node/@isBranch" ,
                                     'false' "node/@first" ,
                                     'unchecked' "node/@state"
                                 FROM
                                     Measure
                                     INNER JOIN DiseaseMeasure
                                     ON Measure.MeasureId = DiseaseMeasure.MeasureId
                                 WHERE
                                     DiseaseMeasure.DiseaseId = Parent.DiseaseId
                                     AND DiseaseMeasure.StatusCode = 'A'
                                     AND Measure.StatusCode = 'A'
                                 FOR
                                     XML PATH('') ,
                                         TYPE )
                           FROM
                               Disease Parent
                               INNER JOIN ( SELECT DISTINCT
                                                DiseaseMeasure.DiseaseId
                                            FROM
                                                DiseaseMeasure
                                                INNER JOIN DiseaseMeasureConditionalFrequency DMCF
                                                ON DMCF.DiseaseMeasureId = DiseaseMeasure.DiseaseMeasureId
                                            WHERE
                                                DiseaseMeasure.StatusCode = 'A' ) D
                               ON D.DiseaseId = Parent.DiseaseId
                           WHERE
                               Parent.StatusCode = 'A'
                           FOR
                               XML PATH('folder') )
                         FOR
                             XML PATH('folderTop') )
                   FOR
                       XML PATH('ParentNode')
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
    ON OBJECT::[dbo].[usp_Reports_AdvancedComparisonXML_DD] TO [FE_rohit.r-ext]
    AS [dbo];

