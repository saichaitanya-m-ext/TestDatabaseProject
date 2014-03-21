/*        
------------------------------------------------------------------------------        
Procedure Name: usp_UserInsurance_Update        
Description   : This procedure is used to Update record in UserInsurance table    
Created By    : Aditya        
Created Date  : 25-Mar-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION      
11-Apr-2012 NagaBabu Added @i_EmployerGroupID Parameter and deleted @i_InsuranceGroupId,@i_EmployerGroupNumber,    
      @vc_EmployerGroupName       
------------------------------------------------------------------------------        
*/      
CREATE PROCEDURE [dbo].[usp_UserInsurance_Update]      
(      
 @i_AppUserId KeyID,      
 @i_InsuranceGroupPlanId KeyID,    
 --@i_InsuranceGroupId KeyID,    
 @i_UserId KeyID,    
 @vc_StatusCode StatusCode,    
 @i_IsPrimary IsIndicator,    
 @i_PCPUserId KeyID,    
 @i_PCPExternalProviderId KeyID,    
 @vc_PCPSystem SourceName,    
 --@i_EmployerGroupNumber Code,    
 --@vc_EmployerGroupName SourceName,    
 @vc_GroupNumber  VARCHAR(15),    
 @vc_PolicyNumber VARCHAR(15),
 @vc_SuperGroupCategory SourceName,    
 @i_PharmacyBenefit IsIndicator,    
 @i_MedicareSupplement IsIndicator,    
 @i_UserInsuranceId KeyID,    
 @dt_StartDate DATETIME,    
 @dt_EndDate  DATETIME,    
 @i_EmployerGroupID KeyId    
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
        
   UPDATE PatientInsurance    
   SET InsuranceGroupPlanId = @i_InsuranceGroupPlanId,    
    StatusCode = @vc_StatusCode,    
    GroupNumber = @vc_GroupNumber ,  
    PolicyNumber=@vc_PolicyNumber,  
    SuperGroupCategory = @vc_SuperGroupCategory,    
    LastModifiedByUserId = @i_AppUserId,    
    LastModifiedDate = GETDATE(),    
    EmployerGroupID = @i_EmployerGroupID    
    WHERE PatientInsuranceID = @i_UserInsuranceId    
    AND PatientID =@i_UserId    
    
  SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT    
           
  IF @l_numberOfRecordsUpdated <> 1    
   BEGIN          
    RAISERROR      
    (  N'Invalid Row count %d passed to update UserInsurance Details'      
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
    ON OBJECT::[dbo].[usp_UserInsurance_Update] TO [FE_rohit.r-ext]
    AS [dbo];

