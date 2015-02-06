/*        
------------------------------------------------------------------------------        
Procedure Name: usp_InboxSharing_Update       
Description   : This procedure is used to update data related to users shared Inboxes  
Created By    : Pramod  
Created Date  : 21-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
31-Aug-2010 NagaBabu Modified Remarks perameter by default as NULL 
27-Sep-2010 NagaBabu Added @l_numberOfRecordsUpdated as parameter for Error message
------------------------------------------------------------------------------        
*/      
CREATE PROCEDURE [dbo].[usp_InboxSharing_Update]      
(      
 @i_AppUserId KeyID,  
 @i_InboxSharingId KeyID,  
 @i_UserId KeyID,     
 @i_ShareWithUserID KeyID,    
 @d_StartSharingDate DATETIME,    
 @d_EndSharingDate DATETIME,    
 @v_Remarks VARCHAR(500) = NULL,  
 @v_StatusCode StatusCode  
)      
AS      
BEGIN TRY    
	 SET NOCOUNT ON      
	 DECLARE @i_numberOfRecordsUpdated INT  
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
	    
	 UPDATE InboxSharing  
		SET ShareWithUserID = @i_ShareWithUserID,  
			StartSharingDate = @d_StartSharingDate,  
			EndSharingDate = @d_EndSharingDate,  
			Remarks = @v_Remarks,
			StatusCode = @v_StatusCode,  
			LastModifiedByUserId = @i_AppUserId,  
			LastModifiedDate = GETDATE()  
	  WHERE InboxSharingId = @i_InboxSharingId  
		AND UserID = @i_UserId 
		
		  
       SET @i_numberOfRecordsUpdated = @@ROWCOUNT    
       IF @i_numberOfRecordsUpdated <> 1    
             RAISERROR     
             ( N'Update of InboxSharing table experienced invalid row count of %d' ,    
                  17 ,    
                  1 ,    
                  @i_numberOfRecordsUpdated     
             )   
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
    ON OBJECT::[dbo].[usp_InboxSharing_Update] TO [FE_rohit.r-ext]
    AS [dbo];

