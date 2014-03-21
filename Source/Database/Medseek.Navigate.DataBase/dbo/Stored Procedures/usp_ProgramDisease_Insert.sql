/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ProgramDisease_Insert    
Description   : This procedure is used to insert record into ProgramDisease table
Created By    : Aditya    
Created Date  : 23-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
08-07-2010 Rathnam StatusCode column added
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ProgramDisease_Insert]  
(  
	@i_AppUserId KeyID,
	@i_ProgramId KeyID,
	@i_DiseaseId KeyID,
	@v_StatusCode StatusCode,
	@o_ProgramDiseaseId KeyID OUTPUT
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

	INSERT INTO ProgramDisease
		( 
			ProgramId,
			DiseaseId,
			CreatedByUserId,
			StatusCode 
	   )
	VALUES
	   ( 
			@i_ProgramId,
			@i_DiseaseId,
			@i_AppUserId,
			@v_StatusCode
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_ProgramDiseaseId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert ProgramDisease'
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
    ON OBJECT::[dbo].[usp_ProgramDisease_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

