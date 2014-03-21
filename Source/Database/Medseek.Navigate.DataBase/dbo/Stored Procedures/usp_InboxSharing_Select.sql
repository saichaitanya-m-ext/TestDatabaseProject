/*          
------------------------------------------------------------------------------          
Procedure Name: usp_InboxSharing_Select          
Description   : This procedure is used to select data related to users shared Inboxes    
Created By    : Pramod    
Created Date  : 21-Apr-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
       
------------------------------------------------------------------------------          
*/        
CREATE PROCEDURE [dbo].[usp_InboxSharing_Select]        
(        
 @i_AppUserId KeyID,    
 @i_UserId KeyID,    
 @v_StatusCode StatusCode = NULL     
)        
AS        
BEGIN TRY      
 SET NOCOUNT ON        
    
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
      
 SELECT 
	  InboxSharing.InboxSharingId,    
	  InboxSharing.ShareWithUserID,    
	  InboxSharing.StartSharingDate,    
	  InboxSharing.EndSharingDate,    
	  InboxSharing.Remarks,    
	  CASE InboxSharing.StatusCode    
		WHEN 'A' THEN 'Active'    
		WHEN 'I' THEN 'InActive'    
	  END AS StatusDescription,    
	  COALESCE( Users.LastName + ' ' + Users.FirstName , '') AS ShareToUserName,    
	  InboxSharing.CreatedByUserId,    
	  InboxSharing.CreatedDate,    
	  InboxSharing.LastModifiedByUserId,    
	  InboxSharing.LastModifiedDate    
 FROM InboxSharing      WITH (NOLOCK)   
      INNER JOIN Provider Users    WITH (NOLOCK)   
          ON Users.ProviderID = InboxSharing.ShareWithUserID    
 WHERE InboxSharing.UserID = @i_UserId       
    AND (InboxSharing.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)    
        
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
    ON OBJECT::[dbo].[usp_InboxSharing_Select] TO [FE_rohit.r-ext]
    AS [dbo];

