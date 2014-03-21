/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_Organization_Select]          
Description   : This procedure is used to Get the organizations and their dependentents     
Created By    : Rathnam         
Created Date  : 02-Jan-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
04-Jan-2012 NagaBabu Replaced table name OrganizationMapType changed as OrganizationWiseType
11-Jan-2012 NagaBabu State field is Modified to statename from statecode, for this Organization table joined with 
						state table.
12-Jan-2012 NagaBabu Removed all statuscodes in where clause						              
------------------------------------------------------------------------------          
*/
--[usp_Organization_Select] 23,4
CREATE PROCEDURE [dbo].[usp_Organization_Select]
(
 @i_AppUserID KEYID
,@i_OrganizationID KEYID
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
                         o.OrganizationId
                        ,o.OrganizationName
                        ,o.EmailID
                        ,o.GroupNPI
                        ,o.AddressLine1
                        ,o.AddressLine2
                        ,o.City
                        ,S.Name AS [State]
                        ,o.ZipCode
                        ,o.MainOfficePhone
                        ,o.MainOfficePhoneExt
                        ,o.AlternateOfficePhone
                        ,o.AlternateOfficePhoneExt
                        ,o.AfterHoursPhone
                        ,o.AfterHoursPhoneExt
                        ,o.Fax
                        ,o.OrganizationURL
                        ,o.CreatedByUserId
                        ,o.CreatedDate
                        ,o.LastModifiedByUserId
                        ,o.LastModifiedDate
                        ,o.OrganizationStatusCode
                        ,o.TinNumber
                     FROM
                         Organization o WITH(NOLOCK)
                     LEFT JOIN State S WITH(NOLOCK)
						 ON S.StateCode = o.[State]    
                     WHERE
                         o.OrganizationId = @i_OrganizationID
                         --AND o.OrganizationStatusCode = 'A'

					SELECT DISTINCT 
						 org.OrganizationId 
						,o.OrganizationId AS OrganizationWiseTypeID
						,org.OrganizationTypeId AS OrganizationTypeId
						,ot.Description OrganizationType
						,0 AS TypeCount 
						-- ,(SELECT COUNT(ofy.OrganizationFacilityID) FROM OrganizationFacility ofy WHERE ofy.OrganizationWiseTypeID = omp.OrganizationWiseTypeID) TypeCount 
					FROM
						Organization o WITH(NOLOCK)
					LEFT JOIN Organization org WITH(NOLOCK)
					   ON o.OrganizationId = org.ParentOrganizationId
					LEFT JOIN Organization orga WITH(NOLOCK)
					   ON org.OrganizationId = orga.ParentOrganizationId
					LEFT JOIN OrganizationType ot WITH(NOLOCK)
					   ON ot.OrganizationTypeID = org.OrganizationTypeId
					WHERE o.OrganizationStatusCode = 'A'
					  AND ot.StatusCode = 'A'
					  AND   o.ParentOrganizationId IS NULL
					ORDER BY  o.OrganizationId,org.OrganizationId ,org.OrganizationTypeId,ot.Description

                     --SELECT
                     --    omt.OrganizationWiseTypeID
                     --   ,omt.OrganizationTypeId
                     --FROM
                     --    Or omt
                     --INNER JOIN Organization o
                     --    ON o.OrganizationId = omt.OrganizationId
                     --INNER JOIN OrganizationType otp
                     --    ON otp.OrganizationTypeID = omt.OrganizationTypeId
                     --WHERE
                     --    o.OrganizationId = @i_OrganizationID
                     --    --AND o.OrganizationStatusCode = 'A'
                     --    --AND omt.StatusCode = 'A'
                     --    --AND otp.StatusCode = 'A'

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
    ON OBJECT::[dbo].[usp_Organization_Select] TO [FE_rohit.r-ext]
    AS [dbo];

