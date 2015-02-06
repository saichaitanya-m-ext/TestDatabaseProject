/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserEncounters_Update  
Description   : This procedure is used to update record into UserEncounters table  
Created By    : Aditya  
Created Date  : 22-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
03-Sep-2010 NagaBabu Added new field CareTeamUserID       
30-Sep-2010 Pramod Added default NULL for CareTeamUserID
06-Jun-2011 Rathnam added @i_DiseaseID one more parameter
30-Aug-2011 NagaBabu Added @i_IsEncounterwithPCP as input parameter for Update statement
10-Nov-2011 NagaBabu Added @b_IsPreventive as input parameter
20-Mar-2013 P.V.P.Mohan modified UserEncounters to PatientEncounters
			and modified columns. 
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_UserEncounters_Update]
(
 @i_AppUserId KEYID ,
 @i_UserId KEYID ,
 @dt_EncounterDate USERDATE ,
 @i_IsInpatient ISINDICATOR ,
 @vc_Comments VARCHAR(200) ,
 @i_StayDays KEYID ,
 @i_EncounterTypeId KEYID ,
 @vc_StatusCode STATUSCODE ,
 @i_UserEncounterID KEYID ,
 @dt_DateDue USERDATE ,
 @dt_ScheduledDate USERDATE ,
 @i_UserProviderID KEYID ,
 @i_CareTeamUserID KEYID = NULL,
 @i_DiseaseID KeyID = NULL,
 @b_IsEncounterwithPCP IsIndicator,
 @b_IsPreventive ISINDICATOR,
 @i_DataSourceId KeyId,
 @i_ManagedPopulationID KeyId=NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsUpdated INT     
 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

      UPDATE
          PatientEncounters
      SET
          PatientID = @i_UserId ,
          EncounterDate = @dt_EncounterDate ,
          IsInpatient = @i_IsInpatient ,
          Comments = @vc_Comments ,
          StayDays = @i_StayDays ,
          EncounterTypeId = @i_EncounterTypeId ,
          StatusCode = @vc_StatusCode ,
          LastModifiedByUserId = @i_AppUserId ,
          LastModifiedDate = GETDATE() ,
          DateDue = @dt_DateDue ,
          ScheduledDate = @dt_ScheduledDate ,
          ProviderID = @i_UserProviderID ,
          CareTeamUserID = @i_CareTeamUserID,
          --DiseaseID = @i_DiseaseID,
          IsEncounterwithPCP = @b_IsEncounterwithPCP,
          IsPreventive = @b_IsPreventive,
          DataSourceId = @i_DataSourceId,
          ProgramID = @i_ManagedPopulationID
      WHERE
          PatientEncounterID = @i_UserEncounterID

      SET @l_numberOfRecordsUpdated = @@ROWCOUNT

      IF @l_numberOfRecordsUpdated <> 1
         BEGIN
               RAISERROR ( N'Invalid row count %d in insert UserEncounters' ,
               17 ,
               1 ,
               @l_numberOfRecordsUpdated )
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
    ON OBJECT::[dbo].[usp_UserEncounters_Update] TO [FE_rohit.r-ext]
    AS [dbo];

