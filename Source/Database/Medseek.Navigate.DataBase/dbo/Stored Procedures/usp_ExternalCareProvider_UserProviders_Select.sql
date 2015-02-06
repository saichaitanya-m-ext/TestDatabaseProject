/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ExternalCareProvider_UserProviders_Select    
Description   : This procedure is used to get the details from ExternalCareProvider   
    and UserProviders table   
Created By    : Aditya    
Created Date  : 25-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
14-Dec-2011 NagaBabu Changed CareProvider field Format      
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_ExternalCareProvider_UserProviders_Select]
(
 @i_AppUserId KEYID
,@i_PatientUserId KEYID = NULL
,@v_StatusCode STATUSCODE = NULL
)
AS
BEGIN TRY
    SET NOCOUNT ON     
-- Check if valid Application User ID is passed  

    IF ( @i_AppUserId IS NULL )
    OR ( @i_AppUserId <= 0 )
       BEGIN
             RAISERROR ( N'Invalid Application User ID %d passed.'
             ,17
             ,1
             ,@i_AppUserId )
       END
    SELECT
        '' AS ExternalProvider
       , '' UserProviderId
       ,'' PatientUserId
       ,'' ExternalProviderId
       ,'' ProviderUserId
       ,'' Comments
       ,'' EmailId
       ,'' AS CareProvider
       ,'' PhoneNumber
       ,'' PhoneNumberExt
       ,'' CreatedByUserId
       ,'' CreatedDate
       ,'' LastModifiedByUserId
       ,'' LastModifiedDate
       ,'' StatusDescription
    --FROM
    --    ExternalCareProvider  WITH (NOLOCK) 
    --INNER JOIN PatientProvider  WITH (NOLOCK) 
    --    ON UserProviders.ExternalProviderId = ExternalCareProvider.ExternalProviderId
    --WHERE
    --    ( UserProviders.PatientUserId = @i_PatientUserId
    --    OR @i_PatientUserId IS NULL
    --    )
    --    AND ( @v_StatusCode IS NULL
    --          OR UserProviders.StatusCode = @v_StatusCode
    --        )
    --UNION
    --SELECT TOP 50
    --    'No' AS ExternalProvider
    --   ,UserProviders.UserProviderId
    --   ,UserProviders.PatientUserId
    --   ,UserProviders.ExternalProviderId
    --   ,UserProviders.ProviderUserId
    --   ,UserProviders.Comments
    --   ,Users.EmailIdPrimary
    --   ,ISNULL(Users.LastName,'') + ' ' + ISNULL(Users.FirstName,'') + ' ' + ISNULL(Users.MiddleName,'') AS CareProvider
    --   ,Users.PhoneNumberPrimary
    --   ,Users.PhoneNumberExtensionPrimary
    --   ,UserProviders.CreatedByUserId
    --   ,UserProviders.CreatedDate
    --   ,UserProviders.LastModifiedByUserId
    --   ,UserProviders.LastModifiedDate
    --   ,CASE UserProviders.StatusCode
    --      WHEN 'A' THEN 'Active'
    --      WHEN 'I' THEN 'InActive'
    --      ELSE ''
    --    END AS StatusDescription
    --FROM
    --    UserProviders  WITH (NOLOCK) 
    --INNER JOIN Users  WITH (NOLOCK) 
    --    ON UserProviders.ProviderUserId = Users.UserId
    --       AND Users.IsProvider = 1
    --WHERE
    --    ( UserProviders.PatientUserId = @i_PatientUserId
    --    OR @i_PatientUserId IS NULL
    --    )
    --    AND ( @v_StatusCode IS NULL
    --          OR UserProviders.StatusCode = @v_StatusCode
    --        )
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
    ON OBJECT::[dbo].[usp_ExternalCareProvider_UserProviders_Select] TO [FE_rohit.r-ext]
    AS [dbo];

