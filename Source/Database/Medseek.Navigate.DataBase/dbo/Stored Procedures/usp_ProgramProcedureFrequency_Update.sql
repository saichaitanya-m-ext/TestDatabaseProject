/*      
------------------------------------------------------------------------------      
Procedure Name: usp_ProgramProcedureFrequency_Update      
Description   : This procedure is used to update record in ProgramProcedureFrequency table  
Created By    : Aditya      
Created Date  : 23-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
26-Apr-2011  RamaChandra added two parameter @b_NeverSchedule and @v_ExclusionReason
11-May-2011  Rathnam added LabTestId one more parameter for updating the labtestid  
24-May-2011  Rathnam added @d_EffectiveStartDate one more parameter 
06-Jun-2011 Rathnam added @b_IsPreventive, @i_DiseaseID two more parameters
10-Aug-2011 NagaBabu Added @v_FrequencyCondition,@t_ProgramProcedureConditionalFrequency as input Parameter 
06-Sep-2011 NagaBabu Added @t_ProgramProcedureTherapeuticDrugFrequency
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ProgramProcedureFrequency_Update]    
(    
 @i_AppUserId KEYID,    
 @i_ProgramId KEYID,  
 @i_ProcedureId KEYID,  
 @vc_StatusCode STATUSCODE,  
 @i_FrequencyNumber KEYID,  
 @vc_Frequency VARCHAR(1),
 @b_NeverSchedule BIT,
 @vc_ExclusionReason ShortDescription,
 @i_LabTestID KEYID = NULL,
 @d_EffectiveStartDate UserDate = NULL,
 @i_DiseaseID KeyID = NULL,
 @b_IsPreventive IsIndicator = NULL ,
 @v_FrequencyCondition SourceName ,
 @t_ProgramProcedureConditionalFrequency ProgramProcedureConditionalFrequency READONLY ,
 @t_ProgramProcedureTherapeuticDrugFrequency ProgramProcedureTherapeuticDrugFrequency READONLY 
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
	  
	  UPDATE ProgramProcedureFrequency  
		 SET FrequencyNumber = @i_FrequencyNumber ,
			 Frequency = @vc_Frequency,  
			 StatusCode = @vc_StatusCode,  
			 LastModifiedByUserId = @i_AppUserId,  
			 LastModifiedDate = GETDATE(),
			 NeverSchedule =  @b_NeverSchedule,
			 ExclusionReason = @vc_ExclusionReason,
			 LabTestId = @i_LabTestID,
			 EffectiveStartDate = @d_EffectiveStartDate,
			 DiseaseID = @i_DiseaseID ,
             IsPreventive = @b_IsPreventive ,
             FrequencyCondition = @v_FrequencyCondition
	   WHERE ProgramId = @i_ProgramId  
		 AND ProcedureId = @i_ProcedureId  
	  	  
		SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
	        
	 IF @l_numberOfRecordsUpdated <> 1  
	  BEGIN        
		   RAISERROR    
		   (  N'Invalid Row count %d passed to update ProgramProcedureFrequency table'    
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramProcedureFrequency_Update] TO [FE_rohit.r-ext]
    AS [dbo];

