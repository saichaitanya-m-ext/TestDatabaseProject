  
/*  
--------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_GetUserByProviderID] 
Description   : This proc is used to get patientcount for given providerid
Created By    : Praveen
Created Date  : 09-May-2013
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_GetUserByProviderID]
(
@i_ProviderID KEYID,
@i_AppUserId KEYID
)
AS
BEGIN
      BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END
		
		select 
		COUNT(*) 
		from usergroup 
		where 
		providerid=@i_ProviderID            
		
      END TRY
      BEGIN CATCH  
---------------------------------------------------------------------------------------------------------------------------------  
    -- Handle exception  
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END  
  


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_GetUserByProviderID] TO [FE_rohit.r-ext]
    AS [dbo];

