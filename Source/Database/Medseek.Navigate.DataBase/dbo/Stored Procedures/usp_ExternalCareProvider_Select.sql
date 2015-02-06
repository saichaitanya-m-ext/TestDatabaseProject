/*  
------------------------------------------------------------------------------  
Procedure Name: usp_ExternalCareProvider_Select  
Description   : This procedure is used to get the details from ExternalCareProvider table 
Created By    : Aditya  
Created Date  : 25-Mar-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
09-Jun-2010 Ratnam Added ZIPCode field for select statement.
  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_ExternalCareProvider_Select]
(
 @i_AppUserId KEYID ,
 @i_ExternalProviderId KEYID = NULL,
 @v_StatusCode StatusCode = NULL
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
			  ExternalProviderId ,
			  isnull(FirstName , '') + '' + isnull(MiddleName , '') + '' + isnull(LastName , '') AS PrimaryCareProvider ,
			  AddressLine1 ,
			  AddressLine2 ,
			  City ,
			  StateCode ,
			  PhoneNumber ,
			  PhoneNumberExt ,
			  EmailId ,
			  Fax ,
			  CreatedByUserId ,
			  CreatedDate ,
			  LastModifiedByUserId ,
			  LastModifiedDate ,
			  CASE StatusCode
				WHEN 'A' THEN 'Active'
				WHEN 'I' THEN 'InActive'
				ELSE ''
			  END AS StatusDescription,
			  ZIPCode
       FROM
            ExternalCareProvider WITH(NOLOCK)
      WHERE
            ( ExternalProviderId = @i_ExternalProviderId
             OR @i_ExternalProviderId IS NULL )
        AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )          
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
    ON OBJECT::[dbo].[usp_ExternalCareProvider_Select] TO [FE_rohit.r-ext]
    AS [dbo];

