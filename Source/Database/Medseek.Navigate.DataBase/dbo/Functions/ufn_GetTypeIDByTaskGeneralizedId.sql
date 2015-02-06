/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetTypeIDByTaskGeneralizedId
Description   : This Function Returns TypeID by TaskGeneralizedId 
Created By    : Rathnam
Created Date  : 29-Nov-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
20-Apr-2011 Rathnam added join to the base tables & added statuscodes for not getting inactive records
20-Jun-2011 Rathnam added Patient Education Material tasktype 
29-Feb-2012 Rathnam modified the lifestyle goal select statement
------------------------------------------------------------------------------                
*/

CREATE FUNCTION [dbo].[ufn_GetTypeIDByTaskGeneralizedId]
     (
        @v_TaskTypeName VARCHAR(50)
       ,@i_TaskGeneralizedId KEYID
     )
RETURNS INT
AS
BEGIN
      DECLARE @i_TypeID INT
      IF @v_TaskTypeName = 'Life Style Goal\Activity Follow Up'
         BEGIN
               SELECT
                   @i_TypeID = LifeStyleGoals.LifeStyleGoalId
               FROM
                  LifeStyleGoals
               INNER JOIN PatientGoal
                   ON PatientGoal.LifeStyleGoalId = LifeStyleGoals.LifeStyleGoalId  
               WHERE
                   PatientGoal.PatientGoalId = @i_TaskGeneralizedId
               --AND LifeStyleGoals.StatusCode = 'A' 
               --AND PatientGoal.StatusCode = 'A' 
          
         END
      ELSE
         IF @v_TaskTypeName = 'Program Enrollment'
            BEGIN
                  SELECT
                      @i_TypeID = Program.ProgramId
                  FROM
                      UserPrograms
                  INNER JOIN Program
                      ON UserPrograms.ProgramId = Program.ProgramId   
                  WHERE
                      UserProgramId = @i_TaskGeneralizedId
                  --AND Program.StatusCode = 'A'    
                  --AND UserPrograms.StatusCode = 'A'
            END
      ELSE
         IF @v_TaskTypeName IN ( 'Questionnaire' , 'Medication Titration' )
            BEGIN
                 SELECT
                     @i_TypeID = Questionaire.QuestionaireId
                 FROM
                     UserQuestionaire
                 INNER JOIN Questionaire
                     ON Questionaire.QuestionaireId = UserQuestionaire.QuestionaireId
                 WHERE
                     UserQuestionaireId = @i_TaskGeneralizedId
                 --AND UserQuestionaire.StatusCode = 'A'
                 --AND Questionaire.StatusCode = 'A'    
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Encounter\Appointment'
            BEGIN
                  SELECT
                      @i_TypeID = EncounterType.EncounterTypeId
                  FROM
                      UserEncounters
                  INNER JOIN EncounterType
                      ON UserEncounters.EncounterTypeId = EncounterType.EncounterTypeId    
                  WHERE
                      UserEncounterID = @i_TaskGeneralizedId
                  --AND UserEncounters.StatusCode = 'A'
                  --AND EncounterType.StatusCode = 'A'    
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Procedure'
            BEGIN
                  SELECT
                      @i_TypeID = CodeSetProcedure.ProcedureId
                  FROM
                      UserProcedureCodes
                  INNER JOIN CodeSetProcedure
                      ON UserProcedureCodes.ProcedureId = CodeSetProcedure.ProcedureId    
                  WHERE
                      UserProcedureId = @i_TaskGeneralizedId
                  --AND UserProcedureCodes.StatusCode = 'A'
                  --AND CodeSetProcedure.StatusCode = 'A'    
            END
      ELSE
         IF @v_TaskTypeName = 'Immunization'
            BEGIN
                  SELECT
                      @i_TypeID = Immunizations.ImmunizationID
                  FROM
                      UserImmunizations
                  INNER JOIN Immunizations
                      ON Immunizations.ImmunizationID = UserImmunizations.ImmunizationID      
                  WHERE
                      UserImmunizationID = @i_TaskGeneralizedId
                  --AND Immunizations.StatusCode = 'A'    
                  --AND UserImmunizations.StatusCode = 'A'
            END
      ELSE
         IF @v_TaskTypeName = 'Medication Prescription'
            BEGIN
                  SELECT
                      @i_TypeID = CodeSetDrug.DrugCodeId
                  FROM
                      UserDrugCodes
                  INNER JOIN CodeSetDrug
                      ON CodeSetDrug.DrugCodeId = UserDrugCodes.DrugCodeId   
                  WHERE
                      UserDrugId = @i_TaskGeneralizedId
                  --AND UserDrugCodes.StatusCode = 'A'    
                  --AND CodeSetDrug.StatusCode = 'A'
            END
	  ELSE
	     IF @v_TaskTypeName = 'Communications'
            BEGIN
				  SELECT
					  @i_TypeID = CommunicationType.CommunicationTypeId
				  FROM
				      UserCommunication
				  INNER JOIN CommunicationType
				      ON CommunicationType.CommunicationTypeId = UserCommunication.CommunicationTypeId     
				  WHERE
					  UserCommunicationId = @i_TaskGeneralizedId
				  --AND UserCommunication.StatusCode = 'A'
				  --AND CommunicationType.StatusCode = 'A'	  
				  
            END
      --ELSE
      --   IF @v_TaskTypeName = 'Evaluate Lab Results'
      --      BEGIN
      --            SELECT
      --                @i_TypeID = @v_TaskTypeName
      --      END
      ELSE
         IF @v_TaskTypeName = 'Schedule Health Risk Score'
            BEGIN
                  SELECT
                      @i_TypeID = HealthStatusScoreType.HealthStatusScoreId
                  FROM
                      UserHealthStatusScore
                  INNER JOIN HealthStatusScoreType 
                      ON HealthStatusScoreType.HealthStatusScoreId = UserHealthStatusScore.HealthStatusScoreId  
                  WHERE
                      UserHealthStatusId = @i_TaskGeneralizedId
                  --AND HealthStatusScoreType.StatusCode = 'A'
                  --AND UserHealthStatusScore.StatusCode = 'A'    
            END
      ELSE
         IF @v_TaskTypeName = 'Cohort Pending Delete Update'
            BEGIN
                  SELECT
                      @i_TypeID = CohortListId
                  FROM
                      CohortList
                  WHERE
                      CohortListId = @i_TaskGeneralizedId
                  --AND StatusCode = 'A'    
            END
      ELSE 
	     IF @v_TaskTypeName='Patient Education Material'
        	BEGIN
	              SELECT 
	                  @i_TypeID = PatientEducationMaterialID
	              FROM 
	                  PatientEducationMaterial pem
	              INNER JOIN EducationMaterial em 
	                  ON pem.EducationMaterialID = em.EducationMaterialID   
	              WHERE 
	                  pem.PatientEducationMaterialID = @i_TaskGeneralizedId
	              --AND StatusCode = 'A'    
	        END      
		ELSE 
	     IF @v_TaskTypeName='Other Tasks'
        	BEGIN
	              SELECT 
	                  @i_TypeID = at.AdhocTaskId
	              FROM 
	                  UserOtherTask uot
	              INNER JOIN AdhocTask at
	                  ON uot.AdhocTaskId = at.AdhocTaskId
	              WHERE 
	                  uot.UserOtherTaskId = @i_TaskGeneralizedId
	        END    
	  --ELSE 
	  --   IF @v_TaskTypeName='Schedule Phone Call'
   --     	BEGIN
	  --            SELECT 
	  --                @i_TypeID = @v_TaskTypeName
	  --            FROM 
	  --                UserPhoneCallLog 
	  --            WHERE 
	  --                UserPhoneCallId = @i_TaskGeneralizedId
	  --      END

      RETURN @i_TypeID
END
