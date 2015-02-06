/*      
------------------------------------------------------------------------------      
Procedure Name: usp_ExternalCareProvider_Insert      
Description   : This procedure is used to insert record into ExternalCareProvider table  
Created By    : Aditya      
Created Date  : 06-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
09-Jun-2010 Rathnam Added ZIPCode filed for insert statement.  
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ExternalCareProvider_Insert]    
(    
 @i_AppUserId KeyID,  
 @vc_FirstName SourceName,  
 @vc_MiddleName SourceName,  
 @vc_LastName SourceName,  
 @vc_AddressLine1 Address,  
 @vc_AddressLine2 Address,  
 @vc_City City,  
 @vc_StateCode State,  
 @vc_PhoneNumber Phone,  
 @vc_PhoneNumberExt PhoneExt,  
 @vc_EmailId EmailId,  
 @vc_Fax Fax,  
 @vc_StatusCode StatusCode,  
 @vc_ZIPCode ZipCode,  
 @o_ExternalProviderId KeyID OUTPUT  
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
  
 INSERT INTO Provider  
  (   
   FirstName,  
   MiddleName,  
   LastName,  
   PrimaryAddressLine1,  
   PrimaryAddressLine2,  
   PrimaryAddressCity,  
   PrimaryAddressStateCodeID,  
   PrimaryPhoneNumber,  
   PrimaryPhoneNumberExtension,  
   PrimaryEmailAddress,  
   TertiaryPhoneNumber,  
   AccountStatusCode,  
   CreatedByUserId,  
   PrimaryAddressPostalCode ,
   IsExternalProvider ,
   IsIndividual,
   IsCareProvider
    )  
 VALUES  
    (   
   @vc_FirstName,  
   @vc_MiddleName,  
   @vc_LastName,  
   @vc_AddressLine1,  
   @vc_AddressLine2,  
   @vc_City,  
   @vc_StateCode,  
   @vc_PhoneNumber,  
   @vc_PhoneNumberExt,  
   @vc_EmailId,  
   @vc_Fax,  
   @vc_StatusCode,  
   @i_AppUserId,  
   @vc_ZIPCode  ,
   1,
   1,0
    )  
       
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT  
          ,@o_ExternalProviderId = SCOPE_IDENTITY()  
        
    IF @l_numberOfRecordsInserted <> 1            
 BEGIN            
  RAISERROR        
   (  N'Invalid row count %d in insert ExternalCareProvider'  
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ExternalCareProvider_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

