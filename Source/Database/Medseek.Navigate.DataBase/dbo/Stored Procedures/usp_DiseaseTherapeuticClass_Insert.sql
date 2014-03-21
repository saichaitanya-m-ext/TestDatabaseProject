/*      
------------------------------------------------------------------------------------------      
Procedure Name: usp_DiseaseTherapeuticClass_Insert      
Description   : This procedure is used to insert record into DiseaseTherapeuticClass table.  
Created By    : Aditya      
Created Date  : 08-Mar-2010      
-------------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
-------------------------------------------------------------------------------------------      
*/    
  
  
  
CREATE PROCEDURE [dbo].[usp_DiseaseTherapeuticClass_Insert]    
(    
	@i_AppUserId KeyID,  
	@i_TherapeuticID KeyID ,  
	@i_DiseaseId KeyID  
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
  
------------------insert operation into DiseaseTherapeuticClass table-----   
      
  INSERT INTO DiseaseTherapeuticClass  
     (   
		DiseaseID,  
		TherapeuticID,  
		CreatedByUserId  
     )  
  VALUES  
   (      
		@i_DiseaseId,  
		@i_TherapeuticID,  
		@i_AppUserId  
    )  
              
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
       
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert DiseaseTherapeuticClass Type'
				,17      
				,1      
				,@l_numberOfRecordsInserted                 
			)              
	END  

	RETURN 0 
  
END TRY      
  
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_DiseaseTherapeuticClass_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

