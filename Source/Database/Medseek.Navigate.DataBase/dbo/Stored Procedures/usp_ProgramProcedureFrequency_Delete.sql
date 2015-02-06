/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_ProgramProcedureFrequency_Delete]
Description   : This procedure used to delete data from ProgramProcedureConditionalFrequency,ProgramProcedureFrequency
Created By    : NagaBabu
Created Date  : 12-Aug-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ProgramProcedureFrequency_Delete]    
(    
 @i_AppUserId KEYID,    
 @i_ProgramId KEYID,  
 @i_ProcedureId KEYID  
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
------------------------------------------------------------------------------	 
		DECLARE @l_TranStarted BIT = 0  
            IF(@@TRANCOUNT = 0)  
				 BEGIN  
					BEGIN TRANSACTION  
					SET @l_TranStarted = 1  
				 END  
			ELSE 
				 BEGIN  
					SET @l_TranStarted = 0
				 END 
				  
		DELETE FROM ProgramProcedureConditionalFrequency
		WHERE ProgramId = @i_ProgramId
		  AND ProcedureId = @i_ProcedureId
		  
		DELETE FROM ProgramProcedureTherapeuticDrugFrequency
		WHERE ProgramId = @i_ProgramId
		  AND ProcedureId = @i_ProcedureId  
		
	    DELETE FROM ProgramProcedureFrequency
	    WHERE ProgramId = @i_ProgramId
		  AND ProcedureId = @i_ProcedureId	  	
			
		IF @l_TranStarted = 1  
			   BEGIN  
					SET @l_TranStarted = 0  
					COMMIT TRANSACTION  
			   END  
			ELSE 
			   BEGIN 
					ROLLBACK TRANSACTION 
			   END			
    
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
    ON OBJECT::[dbo].[usp_ProgramProcedureFrequency_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

