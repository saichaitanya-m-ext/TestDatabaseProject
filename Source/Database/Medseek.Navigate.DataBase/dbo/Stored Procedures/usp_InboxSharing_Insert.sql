/*        
------------------------------------------------------------------------------        
Procedure Name: usp_InboxSharing_Insert        
Description   : This procedure is used to insert record into InboxSharing table    
Created By    : Pramod  
Created Date  : 21-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
31-Aug-2010 NagaBabu Modified Remarks perameter by default as NULL    
------------------------------------------------------------------------------        
*/      
CREATE PROCEDURE [dbo].[usp_InboxSharing_Insert]      
(      
 @i_AppUserId KeyID,    
 @i_UserId KeyID,     
 @i_ShareWithUserID KeyID,    
 @d_StartSharingDate DATETIME,    
 @d_EndSharingDate DATETIME,    
 @v_Remarks VARCHAR(500) = NULL,   
 @v_StatusCode StatusCode,  
 @o_InboxSharingID KeyID OUTPUT    
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
    
 INSERT INTO InboxSharing    
  (     
    UserID,  
    ShareWithUserID,  
    StartSharingDate,  
    EndSharingDate,  
    Remarks,  
    StatusCode,  
    CreatedByUserId  
    )    
 VALUES    
    (    
    @i_UserId,    
    @i_ShareWithUserID,    
    @d_StartSharingDate,    
    @d_EndSharingDate,    
    @v_Remarks,  
    @v_StatusCode,  
    @i_AppUserId  
    )    
         
  SELECT @l_numberOfRecordsInserted = @@ROWCOUNT    
         ,@o_InboxSharingID = SCOPE_IDENTITY()    
          
  IF @l_numberOfRecordsInserted <> 1              
  BEGIN              
   RAISERROR          
    (  N'Invalid row count %d in insert InboxSharing '    
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
    ON OBJECT::[dbo].[usp_InboxSharing_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

