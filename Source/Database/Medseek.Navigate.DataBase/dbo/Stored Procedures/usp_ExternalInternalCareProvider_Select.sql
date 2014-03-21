/*      
------------------------------------------------------------------------------      
Procedure Name: usp_ExternalInternalCareProvider_Select      
Description   : This procedure is used to get the ExternalCareProvider and     
    internal provider data (in Users table with Isprovider = 1)    
Created By    : Pramod    
Created Date  : 19-May-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
8-Jun-10 Pramod Commented the join with UserProvider      
30-Aug-10 Pramod Included Statuscode = 'A' in where clause
01-July-2011 NagaBabu Added PatientCount field and added 'GROUP BY', 'ORDER BY' clause and Joined with UserProviders
						Replaced IsProvider by IsPhysician
27-Sep-2011 Rathnam added Or clause IsProvider=1
23-Feb-2012 NagaBabu Modified PrimaryCareProvider field by changing the order LastName,FirstName,MiddleName						
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ExternalInternalCareProvider_Select]
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

	 SELECT TOP 50
			0 AS PatientCount ,
			1 AS IsExternalProvider,
			ExternalProviderId,
			NULL AS ProviderUserId,
			ISNULL(LastName,'') + ', ' + ISNULL(FirstName,'') + '. ' 
			+ ISNULL(MiddleName,'') as PrimaryCareProvider,  
			EmailId As  EmailId,  
			PhoneNumber As PhoneNumber  
	   FROM ExternalCareProvider    
	  WHERE StatusCode = 'A'
	 -- UNION    
	 --SELECT  TOP 50
		--	COUNT(PatientUserId) AS PatientCount ,
		--	0 AS IsExternalProvider,
		--	NULL AS ExternalProviderId,
		--	UserId AS ProviderUserId,
		--	ISNULL(LastName,'') + ', ' + ISNULL(FirstName,'') + '. ' 
		--	+ ISNULL(MiddleName,'') AS PrimaryCareProvider,  
		--	EmailIdPrimary As EmailId,  
		--	PhoneNumberPrimary As PhoneNumber  
	 --  FROM Users  WITH (NOLOCK) 
	 --   		INNER JOIN UserProviders  WITH (NOLOCK) 
		--	   ON Users.UserId = UserProviders.ProviderUserId
	 -- WHERE  (Users.IsPhysician = 1 OR Users.IsProvider = 1)
		--AND Users.UserStatusCode = 'A'
	 -- GROUP BY ProviderUserId,UserId,FirstName,MiddleName,LastName,EmailIdPrimary,PhoneNumberPrimary	
	 -- ORDER BY PatientCount DESC

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
    ON OBJECT::[dbo].[usp_ExternalInternalCareProvider_Select] TO [FE_rohit.r-ext]
    AS [dbo];

