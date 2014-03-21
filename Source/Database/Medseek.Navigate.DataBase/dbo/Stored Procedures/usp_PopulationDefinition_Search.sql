  
/*    
-------------------------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_PopulationDefinition_Search] 64,21,'A',null,null,0,0,null,1,null,null,null    
Description   : This procedure is used to select the details from CohortList table.    
Created By    : NagaBabu    
Created Date  : 20-Dec-2011    
--------------------------------------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
21-Dec-2011 NagaBabu Replaced INNER JOIN by LEFT OUTER JOIN     
22-Dec-2011 NagaBabu Added ORDER BY clause    
13-Jan-2012 NagaBabu Added Case sttement for RefreshPatientListDaily  field    
01-Feb-2012 added the TaskBundleID column to the select statement    
19-Mar-2012 Gurumoorthy.V Added Top 1 in Disease Definition Subquery    
19-Mar-2012 Gurumoorthy.V Added Commented the Disease INNER JOIN,Not req teh Disease Join    
30-06-2012      Sivakrishna Added Columns BuildingBlock,NonModifiable,OrganizationId,Private,ProductionStatus,CohortListCategoryId    
18-Aug-2012 Gurumoorthy Added CohortlistDesc as parameter,removed the Careteam.   
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in   
            the place of CohortListID and PopulationDefinitionUsers   
  
28-Mar-2013 TLM removed functions from first recordset.               
--------------------------------------------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PopulationDefinition_Search] (  
 @i_AppUserId KEYID  
 ,@i_PopulationDefinitionID KEYID = NULL  
 ,@v_StatusCode STATUSCODE = NULL  
 ,@vc_PopulationDefinitionName SHORTDESCRIPTION = NULL  
 ,@vc_PopulationDefinitionDescription SHORTDESCRIPTION = NULL  
 ,@b_NonModifiable BIT = NULL  
 ,@i_StandardOrganizationId KEYID = NULL  
 ,@b_Private BIT = NULL  
 ,@i_StandardsId KEYID = NULL  
 ,@v_ProductionStatus VARCHAR(1) = NULL  
 ,@v_DefinitionType VARCHAR(1) = NULL  
 ,@i_ConditionId KEYID = NULL  
 ,@b_RefreshPatientListDaily BIT = NULL  
 )  
AS  
BEGIN TRY  
 -- Check if valid Application User ID is passed    
 IF (@i_AppUserId IS NULL)  
  OR (@i_AppUserId <= 0)  
 BEGIN  
  RAISERROR (  
    N'Invalid Application User ID %d passed.'  
    ,17  
    ,1  
    ,@i_AppUserId  
    )  
 END  
  
 -----------------------------------------------------------------------    
 IF (@i_PopulationDefinitionID IS NULL)  
 BEGIN  
  SELECT DISTINCT PopulationDefinition.PopulationDefinitionID  
   ,PopulationDefinition.PopulationDefinitionName  
   ,PopulationDefinition.PopulationDefinitionDescription  
   ,CASE PopulationDefinition.StatusCode  
    WHEN 'A'  
     THEN 'Active'  
    WHEN 'I'  
     THEN 'InActive'  
    ELSE ''  
    END StatusCode  
   ,dbo.ufn_GetUserNameByID(PopulationDefinition.CreatedByUserId) AS CreatedBy  
   ,CONVERT(VARCHAR(10), PopulationDefinition.CreatedDate, 101) AS CreatedDate  
   ,dbo.ufn_GetUserNameByID(PopulationDefinition.LastModifiedByUserId) AS ModifiedBy  
   ,CONVERT(VARCHAR(10), PopulationDefinition.LastModifiedDate, 101) AS LastModifiedDate  
   ,CASE   
    WHEN PopulationDefinition.NonModifiable = 0  
     THEN 'No'  
    ELSE 'Yes'  
    END AS NonModifiable  
   ,StandardOrganization.NAME StandardOrganizationName  
   ,CASE   
    WHEN PopulationDefinition.IsDisplayInHomePage = 0  
     THEN 'No'  
    ELSE 'Yes'  
    END AS Private  
   ,CASE   
    WHEN PopulationDefinition.ProductionStatus IN (  
      'D'  
      ,'U'  
      )  
     THEN 'Draft'  
    ELSE 'Final'  
    END AS ProductionStatus  
   ,CASE   
    WHEN PopulationDefinition.RefreshPatientListDaily = 0  
     THEN 'Monthly'  
    ELSE 'Daily'  
    END AS RefreshPatientListDaily  
   ,Standard.NAME StandardsName  
   ,CASE   
    WHEN PopulationDefinition.DefinitionType = 'C'  
     THEN 'Condition'  
    WHEN PopulationDefinition.DefinitionType = 'P'  
     THEN 'Preventive'  
    END DefinitionType  
   ,DefinitionVersion  
   ,ISNULL(Condition.ConditionName, '') AS ConditionName  
   ,(SELECT top 1    
     PopulationDefinitionCriteriaSQL    
     FROM     
     PopulationDefinitionCriteria PDC     
     where PDC.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID AND    
     PopulationDefPanelConfigurationID=0 ) As SQLNAME   
     ,(  
    SELECT TOP 1 PopulationDefinitionCriteriaSQL  
    FROM PopulationDefinitionCriteria PDC  
    WHERE PDC.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID  
     AND PopulationDefinitionCriteriaSQL is not null   
     AND PopulationDefinitionCriteriaText is  not null  
    ) AS IsPDF 
	,ISNULL(PopulationDefinition.IsADT,0) AS IsADT
  FROM PopulationDefinition WITH (NOLOCK)  
  LEFT JOIN StandardOrganization WITH (NOLOCK) ON StandardOrganization.StandardOrganizationId = PopulationDefinition.StandardOrganizationId  
  LEFT JOIN Standard WITH (NOLOCK) ON Standard.StandardId = PopulationDefinition.StandardsId  
  LEFT JOIN Condition WITH (NOLOCK) ON Condition.ConditionID = PopulationDefinition.ConditionID  
  LEFT JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinitionCriteria.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID  
  WHERE PopulationDefinition.DefinitionType IN (  
    'P'  
    ,'C'  
    )  
   AND (  
    PopulationDefinition.PopulationDefinitionName LIKE '%' + @vc_PopulationDefinitionName + '%'  
    OR @vc_PopulationDefinitionName IS NULL  
    )  
   AND (  
    PopulationDefinition.PopulationDefinitionDescription LIKE '%' + @vc_PopulationDefinitionDescription + '%'  
    OR @vc_PopulationDefinitionDescription IS NULL  
    )  
   AND (  
    PopulationDefinition.StatusCode = @v_StatusCode  
    OR @v_StatusCode IS NULL  
    )  
   AND (  
    PopulationDefinition.NonModifiable = @b_NonModifiable  
    OR @b_NonModifiable IS NULL  
    )  
   AND (  
    PopulationDefinition.StandardOrganizationId = @i_StandardOrganizationId  
    OR @i_StandardOrganizationId IS NULL  
    )  
   AND (  
    PopulationDefinition.Private = @b_Private  
    OR @b_Private IS NULL  
    )  
   AND (  
    PopulationDefinition.StandardsId = @i_StandardsId  
    OR @i_StandardsId IS NULL  
    )  
   AND (  
    PopulationDefinition.ProductionStatus = @v_ProductionStatus  
    OR @v_ProductionStatus IS NULL  
    )  
   AND (  
    PopulationDefinition.DefinitionType = @v_DefinitionType  
    OR @v_DefinitionType IS NULL  
    )  
   AND (  
    PopulationDefinition.RefreshPatientListDaily = @b_RefreshPatientListDaily  
    OR @b_RefreshPatientListDaily IS NULL  
    )  
   AND (  
    PopulationDefinition.ConditionId = @i_ConditionId  
    OR @i_ConditionId IS NULL  
    )  
  ORDER BY PopulationDefinition.PopulationDefinitionID DESC  
 END  
 ELSE  
 BEGIN  
  SELECT DISTINCT PopulationDefinition.PopulationDefinitionID  
   ,PopulationDefinition.PopulationDefinitionName  
   ,PopulationDefinition.PopulationDefinitionDescription  
   ,CASE PopulationDefinition.StatusCode  
    WHEN 'A'  
     THEN 'Active'  
    WHEN 'I'  
     THEN 'InActive'  
    ELSE ''  
    END StatusCode  
   ,dbo.ufn_GetUserNameByID(PopulationDefinition.CreatedByUserId) AS CreatedBy  
   ,CONVERT(VARCHAR(10), PopulationDefinition.CreatedDate, 101) AS CreatedDate  
   ,dbo.ufn_GetUserNameByID(PopulationDefinition.LastModifiedByUserId) AS ModifiedBy  
   ,CONVERT(VARCHAR(10), PopulationDefinition.LastModifiedDate, 101) AS LastModifiedDate  
   ,CASE   
    WHEN PopulationDefinition.NonModifiable = 0  
     THEN 'No'  
    ELSE 'Yes'  
    END AS NonModifiable  
   ,StandardOrganization.NAME StandardOrganizationName  
   ,CASE   
    WHEN PopulationDefinition.Private = 0  
     THEN 'No'  
    ELSE 'Yes'  
    END AS Private  
   ,CASE   
    WHEN PopulationDefinition.ProductionStatus IN (  
      'D'  
      ,'U'  
      )  
     THEN 'Draft'  
    ELSE 'Final'  
    END AS ProductionStatus  
   ,CASE   
    WHEN PopulationDefinition.RefreshPatientListDaily = 0  
     THEN 'Monthly'  
    ELSE 'Daily'  
    END AS RefreshPatientListDaily  
   ,Standard.NAME StandardsName  
   ,CASE   
    WHEN PopulationDefinition.DefinitionType = 'C'  
     THEN 'Condition'  
    WHEN PopulationDefinition.DefinitionType = 'P'  
     THEN 'Population'  
    END DefinitionType  
   ,DefinitionVersion  
   ,ISNULL(Condition.ConditionName, '') AS ConditionName  
   ,(  
    SELECT TOP 1 1  
    FROM Program  
    WHERE PopulationDefinitionID = @i_PopulationDefinitionID  
     AND StatusCode = 'A'  
    ) IsStatusEdit  
   ,(  
    SELECT TOP 1 PopulationDefinitionCriteriaSQL  
    FROM PopulationDefinitionCriteria PDC  
    WHERE PDC.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID  
     AND PopulationDefPanelConfigurationID = 0  
    ) AS SQLNAME  
    ,(  
    SELECT TOP 1 PopulationDefinitionCriteriaSQL  
    FROM PopulationDefinitionCriteria PDC  
    WHERE PDC.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID  
     AND PopulationDefinitionCriteriaSQL is not null   
     AND PopulationDefinitionCriteriaText is  not null  
    ) AS IsPDF  
	,ISNULL(PopulationDefinition.IsADT,0) AS IsADT
  FROM PopulationDefinition WITH (NOLOCK)  
  LEFT JOIN StandardOrganization WITH (NOLOCK) ON StandardOrganization.StandardOrganizationId = PopulationDefinition.StandardOrganizationId  
  LEFT JOIN Standard WITH (NOLOCK) ON Standard.StandardId = PopulationDefinition.StandardsId  
  LEFT JOIN Condition WITH (NOLOCK) ON Condition.ConditionID = PopulationDefinition.ConditionID  
  LEFT JOIN PopulationDefinitionCriteria WITH (NOLOCK) ON PopulationDefinitionCriteria.PopulationDefinitionID = PopulationDefinition.PopulationDefinitionID  
  WHERE PopulationDefinition.PopulationDefinitionID = @i_PopulationDefinitionID  
   AND PopulationDefinition.DefinitionType IN (  
    'P'  
    ,'C'  
    )  
  ORDER BY PopulationDefinition.PopulationDefinitionID DESC  
 END  
  
 DECLARE @tblVersion TABLE (  
  PopulationDefinitionID INT  
  ,DefinitionVersion VARCHAR(5)  
  ,ModifiedDate DATETIME  
  ,ModifiedUserId INT  
  ,ModificationDescription VARCHAR(max)  
  )  
 DECLARE @v_DefinitionVersion VARCHAR(5)  
  ,@v_CohortModificationList VARCHAR(500)  
  ,@v_CohortCriteriaModificationList VARCHAR(500)  
  ,@v_CohortDependencyModificationList VARCHAR(500)  
  ,@i_CreatedByUserId INT  
  ,@d_CreatedDate DATETIME  
  
 DECLARE curVersion CURSOR  
 FOR  
 SELECT @i_PopulationDefinitionID  
  ,DefinitionVersion  
  ,CohortModificationList  
  ,CohortCriteriaModificationList  
  ,CohortDependencyModificationList  
  ,CreatedByUserId  
  ,CreatedDate  
 FROM CohortListHistory  
 WHERE PopulationDefinitionID = @i_PopulationDefinitionID  
  
 OPEN curVersion  
  
 FETCH NEXT  
 FROM curVersion  
 INTO @i_PopulationDefinitionID  
  ,@v_DefinitionVersion  
  ,@v_CohortModificationList  
  ,@v_CohortCriteriaModificationList  
  ,@v_CohortDependencyModificationList  
  ,@i_CreatedByUserId  
  ,@d_CreatedDate  
  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
  INSERT INTO @tblVersion  
  SELECT DISTINCT @i_PopulationDefinitionID  
   ,@v_DefinitionVersion  
   ,@d_CreatedDate  
   ,@i_CreatedByUserId  
   ,KeyValue  
  FROM dbo.udf_SplitStringToTable(@v_CohortModificationList, '$$')  
  WHERE ISNULL(KeyValue, '') <> ''  
    
  UNION ALL  
    
  SELECT DISTINCT @i_PopulationDefinitionID  
   ,@v_DefinitionVersion  
   ,@d_CreatedDate  
   ,@i_CreatedByUserId  
   ,  
   (  
    (  
     SELECT PanelorGroupName  
     FROM PopulationDefPanelConfiguration  
     WHERE PopulationDefPanelConfigurationID = SUBSTRING(KeyValue, charindex('-', KeyValue, 1) + 1, CHARINDEX('*', KeyValue, 1) - charindex('-', KeyValue, 1) - 1)  
     ) + '-' + CASE   
     WHEN SUBSTRING(KeyValue, CHARINDEX('*', KeyValue, 1) + 1, 1) = 'I'  
      THEN 'Inserted'  
     ELSE 'Deleted'  
     END + '-' + (  
     SELECT TOP 1 LTRIM(SUBSTRING(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(PopulationDefinitionCriteriaText, '<font color=''black''><b><br/>', ''), '</b></font>', ''), '(', ''), ')', ''), '<br/>', ''), '&nbsp;', ''), '<font color=''maroon''
><b><br/>', ''), 0, 4000))  
     FROM PopulationDefinitionCriteria  
     WHERE PopulationDefinitionCriteriaID = SUBSTRING(KeyValue, 1, CHARINDEX('-', KeyValue, 1) - 1)  
     )  
    )  
  FROM dbo.udf_SplitStringToTable(@v_CohortCriteriaModificationList, '$$')  
  WHERE ISNULL(KeyValue, '') <> ''  
    
  UNION ALL  
    
  SELECT DISTINCT @i_PopulationDefinitionID  
   ,@v_DefinitionVersion  
   ,@d_CreatedDate  
   ,@i_CreatedByUserId  
   ,(  
    (  
     SELECT PopulationDefinitionName  
     FROM PopulationDefinition  
     WHERE PopulationDefinitionID = SUBSTRING(KeyValue, 1, charindex('-', KeyValue, 1) - 1)  
     ) + '-' + CASE   
     WHEN SUBSTRING(KeyValue, CHARINDEX('-', KeyValue, 1) + 1, 1) = 'I'  
      THEN 'InCluded'  
     ELSE 'Copied'  
     END + '-' + CASE   
     WHEN SUBSTRING(KeyValue, CHARINDEX('*', KeyValue, 1) + 1, 1) = 'I'  
      THEN 'Inserted'  
     ELSE 'Deleted'  
     END  
    )  
  FROM dbo.udf_SplitStringToTable(@v_CohortDependencyModificationList, '$$')  
  WHERE ISNULL(KeyValue, '') <> ''  
  
  FETCH NEXT  
  FROM curVersion  
  INTO @i_PopulationDefinitionID  
   ,@v_DefinitionVersion  
   ,@v_CohortModificationList  
   ,@v_CohortCriteriaModificationList  
   ,@v_CohortDependencyModificationList  
   ,@i_CreatedByUserId  
   ,@d_CreatedDate  
 END  
  
 CLOSE curVersion  
  
 DEALLOCATE curVersion  
  
 SELECT DISTINCT PopulationDefinitionID  
  ,dbo.ufn_GetVersionNumber(DefinitionVersion) DefinitionVersion  
  ,CONVERT(VARCHAR(10), ModifiedDate, 101) ModifiedDate  
  ,DBO.ufn_GetUserNameByID(ModifiedUserId) ModifiedBy  
  ,STUFF((  
    SELECT ' , ' + ModificationDescription  
    FROM @tblVersion t  
    WHERE t.DefinitionVersion = t1.DefinitionVersion  
    FOR XML PATH('')  
    ), 1, 2, '') AS ModificationDescription  
 FROM @tblVersion t1  
END TRY  
  
BEGIN CATCH  
 DECLARE @i_ReturnedErrorID INT  
  
 EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
 RETURN @i_ReturnedErrorID  
END CATCH  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinition_Search] TO [FE_rohit.r-ext]
    AS [dbo];

