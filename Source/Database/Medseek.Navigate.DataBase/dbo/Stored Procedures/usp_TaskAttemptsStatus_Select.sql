/*        
-----------------------------------------------------------------------------------       
Procedure Name: [usp_TaskAttemptsStatus_Select]        
Description   : This procedure is used to select the data from TaskAttemptsStatus table.        
Created By    : Rathnam         
Created Date  : 03-Jan-2011
-----------------------------------------------------------------------------------     
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
   
-----------------------------------------------------------------------------------        
*/  
  
CREATE PROCEDURE [dbo].[usp_TaskAttemptsStatus_Select]
(  
	@i_AppUserId KEYID
) 
AS  
BEGIN TRY         
        SET NOCOUNT ON     
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END        
        
           
---------Selection starts here -------------------      
  
      SELECT 
		  TaskAttemptsStatusId AS TaskStatusId,
		  Description AS TaskStatusText
      FROM  
		  TaskAttemptsStatus WITH(NOLOCK)
      WHERE StatusCode = 'A'		  
	 ORDER BY TaskAttemptsStatusId   
                         
END TRY  
---------------------------------------------------------------------------------------------------
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskAttemptsStatus_Select] TO [FE_rohit.r-ext]
    AS [dbo];

