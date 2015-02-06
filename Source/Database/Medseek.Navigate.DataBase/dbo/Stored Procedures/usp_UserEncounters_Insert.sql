/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserEncounters_Insert      
Description   : This procedure is used to insert record into UserEncounters table  
Created By    : Aditya  
Created Date  : 22-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
03-Sep-2010 NagaBabu Added new field CareTeamUserID
30-Sep-2010 Pramod Added default NULL for CareTeamUserID and @i_UserProviderID
06-Jun-2011 Rathnam added @i_DiseaseID KeyID = NULL, one more parameter
29-Aug-2011 NagaBabu Added @b_IsEncounterwithPCP as input parameter of datatype 'IsIndicator'
10-Nov-2011 NagaBabu Added @b_IsPreventive as input parameter
03-feb-2011 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  UserQuestionaire table  
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_UserEncounters_Insert]
(
 @i_AppUserId KEYID ,
 @i_UserId KEYID ,
 @dt_EncounterDate USERDATE ,
 @i_IsInpatient ISINDICATOR ,
 @vc_Comments VARCHAR(200) ,
 @i_StayDays KEYID ,
 @i_EncounterTypeId KEYID ,
 @vc_StatusCode STATUSCODE ,
 @dt_DateDue USERDATE ,
 @dt_ScheduledDate USERDATE ,
 @i_UserProviderID KEYID = NULL,
 @i_CareTeamUserID KEYID = NULL,
 @o_UserEncounterID KEYID OUTPUT,
 @i_DiseaseID KeyID = NULL,
 @b_IsEncounterwithPCP IsIndicator = 0,
 @b_IsPreventive ISINDICATOR,
 @b_IsAdhoc  BIT = 0 ,
 @i_DataSourceId KeyId = NULL,
 @i_ProgramID KeyId=NULL
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

      INSERT INTO
          PatientEncounters
          (
            PatientID ,
            EncounterDate ,
            IsInpatient ,
            Comments ,
            StayDays ,
            EncounterTypeId ,
            StatusCode ,
            CreatedByUserId ,
            DateDue ,
            ScheduledDate ,
            ProviderID ,
            CareTeamUserID , 
            --DiseaseID ,
            IsEncounterwithPCP ,
            IsPreventive ,
            IsAdhoc,
            DataSourceId,
            ProgramID
          )
      VALUES
          (
            @i_UserId ,
            @dt_EncounterDate ,
            @i_IsInpatient ,
            @vc_Comments ,
            @i_StayDays ,
            @i_EncounterTypeId ,
            @vc_StatusCode ,
            @i_AppUserId ,
            @dt_DateDue ,
            @dt_ScheduledDate ,
            @i_UserProviderID ,
            @i_CareTeamUserID ,
            --@i_DiseaseID ,
            @b_IsEncounterwithPCP ,
            @b_IsPreventive ,
            @b_IsAdhoc,
            @i_DataSourceId,
            @i_ProgramID
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
    ON OBJECT::[dbo].[usp_UserEncounters_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

