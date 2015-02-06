/*      
------------------------------------------------------------------------------      
Procedure Name: usp_InsuranceGroupPlan_Update      
Description   : This procedure is used to Update record in InsuranceGroupPlan table  
Created By    : Aditya      
Created Date  : 25-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
11-Apr-2012 NagaBabu Deleted @vc_PlanType Parameter and Added @vc_PlanCode Parameter       
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_InsuranceGroupPlan_Update]    
(    
 @i_AppUserId KeyID,    
 @i_InsuranceGroupId KeyID,  
 @vc_PlanName SourceName,
 --@vc_PlanType VARCHAR(10), 
 @vc_StatusCode StatusCode,  
 @i_InsuranceGroupPlanId KeyID ,
 @vc_PlanCode VARCHAR(4)
)    
AS    
BEGIN TRY  
  
	 SET NOCOUNT ON    
	 DECLARE @l_numberOfRecordsUpdated INT     
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
  
	  UPDATE InsuranceGroupPlan  
		 SET InsuranceGroupId = @i_InsuranceGroupId,  
			 PlanName = @vc_PlanName,
			 --PlanType = @vc_PlanType,  
			 StatusCode = @vc_StatusCode,  
			 LastModifiedByUserId = @i_AppUserId,  
			 LastModifiedDate = GETDATE()
			 --PlanCode = @vc_PlanCode
	   WHERE InsuranceGroupPlanId = @i_InsuranceGroupPlanId  
	  
		SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
	        
	 IF @l_numberOfRecordsUpdated <> 1  
	  BEGIN        
	   RAISERROR    
	   (  N'Invalid Row count %d passed to update InsuranceGroupPlan Details'    
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
    ON OBJECT::[dbo].[usp_InsuranceGroupPlan_Update] TO [FE_rohit.r-ext]
    AS [dbo];

