/*  
------------------------------------------------------------------------------  
Procedure Name: usp_OrganizationUser_Select  
Description   : This procedure is used to get the details from OrganizationUser,
				Organization and Users table 
Created By    : Aditya  
Created Date  : 08-Apr-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_OrganizationUser_Select]
(
 @i_AppUserId KEYID ,
 @i_UserId KEYID = NULL,
 @i_OrganizationUserId KEYID = NULL, 
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

      SELECT OrganizationUser.OrganizationUserId,
			 OrganizationUser.OrganizationId,
			 Organization.OrganizationName,
			 Organization.IsClinic,
			 OrganizationUser.ProviderUserId UserId,
			 OrganizationUser.StatusCode,
			 OrganizationUser.isPrimary,
			 OrganizationUser.Comments,
			 OrganizationUser.CreatedByUserId,
			 OrganizationUser.CreatedDate,
			 OrganizationUser.LastModifiedByUserId,
			 OrganizationUser.LastModifiedDate,
			 CASE OrganizationUser.StatusCode
				WHEN 'A' THEN 'Active'
				WHEN 'I' THEN 'InActive'
				ELSE ''
			 END AS StatusDescription
       FROM
            OrganizationUser WITH(NOLOCK)
				INNER JOIN Organization WITH(NOLOCK)
					ON Organization.OrganizationId = OrganizationUser.OrganizationId
	 WHERE ( OrganizationUser.ProviderUserId = @i_UserId OR @i_UserId IS NULL )
            AND ( OrganizationUser.OrganizationUserId = @i_OrganizationUserId OR @i_OrganizationUserId IS NULL )
            AND ( OrganizationUser.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL  ) 
            AND ( Organization.IsClinic = 1 )      
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
    ON OBJECT::[dbo].[usp_OrganizationUser_Select] TO [FE_rohit.r-ext]
    AS [dbo];

