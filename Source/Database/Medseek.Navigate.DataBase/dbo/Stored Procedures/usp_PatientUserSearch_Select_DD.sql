/*          
------------------------------------------------------------------------------          
Procedure Name: usp_PatientUserSearch_Select_DD 2          
Description   : This procedure is used to get all control master data for Patient/User search page
Created By    : Praveen Takasi
Created Date  : 24-Jan-2013          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
24-01-2013 Praveen Takasi Created to load all control data for Patient/User search
------------------------------------------------------------------------------          
*/  
CREATE PROCEDURE [dbo].[usp_PatientUserSearch_Select_DD]-- 23,null,@v_StatusCode,null,null
(
@i_AppUserId KeyID,
@v_StatusCode StatusCode = 'A'
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
  --      exec usp_Language_Select_DD @i_AppUserId
		--exec usp_Speciality_Select_DD @i_AppUserId
		--exec usp_ProfessionalType_Select_DD @i_AppUserId
		--exec usp_UserStatus_Select_DD @i_AppUserId
		--exec usp_Program_Select_DD @i_AppUserId
		--exec usp_Disease_Select_DD @i_AppUserId
		--exec usp_Operator_Select @i_AppUserId
		--exec usp_InsuranceGroup_Select @i_AppUserId,@i_InsuranceGroupID,@vc_GroupName,@v_StatusCode
		--exec usp_CareTeam_Select @i_AppUserId,@i_CareTeamId,@v_StatusCode
		
		---------------- All the Active Language records are retrieved --------  
      SELECT  
          LanguageID,  
		  LanguageName          
      FROM  
          CodeSetLanguage  
      WHERE  
		  StatusCode = @v_StatusCode   
      ORDER BY  
          LanguageName   
		
		---- Get the List of Code Set Specialty  ---
		
	  SELECT TOP 50  
          CMSProviderSpecialtyCodeID SpecialityId ,  
          ProviderSpecialtyName SpecialityName   
      FROM  
          CodeSetCMSProviderSpecialty  
      WHERE  
          StatusCode = @v_StatusCode  
	---- Get the List of CodesetProfessionalType  ----
	  SELECT  
          ProfessionalTypeID ,  
          ProfessionalType Name 
      FROM  
          CodesetProfessionalType  
      WHERE  
          StatusCode = @v_StatusCode  
      ORDER BY  
		  Name   
	---- Get the all LkUpAccountStatus  ----
	  SELECT    
          AccountStatusCode,    
          AccountStatusName
      FROM    
          LkUpAccountStatus    
      WHERE    
          IsActive = 1  
      ORDER BY         
		  AccountStatusName   
	    --------------- Select all Program Names -------------  
      SELECT  
          ProgramId,  
		  ProgramName
      FROM  
          Program  
      WHERE  
		  StatusCode = @v_StatusCode  
	  ORDER BY  
		  ProgramName  
	-- Get the All Conditions ----
	  SELECT    
		   ConditionID ,    
		   ConditionName 
	  FROM    
		   Condition    
	  WHERE    
		   StatusCode = @v_StatusCode    
	  ORDER BY    
		   ConditionName
	
	--- GEt the All Operators ---
	  SELECT      
		OperatorId,    
		OperatorValue  
	  FROM       
		Operator    
	  ORDER BY    
		SortOrder
		
	-- Get the All Insurance Groups --
	  SELECT    
		InsuranceGroupID,    
		GroupName
	  FROM
		InsuranceGroup    
	  ORDER BY  
		GroupName  
	--- Get  all the careteams ----
	  SELECT      
          CareTeamId ,      
          CareTeamName 
      FROM      
          CareTeam 
      ORDER BY      
          CareTeamName      
		
END TRY          
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH  
  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientUserSearch_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

