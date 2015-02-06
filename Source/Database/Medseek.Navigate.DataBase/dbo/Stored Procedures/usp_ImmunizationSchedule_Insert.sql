/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ImmunizationSchedule_Insert
Description   : This procedure is used to insert data into ImmunizationSchedule
Created By    : NagaBabu
Created Date  : 16-Aug-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY  DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ImmunizationSchedule_Insert]  
(  
	@i_AppUserId KeyID ,
	@i_ImmunizationId KeyID ,
	@i_FrequenceNumber INT ,
	@c_Frequence CHAR(1) ,
	@v_StatusCode StatusCode ,	
	@o_ImmunizationScheduleId KeyID OUTPUT
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

	INSERT INTO ImmunizationSchedule
	(
		ImmunizationId ,
		FrequenceNumber ,
		Frequence ,
		StatusCode ,
		CreatedByUserId
	)
	VALUES 
	(
		@i_ImmunizationId ,
		@i_FrequenceNumber ,
		@c_Frequence ,
		@v_StatusCode ,
		@i_AppUserId
	)		
	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_ImmunizationScheduleId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert ImmunizationSchedule'
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
    ON OBJECT::[dbo].[usp_ImmunizationSchedule_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

