/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetTypeNamesByTaskGeneralizedId
Description   : This Function Returns TypeName by TaskGeneralizedId 
Created By    : Rathnam
Created Date  : 28-Oct-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
24-May-2011 Rathnam added tasktype PatientEducationMaterial 
29-Feb-2012 Rathnam modified the lifestyle goal select statement
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetTypeNamesByTaskGeneralizedId]
     (
        @v_TaskTypeName VARCHAR(50)
       ,@i_TaskGeneralizedId KEYID
     )
RETURNS VARCHAR(50)
AS
BEGIN
      DECLARE @v_TypeName VARCHAR(50)
      IF @v_TaskTypeName = 'Life Style Goal\Activity Follow Up'
         BEGIN
               SELECT
                   @v_TypeName = LifeStyleGoals.LifeStyleGoal-- + ' '+ ISNULL(PatientGoal.Description,'')
              FROM
                  LifeStyleGoals
               INNER JOIN PatientGoal
                   ON PatientGoal.LifeStyleGoalId = LifeStyleGoals.LifeStyleGoalId  
               WHERE
                   PatientGoal.PatientGoalId = @i_TaskGeneralizedId
              
         END
      ELSE
         IF @v_TaskTypeName = 'Program Enrollment'
            BEGIN
                  SELECT
                      @v_TypeName = Program.ProgramName
                  FROM
                      Program
                  INNER JOIN UserPrograms
                      ON Program.ProgramId = UserPrograms.ProgramId
                  WHERE
                      UserPrograms.UserProgramId = @i_TaskGeneralizedId
            END
      ELSE
         IF @v_TaskTypeName IN ( 'Questionnaire' , 'Medication Titration' )
            BEGIN
                 SELECT
                     @v_TypeName = Questionaire.QuestionaireName
                 FROM
                     Questionaire
                 INNER JOIN UserQuestionaire
                     ON Questionaire.QuestionaireId = UserQuestionaire.QuestionaireId
                 WHERE
                     UserQuestionaire.UserQuestionaireId = @i_TaskGeneralizedId
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Encounter\Appointment'
            BEGIN
                  SELECT
                      @v_TypeName = EncounterType.Name
                  FROM
                      EncounterType
                  INNER JOIN UserEncounters
                      ON EncounterType.EncounterTypeId = UserEncounters.EncounterTypeId
                  WHERE
                      UserEncounters.UserEncounterID = @i_TaskGeneralizedId
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Procedure'
            BEGIN
                  SELECT
                      @v_TypeName = CodeSetProcedure.ProcedureName
                  FROM
                      CodeSetProcedure
                  INNER JOIN UserProcedureCodes
                      ON CodeSetProcedure.ProcedureId = UserProcedureCodes.ProcedureId
                  WHERE
                      UserProcedureCodes.UserProcedureId = @i_TaskGeneralizedId
            END
      ELSE
         IF @v_TaskTypeName = 'Immunization'
            BEGIN
                  SELECT
                      @v_TypeName = Immunizations.Name
                  FROM
                      Immunizations
                  INNER JOIN UserImmunizations
                      ON Immunizations.ImmunizationID = UserImmunizations.ImmunizationID
                  WHERE
                      UserImmunizations.UserImmunizationID = @i_TaskGeneralizedId
            END
      ELSE
         IF @v_TaskTypeName = 'Medication Prescription'
            BEGIN
                  SELECT
                      @v_TypeName = CodeSetDrug.DrugName
                  FROM
                      CodeSetDrug
                  INNER JOIN UserDrugCodes
                      ON CodeSetDrug.DrugCodeId = UserDrugCodes.DrugCodeId
                  WHERE
                      UserDrugCodes.UserDrugId = @i_TaskGeneralizedId
            END
	  ELSE
	     IF @v_TaskTypeName = 'Communications'
            BEGIN
				  SELECT
					  @v_TypeName = CommunicationType
				  FROM
					  CommunicationType
				  INNER JOIN UserCommunication
					  ON CommunicationType.CommunicationTypeId = UserCommunication.CommunicationTypeId
				  WHERE
					  UserCommunication.UserCommunicationId = @i_TaskGeneralizedId
            END
      ELSE
         IF @v_TaskTypeName = 'Evaluate Lab Results'
            BEGIN
                  SELECT
                      @v_TypeName = @v_TaskTypeName
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Health Risk Score'
            BEGIN
                  SELECT
                      @v_TypeName = Name
                  FROM
                      HealthStatusScoreType
                  INNER JOIN UserHealthStatusScore
                      ON HealthStatusScoreType.HealthStatusScoreId = UserHealthStatusScore.HealthStatusScoreId
                  WHERE
                      UserHealthStatusScore.UserHealthStatusId = @i_TaskGeneralizedId
            END
      ELSE
         IF @v_TaskTypeName = 'Cohort Pending Delete Update'
            BEGIN
                  SELECT
                      @v_TypeName = CohortListName
                  FROM
                      CohortList
                  WHERE
                      CohortListId = @i_TaskGeneralizedId
            END

	  ELSE 
	     IF @v_TaskTypeName='Schedule Phone Call'
        	BEGIN
	              SELECT 
	                  @v_TypeName = @v_TaskTypeName
	              FROM 
	                  UserPhoneCallLog 
	              WHERE 
	                  UserPhoneCallId = @i_TaskGeneralizedId
	        END
          IF @v_TaskTypeName='Patient Education Material'
        	BEGIN
	              SELECT 
	                  @v_TypeName = em.Name
	              FROM 
	                  PatientEducationMaterial pem
	              INNER JOIN EducationMaterial em
	                 ON pem.EducationMaterialID = em.EducationMaterialID     
	              WHERE 
	                  pem.PatientEducationMaterialID = @i_TaskGeneralizedId
	              --AND PatientEducationMaterial.StatusCode = 'A'    
	        END
	   ELSE 
	     IF @v_TaskTypeName='Other Tasks'
        	BEGIN
	              SELECT 
	                  @v_TypeName =  at.Name
	              FROM 
	                  UserOtherTask uot
	              INNER JOIN AdhocTask at
	                  ON uot.AdhocTaskId = at.AdhocTaskId
	              WHERE 
	                  uot.UserOtherTaskId = @i_TaskGeneralizedId
	        END       
      RETURN @v_TypeName
END
