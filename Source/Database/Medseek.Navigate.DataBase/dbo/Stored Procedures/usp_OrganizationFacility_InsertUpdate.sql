/*          
------------------------------------------------------------------------------          
Procedure Name: usp_OrganizationFacility_InsertUpdate          
Description   : This procedure is used to insert record into Organization table      
Created By    : Rathnam         
Created Date  : 02-Jan-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
04-Jan-2012 NagaBabu Replaced OrganizationMapTypeID by OrganizationWiseTypeID while field name is changed in OrganizationFacility          
14-May-2012 Sivakrishna Added logic for careteam and changed logic as per organization Desighn changes.
           (Changed OrganizationFacilityProvider table to OrganizationUser And added organizationcareTeam Table
           To maintain organization Careteams)
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_OrganizationFacility_InsertUpdate]
(
 @i_AppUserId KEYID
,@i_OrganizationWiseTypeID KEYID
,@vc_FacilityName SHORTDESCRIPTION
,@vc_EmailID EMAILID
,@vc_GroupNPI VARCHAR(10)
,@vc_TIN VARCHAR(10)
,@vc_AddressLine1 ADDRESS
,@vc_AddressLine2 ADDRESS
,@vc_City CITY
,@vc_State STATE
,@i_ZipCode ZIPCODE
,@i_MainOfficePhone PHONE
,@i_MainOfficePhoneExt PHONEEXT
,@i_AlternateOfficePhone PHONE
,@i_AlternateOfficePhoneExt PHONEEXT
,@i_AfterHoursPhone PHONE
,@i_AfterHoursPhoneExt PHONEEXT
,@i_Fax FAX
,@vc_FacilityURL SHORTDESCRIPTION
,@vc_StatusCode STATUSCODE
,@o_OrganizationFacilityID KEYID OUTPUT
,@i_OrganizationFacilityID KEYID = NULL
,@tblProviderID TTYPEKEYID READONLY
--,@tblCareTeamId TTypeKeYId READONLY
,@b_IsProvider BIT 
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON
            DECLARE @l_numberOfRecordsInserted INT  
 -- Check if valid Application User ID is passed          
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END        
  
 ------------------------------insert operation into Organization table-----  
            DECLARE @l_TranStarted BIT = 0
            IF ( @@TRANCOUNT = 0 )
               BEGIN
                     BEGIN TRANSACTION
                     SET @l_TranStarted = 1  -- Indicator for start of transactions
               END
            ELSE
               BEGIN
                     SET @l_TranStarted = 0
               END

			IF @i_OrganizationFacilityID IS NULL
               BEGIN
                     INSERT 
                         Organization
                         (
							 OrganizationName
							,ParentOrganizationId
							,EmailID
							,GroupNPI
							,AddressLine1
							,AddressLine2
							,City
							,State
							,ZipCode
							,MainOfficePhone
							,MainOfficePhoneExt
							,AlternateOfficePhone
							,AlternateOfficePhoneExt
							,AfterHoursPhone
							,AfterHoursPhoneExt
							,Fax
							,OrganizationURL
							,CreatedByUserId
							,OrganizationStatusCode
							    )
                       SELECT 
							  @vc_FacilityName
							 ,@i_OrganizationWiseTypeID
							 ,@vc_EmailID
							 ,@vc_GroupNPI
							 ,@vc_AddressLine1
							 ,@vc_AddressLine2
							 ,@vc_City
							 ,@vc_State
							 ,@i_ZipCode
							 ,@i_MainOfficePhone
							 ,@i_MainOfficePhoneExt
							 ,@i_AlternateOfficePhone
							 ,@i_AlternateOfficePhoneExt
							 ,@i_AfterHoursPhone
							 ,@i_AfterHoursPhoneExt
							 ,@i_Fax
							 ,@vc_FacilityURL
							 ,@i_AppUserId
							 ,@vc_StatusCode
	                         

                     SELECT
                         @o_OrganizationFacilityID = SCOPE_IDENTITY()
					
				 IF EXISTS(SELECT 
								1
						    FROM 
							   @tblProviderID
						   )
					BEGIN
					   IF @b_IsProvider = 1
						
						 BEGIN    
								INSERT INTO
                                  OrganizationUser
                                  (
                                   OrganizationId
                                  ,ProviderUserId
                                  ,CreatedByUserId
                                  )
                                  SELECT
                                      @o_OrganizationFacilityID
                                     ,tKeyId
                                     ,@i_AppUserId
                                  FROM
                                      @tblProviderID
                         END
                         
						 ELSE 
						   
						    BEGIN
						
								 INSERT OrganizationCareTeam
									(OrganizationId
									 ,CareTeamId
									 ,CreatedByUserId
									)
								 SELECT 
									 @o_OrganizationFacilityID
									 ,tKeyId
									 ,@i_AppUserId
								 FROM 
									@tblProviderID
                           END
					END 
            END
            ELSE
               BEGIN

                     UPDATE
                         Organization
                      SET
                        OrganizationName  = @vc_FacilityName
                        ,EmailID = @vc_EmailID
                        ,GroupNPI = @vc_GroupNPI
                        ,AddressLine1 = @vc_AddressLine1
                        ,AddressLine2 = @vc_AddressLine2
                        ,City = @vc_City
                        ,State = @vc_State
                        ,ZipCode = @i_ZipCode
                        ,MainOfficePhone = @i_MainOfficePhone
                        ,MainOfficePhoneExt = @i_MainOfficePhoneExt
                        ,AlternateOfficePhone = @i_AlternateOfficePhone
                        ,AlternateOfficePhoneExt = @i_AlternateOfficePhoneExt
                        ,AfterHoursPhone = @i_AfterHoursPhone
                        ,AfterHoursPhoneExt = @i_AfterHoursPhoneExt
                        ,Fax = @i_Fax
                        ,OrganizationURL= @vc_FacilityURL
                        ,OrganizationStatusCode = @vc_StatusCode
                        ,LastModifiedByUserId = @i_AppUserId
                        ,LastModifiedDate = GETDATE()
                     WHERE
                         OrganizationId = @i_OrganizationFacilityId

						 IF EXISTS(SELECT 
										1
								  FROM 
									 @tblProviderID
								  )
							 BEGIN
							     IF @b_IsProvider = 1
									
									BEGIN
									 
										  DELETE  FROM
												  OrganizationUser
										  WHERE
												  OrganizationId = @i_OrganizationFacilityId
		                                     
										  INSERT INTO
											  OrganizationUser
											  (
												OrganizationId
											   ,ProviderUserId
											   ,CreatedByUserId
											   )
										  SELECT
												  @i_OrganizationFacilityID
												 ,tKeyId
												 ,@i_AppUserId
										   FROM
											  @tblProviderID
									END
						 
									ELSE
										BEGIN

											DELETE  FROM
													  OrganizationCareTeam
											  WHERE
													  OrganizationId = @i_OrganizationFacilityId
				                                     
											  INSERT INTO
												  OrganizationCareTeam
												  (
													OrganizationId
												   ,CareTeamId
												   ,CreatedByUserId
												  )
											  SELECT
													  @i_OrganizationFacilityID
													 ,tKeyId
													 ,@i_AppUserId
											   FROM
												  @tblProviderID
										 END
								END
			END	

            IF ( @l_TranStarted = 1 )  -- If transactions are there, then commit
               BEGIN
                     SET @l_TranStarted = 0
                     COMMIT TRANSACTION
               END
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
    ON OBJECT::[dbo].[usp_OrganizationFacility_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

