/*    
------------------------------------------------------------------------------    
Procedure Name: usp_MedicalProblemClassification_Update    
Description   : This procedure is used to update record in MedicalProblemClassification table.
Created By    : Nagababu    
Created Date  : 18-May-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
05-Aug-2010 NagaBabu Added isPatientViewable field in the Update statement
27-Sep-2010 NagaBabu Deleted  the statement 'RETURN @l_numberOfRecordsUpdated'  
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_MedicalProblemClassification_Update]  
(  
	@i_AppUserId KEYID ,  
	@vc_ProblemClassName ShortDescription,
	@vc_Description	LongDescription,
	@vc_StatusCode	StatusCode,
	@i_MedicalProblemClassificationId KEYID,
	@i_isPatientViewable ISINDICATOR
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
	
---------Update operation into MedicalProblemClassification table-----  
		
	 UPDATE MedicalProblemClassification
	    SET	ProblemClassName = @vc_ProblemClassName,
			Description = @vc_Description,
			StatusCode = @vc_StatusCode,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			isPatientViewable = @i_isPatientViewable 
	  WHERE MedicalProblemClassificationId = @i_MedicalProblemClassificationId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update MedicalProblemClassification Details'  
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
    ON OBJECT::[dbo].[usp_MedicalProblemClassification_Update] TO [FE_rohit.r-ext]
    AS [dbo];

