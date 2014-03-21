/*        
------------------------------------------------------------------------------------------        
Procedure Name: usp_TherapeuticClassDrug_Insert        
Description   : This procedure is used to insert record into TherapeuticClassDrug table.    
Created By    : Aditya        
Created Date  : 09-Mar-2010        
-------------------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
27-Sep-2010 NagaBabu Added @l_numberOfRecordsInserted for error message        
-------------------------------------------------------------------------------------------        
*/      
    
    
CREATE PROCEDURE [dbo].[usp_TherapeuticClassDrug_Insert]      
(      
 @i_AppUserId KeyID,    
 @i_TherapeuticID KeyID ,    
 @i_DrugCodeID KeyID,    
 @o_TherapeuticClassDrug INT OUTPUT    
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
	 ----------- Insert into TherapeuticClassDrug Table -----------    
	    
	  INSERT INTO TherapeuticClassDrug    
		 (     
			DrugCodeID,    
			TherapeuticID,    
			CreatedByUserId    
		 )    
	  VALUES     
		 (    
			  @i_DrugCodeID,    
			  @i_TherapeuticID,    
			  @i_AppUserId    
		  )    
	       
	  SELECT @o_TherapeuticClassDrug = SCOPE_IDENTITY(),
			 @l_numberOfRecordsInserted = @@ROWCOUNT
	  IF @l_numberOfRecordsInserted <> 1
		BEGIN 
			RAISERROR	
				(  N'Invalid Row count %d passed to Delete Drug from TherapeuticClassDrug'  
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
    ON OBJECT::[dbo].[usp_TherapeuticClassDrug_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

