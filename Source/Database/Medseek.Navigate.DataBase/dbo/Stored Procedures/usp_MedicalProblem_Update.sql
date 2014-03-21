/*    
------------------------------------------------------------------------------    
Procedure Name: usp_MedicalProblem_Update    
Description   : This procedure is used to update record in MedicalProblem table.
Created By    : Aditya    
Created Date  : 18-May-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
27-Sep-2010 NagaBabu Deleted  the statement 'RETURN @l_numberOfRecordsUpdated'
06-July-2011 NagaBabu Added @b_IsShowPatientCriteria as bit Parameter       
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_MedicalProblem_Update]  
(  
	@i_AppUserId KEYID ,  
	@vc_ProblemName	ShortDescription,
	@vc_Description	LongDescription,
	@i_MedicalProblemClassificationId	KeyID,
	@vc_StatusCode	StatusCode,
	@i_MedicalProblemId	KeyID ,
	@b_IsShowPatientCriteria IsIndicator
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
	
---------Update operation into MedicalProblem table-----  
		
	 UPDATE MedicalProblem
	    SET	ProblemName = @vc_ProblemName,
			Description = @vc_Description,
			MedicalProblemClassificationId = @i_MedicalProblemClassificationId,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode,
			IsShowPatientCriteria = @b_IsShowPatientCriteria
	  WHERE MedicalProblemId = @i_MedicalProblemId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update MedicalProblem Details'  
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
    ON OBJECT::[dbo].[usp_MedicalProblem_Update] TO [FE_rohit.r-ext]
    AS [dbo];

