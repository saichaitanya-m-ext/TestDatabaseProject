/*        
------------------------------------------------------------------------------        
Procedure Name: usp_MedicalProblem_Insert        
Description   : This procedure is used to insert records into MedicalProblem table    
Created By    : Aditya        
Created Date  : 18-May-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
27-Sep-2010 NagaBabu Added @l_numberOfRecordsInserted as parameter for Error message  
06-July-2011 NagaBabu Added @b_IsShowPatientCriteria as bit Parameter      
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_MedicalProblem_Insert]  
(  
	@i_AppUserId KEYID ,  
	@vc_ProblemName	ShortDescription,
	@vc_Description	LongDescription,
	@i_MedicalProblemClassificationId	KeyID,
	@vc_StatusCode	StatusCode,
	@b_IsShowPatientCriteria IsIndicator,
	@o_MedicalProblemId	KeyID OUTPUT
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
    
---------insert operation into MedicalProblem table-----       
  

         INSERT INTO  
             MedicalProblem  
             (  
				ProblemName,
				Description,
				MedicalProblemClassificationId,
				StatusCode,
				CreatedByUserId ,
				IsShowPatientCriteria
			 )  
         VALUES  
             ( 
                @vc_ProblemName,
				@vc_Description,
				@i_MedicalProblemClassificationId,
				@vc_StatusCode,
                @i_AppUserId,
                @b_IsShowPatientCriteria
              )  
        
      SELECT @o_MedicalProblemId = SCOPE_IDENTITY(),
		  @l_numberOfRecordsInserted = @@ROWCOUNT  
      IF @l_numberOfRecordsInserted <> 1
		 BEGIN
			   RAISERROR ( N'Invalid row count %d in Insert MedicalProblem' ,
			   17 ,
			   1 ,
			   @l_numberOfRecordsInserted )
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
    ON OBJECT::[dbo].[usp_MedicalProblem_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

