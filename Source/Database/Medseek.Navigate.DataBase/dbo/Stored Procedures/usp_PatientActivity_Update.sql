/*      
------------------------------------------------------------------------------      
Procedure Name: usp_PatientActivity_Update      
Description   : This procedure is used to Update record in PatientActivity table  
Created By    : Aditya      
Created Date  : 29-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_PatientActivity_Update]    
(    
 @i_AppUserId KeyId,    
 @t_Activity ttypeKeyID READONLY,  
 @i_PatientGoalId KeyID,  
 @vc_Description LongDescription = NULL ,  
 @vc_StatusCode StatusCode,  
 @i_PatientActivityId KeyID ,
 @b_IsAdhoc IsIndicator = NULL     
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
  
  UPDATE PatientActivity  
     SET   
   StatusCode = @vc_StatusCode,  
   LastModifiedByUserId = @i_AppUserId,  
   LastModifiedDate = GETDATE()  
   WHERE PatientActivityId = @i_PatientActivityId  
  
    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
        
 IF @l_numberOfRecordsUpdated <> 1  
  BEGIN        
   RAISERROR    
   (  N'Invalid Row count %d passed to update PatientActivity'    
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
    ON OBJECT::[dbo].[usp_PatientActivity_Update] TO [FE_rohit.r-ext]
    AS [dbo];

