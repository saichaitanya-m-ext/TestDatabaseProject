
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_MedicalCondition_Update]
Description   : This procedure used to update data into MedicalCondition table
Created By    : Rama Krishna Prasad
Created Date  : 06-July-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
04-Aug-2011 NagaBabu Changed datatype of @s_Condition as VARCHAR(256)    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_MedicalCondition_Update]  
(  
	@i_AppUserId KeyID ,
	@i_DiseaseId KeyID,
	@v_Condition VARCHAR(256) ,
	@v_StatusCode StatusCode ,
	@i_MedicalConditionID KeyID
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

	 UPDATE MedicalCondition
	    SET DiseaseId = @i_DiseaseId,
			Condition = @v_Condition,
			StatusCode = @v_StatusCode ,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE()
	 WHERE MedicalConditionID = @i_MedicalConditionID
	   
	   	
    SET @l_numberOfRecordsUpdated = @@ROWCOUNT
     
    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update MedicalCondition'
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
    ON OBJECT::[dbo].[usp_MedicalCondition_Update] TO [FE_rohit.r-ext]
    AS [dbo];

