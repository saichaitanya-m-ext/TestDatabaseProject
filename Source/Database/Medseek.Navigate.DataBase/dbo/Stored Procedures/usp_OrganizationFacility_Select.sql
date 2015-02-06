/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_OrganizationFacility_Select]          
Description   : This procedure is used to Get the usp_OrganizationFacility_Select and their dependentents     
Created By    : Rathnam         
Created Date  : 03-Jan-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION   
04-Jan-2012 NagaBabu Replaced OrganizationMapTypeID by OrganizationWiseTypeID while field name is changed in OrganizationFacility          
11-jan-2012 Sivakrishna added join condintion with table state for getting the state Name
30-Jan-2012 NagaBabu Removed CareTeamId,CareTeamName Fields while these field are removed from OrganizationFacilityProvider table 
------------------------------------------------------------------------------          
*/
--[usp_OrganizationFacility_Select] 23,4
CREATE PROCEDURE [dbo].[usp_OrganizationFacility_Select]
(
 @i_AppUserID KEYID
,@i_OrganizationFacilityID KEYID 
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
                        ofy.OrganizationId AS OrganizationFacilityID,
						ofy.ParentOrganizationId AS OrganizationWiseTypeID,
						ofy.OrganizationName AS FacilityName,
						ofy.EmailID,
						ofy.GroupNPI,
						ofy.AddressLine1,
						ofy.AddressLine2,
						ofy.City,
						St.Name AS State,
						ofy.ZipCode,
						ofy.MainOfficePhone,
						ofy.MainOfficePhoneExt, 
						ofy.AlternateOfficePhone,
						ofy.AlternateOfficePhoneExt,
						ofy.AfterHoursPhone,
						ofy.AfterHoursPhoneExt,
						ofy.Fax,
						ofy.OrganizationURL AS FacilityURL,
						ofy.TinNumber,
						ofy.OrganizationStatusCode AS StatusCode,
						ofy.CreatedByUserId,
						ofy.CreatedDate,
						ofy.LastModifiedByUserId,
						ofy.LastModifiedDate
                     FROM
                         Organization ofy WITH(NOLOCK)
					 LEFT JOIN State St WITH(NOLOCK)
					    ON ofy.State = St.StateCode
                     WHERE
                         ofy.OrganizationId = @i_OrganizationFacilityID
                         AND ofy.OrganizationStatusCode= 'A'

                     SELECT
                         Ou.OrganizationUserId OrganizationFacilityProviderID,
						org.OrganizationId AS OrganizationFacilityID,
						ou.ProviderUserId  AS ProviderId,
						dbo.ufn_GetUserNameByID(ou.ProviderUserId) ProviderName,
						ou.CreatedByUserId,
						ou.CreatedDate
                     FROM
                         OrganizationUser ou WITH(NOLOCK)
                     INNER JOIN Organization org WITH(NOLOCK)
						ON ou.OrganizationID = org.OrganizationId
                     WHERE
                         ou.OrganizationID = @i_OrganizationFacilityID
                         AND org.OrganizationStatusCode = 'A'
                         
                    
                      SELECT
						ou.ProviderUserId AS ProviderId,
						dbo.ufn_GetUserNameByID(ou.ProviderUserId) ProviderName
                     FROM
                         OrganizationUser ou WITH(NOLOCK)
                     INNER JOIN Organization org WITH(NOLOCK)
                        ON ou.OrganizationID = org.OrganizationID
                     WHERE
                         org.OrganizationID = @i_OrganizationFacilityID
                         AND org.organizationStatusCode = 'A'
                         
				----------Organization Care team---------------
                     
                      SELECT
                         Oc.OrganizationCareTeamId
                        ,org.OrganizationId
                         ,oc.CareTeamId  AS CareTeamId
						,ct.CareTeamName AS CareTeam
						,Org.CreatedByUserId
						,org.CreatedDate
                     FROM
                         OrganizationCareTeam oc WITH(NOLOCK)
                     INNER JOIN Organization org WITH(NOLOCK)
						ON oc.OrganizationID = org.OrganizationId
					 INNER JOIN CareTeam ct WITH(NOLOCK)
						ON oc.Careteamid = ct.CareTeamId
                     WHERE
                         org.OrganizationID = @i_OrganizationFacilityID
                         AND org.OrganizationStatusCode = 'A'
                     
                    SELECT
						oc.CareTeamId,
						ct.CareTeamName AS CareTeam
                     FROM
                         OrganizationCareTeam oc WITH(NOLOCK)
                     INNER JOIN Organization org WITH(NOLOCK)
                        ON oc.OrganizationID = org.OrganizationID
                     INNER JOIN CareTeam ct WITH(NOLOCK)
                         On oc.careteamId = ct.CareTeamId
                     WHERE
                         org.OrganizationID = @i_OrganizationFacilityID
                         AND org.organizationStatusCode = 'A'

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
    ON OBJECT::[dbo].[usp_OrganizationFacility_Select] TO [FE_rohit.r-ext]
    AS [dbo];

