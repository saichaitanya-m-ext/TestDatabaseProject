/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserNotes_Update    
Description   : This procedure is used to update record in UserNotes table
Created By    : Aditya    
Created Date  : 24-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
20-Mar-2013 P.V.P.Mohan modified UserNotes to PatientNotes
			and modified columns.   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserNotes_Update]  
(  
	@i_AppUserId KeyID,    
	@i_UserId KeyID,
	@vc_Note LongDescription,
	@vc_ViewableByPatient BIT,
	@vc_StatusCode StatusCode,
	@dt_UserNoteDate DATE,
	@i_UserNotesId KeyID,
	@vc_NoteType CHAR   
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

	 UPDATE PatientNotes
	    SET	PatientId = @i_UserId,
			Note = @vc_Note,
			ViewableByPatient = @vc_ViewableByPatient,
			UserNoteDate = @dt_UserNoteDate,
			NoteType = @vc_NoteType,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @vc_StatusCode
	  WHERE PatientNotesId = @i_UserNotesId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update UserNotes'  
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserNotes_Update] TO [FE_rohit.r-ext]
    AS [dbo];

