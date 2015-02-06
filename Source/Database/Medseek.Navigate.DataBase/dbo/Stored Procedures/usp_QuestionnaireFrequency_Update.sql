/*  
-----------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_QuestionnaireFrequency_Update]  
Description   : This procedure is used to update the data into QuestionnaireFrequency
Created By    : NagaBabu  
Created Date  : 30-Aug-2010  
------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
01-Sep-2010 NagaBabu Deleted ScheduleQuestionaireId Field this sp while this field was
						deleted from QuestionnaireFrequency table  
25-Jan-2011 Rathnam added if clause for avoidng duplicate records.
21-Feb-2011 Rathnam Changed conditions in if clause for avoiding duplicate records
06-Jun-2011 Rathnam added @b_IsPreventive, @i_DiseaseID two more parameters
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers 
27-mar-2013 P.V.P.Mohan changed parameters PatientID
            the place of UserID
------------------------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_QuestionnaireFrequency_Update]
       (
        @i_AppUserId KEYID
       ,@i_FrequencyNumber INT
       ,@vc_Frequency VARCHAR(1)
       ,@i_QuestionaireId KEYID
       ,@i_CareTeamId KEYID
       ,@i_PopulationDefinitionId KEYID
       ,@i_ProgramId KEYID
       ,@i_UserId KEYID
       ,@vc_StatusCode STATUSCODE
       ,@i_QuestionnaireFrequencyID KEYID
       ,@i_DiseaseID KeyID = NULL
       ,@b_IsPreventive IsIndicator = NULL
       )
AS
BEGIN TRY

      SET NOCOUNT ON   
 -- Check if valid Application User ID is passed  
      DECLARE @i_numberOfRecordsUpdated INT
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )

         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END  
------------    Updation operation takes place   --------------------------  

      IF EXISTS ( SELECT
                      1
                  FROM
                      QuestionnaireFrequency
                  WHERE
                      ( QuestionaireId = @i_QuestionaireId )
                      AND (
								(
								CareTeamId = @i_CareTeamId
								AND CareTeamId IS NOT NULL
								AND PopulationDefinitionId IS NULL
								AND ProgramId IS NULL
								AND PatientId IS NULL
								)
							OR (
								 PopulationDefinitionId = @i_PopulationDefinitionId
								 AND PopulationDefinitionId IS NOT NULL
								 AND CareTeamId IS NULL
								 AND ProgramId IS NULL
								 AND PatientId IS NULL
							   )
							OR (
								 ProgramId = @i_ProgramId
								 AND ProgramId IS NOT NULL
								 AND CareTeamId IS NULL
								 AND PopulationDefinitionId IS NULL
								 AND PatientId IS NULL
							   )
							OR (
								 PatientId = @i_UserId
								 AND PatientId IS NOT NULL
								 AND CareTeamId IS NULL
								 AND PopulationDefinitionId IS NULL
								 AND ProgramId IS NULL
							   )
                          )
                          --AND Frequency = @vc_Frequency
                      AND StatusCode = @vc_StatusCode
                      AND QuestionnaireFrequencyID <> @i_QuestionnaireFrequencyID )
         BEGIN
               SELECT 2601
         END
      ELSE

         UPDATE
             QuestionnaireFrequency
         SET
             FrequencyNumber = @i_FrequencyNumber
            ,Frequency = @vc_Frequency
            ,QuestionaireId = @i_QuestionaireId
            ,CareTeamId = @i_CareTeamId
            ,PopulationDefinitionId = @i_PopulationDefinitionId
            ,ProgramId = @i_ProgramId
            ,PatientId = @i_UserId
            ,StatusCode = @vc_StatusCode
            ,LastModifiedDate = GETDATE()
            ,LastModifiedByUserId = @i_AppUserId
            ,DiseaseID = @i_DiseaseID
            ,IsPreventive = @b_IsPreventive 
         WHERE
             QuestionnaireFrequencyID = @i_QuestionnaireFrequencyID

      SET @i_numberOfRecordsUpdated = @@ROWCOUNT

      IF @i_numberOfRecordsUpdated <> 1
         RAISERROR ( N'Update of QuestionnaireFrequency table experienced invalid row count of %d'
         ,17
         ,1
         ,@i_numberOfRecordsUpdated )

      RETURN 0
END TRY   
------------ Exception Handling --------------------------------  
BEGIN CATCH
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionnaireFrequency_Update] TO [FE_rohit.r-ext]
    AS [dbo];

