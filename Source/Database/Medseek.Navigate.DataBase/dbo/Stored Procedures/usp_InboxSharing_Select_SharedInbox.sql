/*        
------------------------------------------------------------------------------        
Procedure Name: usp_InboxSharing_Select_SharedInbox  
Description   : This procedure is used to return the list of users who shared   
    their inbox with the user  
Created By    : Pramod  
Created Date  : 21-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
        
------------------------------------------------------------------------------        
*/      
CREATE PROCEDURE [dbo].[usp_InboxSharing_Select_SharedInbox]      
(      
 @i_AppUserId KeyID,  
 @i_UserId KeyID  
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
    
 SELECT InboxSharing.UserID,  
  COALESCE( Users.LastName + ' ' + Users.FirstName , '' ) AS ShareUserName  
   FROM InboxSharing    WITH (NOLOCK)   
     INNER JOIN Provider Users  WITH (NOLOCK) 
       ON Users.ProviderID = InboxSharing.UserID  
  WHERE InboxSharing.ShareWithUserID = @i_UserId  
    AND InboxSharing.StatusCode = 'A'  
    AND  ( ( GETDATE() BETWEEN InboxSharing.StartSharingDate AND InboxSharing.EndSharingDate )  
   OR   
     ( InboxSharing.StartSharingDate <= GETDATE() AND InboxSharing.EndSharingDate IS NULL )  
   )  
  
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
    ON OBJECT::[dbo].[usp_InboxSharing_Select_SharedInbox] TO [FE_rohit.r-ext]
    AS [dbo];

