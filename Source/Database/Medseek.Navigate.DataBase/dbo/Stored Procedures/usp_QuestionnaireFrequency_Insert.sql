/*        
------------------------------------------------------------------------------        
Procedure Name: usp_QuestionnaireFrequency_Insert        
Description   : This procedure is used to insert record into QuestionnaireFrequency table    
Created By    : NagaBabu       
Created Date  : 30-Aug-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION   
01-Sep-2010 NagaBabu Deleted ScheduleQuestionaireId Field this sp while this field was  
      deleted from QuestionnaireFrequency table    
25-Jan-2011 Rathnam added if clause for avoidng duplicate records.         
21-Feb-2011 Rathnam Included status code and changed the if clause for duplicate checking
06-Jun-2011 Rathnam added @b_IsPreventive, @i_DiseaseID two more parameters
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers 
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_QuestionnaireFrequency_Insert]
       (
        @i_AppUserId KEYID
       ,@i_FrequencyNumber INT
       ,@vc_Frequency VARCHAR(1)
       ,@i_QuestionaireId KEYID
       ,@i_CareTeamId KEYID
       ,@i_PopulationDefinitionID KEYID
       ,@i_ProgramId KEYID
       ,@i_UserId KEYID
       ,@vc_StatusCode STATUSCODE
       ,@o_QuestionnaireFrequencyID KEYID OUTPUT
       ,@i_DiseaseID KeyID = NULL
       ,@b_IsPreventive IsIndicator = NULL
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
      IF NOT EXISTS ( SELECT
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
                          AND StatusCode = @vc_StatusCode )
         BEGIN
               INSERT INTO
                   QuestionnaireFrequency
                   (
                    FrequencyNumber
                   ,Frequency
                   ,QuestionaireId
                   ,CareTeamId
                   ,PopulationDefinitionId
                   ,ProgramId
                   ,PatientId
                   ,StatusCode
                   ,CreatedByUserId
                   ,DiseaseID
			       ,IsPreventive
                   )
               VALUES
                   (
                    @i_FrequencyNumber
                   ,@vc_Frequency
                   ,@i_QuestionaireId
                   ,@i_CareTeamId
                   ,@i_PopulationDefinitionId
                   ,@i_ProgramId
                   ,@i_UserId
                   ,@vc_StatusCode
                   ,@i_AppUserId
                   ,@i_DiseaseID
			       ,@b_IsPreventive
                   )

               SELECT
                   @l_numberOfRecordsInserted = @@ROWCOUNT
                  ,@o_QuestionnaireFrequencyID = SCOPE_IDENTITY()

         END
      ELSE
         BEGIN
               SELECT 2601 ----- if data exists return the 2601 values  
         END
      IF @l_numberOfRecordsInserted <> 1
         BEGIN
               RAISERROR ( N'Invalid row count %d in insert QuestionnaireFrequency Table'
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
    ON OBJECT::[dbo].[usp_QuestionnaireFrequency_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

