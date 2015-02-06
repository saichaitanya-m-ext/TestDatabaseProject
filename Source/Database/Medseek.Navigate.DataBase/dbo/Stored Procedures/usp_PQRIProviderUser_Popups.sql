/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIProviderUser_Popups]  
Description   : This Procedure is used for getting popupdata by patientuseid & UserTypeIdlist
Created By    : Rathnam
Created Date  : 18-Jan-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
25-Jan-2011 NagaBabu Added Alias names in the select statements  
15-Feb-2011 Rathnam Comments alias name added for cpt & icd select statements   
11-Dec-2012 Mohan removed Status Code
------------------------------------------------------------------------------    
*/ 
CREATE PROCEDURE [dbo].[usp_PQRIProviderUser_Popups]
       (
        @i_AppUserId KEYID
       ,@i_PatientUserID KEYID
       ,@v_TypeIDList VARCHAR(500)
       ,@v_PopUpType VARCHAR(10)
       )
AS
BEGIN TRY
      SET NOCOUNT ON     
    -- Check if valid Application User ID is passed  

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      DECLARE @tblTypeID TABLE 
            (
               TypeID KEYID
            )
      INSERT INTO
          @tblTypeID
          (
            TypeID
          )
          SELECT DISTINCT
              KeyValue
          FROM
              DBO.udf_SplitStringToTable(@v_TypeIDList , ',')
          WHERE
              KeyValue <> ''

      IF @v_PopUpType = 'CPT'
         BEGIN
               SELECT
                   --UserProcedureCodes.UserProcedureId
                   CodeSetProcedure.ProcedureCode AS 'Procedure Code'
                  ,CodeSetProcedure.ProcedureName as 'Procedure Name'
                  ,CONVERT(VARCHAR,UserProcedureCodes.ProcedureCompletedDate,101) AS 'Procedure Completed Date'
                  ,UserProcedureCodes.Commments AS Comments
               FROM
                   UserProcedureCodes
               INNER JOIN @tblTypeID TypeID
                   ON TypeID.TypeID = UserProcedureCodes.UserProcedureId
               INNER JOIN CodeSetProcedure
                   ON CodeSetProcedure.ProcedureId = UserProcedureCodes.ProcedureId
               WHERE
                   UserProcedureCodes.StatusCode = 'A'
                   --AND CodeSetProcedure.StatusCode = 'A'
                   AND UserProcedureCodes.UserId = @i_PatientUserID
               ORDER BY
                   UserProcedureCodes.DueDate
         END

      IF @v_PopUpType = 'ICD'
         BEGIN
               SELECT
                   --UserDiagnosisCodes.UserDiagnosisId
                   CONVERT(VARCHAR,UserDiagnosisCodes.DateDiagnosed,101) AS 'Date Diagnosed'
                  ,CodeSetICD.ICDCode AS 'ICD Code'
                  ,CodeSetICD.ICDDescription AS 'ICD Description'
                  ,UserDiagnosisCodes.Commments AS Comments
               FROM
                   UserDiagnosisCodes
               INNER JOIN @tblTypeID TypeID
                   ON TypeID.TypeID = UserDiagnosisCodes.UserDiagnosisId
               INNER JOIN CodeSetICD
                   ON CodeSetICD.ICDCodeId = UserDiagnosisCodes.DiagnosisId
               WHERE
                   UserDiagnosisCodes.StatusCode = 'A'
                   --AND CodeSetICD.StatusCode = 'A'
                   AND UserDiagnosisCodes.UserId = @i_PatientUserID
               ORDER BY
                   UserDiagnosisCodes.DateDiagnosed
         END

      IF @v_PopUpType = 'Encounter'
         BEGIN
               SELECT
                   CONVERT(VARCHAR,UserEncounters.EncounterDate,101) AS 'Encounter Date'
                  ,CONVERT(VARCHAR,UserEncounters.ScheduledDate,101) AS 'Scheduled Date'
                  ,EncounterType.Name AS 'Encounter Name'
                  ,CASE WHEN UserEncounters.IsInpatient = 1 THEN 'YES' ELSE 'NO' END AS IsInpatient
                  ,UserEncounters.CareTeamUserID AS 'CareTeam UserID'
                  ,UserEncounters.StayDays AS 'Stay Days'
                  ,UserEncounters.Comments
               FROM
                   UserEncounters
               INNER JOIN @tblTypeID TypeID
                   ON TypeID.TypeID = UserEncounters.UserEncounterID
               INNER JOIN EncounterType
                   ON EncounterType.EncounterTypeId = UserEncounters.EncounterTypeId
               WHERE
                   UserEncounters.StatusCode = 'A'
                   AND EncounterType.StatusCode = 'A'
                   AND UserEncounters.UserId = @i_PatientUserID
               ORDER BY
                   UserEncounters.DateDue
         END
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
    ON OBJECT::[dbo].[usp_PQRIProviderUser_Popups] TO [FE_rohit.r-ext]
    AS [dbo];

