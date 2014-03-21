/*
-------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_User_Profile_Select_Wrapper]2,29
Description	  : All the User Profile  dropdown SP's are executed through this wrapper. 
Created By    :	P.V.P.Mohan
Created Date  : 23-Jan-2012
--------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

--------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_User_Profile_Select_Wrapper]
(
 @i_AppUserId KEYID,
 @i_UserId KEYID  
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

			--EXEC USP_SPECIALITY_SELECT_DD @i_AppUserId
			--EXEC usp_Language_Select_DD   @i_AppUserId
			--EXEC usp_InsuranceGroup_Select @i_AppUserId
			EXEC usp_State_Select_DD @i_AppUserId
			EXEC usp_Race_Select_DD @i_AppUserId
			--EXEC usp_CareTeam_Select_DD @i_AppUserId
			EXEC usp_CallTimePreference_Select_DD @i_AppUserId
			EXEC usp_Ethnicity_Select_DD @i_AppUserId
			EXEC usp_CommunicationType_Select_All @i_AppUserId
			EXEC usp_NamePrefix_Select_DD @i_AppUserId
			EXEC usp_NameSuffix_Select_DD @i_AppUserId
			EXEC usp_ProfessionalType_Select_DD @i_AppUserId
			EXEC usp_SecurityRole_Select_DD @i_AppUserId
			/*
		    EXEC usp_UsersSecurityRoles_Select_ByUserId   
				   @i_AppUserId = @i_AppUserId,    
				   @i_UserId = @i_UserId  
				   */
			--EXEC usp_ExternalInternalCareProvider_Select @i_AppUserId
            EXEC usp_BloodTypes_Select_DD @i_AppUserId
            EXEC usp_UserStatus_Select_DD @i_AppUserId
       --     EXEC USP_USERSPECIALITYLANGUAGE_SEARCHBYUSERID
				   --@i_AppUserId = @i_AppUserId,   
       --            @i_UserId = @i_UserId  
            EXEC usp_Country_Select_DD  @i_AppUserId
            EXEC usp_MaritalStatus_Select_DD  @i_AppUserId
            EXEC usp_PCPName_Select_DD  @i_AppUserId
            EXEC usp_Relation_Select_DD  @i_AppUserId
            EXEC usp_AddressType_Select_DD  @i_AppUserId
            EXEC usp_EmailAddressType_Select_DD  @i_AppUserId
            EXEC usp_PhoneType_Select_DD  @i_AppUserId
            EXEC usp_County_Select_DD  @i_AppUserId
            EXEC usp_ProviderRole_Select_DD  @i_AppUserId
            EXEC usp_EmploymentStatus_Select_DD  @i_AppUserId
            /*
            EXEC usp_ExternalCareProvider_UserProviders_Select
                   @i_AppUserId = @i_AppUserId,  
                   @i_PatientUserId  = @i_UserId ,
                   @v_StatusCode ='A'
                   */
                   
            SELECT ProviderTypeCodeID ProviderTypeId, ProviderTypeCode ProviderTypeCode, Description FROM CodesetProviderType WHERE StatusCode = 'A'
END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_User_Profile_Select_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

