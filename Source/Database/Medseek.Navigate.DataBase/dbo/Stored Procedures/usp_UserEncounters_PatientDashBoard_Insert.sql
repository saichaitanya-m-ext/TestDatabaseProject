/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_UserEncounters_PatientDashBoard_Insert]
Description   : This procedure is used to insert or update data into userencounters from Patient DashBoard page
Created By    : NagaBabu
Created Date  : 21-May-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
09-01-2013 PRAVEEN Added ProgramID as nullable parameter to map encounter to program.
03-March-2012 Rathnam added IF @i_ProgramId = 0 OR @i_ProgramId IS NULL condition for avoiding the FK conflict errors when programid is 0
20-Mar-2013 P.V.P.Mohan modified UserEncounters to PatientEncounters
			and modified columns.
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_UserEncounters_PatientDashBoard_Insert]  
(  
 @i_AppUserId KEYID ,  
 @i_UserId KEYID ,  
 @i_EncounterTypeId KEYID ,  
 @vc_StatusCode STATUSCODE ,  
 @dt_DateDue USERDATE ,  
 @i_UserProviderID KEYID = NULL ,  
 @o_UserEncounterID KEYID OUTPUT , 
 @i_OrganizationHospitalId KEYID,
 @i_SpecialityID KEYID,
 @i_ProgramID KEYID=null,
 @i_AssignedCareProviderID KEYID=null
 --@i_UserEncounterID KEYID = NULL
 )  
AS  
BEGIN TRY  
      SET NOCOUNT ON  
      DECLARE @l_numberOfRecordsInserted INT       
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END  
		IF @i_ProgramId = 0 OR @i_ProgramId IS NULL
		BEGIN
			SELECT TOP 1
                @i_ProgramId = p.ProgramId  
            FROM  
				Program p WITH(NOLOCK)
			INNER JOIN ProgramCareTeam pct WITH(NOLOCK)
			    ON pct.ProgramId = p.ProgramId
			INNER JOIN CareTeamMembers ctm WITH(NOLOCK)
			    ON ctm.CareTeamId = pct.CareTeamId    	  
            WHERE  
                p.StatusCode = 'A'  
            AND ctm.StatusCode = 'A'
            AND ctm.ProviderID = @i_AppUserId  
        END
		--IF @i_UserEncounterID IS NULL
		   --BEGIN
			  INSERT INTO  
				  PatientEncounters  
				  (  
					PatientID ,  
					EncounterTypeId ,  
					StatusCode ,  
					CreatedByUserId ,  
					DateDue ,  
					ProviderID ,
					OrganizationHospitalId,
					CustomProviderSpecialtyCodeID,
					ProgramID,
					CareTeamUserID
				  )  
			  VALUES  
				  (  
					@i_UserId ,  
					@i_EncounterTypeId ,  
					@vc_StatusCode ,  
					@i_AppUserId ,  
					@dt_DateDue ,  
					@i_UserProviderID ,
					CASE WHEN @i_OrganizationHospitalId = 0 THEN NULL ELSE @i_OrganizationHospitalId END,
					@i_SpecialityID,
					CASE WHEN @i_ProgramId = 0 THEN NULL ELSE @i_ProgramId END,
					@i_AssignedCareProviderID
				  ) 
			  SELECT  
				  @l_numberOfRecordsInserted = @@ROWCOUNT ,  
				  @o_UserEncounterID = SCOPE_IDENTITY()  
		  
			  IF @l_numberOfRecordsInserted <> 1  
				 BEGIN  
					   RAISERROR ( N'Invalid row count %d in insert UserEncounters' ,  
					   17 ,  
					   1 ,  
					   @l_numberOfRecordsInserted )  
				 END  
			  RETURN 0 	 	   
		   --END
  
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
    ON OBJECT::[dbo].[usp_UserEncounters_PatientDashBoard_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

