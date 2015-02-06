
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_PopulationDefinitionCriteria_Update
Description   : This procedure is used to Update record in CohortListCriteria table  
Created By    : Gurumoorthy.V
Created Date  : 31-MAY-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
16-Dec-2011 Rathnam Removed @vc_CohortCriteriaSQL and added   @v_JoinType, @v_JoinStatement,@v_OnClause,@v_WhereClause  
14-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinitionID in 
            the place of CohortListID  
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionCriteria_Update]    
	(    
		 @i_AppUserId KEYID ,  
		 @i_PopulationDefinitionCriteriaID KEYID,  
		 @i_PopulationDefinitionID KEYID ,  
		 @vc_PopulationDefinitionCriteriaText VARCHAR(MAX) ,  
		 @vc_CriteriaTypeName SourceName,
		 @vc_PopulationDefinitionCriteriaSQL VARCHAR(MAX) ,  
		 @vc_CohortGeneralizedIdList VARCHAR(MAX)
	)    
AS    
BEGIN TRY  
  
	 SET NOCOUNT ON    
	  DECLARE @l_numberOfRecordsUpdated INT,  
		 @i_PopulationDefPanelConfigurationID KEYID     
	 -- Check if valid Application User ID is passed      
	 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
	 BEGIN    
		 RAISERROR   
		 ( N'Invalid Application User ID %d passed.' ,    
		   17 ,    
		   1 ,    
		   @i_AppUserId  
		 )    
	 END 
	    
	 SELECT 
		 @i_PopulationDefPanelConfigurationID = PopulationDefPanelConfigurationID  
	 FROM 
		 PopulationDefPanelConfiguration  
	 WHERE 
		 PanelorGroupName = @vc_CriteriaTypeName 
	    
	 UPDATE 
		PopulationDefinitionCriteria  
	 SET   
		PopulationDefinitionID =	@i_PopulationDefinitionID	,  
		PopulationDefinitionCriteriaSQL=@vc_PopulationDefinitionCriteriaSQL,
		PopulationDefinitionCriteriaText = @vc_PopulationDefinitionCriteriaText,  
		PopulationDefPanelConfigurationID = @i_PopulationDefPanelConfigurationID, 
		CohortGeneralizedIdList = @vc_CohortGeneralizedIdList,
		LastModifiedByUserId = @i_AppUserId,  
		LastModifiedDate = GETDATE()
	
	 WHERE 
		PopulationDefinitionCriteriaID = @i_PopulationDefinitionCriteriaID
		
	  
	 SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
	        
	 IF @l_numberOfRecordsUpdated <> 1  
	  BEGIN        
	   RAISERROR    
	   (  N'Invalid Row count %d passed to update CohortListCriteria'    
		,17    
		,1   
		,@l_numberOfRecordsUpdated              
	   )            
	  END    
    
    RETURN 0   
    
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
    ON OBJECT::[dbo].[usp_PopulationDefinitionCriteria_Update] TO [FE_rohit.r-ext]
    AS [dbo];

