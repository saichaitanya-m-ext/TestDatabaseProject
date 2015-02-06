/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_CareProvider_User_SelectMore]         
Description   : This procedure is used to get the ExternalCareProvider and         
    internal provider data (in Users table with Isprovider = 1) and to be  
    used for more feature in the external/internal care provider detail        
Created By    : Rajendra  
Created Date  : 25-Apr-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
09-June-2010 NagaBabu  Added ZipCode field to select statements
08-Dec-2010  Rathnam   Modify the second select statement condition UserProviders.UserProviderId as 
                       Users.UserId = UserProviders.ProviderUserId. 
09-Dec-2010 Rathnam    Arrange the order of the second select statement columns 
                       according to 1st select statement.                               
------------------------------------------------------------------------------          
*/  
  
CREATE PROCEDURE [dbo].[usp_CareProvider_User_SelectMore]      
(        
   @i_AppUserId KeyID,    
   @i_UserProviderId KeyID    
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
    FirstName + ' ' + MiddleName + ' ' + LastName as PrimaryCareProvider,      
    PhoneNumber As PhoneNumber,  
    PhoneNumberExt As PhoneNumberExt,  
    Fax As Fax,  
    EmailId As EmailId,      
    AddressLine1 As AddressLine1,  
    AddressLine2 As AddressLine2,  
    City As City,  
    StateCode As State,
    ZIPCode AS ZipCode 
   FROM ExternalCareProvider    WITH (NOLOCK)     
    INNER JOIN UserProviders    WITH (NOLOCK) 
    ON ExternalCareProvider.ExternalProviderId = UserProviders.ExternalProviderId    
    WHERE UserProviders.UserProviderId = @i_UserProviderId          
   UNION        
  SELECT      
    FirstName + ' ' + MiddleName + ' ' + LastName as PrimaryCareProvider,      
    PhoneNumberPrimary As PhoneNumber,  
    PhoneNumberExtensionPrimary As PhoneNumberExtensionPrimary,  
    Fax As Fax,  
    EmailIdPrimary As EmailId,
    AddressLine1 As AddressLine1,  
    AddressLine2 As AddressLine2,  
    City As City,
    State As State,      
    ZipCode AS ZipCode
    FROM Users      WITH (NOLOCK) 
       INNER JOIN UserProviders     WITH (NOLOCK)  
        ON Users.UserId = UserProviders.ProviderUserId    
   WHERE Users.IsProvider = 1  
     AND UserProviders.UserProviderId = @i_UserProviderId    
  
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
    ON OBJECT::[dbo].[usp_CareProvider_User_SelectMore] TO [FE_rohit.r-ext]
    AS [dbo];

