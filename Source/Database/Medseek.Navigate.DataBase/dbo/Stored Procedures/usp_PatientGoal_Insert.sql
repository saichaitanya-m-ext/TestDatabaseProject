/*        
------------------------------------------------------------------------------        
Procedure Name: usp_PatientGoal_Insert        
Description   : This procedure is used to insert record into PatientGoal table    
Created By    : Aditya        
Created Date  : 29-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
29-Feb-2012 NagaBabu Added @b_IsAdhoc parameter as this field was newly added to PatientGoal table  
06-Mar-2012 Gurumoorthy Added Parameter   @t_AdhocTaskSchduledAttempts and added attempts    
19-Mar-2012 Gurumoorthy Added Parameter   @i_AssignedCareProviderId in PatientGoal table  
14-Nov-2012 P.V.P.MOhan Added Parameter   @i_AssignedCareProviderId in PatientGoal table 
16-Nov-2012 Rathnam removed the table type parameters as we move the functionality to the adhoc related tasks 
03-March-2012 Rathnam added IF @i_ProgramId = 0 OR @i_ProgramId IS NULL condition for avoiding the FK conflict errors when programid is 0
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PatientGoal_Insert]
(
 @i_AppUserId KEYID
,@i_UserId KEYID
,    
 --@vc_Description LongDescription = NULL ,    
 @vc_DurationUnits UNIT
,@i_DurationTimeline SMALLINT
,    
 --@vc_ContactFrequencyUnits Unit,    
 --@i_ContactFrequency smallint,    
 --@i_CommunicationTypeId KeyID = NULL,    
 --@i_CancellationReason ShortDescription,    
 @vc_Comments LONGDESCRIPTION
,@vc_StatusCode STATUSCODE
,@dt_StartDate USERDATE
,@i_LifeStyleGoalId KEYID
,@dt_GoalCompletedDate USERDATE = NULL
,@v_GoalStatus STATUSCODE
,@i_ProgramId KEYID
,@o_PatientGoalId KEYID OUTPUT
,@b_IsAdhoc ISINDICATOR = NULL
,@i_AssignedCareProviderId KEYID = NULL
)
AS
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
      
      INSERT INTO
          PatientGoal
          (
            PatientId
          ,DurationUnits
          ,DurationTimeline
          ,Comments
          ,LifeStyleGoalId
          ,GoalCompletedDate
          ,GoalStatus
          ,ProgramId
          ,StatusCode
          ,StartDate
          ,CreatedByUserId
          ,IsAdhoc
          ,AssignedCareProviderId
          )
      VALUES
          (
            @i_UserId
          ,@vc_DurationUnits
          ,@i_DurationTimeline
          ,@vc_Comments
          ,@i_LifeStyleGoalId
          ,@dt_GoalCompletedDate
          ,@V_GoalStatus
          ,CASE WHEN @i_ProgramId = 0 THEN NULL ELSE @i_ProgramId END
          ,@vc_StatusCode
          ,CONVERT(DATE,@dt_StartDate)
          ,@i_AppUserId
          ,@b_IsAdhoc
          ,@i_AssignedCareProviderId
          )

      SELECT
          @l_numberOfRecordsInserted = @@ROWCOUNT
         ,@o_PatientGoalId = SCOPE_IDENTITY()




      IF @l_numberOfRecordsInserted <> 1
         BEGIN
               RAISERROR ( N'Invalid row count %d in Insert PatientGoal'
               ,17
               ,1
               ,@l_numberOfRecordsInserted )
         END

      RETURN 0
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
    ON OBJECT::[dbo].[usp_PatientGoal_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

