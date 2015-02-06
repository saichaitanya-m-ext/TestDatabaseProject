/*    
--------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIProviderPersonalizationByProvider_Select]
Description   : selecting ReportingYear by ProviderUserID from PQRIProviderPersonalization table
Created By    : NagaBabu
Created Date  : 21-Jan-2011
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------    
*/       
CREATE PROCEDURE [dbo].[usp_PQRIProviderPersonalizationByProvider_Select]
(    
    @i_AppUserId KEYID 
)    
AS    
BEGIN TRY     
    
 -- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
         BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed.'    
               ,17    
               ,1    
               ,@i_AppUserId )    
         END    
----------- Select data from PQRIProviderPersonalization ---------------   
      SELECT 
		  ProviderUserID ,
		  ReportingYear 
	  FROM
		  PQRIProviderPersonalization	
	  WHERE
		  ProviderUserID = @i_AppUserId
	  
END TRY    
---------------------------------------------------------------------------------------------------------------    
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIProviderPersonalizationByProvider_Select] TO [FE_rohit.r-ext]
    AS [dbo];

