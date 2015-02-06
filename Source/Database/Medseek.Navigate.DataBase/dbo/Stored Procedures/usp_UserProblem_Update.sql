/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserProblem_Update      
Description   : This procedure is used to update records in UserProblem table.  
Created By    : NagaBabu     
Created Date  : 19-May-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
20-Mar-2013 P.V.P.Mohan modified UserProblem to PatientProblem
			and modified columns.     
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserProblem_Update]    
(    
 @i_AppUserId KeyID,
 @i_UserId	KeyID,  
 @i_MedicalProblemId KeyID,
 @vc_Comments LongDescription,
 @dt_ProblemStartDate UserDate =null,
 @dt_ProblemEndDate	UserDate=null,
 @vc_StatusCode	StatusCode,
 @i_MedicalProblemClassificationId KeyID,
 @i_UserProblemId Keyid ,
 @i_DataSourceId KeyId
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
	    
	 UPDATE PatientProblem  
		SET PatientID = @i_UserId,
			MedicalProblemId = @i_MedicalProblemId,
			Comments = @vc_Comments,
			ProblemStartDate = @dt_ProblemStartDate,
			ProblemEndDate = @dt_ProblemEndDate,
			StatusCode = @vc_StatusCode,
			LastModifiedByUserId = @i_AppUserId,
			MedicalProblemClassificationId = @i_MedicalProblemClassificationId,
			LastModifiedDate = GETDATE() ,
			DataSourceId = @i_DataSourceId
	  WHERE PatientProblemID = @i_UserProblemId
	     
	 SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT  
	        
	 IF @l_numberOfRecordsUpdated <> 1  
	 BEGIN        
		  RAISERROR  
			( N'Invalid Row count %d passed to update Details'    
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
    ON OBJECT::[dbo].[usp_UserProblem_Update] TO [FE_rohit.r-ext]
    AS [dbo];

