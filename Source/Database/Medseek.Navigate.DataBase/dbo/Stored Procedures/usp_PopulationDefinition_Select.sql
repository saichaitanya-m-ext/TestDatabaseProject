  
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PopulationDefinition_Select]23,105  
Description   : This procedure is used to select the details from PopulationDefinition,Standards tables.  
Created By    : Gurumoorthy.V  
Created Date  : 20.12.2011  
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
15-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID
--------------------------------------------------------------------------------------------------------------------  
*/  

CREATE PROCEDURE [dbo].[usp_PopulationDefinition_Select] -- 23,105,'A'  
(  
 @i_AppUserId KEYID,  
 @i_PopulationDefinitionID KeyID ,  
 @v_StatusCode StatusCode   
)  
AS  
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END  
----------- Select all the Activity details ---------------  
	SELECT  
	   PopulationDefinition.PopulationDefinitionID ,  
	   PopulationDefinition.PopulationDefinitionName ,  
	   PopulationDefinition.PopulationDefinitionDescription ,  
	   CONVERT(varchar,PopulationDefinition.LastDateListGenerated ,101) AS LastDateListGenerated,  
	   CASE PopulationDefinition.StatusCode 
				WHEN 'A' THEN 'Active'
				WHEN 'I' THEN 'InActive'
			END AS StatusCode	,  
	   PopulationDefinition.RefreshPatientListDaily ,  
	   PopulationDefinition.CreatedByUserId ,  
	   PopulationDefinition.CreatedDate ,  
	   PopulationDefinition.LastModifiedByUserId ,  
	   PopulationDefinition.LastModifiedDate,   
	   CONVERT(VARCHAR(10),PopulationDefinition.CreatedDate,101) AS CreatedDate,  
	   CASE WHEN PopulationDefinition.NonModifiable = 0 THEN 'No' ELSE 'Yes' END AS NonModifiable,  
	   Standard.Name StandardsName,  
	   CASE WHEN PopulationDefinition.Private = 0 THEN 'No' ELSE 'Yes' END AS Private,  
	   PopulationDefinition.ProductionStatus,  
	   standardorganization.Name StandardOrganizationName,
	   DefinitionVersion,
	   dbo.ufn_GetUserNameByID(PopulationDefinition.CreatedByUserId) AS CreatedBy ,
	   ISNULL(PopulationDefinition.IsADT,0) AS IsADT
   FROM  
       PopulationDefinition  WITH(NOLOCK)
   LEFT JOIN [Standard]    WITH(NOLOCK)
	   ON [Standard].StandardId = PopulationDefinition.StandardsId  
   LEFT JOIN standardorganization  WITH(NOLOCK)  
       ON standardorganization.StandardOrganizationId = PopulationDefinition.StandardOrganizationId   
   WHERE ( PopulationDefinition.PopulationDefinitionID = @i_PopulationDefinitionID 
       OR @i_PopulationDefinitionID IS NULL )  
   ORDER BY  
      PopulationDefinition.PopulationDefinitionName  
  
 --IF @i_PopulationDefinitionID IS NOT NULL  
 --BEGIN  
  
 -- EXEC usp_CohortListCriteria_Select  
 --  @i_AppUserId = @i_AppUserId,  
 --  @i_PopulationDefinitionID = @i_PopulationDefinitionID  
     
 -- --SELECT TOP 10  -- For showing the top 10 records  
 -- --    Users.UserId,  
 -- --    Users.UserLoginName,  
 -- --    Users.FullName,  
 -- --    CASE Users.Gender  
 -- --   WHEN 'M' THEN 'Male'  
 -- --   WHEN 'F' THEN 'Female'  
 -- --    END AS Gender,  
 -- --    Users.Age,  
 -- --    Users.MemberNum,  
 -- --    Users.UserStatusCode,  
 -- --    CASE CohortListUsers.LeaveInList  
 -- --   WHEN 0 THEN 'NO'  
 -- --   WHEN 1 THEN 'YES'  
 -- --    END AS LeaveInList,  
 -- --    CASE CohortListUsers.StatusCode  
 -- --      WHEN 'A' THEN 'Active'  
 -- --      WHEN 'I' THEN 'InActive'  
 -- --      WHEN 'P' THEN 'Pending Delete'  
 -- -- END AS StatusCode  
 -- --  FROM   
 -- --      CohortListUsers  
 -- --     INNER JOIN Patients Users  
 -- --   ON Users.UserId = CohortListUsers.UserId  
 -- --  AND (CohortListUsers.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)  
 -- --  AND Users.UserStatusCode = 'A'  
 -- -- WHERE CohortListUsers.PopulationDefinitionID = @i_PopulationDefinitionID  
 -- --   AND Users.EndDate is NULL  
 -- --   AND ISNULL(IsDeceased,0) = 0  
 -- -- ORDER By CohortListUsers.StatusCode,  
 -- --    FullName,  
 -- --    MemberNum  
     
 --  --      SELECT   
 --  --          COUNT(Users.UserId)AS TotalPatients   
 --  --      FROM  
 --  --          CohortListUsers  
 --  --      INNER JOIN Patients Users  
 --  --  ON Users.UserId = CohortListUsers.UserId  
 --  -- AND Users.UserStatusCode = 'A'  
 --  --WHERE CohortListUsers.PopulationDefinitionID = @i_PopulationDefinitionID
 --  --  AND Users.EndDate is NULL  
 --  --  AND ISNULL(IsDeceased,0) = 0       
 --  --        AND StatusCode = @v_StatusCode        
 --END  

	--SELECT TOP 1
	--	 CohortCriteriaID
	--	,CohortCriteriaSQL
	--	,CohortCriteriaText 
	--FROM 
	--	CohortListCriteria
 --   WHERE 
	--	PopulationDefinitionID = 160
	--	AND PopulationDefPanelConfigurationID IS NULL
	--ORDER BY CreatedDate DESC
   
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH  
  

  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinition_Select] TO [FE_rohit.r-ext]
    AS [dbo];

