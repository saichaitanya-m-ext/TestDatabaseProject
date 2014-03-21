/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_HealthIndicatorsAndBarriers_Insert]
Description   : This procedure is used to insert data into HealthIndicatorsAndBarriers
Created By    : NagaBabu
Created Date  : 09-Sep-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_HealthIndicatorsAndBarriers_Insert]  
(  
	@i_AppUserId KeyID ,
	@v_Name ShortDescription ,
	@v_Description LongDescription ,
	@v_StatusCode StatusCode ,
	@c_Type CHAR(1) ,
	@o_HealthIndicatorsAndBarriersId KeyId OUTPUT
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
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
	
	INSERT INTO HealthIndicatorsAndBarriers
	(
		Name,
		[Description],
		StatusCode,
		[Type],
		CreatedByUserId
	)
	VALUES
	(
		@v_Name,
		@v_Description,
		@v_StatusCode,
		@c_Type,
		@i_AppUserId
	)
	
	SELECT @o_HealthIndicatorsAndBarriersId = SCOPE_IDENTITY(),
		   @l_numberOfRecordsInserted =	@@ROWCOUNT		

    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert HealthIndicatorsAndBarriers'
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthIndicatorsAndBarriers_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

