/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetTypeIdAndNamesByTaskGeneralizedId
Description   : This Function Returns TypeID and TypeName by TaskGeneralizedId 
Created By    : Rathnam
Created Date  : 14-Oct-2011
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
29-Feb-2012 Rathnam changed the lifestylegoal select statement getting from Goal
28-June-2012 Rathnam added Typeid column to the task table
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetTypeIdAndNamesByTaskGeneralizedId]
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
                   @v_TypeName = CONVERT(VARCHAR,LifeStyleGoals.LifeStyleGoalId) + ' - ' + ISNULL(LifeStyleGoals.LifeStyleGoal,'')
               FROM
                   LifeStyleGoals
               INNER JOIN PatientGoal
                   ON PatientGoal.LifeStyleGoalId = LifeStyleGoals.LifeStyleGoalId
               WHERE
                   PatientGoal.PatientGoalId = @i_TaskGeneralizedId
               --AND Activity.StatusCode = 'A' 
               --AND PatientGoalProgressLog.StatusCode = 'A' 
               --AND PatientGoal.StatusCode = 'A'      
         END
      ELSE
         IF @v_TaskTypeName = 'Program Enrollment'
            BEGIN
                  SELECT
                      @v_TypeName = CONVERT(VARCHAR,Program.ProgramId) + ' - ' + Program.ProgramName
                  FROM
                      Program
                  INNER JOIN UserPrograms
                      ON Program.ProgramId = UserPrograms.ProgramId
                  WHERE
                      UserPrograms.UserProgramId = @i_TaskGeneralizedId
                  --AND Program.StatusCode = 'A'    
                  --AND UserPrograms.StatusCode = 'A'    
            END
      ELSE
         IF @v_TaskTypeName IN ( 'Questionnaire' , 'Medication Titration' )
            BEGIN
                 SELECT
                     @v_TypeName = CONVERT(VARCHAR,Questionaire.QuestionaireId) + ' - ' +  Questionaire.QuestionaireName
                 FROM
                     Questionaire
                 INNER JOIN UserQuestionaire
                     ON Questionaire.QuestionaireId = UserQuestionaire.QuestionaireId
                 WHERE
                     UserQuestionaire.UserQuestionaireId = @i_TaskGeneralizedId
                 --AND UserQuestionaire.StatusCode = 'A'
                 --AND Questionaire.StatusCode = 'A'    
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Encounter\Appointment'
            BEGIN
                  SELECT
                      @v_TypeName = CONVERT(VARCHAR,EncounterType.EncounterTypeId) + ' - ' +  EncounterType.Name
                  FROM
                      EncounterType
                  INNER JOIN UserEncounters
                      ON EncounterType.EncounterTypeId = UserEncounters.EncounterTypeId
                  WHERE
                      UserEncounters.UserEncounterID = @i_TaskGeneralizedId
                  --AND UserEncounters.StatusCode = 'A'
                  --AND EncounterType.StatusCode = 'A'     
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Procedure'
            BEGIN
                  SELECT
                      @v_TypeName = CONVERT(VARCHAR,CodeSetProcedure.ProcedureId) + ' - ' + CodeSetProcedure.ProcedureName
                  FROM
                      CodeSetProcedure
                  INNER JOIN UserProcedureCodes
                      ON CodeSetProcedure.ProcedureId = UserProcedureCodes.ProcedureId
                  WHERE
                      UserProcedureCodes.UserProcedureId = @i_TaskGeneralizedId
                  --AND UserProcedureCodes.StatusCode = 'A'
                  --AND CodeSetProcedure.StatusCode = 'A'        
            END
      ELSE
         IF @v_TaskTypeName = 'Immunization'
            BEGIN
                  SELECT
                      @v_TypeName = CONVERT(VARCHAR,Immunizations.ImmunizationID) + ' - ' + Immunizations.Name
                  FROM
                      Immunizations
                  INNER JOIN UserImmunizations
                      ON Immunizations.ImmunizationID = UserImmunizations.ImmunizationID
                  WHERE
                      UserImmunizations.UserImmunizationID = @i_TaskGeneralizedId
                  --AND Immunizations.StatusCode = 'A'    
                  --AND UserImmunizations.StatusCode = 'A'    
            END
      ELSE
         IF @v_TaskTypeName = 'Medication Prescription'
            BEGIN
                  SELECT
                      @v_TypeName = CONVERT(VARCHAR,CodeSetDrug.DrugCodeId) + ' - ' + CodeSetDrug.DrugName
                  FROM
                      CodeSetDrug
                  INNER JOIN UserDrugCodes
                      ON CodeSetDrug.DrugCodeId = UserDrugCodes.DrugCodeId
                  WHERE
                      UserDrugCodes.UserDrugId = @i_TaskGeneralizedId
                  --AND UserDrugCodes.StatusCode = 'A'    
                  --AND CodeSetDrug.StatusCode = 'A'    
            END
	  ELSE
	     IF @v_TaskTypeName = 'Communications'
            BEGIN
				  SELECT
					  @v_TypeName = CONVERT(VARCHAR,CommunicationType.CommunicationTypeId) + ' - ' + CommunicationType
				  FROM
					  CommunicationType
				  INNER JOIN UserCommunication
					  ON CommunicationType.CommunicationTypeId = UserCommunication.CommunicationTypeId
				  WHERE
					  UserCommunication.UserCommunicationId = @i_TaskGeneralizedId
				  --AND UserCommunication.StatusCode = 'A'
				  --AND CommunicationType.StatusCode = 'A'	  
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
                      @v_TypeName = CONVERT(VARCHAR,HealthStatusScoreType.HealthStatusScoreId) + ' - ' + HealthStatusScoreType.Name
                  FROM
                      HealthStatusScoreType
                  INNER JOIN UserHealthStatusScore
                      ON HealthStatusScoreType.HealthStatusScoreId = UserHealthStatusScore.HealthStatusScoreId
                  WHERE
                      UserHealthStatusScore.UserHealthStatusId = @i_TaskGeneralizedId
                  --AND HealthStatusScoreType.StatusCode = 'A'
                  --AND UserHealthStatusScore.StatusCode = 'A'     
            END
      ELSE
         IF @v_TaskTypeName = 'Cohort Pending Delete Update'
            BEGIN
                  SELECT
                      @v_TypeName = CONVERT(VARCHAR,CohortList.CohortListId) + ' - ' +  CohortListName
                  FROM
                      CohortList
                  WHERE
                      CohortListId = @i_TaskGeneralizedId
                  --AND StatusCode = 'A'     
            END

	  ELSE 
	     IF @v_TaskTypeName='Schedule Phone Call'
        	BEGIN
	              SELECT 
	                  @v_TypeName = CONVERT(VARCHAR,UserPhoneCallId) + ' - '+ @v_TaskTypeName
	              FROM 
	                  UserPhoneCallLog 
	              WHERE 
	                  UserPhoneCallId = @i_TaskGeneralizedId
	              --AND StatusCode = 'A'  

	        END
      ELSE 
	     IF @v_TaskTypeName='Patient Education Material'
        	BEGIN
	              SELECT 
	                  @v_TypeName = CONVERT(VARCHAR,em.EducationMaterialID) + ' - ' + em.Name
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
	                  @v_TypeName = CONVERT(VARCHAR,at.AdhocTaskId) + ' - ' +  at.Name
	              FROM 
	                  UserOtherTask uot
	              INNER JOIN AdhocTask at
	                  ON uot.AdhocTaskId = at.AdhocTaskId
	              WHERE 
	                  uot.UserOtherTaskId = @i_TaskGeneralizedId
	        END          
      RETURN @v_TypeName
END
