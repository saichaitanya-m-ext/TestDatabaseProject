/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_CohortCriteriaByCohortID_Select]  1,4 
Description   : This procedure is used for getting the answers for a question  
Created By    : Gurumoorthy
Created Date  : 25 July 2012  
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION 
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID 
----------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_PopulationDefinitionCriteriaByDefinitionID_Select]
(
 @i_AppUserId KEYID
,@i_PopulationDefinitionID KEYID
)
AS
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END  
---------------- All the Active Answers are retrieved -------- 
      SELECT
          PD.PopulationDefinitionID
         ,PD.PopulationDefinitionName
         ,CLC.PopulationDefinitionCriteriaID
         ,CLC.PopulationDefinitionCriteriaSQL
         ,SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CLC.PopulationDefinitionCriteriaText , '<font color=''black''><b><br/>' , '') , '</b></font>' , '') , '(' , '') , ')' , '') , '<br/>' , '') , '&nbsp;' , '') , 0 , 30) AS PopulationDefinitionCriteriaText
         ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CLC.PopulationDefinitionCriteriaText , '<font color=''black''><b>' , '') , '</b></font>' , '') , '<br/>' , '') , '<font color=		 black><b>' , '') , '<b></font>' , '') AS FullText
         ,CLC.PopulationDefinitionCriteriaText AS SqlText
         --,CLC.Operator
         --,ISNULL(CLC.ParentID,CL.CohortListId) ParentID
      FROM
          PopulationDefinitionCriteria CLC WITH(NOLOCK)
      INNER JOIN PopulationDefinition PD WITH(NOLOCK)
          ON CLC.PopulationDefinitionID = PD.PopulationDefinitionID
      INNER JOIN PopulationDefPanelConfiguration PDP WITH(NOLOCK)
          ON PDP.PopulationDefPanelConfigurationID = CLC.PopulationDefPanelConfigurationID
      WHERE
          PD.PopulationDefinitionID = @i_PopulationDefinitionID
          AND PDP.PanelorGroupName <> 'Compound'
          
          
          
      SELECT TOP 1
          NULL AS PopulationDefinitionID
         ,PD.PopulationDefinitionName
         ,PD.PopulationDefinitionID AS PopulationDefinitionCriteriaID
         ,'' AS PopulationDefinitionCriteriaSQL
         ,'' AS PopulationDefinitionCriteriaText
         ,'' AS FullText
         ,PD.PopulationDefinitionName AS SqlText
         --,'' Operator
         --,NULL ParentID
      FROM
        PopulationDefinition PD WITH(NOLOCK)
      WHERE
          PD.PopulationDefinitionID = @i_PopulationDefinitionID
      UNION
      SELECT
          PD.PopulationDefinitionID
         ,PopulationDefinitionName
         ,CLC.PopulationDefinitionCriteriaID
         ,CLC.PopulationDefinitionCriteriaSQL
         ,SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CLC.PopulationDefinitionCriteriaText , '<font color=''black''><b><br/>' , '') , '</b></font>' , '') , '(' , '') , ')' , '') , '<br/>' , '') , '&nbsp;' , '') , 0 , 30) AS PopulationDefinitionCriteriaText
         ,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CLC.PopulationDefinitionCriteriaText , '<font color=''black''><b>' , '') , '</b></font>' , '') , '<br/>' , '') , '<font color=		 black><b>' , '') , '<b></font>' , '') AS FullText
         ,CLC.PopulationDefinitionCriteriaText AS SqlText
         --,CLC.Operator
         --,ISNULL(CLC.ParentID,CL.CohortListId) ParentID
      FROM
          PopulationDefinitionCriteria CLC WITH(NOLOCK)
      LEFT JOIN PopulationDefinition PD WITH(NOLOCK)
          ON CLC.PopulationDefinitionID = PD.PopulationDefinitionID
      INNER JOIN PopulationDefPanelConfiguration PDP WITH(NOLOCK)
          ON PDP.PopulationDefPanelConfigurationID = CLC.PopulationDefPanelConfigurationID
      WHERE
          PD.PopulationDefinitionID = @i_PopulationDefinitionID
          AND PDP.PanelorGroupName <> 'Compound'
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionCriteriaByDefinitionID_Select] TO [FE_rohit.r-ext]
    AS [dbo];

