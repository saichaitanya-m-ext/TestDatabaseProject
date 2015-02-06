/*          
------------------------------------------------------------------------------          
Procedure Name: usp_Organization_InsertUpdate          
Description   : This procedure is used to insert record into Organization table      
Created By    : Rathnam         
Created Date  : 02-Jan-2012
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION  
04-Jan-2012 NagaBabu Replaced table name OrganizationMapType changed as OrganizationWiseType and added TinNumber for 
						inser statement  
11-mAY-2012 Sivakrishna Changed the logic as per table structure changes
           (Removed table organizationWiseType and maintain the child record in same table with the parent record)
------------------------------------------------------------------------------          
*/

--DECLARE @o_OrganizationId KeyId
--DECLARE @tblOrganizationTypeID AS ttypekeyId
--INSERT INTO @tblOrganizationTypeID
--SELECT 6
--UNION 
--SELECT 25
--Exec [usp_Organization_InsertUpdate] 64,'CCM',NULL,NULL,NULL,'CCM',NULL,'CCM','AL','1111134',null,
--null,null,null,null,null,NUll,NULL,'A',@o_OrganizationId,4,@tblOrganizationTypeID
CREATE PROCEDURE [dbo].[usp_Organization_InsertUpdate]
(
 @i_AppUserId KEYID
,@v_OrganizationName SHORTDESCRIPTION
,@vc_EmailID EMAILID
,@vc_GroupNPI VARCHAR(10)
,@vc_TIN VARCHAR(10)
,@vc_AddressLine1 ADDRESS
,@vc_AddressLine2 ADDRESS
,@vc_City CITY
,@vc_State STATE
,@i_ZipCode VARCHAR(10)
,@i_MainOfficePhone PHONE
,@i_MainOfficePhoneExt PHONEEXT
,@i_AlternateOfficePhone PHONE
,@i_AlternateOfficePhoneExt PHONEEXT
,@i_AfterHoursPhone PHONE
,@i_AfterHoursPhoneExt PHONEEXT
,@i_Fax FAX
,@vc_OrganizationURL SHORTDESCRIPTION
,@vc_OrganizationStatusCode STATUSCODE
,@o_OrganizationId KEYID OUTPUT
,@i_OrganizationId KEYID = NULL
,@tblOrganizationTypeID TTYPEKEYID READONLY
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

            IF @i_OrganizationId IS NULL
               BEGIN
                     INSERT INTO
                         Organization
                         (
                           OrganizationName
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
                         ,OrganizationStatusCode
                         ,CreatedByUserId
                         ,TinNumber
                         )
                     VALUES
                         (
                           @v_OrganizationName
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
                         ,@vc_OrganizationURL
                         ,@vc_OrganizationStatusCode
                         ,@i_AppUserId 
                         ,@vc_TIN
                         )

                     SELECT
                         @l_numberOfRecordsInserted = @@ROWCOUNT
                        ,@o_OrganizationId = SCOPE_IDENTITY()

                     IF EXISTS(SELECT 
									1
							  FROM 
								@tblOrganizationTypeID
									 )
								BEGIN		 
									INSERT INTO  
										Organization  
									(  
										OrganizationTypeId ,  
										ParentOrganizationId ,  
										OrganizationStatusCode,
										CreatedByUserId 
										
									)  
									SELECT 
									
										ot.tKeyId ,  
										@o_OrganizationId ,  
										@vc_OrganizationStatusCode,
										@i_AppUserId 
									FROM 
										@tblOrganizationTypeID Ot

								   END
				END
            ELSE
               BEGIN

                     UPDATE
                         Organization
                     SET
                         OrganizationName = @v_OrganizationName
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
                        ,OrganizationURL = @vc_OrganizationURL
                        ,OrganizationStatusCode = @vc_OrganizationStatusCode
                        ,LastModifiedByUserId = @i_AppUserId
                        ,LastModifiedDate = GETDATE()
                        ,TinNumber = @vc_TIN
                     WHERE
                         OrganizationId = @i_OrganizationId


					IF EXISTS(SELECT 
									1
							  FROM 
								@tblOrganizationTypeID
							 )
						BEGIN
							
							UPDATE Organization SET OrganizationStatusCode = 'I'
							 WHERE  EXISTS(
							                SELECT
													 1
											   FROM 
												  @tblOrganizationTypeID
										  )
							   				   	
							  AND ParentOrganizationId = @i_OrganizationId
							  AND OrganizationName IS NULL
							   
							INSERT INTO  
									Organization  
									(  
										OrganizationTypeId ,  
										ParentOrganizationId ,  
										OrganizationStatusCode,
										CreatedByUserId 
										
									)  
									SELECT 
									    ot.tKeyId ,  
										@i_OrganizationId ,  
										@vc_OrganizationStatusCode,
										@i_AppUserId 
									FROM 
										@tblOrganizationTypeID Ot
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
    ON OBJECT::[dbo].[usp_Organization_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

