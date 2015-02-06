/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserProcedureCodes_Update      
Description   : This procedure is used to Update record in UserProcedureCodes table  
Created By    : Aditya      
Created Date  : 07-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
27-July-2010 NagaBabu Added ProcedureLeadtime Field to this Update Statement  
18-Oct-2010  Rathnam  pass null value to @i_ProcedureLeadtime   
19-Jan-2011   Rama added ProcedureCodeModifierId column and passing null value to @i_ProcedureCodeModifierId
09-May-2011   Rathnam added @i_LabTestId one more parameter to the sp.
06-Jun-2011 Rathnam added @b_IsPreventive, @i_DiseaseID two more parameters 
09-Nov-2011 NagaBabu Added @i_ProgramId as input parameter
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserProcedureCodes_Update]    
(    
	@i_AppUserId KeyID,
	@i_UserId KeyID,
	@i_ProcedureId KeyID,
	@vc_Commments ShortDescription,
	@vc_StatusCode StatusCode,
	@dt_DueDate UserDate,
	@dt_ProcedureCompletedDate	UserDate,
	@i_UserProcedureId	KeyID ,
	@i_ProcedureLeadtime INT = NULL,
	@i_ProcedureCodeModifierId KeyID = NULL,
	@i_LabTestId KEYID = NULL,
	@i_DiseaseID KeyID = NULL,
    @b_IsPreventive IsIndicator = NULL,
    @i_ProgramId KeyId = NULL,
    @i_DataSourceId KeyId = NULL
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
	  
	  UPDATE UserProcedureCodes  
		 SET UserId = @i_UserId,
			 ProcedureId = @i_ProcedureId, 
			 Commments = @vc_Commments,
			 ProcedureCompletedDate = @dt_ProcedureCompletedDate, 
			 StatusCode = @vc_StatusCode, 
			 DueDate = @dt_DueDate, 
			 LastModifiedByUserId = @i_AppUserId,  
			 LastModifiedDate = GETDATE(),
			 ProcedureLeadtime = @i_ProcedureLeadtime  ,
			 ProcedureCodeModifierId = @i_ProcedureCodeModifierId,
			 LabTestId = @i_LabTestId,
			 DiseaseID = @i_DiseaseID ,
             IsPreventive = @b_IsPreventive ,
             ProgramId = @i_ProgramId ,
             DataSourceID = @i_DataSourceId
	   WHERE UserProcedureId = @i_UserProcedureId  
	  
		SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
	        
	 IF @l_numberOfRecordsUpdated <> 1  
	  BEGIN        
		   RAISERROR    
		   (  N'Invalid Row count %d passed to update UserProcedureCodes'    
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
    ON OBJECT::[dbo].[usp_UserProcedureCodes_Update] TO [FE_rohit.r-ext]
    AS [dbo];

