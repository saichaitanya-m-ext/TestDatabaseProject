/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ImmunizationSchedule_Update
Description   : This procedure is used to Update data into ImmunizationSchedule
Created By    : NagaBabu
Created Date  : 16-Aug-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY  DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ImmunizationSchedule_Update]  
(  
	@i_AppUserId KeyID ,
	@i_ImmunizationId KeyID ,
	@i_FrequenceNumber INT ,
	@c_Frequence CHAR(1) ,
	@v_StatusCode StatusCode ,	
	@i_ImmunizationScheduleId KeyID 
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

	UPDATE ImmunizationSchedule
	   SET ImmunizationId = @i_ImmunizationId ,
		   FrequenceNumber = @i_FrequenceNumber ,
		   Frequence = @c_Frequence ,
		   StatusCode = @v_StatusCode ,
		   LastModifiedByUserId = @i_AppUserId ,
		   LastModifiedDate = GETDATE()
	 WHERE ImmunizationScheduleId = @i_ImmunizationScheduleId	    	
	
    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update ImmunizationSchedule'
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
    ON OBJECT::[dbo].[usp_ImmunizationSchedule_Update] TO [FE_rohit.r-ext]
    AS [dbo];

