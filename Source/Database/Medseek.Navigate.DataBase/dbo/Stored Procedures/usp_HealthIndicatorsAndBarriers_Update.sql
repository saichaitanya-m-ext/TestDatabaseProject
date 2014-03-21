/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_HealthIndicatorsAndBarriers_Update]
Description   : This procedure is used to Update data into HealthIndicatorsAndBarriers
Created By    : NagaBabu
Created Date  : 09-Sep-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/ 
CREATE PROCEDURE [dbo].[usp_HealthIndicatorsAndBarriers_Update]  
(  
	@i_AppUserId KeyID ,
	@v_Name ShortDescription ,
	@v_Description LongDescription ,
	@v_StatusCode StatusCode ,
	@c_Type CHAR(1) ,
	@i_HealthIndicatorsAndBarriersId KeyId 
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
	
	UPDATE HealthIndicatorsAndBarriers
	   SET Name = @v_Name ,
		   [Description] = @v_Description ,
		   StatusCode = @v_StatusCode ,
		   [Type] = @c_Type ,
		   LastModifiedByUserId = @i_AppUserId ,
		   LastModifiedDate = GETDATE() 
	 WHERE HealthIndicatorsAndBarriersId = @i_HealthIndicatorsAndBarriersId	   
	
	SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT		

    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Updated HealthIndicatorsAndBarriers'
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
    ON OBJECT::[dbo].[usp_HealthIndicatorsAndBarriers_Update] TO [FE_rohit.r-ext]
    AS [dbo];

