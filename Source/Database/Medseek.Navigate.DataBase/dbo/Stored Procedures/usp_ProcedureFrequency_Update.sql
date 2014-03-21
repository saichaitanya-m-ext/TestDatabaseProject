/*      
------------------------------------------------------------------------------      
Procedure Name: usp_ProcedureFrequency_Update      
Description   : This procedure is used to Update record in ProcedureFrequency table  
Created By    : Aditya      
Created Date  : 12-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
26-Apr-2011 NagaBabu Added two Parameters @vc_ExclusionReason,@b_NeverSchedule  
11-May-2011 Rathnam added @i_LabTestId one more parameter for updating labtestid
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ProcedureFrequency_Update]    
(    
 @i_AppUserId KeyId,  
 @vc_StatusCode StatusCode,  
 @i_FrequencyNumber KeyID,  
 @vc_Frequency VARCHAR(1),  
 @vc_GenderSpecific VARCHAR(1),  
 @i_ProcedureId KeyID,
 @b_NeverSchedule BIT ,
 @vc_ExclusionReason ShortDescription,
 @i_LabTestId KEYID = NULL    
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
  
  UPDATE ProcedureFrequency  
     SET ProcedureId = @i_ProcedureId,  
		 StatusCode = @vc_StatusCode,  
	     FrequencyNumber = @i_FrequencyNumber,  
	     Frequency = @vc_Frequency,   
	     GenderSpecific = @vc_GenderSpecific,   
	     LastModifiedByUserId = @i_AppUserId,  
	     LastModifiedDate = GETDATE(),
	     NeverSchedule = @b_NeverSchedule ,
	     ExclusionReason = @vc_ExclusionReason, 
	     LabTestId = @i_LabTestId
   WHERE ProcedureId = @i_ProcedureId  
  
    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
        
 IF @l_numberOfRecordsUpdated <> 1  
  BEGIN        
   RAISERROR    
   (  N'Invalid Row count %d passed to update ProcedureFrequency Details'    
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
    ON OBJECT::[dbo].[usp_ProcedureFrequency_Update] TO [FE_rohit.r-ext]
    AS [dbo];

