/*          
--------------------------------------------------------------------------          
Procedure Name: [usp_OrganizationTree_Select]          
Description   : This procedure is used to Get the organizations and their dependentents     
Created By    : Rathnam         
Created Date  : 02-Jan-2012
--------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
04-Jan-2012 Replaced OrganizationMapTypeID by OrganizationWiseTypeID while field name is changed in OrganizationFacility          
								and Table name OrganizationMapType changed as OrganizationWiseType 
12-Jan-20112 NagaBabu Added @vc_StatusCode as input Parameter								       
--------------------------------------------------------------------------          
*/ 

--[usp_OrganizationTree_Select] 23
CREATE PROCEDURE [dbo].[usp_OrganizationTree_Select]
(
 @i_AppUserID KEYID
,@vc_StatusCode StatusCode = 'A'   
)
AS
BEGIN TRY
            SET NOCOUNT ON
            DECLARE @l_numberOfRecordsInserted INT  
  --Check if valid Application User ID is passed          
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END        
  
            
            SELECT 1 GroupID,'Symphony CareSolutions' OrganizationGroup
            
            SELECT
                1 GroupID
               ,OrganizationId
               ,OrganizationName
               ,CASE OrganizationStatusCode 
					WHEN 'A' THEN 'Active'
					WHEN 'I' THEN 'InActive'
				END AS OrganizationStatusCode 	 
            FROM
                Organization WITH(NOLOCK)
            WHERE
                OrganizationStatusCode = @vc_StatusCode OR @vc_StatusCode = 'I'
               AND ParentOrganizationId IS NULL
            ORDER BY OrganizationId ASC 
             
            SELECT DISTINCT 
                 o.OrganizationId
                 ,org.OrganizationId  AS OrganizationWiseTypeID
                ,org.OrganizationTypeId AS OrganizationTypeId
                ,ot.OrganizationType OrganizationType
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
             WHERE
               o.OrganizationStatusCode = 'A'
              AND ot.StatusCode = 'A'
              AND   o.ParentOrganizationId IS NULL
              ORDER BY  o.OrganizationId,org.OrganizationId ,org.OrganizationTypeId,ot.OrganizationType
             
             SELECT DISTINCT 
				  orgff.OrganizationId AS OrganizationFacilityID
                 ,orgtf.OrganizationId  AS OrganizationWiseTypeID
                 ,orgff.OrganizationName AS FacilityName
         
		     FROM
			     Organization orgt WITH(NOLOCK)
			     LEFT JOIN Organization orgtf WITH(NOLOCK)
					ON orgt.OrganizationId = orgtf.ParentOrganizationId
			     LEFT JOIN Organization orgff WITH(NOLOCK)
			     ON orgff.ParentOrganizationId = orgtf.OrganizationId
		     WHERE
			     orgtf.OrganizationStatusCode = 'A'
			     AND orgff.OrganizationStatusCode = 'A'
			     AND orgff.ParentOrganizationId IS NOT NULL
			     AND orgff.OrganizationName IS NOT NULL
              ORDER BY  orgtf.OrganizationId ,orgff.OrganizationId  ,orgff.OrganizationName
              
			 
			  SELECT DISTINCT 
			      orgff.OrganizationId AS OrganizationFacilityID
			      ,ou.OrganizationUserId AS OrganizationFacilityProviderID
			      ,Ou.ProviderUserId AS ProviderId
                 ,dbo.ufn_GetUserNameByID(Ou.ProviderUserId) ProviderName
         
		     FROM
			     Organization orgt WITH(NOLOCK)
			     LEFT JOIN Organization orgtf WITH(NOLOCK)
					ON orgt.OrganizationId = orgtf.ParentOrganizationId
			     LEFT JOIN Organization orgff WITH(NOLOCK)
			     ON orgff.ParentOrganizationId = orgtf.OrganizationId
			     LEFT JOIN OrganizationUser Ou WITH(NOLOCK)
			        ON orgff.OrganizationId = Ou.OrganizationId
		     WHERE
			     orgtf.OrganizationStatusCode = 'A'
			     AND orgff.OrganizationStatusCode = 'A'
			     AND orgff.ParentOrganizationId IS NOT NULL
			     AND orgff.OrganizationName IS NOT NULL
              ORDER BY  orgff.OrganizationId ,
						ou.OrganizationUserId ,
						Ou.ProviderUserId 
						
END TRY
-------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH          
 -- Handle exception          
    DECLARE @i_ReturnedErrorID INT
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

    RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_OrganizationTree_Select] TO [FE_rohit.r-ext]
    AS [dbo];

