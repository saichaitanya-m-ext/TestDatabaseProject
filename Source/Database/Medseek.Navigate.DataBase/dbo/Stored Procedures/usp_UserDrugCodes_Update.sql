/*          
------------------------------------------------------------------------------          
Procedure Name: usp_UserDrugCodes_Update          
Description   : This procedure is used to update record in UserDrugCodes table      
Created By    : Aditya          
Created Date  : 06-Apr-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
03-Sep-2010 NagaBabu Added new field CareTeamUserID  
30-Sep-2010 Pramod Added default NULL for CareTeamUserID
10-Nov-2011 NagaBabu Added @i_DiseaseId as input parameter
12-07-2014   Sivakrishna Added @i_DataSourceId parameter and added DataSourceId column to Existing Update statement.
07-Jan-2013 Praveen Added ProgramID as parameter and inserting to medications table for Patient Specific Managed Population
19-Mar-2013 P.V.P.Mohan changed Table name UserDrugCodes to PatientDrugCodes
-----------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_UserDrugCodes_Update]
(
 @i_AppUserId KEYID ,
 @i_UserId KEYID ,
 @i_DrugCodeId KEYID ,
 @i_NumberOfDays INT = NULL ,
 @i_TimesPerDay SMALLINT = NULL ,
 @vc_DeliveryMethod VARCHAR(50) = NULL ,
 @i_Refills INT = NULL ,
 @dt_DiscontinuedDate DATETIME = NULL ,
 @vc_StatusCode STATUSCODE = NULL ,
 @vc_IsTitration ISINDICATOR = NULL ,
 @dt_StartDate USERDATE = NULL ,
 @dt_EndDate USERDATE = NULL ,
 @vc_Comments LONGDESCRIPTION = NULL ,
 @i_UserProviderID KEYID = NULL ,
 @i_FrequencyOfTitrationDays INT = NULL ,
 @i_UserDrugId KEYID ,
 @dt_DatePrescribed USERDATE ,
 @dt_DateFilled USERDATE,
 @i_CareTeamUserID KEYID = NULL ,
 @i_DiseaseId KeyId = NULL,
 @i_DataSourceId KeyId = NULL,
 @i_ManagedPopulationID KeyID = NULL
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
          PatientDrugCodes
      SET
          PatientID = @i_UserId ,
          DrugCodeId = @i_DrugCodeId ,
          NumberOfDays = @i_NumberOfDays ,
          TimesPerDay = @i_TimesPerDay ,
          DeliveryMethod = @vc_DeliveryMethod ,
          Refills = @i_Refills ,
          DiscontinuedDate = @dt_DiscontinuedDate ,
          StatusCode = @vc_StatusCode ,
          IsTitration = @vc_IsTitration ,
          StartDate = @dt_StartDate ,
          EndDate = @dt_EndDate ,
          Comments = @vc_Comments ,
          ProviderID = @i_UserProviderID ,
          FrequencyOfTitrationDays = @i_FrequencyOfTitrationDays ,
          LastModifiedByUserId = @i_AppUserId ,
          LastModifiedDate = GETDATE() ,
          DatePrescribed = @dt_DatePrescribed ,
          DateFilled = @dt_DateFilled ,
          CareTeamUserID = @i_CareTeamUserID ,
          --DiseaseId = @i_DiseaseId,
          DataSourceId = @i_DataSourceId,
          ProgramID=@i_ManagedPopulationID
      WHERE
          PatientDrugId = @i_UserDrugId

      SELECT
          @l_numberOfRecordsUpdated = @@ROWCOUNT

      IF @l_numberOfRecordsUpdated <> 1
         BEGIN
               RAISERROR ( N'Invalid Row count %d passed to update UserDrugCodes Details' ,
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
    ON OBJECT::[dbo].[usp_UserDrugCodes_Update] TO [FE_rohit.r-ext]
    AS [dbo];

