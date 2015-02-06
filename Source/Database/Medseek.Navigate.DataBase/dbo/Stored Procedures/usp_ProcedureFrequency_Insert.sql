/*      
------------------------------------------------------------------------------      
Procedure Name: usp_ProcedureFrequency_Insert      
Description   : This procedure is used to insert record into ProcedureFrequency table  
Created By    : Aditya      
Created Date  : 12-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
26-Apr-2011 NagaBabu Added two Parameters @vc_ExclusionReason,@b_NeverSchedule      
11-May-2011 Rathnam added @i_LabTestId one more parameter for inserting Labtestid 
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ProcedureFrequency_Insert]    
(    
 @i_AppUserId KeyId,  
 @vc_StatusCode StatusCode,  
 @i_FrequencyNumber KeyID,  
 @vc_Frequency VARCHAR(1),  
 @vc_GenderSpecific VARCHAR(1),  
 @i_ProcedureId KeyID ,
 @b_NeverSchedule BIT ,
 @vc_ExclusionReason ShortDescription ,
 @i_LabTestId KEYID = NULL
)    
AS    
BEGIN TRY    
 SET NOCOUNT ON    
 DECLARE @l_numberOfRecordsInserted INT     
 -- Check if valid Application User ID is passed      
 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
 BEGIN    
     RAISERROR ( N'Invalid Application User ID %d passed.' ,    
     17 ,    
     1 ,    
     @i_AppUserId )    
 END    
  
 INSERT INTO ProcedureFrequency  
    (   
	   ProcedureId,  
	   StatusCode,  
	   FrequencyNumber,  
	   Frequency,  
	   GenderSpecific,  
	   CreatedByUserId,
	   NeverSchedule,
	   ExclusionReason,
	   LabTestId  
    )  
 VALUES  
    (   
	   @i_ProcedureId,  
	   @vc_StatusCode,  
	   @i_FrequencyNumber,  
	   @vc_Frequency,  
	   @vc_GenderSpecific,  
	   @i_AppUserId,
	   @b_NeverSchedule,
	   @vc_ExclusionReason,
	   @i_LabTestId  
    )  
       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT  
            
        
    IF @l_numberOfRecordsInserted <> 1            
 BEGIN            
  RAISERROR        
   (  N'Invalid row count %d in Insert ProcedureFrequency'  
    ,17        
    ,1        
    ,@l_numberOfRecordsInserted                   
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
    ON OBJECT::[dbo].[usp_ProcedureFrequency_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

