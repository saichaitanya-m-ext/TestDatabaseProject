/*      
------------------------------------------------------------------------------      
Procedure Name: usp_ExternalCareProvider_User_Select      
Description   : This procedure is used to get the ExternalCareProvider and     
    internal provider data (in Users table with Isprovider = 1)    
Created By    : Pramod    
Created Date  : 25-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
30-Aug-10 Pramod Included a new select with join with careteam specific tables
14-Dec-2011 NagaBabu deleted ',' from  PrimaryCareProvider field 
03-APR-2013 Mohan Modified IsExternalProvider to Provider and UserProvider to PatientProvider  Tables.   
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ExternalCareProvider_User_Select]    
(    
   @i_AppUserId KeyID,
   @i_PatientUserId KeyID
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
			PatientProvider.PatientProviderID AS UserProviderId,
			COALESCE
			(  ISNULL(Provider.LastName , '') + ' '
			 + ISNULL(Provider.FirstName , '') + ' '     
			 + ISNULL(Provider.MiddleName , '')  
			 ,''
			) AS PrimaryCareProvider,
			Provider.PrimaryEmailAddress As EmailId,
			Provider.PrimaryPhoneNumber As PhoneNumber  
	   FROM Provider   WITH (NOLOCK)   
			INNER JOIN PatientProvider  WITH (NOLOCK) 
			   ON Provider.ProviderID = PatientProvider.ProviderID
	  WHERE PatientProvider.PatientID = @i_PatientUserId			   
	    AND Provider.AccountStatusCode = 'A'
	    AND PatientProvider.StatusCode = 'A'
	    AND IsExternalProvider=1
	  UNION    
	 SELECT DISTINCT 0 AS IsExternalProvider,
			PatientProvider.PatientProviderID AS UserProviderId,
			COALESCE
			(  ISNULL(Patient.LastName , '') + ' '
			 + ISNULL(Patient.FirstName , '') + ' '     
			 + ISNULL(Patient.MiddleName , '')  
			 ,''
			) AS PrimaryCareProvider,
			Patient.PrimaryEmailAddress As EmailId,
			Patient.PrimaryPhoneNumber As PhoneNumber  
		FROM Patient   WITH (NOLOCK) 
			INNER JOIN PatientProvider WITH (NOLOCK) 
				ON Patient.PatientID = PatientProvider.PatientID
				AND Patient.PatientID = @i_PatientUserId
				AND Patient.AccountStatusCode = 'A'
				AND PatientProvider.StatusCode = 'A'
			
			LEFT JOiN PatientCareTeam WITH (NOLOCK)
				ON PatientCareTeam.PatientID=Patient.PatientID
			
			LEFT JOIN CareTeamMembers WITH (NOLOCK)
				ON CareTeamMembers.CareTeamId=PatientCareTeam.CareTeamID
		   
				AND PatientCareTeam.StatusCode = 'A'  
				AND CareTeamMembers.StatusCode = 'A'  
				 

	 --SELECT  
		--	0 AS IsExternalProvider,
		--	UserProviders.UserProviderId AS UserProviderId,
		--	FirstName + ' ' + MiddleName + ' ' + LastName as PrimaryCareProvider,  
		--	EmailIdPrimary As EmailId,  
		--	PhoneNumberPrimary As PhoneNumber  
	 --  FROM Users
	 --  		INNER JOIN UserProviders
		--	   ON Users.UserId = UserProviders.PatientUserId
	 -- WHERE Users.IsProvider = 1
	 --   AND UserProviders.PatientUserId = @i_PatientUserId
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
    ON OBJECT::[dbo].[usp_ExternalCareProvider_User_Select] TO [FE_rohit.r-ext]
    AS [dbo];

