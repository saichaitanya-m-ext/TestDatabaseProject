﻿/*        
------------------------------------------------------------------------------        
Procedure Name: usp_MedicalProblemClassification_Insert        
Description   : This procedure is used to insert records into MedicalProblemClassification table    
Created By    : NagaBabu        
Created Date  : 18-May-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
05-Aug-2010 NagaBabu Added isPatientViewable field in the Insert statement 
27-Sep-2010 NagaBabu Added @l_numberOfRecordsInserted as parameter for Error message
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_MedicalProblemClassification_Insert]
(  
    @i_AppUserId KEYID , 
	@vc_ProblemClassName	ShortDescription,
	@vc_Description	LongDescription  ,
	@vc_StatusCode	StatusCode ,
	@o_MedicalProblemClassificationId KEYID OUTPUT,
	@i_isPatientViewable ISINDICATOR
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
    
---------insert operation into MedicalProblemClassification table-----       
  

         INSERT INTO  
             MedicalProblemClassification  
             (  
				ProblemClassName,
				Description,
				StatusCode,
				CreatedByUserId,
				isPatientViewable 
			 ) 
			  
         VALUES  
             ( 
                @vc_ProblemClassName,
				@vc_Description,
				@vc_StatusCode,
                @i_AppUserId,
                @i_isPatientViewable 
              )  
         SELECT @o_MedicalProblemClassificationId = SCOPE_IDENTITY()  ,
			    @l_numberOfRecordsInserted = @@ROWCOUNT
	     IF @l_numberOfRecordsInserted <> 1
	     BEGIN 
		     RAISERROR
		         (  N'Invalid Row count %d passed to update MedicalProblemClassification Details'  
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
    ON OBJECT::[dbo].[usp_MedicalProblemClassification_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

