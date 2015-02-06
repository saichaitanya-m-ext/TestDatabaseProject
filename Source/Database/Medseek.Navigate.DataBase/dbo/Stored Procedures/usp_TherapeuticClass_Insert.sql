/*    
------------------------------------------------------------------------------    
Procedure Name: usp_TherapeuticClass_Insert    
Description   : This procedure is used to insert record into TherapeuticClass table.
Created By    : Aditya    
Created Date  : 08-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
28-Sep-2010 NagaBabu Replaced RETURN @o_TherapeuticID by -1 in First statement and replaced by RETURN 0 at the 
						second statement
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_TherapeuticClass_Insert]  
(  
	@i_AppUserId KeyID,  
	@vc_Name SourceName,
	@vc_Description LongDescription,
	@i_SortOrder STID,
	@vc_StatusCode StatusCode,
	@o_TherapeuticID KeyID OUTPUT
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
    
    ----------- INSERT OPERATION TAKES PLACE -----------------------------------
	
		INSERT INTO TherapeuticClass
		   ( 
			 Name,
			 Description,
			 SortOrder,
			 StatusCode,
			 CreatedByUserId

		   )
		VALUES
		   ( 
			@vc_Name ,
			@vc_Description ,
			@i_SortOrder,
			@vc_StatusCode,
			@i_AppUserId 
		   )
		   	
		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
			  ,@o_TherapeuticID = SCOPE_IDENTITY()
	      
		IF @l_numberOfRecordsInserted <> 1          
		BEGIN          
			RAISERROR      
				(  N'Invalid row count %d in insert TherapeuticClass Table'      
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
    ON OBJECT::[dbo].[usp_TherapeuticClass_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

