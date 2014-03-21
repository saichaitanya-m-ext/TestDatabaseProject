/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetTypeNamesByTaskGeneralizedId
Description   : This Function Returns TypeName by TypeID 
Created By    : Rathnam
Created Date  : 26-June-2012
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
09/07/2013:Santosh Changed the name 'Program Enrollment' to 'Managed Population Enrollment'
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetTypeNamesByTypeId]
     (
        @v_TaskTypeName VARCHAR(50)
       ,@i_TypeId KEYID
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
                  LifeStyleGoals WITH(NOLOCK)
               WHERE
                   LifeStyleGoals.LifeStyleGoalId = @i_TypeId
              
         END
      ELSE
         IF @v_TaskTypeName = 'Managed Population Enrollment'
            BEGIN
                  SELECT
                      @v_TypeName = Program.ProgramName
                  FROM
                      Program WITH(NOLOCK)
                  WHERE
                      Program.ProgramId = @i_TypeId
             
                  
            END
      ELSE
         IF @v_TaskTypeName IN ( 'Questionnaire' , 'Medication Titration' )
            BEGIN
                 SELECT
                     @v_TypeName = Questionaire.QuestionaireName
                 FROM
                     Questionaire WITH(NOLOCK)
                 WHERE
                     Questionaire.QuestionaireId = @i_TypeId
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Encounter\Appointment'
            BEGIN
                  SELECT
                      @v_TypeName = EncounterType.Name
                  FROM
                      EncounterType WITH(NOLOCK)
                  WHERE
                      EncounterType.EncounterTypeId = @i_TypeId
            END
      ELSE
         IF @v_TaskTypeName = 'Schedule Procedure'
            BEGIN
                  SELECT
                      @v_TypeName = CodeGrouping.CodeGroupingName
                  FROM
                      CodeGrouping WITH(NOLOCK)
                  WHERE
                      CodeGrouping.CodeGroupingID = @i_TypeId
            END
      ELSE
         IF @v_TaskTypeName = 'Immunization'
            BEGIN
                  SELECT
                      @v_TypeName = Immunizations.Name
                  FROM
                      Immunizations WITH(NOLOCK)
                  WHERE
                      Immunizations.ImmunizationID = @i_TypeId
            END
      ELSE
         IF @v_TaskTypeName = 'Medication Prescription'
            BEGIN
                  SELECT
                      @v_TypeName = CodeSetDrug.DrugName
                  FROM
                      CodeSetDrug WITH(NOLOCK)
                  WHERE
                      CodeSetDrug.DrugCodeId = @i_TypeId
            END
	  ELSE
	     IF @v_TaskTypeName = 'Communications'
            BEGIN
				  SELECT
					  @v_TypeName = CommunicationType
				  FROM
					  CommunicationType WITH(NOLOCK)
				  WHERE
					 CommunicationType.CommunicationTypeId = @i_TypeId
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
                      HealthStatusScoreType WITH(NOLOCK)
                  WHERE
                      HealthStatusScoreType.HealthStatusScoreId = @i_TypeId
            END
      ELSE
         IF @v_TaskTypeName = 'Cohort Pending Delete Update'
            BEGIN
                  SELECT
                      @v_TypeName = PopulationDefinitionName
                  FROM
                      PopulationDefinition WITH(NOLOCK)
                  WHERE
                      PopulationDefinitionID = @i_TypeId
            END

	  ELSE 
	     IF @v_TaskTypeName='Schedule Phone Call'
        	BEGIN
	              SELECT 
	                  @v_TypeName = @v_TaskTypeName
	        END
      ELSE 
	     IF @v_TaskTypeName='Patient Education Material'
        	BEGIN
	              
	              SELECT @v_TypeName = em.Name
	              FROM EducationMaterial em WITH(NOLOCK)
	              WHERE em.EducationMaterialID = @i_TypeId
	              --SELECT 
	              --    @v_TypeName = em.Name
	              --FROM 
	              --    PatientEducationMaterial pem
	              --INNER JOIN EducationMaterial em
	              --    ON pem.EducationMaterialID = em.EducationMaterialID      
	              --WHERE 
	              --    PatientEducationMaterialID = @i_TypeId
	        END
	   ELSE 
	     IF @v_TaskTypeName='Other Tasks'
        	BEGIN
	               SELECT 
	                  @v_TypeName = at.Name
	               FROM AdhocTask at  WITH(NOLOCK) 
	               WHERE at.AdhocTaskId = @i_TypeId
	                  
	              
	              --SELECT 
	              --    @v_TypeName = at.Name
	              --FROM 
	              --    UserOtherTask uot
	              --INNER JOIN AdhocTask at
	              --    ON uot.AdhocTaskId = at.AdhocTaskId
	              --WHERE 
	              --    uot.UserOtherTaskId = @i_TypeId
	        END     
      RETURN @v_TypeName
END


--SELECT [dbo].[ufn_GetTypeNamesByTypeId]('Managed Population Enrollment',126)

--SELECT * FROM TaskType
