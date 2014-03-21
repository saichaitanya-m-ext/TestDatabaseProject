/*  
------------------------------------------------------------------------------  
Procedure Name: usp_CareProvider_Select
Description   : This procedure is used to get the id and name from ExternalCareProvider 
				and UserProviders table 
Created By    : Pramod
Created Date  : 08-Apr-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
14-Dec-2011 NagaBabu Changed CareProviderName field Format  
07-Feb-2013 Rathnam commented the ExternalCareProvider select statement for Wellpoint
25-Mar-2013 P.V.P.MOhan Modified PatientID in place of UserID  and modified Users table to Patient and UserProvider 
			to PatientProvider
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CareProvider_Select]-- 42,null
(
	@i_AppUserId KeyID,
	@i_PatientUserId KeyID = NULL
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
    /*
 	 SELECT 'Y' AS ExternalProvider,
 			UserProviders.UserProviderId,
 			COALESCE(ISNULL(ExternalCareProvider.LastName,'') + ' ' 
 			  + ISNULL(ExternalCareProvider.FirstName,'') + ' ' 
 			  + ISNULL(ExternalCareProvider.MiddleName,''),'') AS CareProviderName
	  FROM  UserProviders WITH (NOLOCK)
			INNER JOIN ExternalCareProvider WITH (NOLOCK)
			   ON UserProviders.ExternalProviderId = ExternalCareProvider.ExternalProviderId
	  WHERE ( UserProviders.PatientUserId = @i_PatientUserId 
	         OR @i_PatientUserId IS NULL
	        )
	    AND UserProviders.StatusCode = 'A'

	  UNION
     */
	    
	SELECT DISTINCT TOP 50
         'N' AS ExternalProvider,
		PatientProvider.ProviderID UserProviderId,
		COALESCE(ISNULL(provider.LastName,'') + ' ' 
      + ISNULL(provider.FirstName,'') + ' ' 
      + ISNULL(provider.MiddleName,''),'') AS CareProviderName
    FROM PatientProvider WITH (NOLOCK)
         INNER JOIN Provider WITH (NOLOCK)
            ON PatientProvider.ProviderID = Provider.ProviderID
    WHERE ( PatientProvider.PatientID = @i_PatientUserId 
            OR @i_PatientUserId IS NULL
          )
     AND PatientProvider.StatusCode = 'A'
     AND PatientProvider.ServiceDateEnd IS NULL
	    
	    
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
    ON OBJECT::[dbo].[usp_CareProvider_Select] TO [FE_rohit.r-ext]
    AS [dbo];

