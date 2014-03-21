/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_Organization_CheckMappings]         
Description   : This procedure is used to Check for the dependents for organization Types  to the perticular organization  
Created By    : Rathnam         
Created Date  : 02-Jan-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION
04-Jan-2012 NagaBabu Replaced OrganizationMapTypeID by OrganizationWiseTypeID while field name is changed in OrganizationFacility         
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_Organization_CheckMappings]
(
 @i_AppUserID KEYID
,@i_OrganizationWiseTypeID KEYID = NULL
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
            DECLARE @b_IsFacilities BIT

            SELECT TOP 1
                @b_IsFacilities = 1
            FROM
                OrganizationFacility
            WHERE
                OrganizationWiseTypeID = @i_OrganizationWiseTypeID

            SELECT
                ISNULL(@b_IsFacilities , 0)
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
    ON OBJECT::[dbo].[usp_Organization_CheckMappings] TO [FE_rohit.r-ext]
    AS [dbo];

