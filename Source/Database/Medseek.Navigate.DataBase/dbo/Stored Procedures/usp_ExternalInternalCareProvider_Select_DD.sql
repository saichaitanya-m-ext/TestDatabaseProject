/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_ExternalInternalCareProvider_Select_DD] 23      
Description   : This procedure is used to get the ExternalCareProvider and     
    internal provider data (in Users table with Isprovider = 1)    
Created By    : Rathnam    
Created Date  : 13-Oct-2011      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ExternalInternalCareProvider_Select_DD] --23
(    
   @i_AppUserId KeyID
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

	 SELECT 
			1 AS IsExternalProvider,
			ExternalProviderId,
			ISNULL(LastName,'') + ' ' + ISNULL(FirstName,'') + ' ' + ISNULL(MiddleName,'') AS PrimaryCareProvider,
			EmailId As  EmailId,    
			PhoneNumber As PhoneNumber,
			NULL AS ProviderUserId  
	   FROM ExternalCareProvider     WITH (NOLOCK) 
	  WHERE StatusCode = 'A'
	 UNION    
	 SELECT  
			0 AS IsExternalProvider,
			NULL AS ProviderUserId,
			ISNULL(LastName,'') + ' ' + ISNULL(FirstName,'') + ' ' 
			+ ISNULL(MiddleName,'') AS PrimaryCareProvider,
			 EmailIdPrimary As EmailId,    
			PhoneNumberPrimary As PhoneNumber ,
			UserId AS ExternalProviderId
	   FROM Users  WITH (NOLOCK) 
	  WHERE  (Users.IsPhysician = 1 OR Users.IsProvider = 1)
		AND Users.UserStatusCode = 'A'

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
    ON OBJECT::[dbo].[usp_ExternalInternalCareProvider_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

