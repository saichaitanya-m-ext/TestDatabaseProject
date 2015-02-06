/*    
------------------------------------------------------------------------------    
Procedure Name: usp_InsuranceGroupPlan_Select    
Description   : This procedure is used to get the details from InsuranceGroupPlan   
    table.  
Created By    : Aditya    
Created Date  : 26-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
11-Apr-2012 NagaBabu Added PlanCode field and deleted PlanType field    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_InsuranceGroupPlan_Select]  
(  
 @i_AppUserId KeyID,  
 @i_InsuranceGroupId KeyID = NULL,
 @i_InsuranceGroupPlanId KeyID = NULL,  
 @v_StatusCode StatusCode = NULL  
)  
AS  
BEGIN TRY  
    SET NOCOUNT ON     
-- Check if valid Application User ID is passed  
  
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
    BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
    END  
  
	SELECT  InsuranceGroupPlanId,  
		InsuranceGroupId,  
		PlanName,
		--PlanType,  
		CreatedByUserId,  
		CreatedDate,  
		LastModifiedByUserId,  
		LastModifiedDate,  
		CASE StatusCode   
		    WHEN 'A' THEN 'Active'  
		    WHEN 'I' THEN 'InActive'  
		    ELSE ''  
		END AS StatusDescription ,
	    '' PlanCode    
	FROM InsuranceGroupPlan  
	WHERE (InsuranceGroupId = @i_InsuranceGroupId OR @i_InsuranceGroupId IS NULL )
	   AND ( InsuranceGroupPlanId = @i_InsuranceGroupPlanId OR @i_InsuranceGroupPlanId IS NULL )   
	   AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )  
  
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
    ON OBJECT::[dbo].[usp_InsuranceGroupPlan_Select] TO [FE_rohit.r-ext]
    AS [dbo];

