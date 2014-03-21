/*          
------------------------------------------------------------------------------          
Procedure Name: usp_Organization_Facility_Select
Description   : This Proc is used to fecth the orginzation list from the provider table
Created By    : Rathnam
Created Date  : 04-April-2013
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_Organization_Facility_Select]
(
 @i_AppUserID KEYID
)
AS
BEGIN
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
                p.ProviderID FacilityId
               ,p.OrganizationName FacilityName
            FROM
                Provider p
            INNER JOIN CodeSetProviderType pt
                ON p.ProviderTypeID = pt.ProviderTypeCodeID
            WHERE
                OrganizationName IS NOT NULL
                AND pt.Description = 'Clinic'
                AND p.AccountStatusCode = 'A'
                AND pt.StatusCode = 'A'
      END TRY
-----------------------------------------------------------------------------------------------------------------------------------      
      BEGIN CATCH          
    -- Handle exception          
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Organization_Facility_Select] TO [FE_rohit.r-ext]
    AS [dbo];

