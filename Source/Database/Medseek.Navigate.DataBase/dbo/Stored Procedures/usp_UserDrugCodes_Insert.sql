  
/*            
------------------------------------------------------------------------------            
Procedure Name: usp_UserDrugCodes_Insert            
Description   : This procedure is used to insert record into UserDrugCodes table        
Created By    : Aditya            
Created Date  : 06-Apr-2010            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION            
03-Sep-2010 NagaBabu Added new field CareTeamUserID              
30-Sep-2010 Pramod Added default NULL for CareTeamUserID  
10-Nov-2011 NagaBabu Added @i_DiseaseId as input parameter  
03-feb-2011 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  UserDrugCodes table    
12-Jul-2012 Sivakrishna Added @i_DataSourceId parameter  and added DatasourceId Column to Existing insert Statement  
05-Jan-2013 Praveen Added ProgramID as parameter and inserting to immunization table for Patient Specific Managed Population  
19-Mar-2013 P.V.P.Mohan changed Table names UserDrugCodes to PatientDrugCodes  
------------------------------------------------------------------------------            
*/  
CREATE PROCEDURE [dbo].[usp_UserDrugCodes_Insert]  
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
 @o_UserDrugId KEYID OUTPUT ,  
 @dt_DatePrescribed USERDATE ,  
 @dt_DateFilled USERDATE ,  
 @i_CareTeamUserID KEYID = NULL ,  
 @i_DiseaseId KeyId = NULL,  
 @b_IsAdhoc  BIT = 0,  
 @i_DataSourceId KeyId = NULL,  
 @i_ManagedPopulationID KeyID = NULL  
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
          PatientDrugCodes  
          (  
            PatientID ,  
            DrugCodeId ,  
            NumberOfDays ,  
            TimesPerDay ,  
            DeliveryMethod ,  
            Refills ,  
            DiscontinuedDate ,  
            StatusCode ,  
            IsTitration ,  
            StartDate ,  
            EndDate ,  
            Comments ,  
            ProviderID ,  
            FrequencyOfTitrationDays ,  
            CreatedByUserId ,  
            DatePrescribed ,  
            DateFilled ,  
            CareTeamUserID ,  
            --DiseaseId ,  
            IsAdhoc,  
            DataSourceId ,  
            ProgramID  
          )  
      VALUES  
          (  
            @i_UserId ,  
            @i_DrugCodeId ,  
            @i_NumberOfDays ,  
            @i_TimesPerDay ,  
            @vc_DeliveryMethod ,  
            @i_Refills ,  
            @dt_DiscontinuedDate ,  
            @vc_StatusCode ,  
            @vc_IsTitration ,  
            @dt_StartDate ,  
            @dt_EndDate ,  
            @vc_Comments ,  
            @i_UserProviderID ,  
            @i_FrequencyOfTitrationDays ,  
            @i_AppUserId ,  
            @dt_DatePrescribed ,  
            @dt_DateFilled ,  
            @i_CareTeamUserID ,  
            --@i_DiseaseId ,  
            @b_IsAdhoc  ,  
            @i_DataSourceId,  
            @i_ManagedPopulationID )  
  
      SELECT  
          @l_numberOfRecordsInserted = @@ROWCOUNT ,  
          @o_UserDrugId = SCOPE_IDENTITY()  
  
      IF @l_numberOfRecordsInserted <> 1  
         BEGIN  
               RAISERROR ( N'Invalid row count %d in insert UserDrugCodes' ,  
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
    ON OBJECT::[dbo].[usp_UserDrugCodes_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

