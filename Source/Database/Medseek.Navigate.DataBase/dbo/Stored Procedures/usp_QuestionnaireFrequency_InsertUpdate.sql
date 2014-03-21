/*        
------------------------------------------------------------------------------        
Procedure Name: usp_QuestionnaireFrequency_InsertUpdate        
Description   : This procedure is used to insert or Update record into QuestionnaireFrequency table    
Created By    : NagaBabu       
Created Date  : 31-May-2012     
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION   
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers
18-Mar-2013 P.V.P.Mohan changed table UserQuestionire to PatientQuestionaire  and Modified UserId to PatientID
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_QuestionnaireFrequency_InsertUpdate]
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
,@o_QuestionnaireFrequencyID KEYID = NULL
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
									AND PopulationDefinitionID IS NULL
									AND ProgramId IS NULL
									AND PatientId IS NULL
									)
                                OR (
                                     PopulationDefinitionID = @i_PopulationDefinitionID
                                     AND PopulationDefinitionID IS NOT NULL
                                     AND CareTeamId IS NULL
                                     AND ProgramId IS NULL
                                     AND PatientId IS NULL
                                   )
                                OR (
                                     ProgramId = @i_ProgramId
                                     AND ProgramId IS NOT NULL
                                     AND CareTeamId IS NULL
                                     AND PopulationDefinitionID IS NULL
                                     AND PatientId IS NULL
                                   )
                                OR (
                                     PatientId = @i_UserId
                                     AND PatientId IS NOT NULL
                                     AND CareTeamId IS NULL
                                     AND PopulationDefinitionID IS NULL
                                     AND ProgramId IS NULL
                                   )
                              )
                          --AND Frequency = @vc_Frequency
                          AND StatusCode = @vc_StatusCode ) 
         AND @o_QuestionnaireFrequencyID IS NULL
         BEGIN
               INSERT INTO
                   QuestionnaireFrequency
                   (
                    FrequencyNumber
                   ,Frequency
                   ,QuestionaireId
                   ,CareTeamId
                   ,PopulationDefinitionID
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
                   ,@i_PopulationDefinitionID
                   ,@i_ProgramId
                   ,@i_UserId
                   ,@vc_StatusCode
                   ,@i_AppUserId
                   ,@i_DiseaseID
			       ,@b_IsPreventive
                   )
                   
			  INSERT PatientQuestionaire
			  (
				PatientId ,
				QuestionaireId ,
				CreatedByUserId ,
				Comments ,
				DateDue ,
				DateAssigned ,
				--DiseaseId ,
				IsPreventive ,
				ProgramId
			  )
			  VALUES
			  (
				@i_UserId ,
				@i_QuestionaireId ,
				@i_AppUserId ,
				'Data Created by Patient Dashboard' ,
				GETDATE() + (SELECT ScheduledDays FROM TaskType WHERE TaskTypeName = 'Questionnaire')  ,
				GETDATE() ,
				--@i_DiseaseID ,  
				@b_IsPreventive ,
				@i_ProgramId 
			  )                      
         END
      ELSE
         BEGIN
               UPDATE QuestionnaireFrequency
               SET FrequencyNumber = @i_FrequencyNumber ,
				   Frequency = @vc_Frequency ,
				   --QuestionaireId = @i_QuestionaireId ,
				   --CareTeamId = @i_CareTeamId ,
				   --CohortListId = @i_CohortListId ,
				   --ProgramId = @i_ProgramId ,
				   PatientId = @i_UserId ,
				   StatusCode = @vc_StatusCode ,
				   LastModifiedDate = GETDATE() ,
				   LastModifiedByUserId = @i_AppUserId ,
				   --DiseaseID = @i_DiseaseID ,
				   IsPreventive = @b_IsPreventive
			  WHERE QuestionnaireFrequencyID = @o_QuestionnaireFrequencyID	
			  
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
    ON OBJECT::[dbo].[usp_QuestionnaireFrequency_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

