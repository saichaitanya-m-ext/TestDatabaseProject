/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserNotes_Insert      
Description   : This procedure is used to insert record into UserNotes table  
Created By    : Aditya      
Created Date  : 24-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
20-Mar-2013 P.V.P.Mohan modified UserNotes to PatientNotes
			and modified columns.     
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_UserNotes_Insert]    
(    
	@i_AppUserId KeyID,    
	@i_UserId KeyID,
	@vc_Note LongDescription,
	@vc_ViewableByPatient BIT,
	@vc_StatusCode StatusCode,
	@dt_UserNoteDate DATE,
	@vc_NoteType CHAR,
	@o_UserNotesId KeyID OUTPUT  
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
	  
	 INSERT INTO PatientNotes  
		( 
			PatientId,
			Note,
			ViewableByPatient,
			UserNoteDate,
			NoteType,
			StatusCode,
			CreatedByUserId 
		 )  
	 VALUES  
		(		
			@i_UserId,
			@vc_Note,
			@vc_ViewableByPatient,
			@dt_UserNoteDate,
			@vc_NoteType,
			@vc_StatusCode,
			@i_AppUserId
		)  
	       
		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT  
			  ,@o_UserNotesId = SCOPE_IDENTITY()  
	        
	 IF @l_numberOfRecordsInserted <> 1            
	 BEGIN            
		  RAISERROR        
		   (  N'Invalid row count %d in Insert UserNotes'  
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
    ON OBJECT::[dbo].[usp_UserNotes_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

