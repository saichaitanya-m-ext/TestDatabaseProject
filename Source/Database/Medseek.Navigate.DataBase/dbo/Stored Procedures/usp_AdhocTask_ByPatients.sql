/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_AdhocTask_ByPatients]
Description   : This procedure is used to get the records from CareTeamTaskRights    
    table.        
Created By    : Rathnam
Created Date  : 06-Nov-2012          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
19-Mar-2013 P.V.P.Moahn  Modified table UserCareTeam  to PatientCareTeam 
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_AdhocTask_ByPatients]
(
 @i_AppUserId KEYID
,@t_PatientIdList TTYPEKEYID READONLY
,@b_IsScheduled VARCHAR(1) = 'S'
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON           
 -- Check if valid Application User ID is passed          
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END    
             
----------- Select CareTeamTaskRights details -------------------    

            SELECT DISTINCT
                ctr.TaskTypeId
               ,tt.TaskTypeName
            FROM
                CareTeamTaskRights ctr WITH(NOLOCK)
            INNER JOIN TaskType tt WITH(NOLOCK)
                ON tt.TaskTypeId = ctr.TaskTypeId
            INNER JOIN PatientCareTeam uc WITH(NOLOCK)
                ON uc.CareTeamId = ctr.CareTeamId
            INNER JOIN @t_PatientIdList p 
                ON p.tKeyId = uc.PatientID
            WHERE
                ctr.ProviderID = @i_AppUserId
                AND ctr.StatusCode = 'A'
                AND uc.StatusCode = 'A'
            ORDER BY
                ctr.TaskTypeId

            IF @b_IsScheduled = 'S'
               BEGIN
                     SELECT DISTINCT
                         '' PatientName --> For UI consistency
                        ,CONVERT(VARCHAR(10) , t.TaskDueDate , 101) TaskDueDate
                        ,t.TaskCompletedDate AS TaskCompletedDate
                        ,t.Comments
                        ,ts.TaskStatusText
                        ,tt.TaskTypeName
                        ,CASE
                              WHEN t.ManualTaskName IS NOT NULL THEN t.ManualTaskName
                              ELSE dbo.ufn_GetTypeNamesByTypeId(tt.TaskTypeName , t.TypeID)
                         END TypeName
                        ,dbo.ufn_GetUserNameByID(t.AssignedCareProviderId) AS AssignedCareProviderName
                     FROM
                         Task t WITH(NOLOCK)
                     INNER JOIN @t_PatientIdList p
                         ON p.tKeyId = t.PatientId
                     LEFT OUTER JOIN TaskType tt WITH(NOLOCK)
                         ON tt.TaskTypeId = t.TaskTypeId
                     INNER JOIN TaskStatus ts WITH(NOLOCK)
                         ON ts.TaskStatusId = t.TaskStatusId
                     WHERE
                         t.Isadhoc = 1
                         AND ts.TaskStatusText IN ( 'Scheduled' , 'Open' )
                         AND t.TaskCompletedDate IS NULL

               END
            ELSE
               BEGIN
					SELECT DISTINCT
                         dbo.ufn_GetUserNameByID(t.PatientId) AS PatientName
                        ,CONVERT(VARCHAR , t.TaskDueDate , 101) AS TaskDueDate
                        ,CONVERT(VARCHAR , t.TaskCompletedDate , 101) AS TaskCompletedDate
                        ,t.Comments Comments
                        ,ts.TaskStatusText
                        ,CASE
                              WHEN t.ManualTaskName IS NOT NULL THEN t.ManualTaskName
                              ELSE dbo.ufn_GetTypeNamesByTypeId(ty.TaskTypeName , t.TypeID)
                         END TypeName
                        ,ty.TaskTypeName
                        ,dbo.ufn_GetUserNameByID(t.AssignedCareProviderId) AS AssignedCareProviderName
                     FROM
                         Task t WITH(NOLOCK)
                     INNER JOIN @t_PatientIdList p
                         ON p.tKeyId = t.PatientId
                     INNER JOIN TaskStatus ts WITH(NOLOCK)
                         ON ts.TaskStatusId = t.TaskStatusId
                     INNER JOIN TaskType ty WITH(NOLOCK)
                         ON ty.TaskTypeId = t.TaskTypeId        
                     WHERE
                         t.IsAdhoc = 1
                     AND ts.TaskStatusText IN ( 'Closed Complete' )    
						
                     -- Questionnaire
   --                  SELECT DISTINCT
   --                      dbo.ufn_GetUserNameByID(usp.UserId) AS PatientName
   --                     ,CONVERT(VARCHAR , usp.DateDue , 101) AS TaskDueDate
   --                     ,CONVERT(VARCHAR , usp.DateTaken , 101) AS TaskCompletedDate
   --                     ,usp.Comments Comments
   --                     ,'Closed Complete' TaskStatusText
   --                     ,q.QuestionaireName TypeName
   --                     ,'Questionaire' TaskTypeName
   --                     ,dbo.ufn_GetUserNameByID(usp.AssignedCareProviderId) AS AssignedCareProviderName
   --                  FROM
   --                      UserQuestionaire usp
   --                  INNER JOIN @t_PatientIdList p
   --                      ON p.tKeyId = usp.UserId
   --                  INNER JOIN Questionaire q
   --                      ON usp.UserQuestionaireId = q.QuestionaireId
   --                  WHERE
   --                      usp.IsAdhoc = 1
   --                      AND DateTaken IS NOT NULL
   --                      AND NOT EXISTS ( SELECT
   --                                           1
   --                                       FROM
   --                                           Task t
   --                                       WHERE
   --                                           t.UserQuestionaireId = usp.UserQuestionaireId )
				
			----Schedule Encounter\Appointment

   --                  UNION
   --                  SELECT
   --                      dbo.ufn_GetUserNameByID(usp.UserId) AS PatientName
   --                     ,CONVERT(VARCHAR , usp.DateDue , 101) AS TaskDueDate
   --                     ,CONVERT(VARCHAR , usp.EncounterDate , 101) AS TaskCompletedDate
   --                     ,usp.Comments Comments
   --                     ,'Closed Complete' TaskStatusText
   --                     ,csp.Name TypeName
   --                     ,'Schedule Encounter\Appointment' TaskTypeName
   --                     ,dbo.ufn_GetUserNameByID(usp.CareTeamUserID) AS AssignedCareProviderName
   --                  FROM
   --                      UserEncounters usp
   --                  INNER JOIN @t_PatientIdList p
   --                      ON p.tKeyId = usp.UserId
   --                  INNER JOIN EncounterType csp
   --                      ON usp.EncounterTypeId = csp.EncounterTypeId
   --                  WHERE
   --                      IsAdhoc = 1
   --                      AND EncounterDate IS NOT NULL
   --                      AND NOT EXISTS ( SELECT
   --                                           1
   --                                       FROM
   --                                           Task t
   --                                       WHERE
   --                                           t.UserEncounterID = usp.UserEncounterID )
   --                  UNION 
   --                  -- Schedule Procedure
   --                  SELECT
   --                      dbo.ufn_GetUserNameByID(usp.UserId) AS PatientName
   --                     ,CONVERT(VARCHAR , usp.DueDate , 101) AS TaskDueDate
   --                     ,CONVERT(VARCHAR , usp.ProcedureCompletedDate , 101) AS TaskCompletedDate
   --                     ,usp.Commments Comments
   --                     ,'Closed Complete' TaskStatusText
   --                     ,csp.ProcedureName TypeName
   --                     ,'Schedule Procedure' TaskTypeName
   --                     ,dbo.ufn_GetUserNameByID(usp.AssignedCareProviderId) AS AssignedCareProviderName
   --                  FROM
   --                      UserProcedureCodes usp
   --                  INNER JOIN @t_PatientIdList p
   --                      ON p.tKeyId = usp.UserId
   --                  INNER JOIN CodeSetProcedure csp
   --                      ON usp.ProcedureId = csp.ProcedureId
   --                  WHERE
   --                      IsAdhoc = 1
   --                      AND ProcedureCompletedDate IS NOT NULL
   --                      AND NOT EXISTS ( SELECT
   --                                           1
   --                                       FROM
   --                                           Task t
   --                                       WHERE
   --                                           t.UserProcedureId = usp.UserProcedureId )
   --                  UNION
   --                  --Immunization
   --                  SELECT
   --                      dbo.ufn_GetUserNameByID(usp.UserId) AS PatientName
   --                     ,CONVERT(VARCHAR , usp.DueDate , 101) AS TaskDueDate
   --                     ,CONVERT(VARCHAR , usp.ImmunizationDate , 101) AS TaskCompletedDate
   --                     ,usp.Comments Comments
   --                     ,'Closed Complete' TaskStatusText
   --                     ,csp.Name TypeName
   --                     ,'Immunization' TaskTypeName
   --                     ,dbo.ufn_GetUserNameByID(usp.AssignedCareProviderId) AS AssignedCareProviderName
   --                  FROM
   --                      UserImmunizations usp
   --                  INNER JOIN @t_PatientIdList p
   --                      ON p.tKeyId = usp.UserId
   --                  INNER JOIN Immunizations csp
   --                      ON usp.ImmunizationID = csp.ImmunizationID
   --                  WHERE
   --                      IsAdhoc = 1
   --                      AND ImmunizationDate IS NOT NULL
   --                      AND NOT EXISTS ( SELECT
   --                                           1
   --                                       FROM
   --                                           Task t
   --                                       WHERE
   --                                           t.UserImmunizationID = usp.UserImmunizationID )
   --                  UNION
				
   --                  --Medication Titration
   --                  SELECT
   --                      dbo.ufn_GetUserNameByID(usp.UserId) AS PatientName
   --                     ,CONVERT(VARCHAR , usp.DueDate , 101) AS TaskDueDate
   --                     ,CONVERT(VARCHAR , usp.ProcedureCompletedDate , 101) AS TaskCompletedDate
   --                     ,usp.Commments Comments
   --                     ,'Closed Complete' TaskStatusText
   --                     ,csp.ProcedureName TypeName
   --                     ,'Schedule Procedure' TaskTypeName
   --                     ,dbo.ufn_GetUserNameByID(usp.AssignedCareProviderId) AS AssignedCareProviderName
   --                  FROM
   --                      UserProcedureCodes usp
   --                  INNER JOIN @t_PatientIdList p
   --                      ON p.tKeyId = usp.UserId
   --                  INNER JOIN CodeSetProcedure csp
   --                      ON usp.ProcedureId = csp.ProcedureId
   --                  WHERE
   --                      IsAdhoc = 1
   --                      AND ProcedureCompletedDate IS NOT NULL
   --                      AND NOT EXISTS ( SELECT
   --                                           1
   --                                       FROM
   --                                           Task t
   --                                       WHERE
   --                                           t.UserProcedureId = usp.UserProcedureId )
   --                  UNION
   --                  --Medication Prescription
   --                  SELECT
   --                      dbo.ufn_GetUserNameByID(usp.UserId) AS PatientName
   --                     ,CONVERT(VARCHAR , usp.DatePrescribed , 101) AS TaskDueDate
   --                     ,CONVERT(VARCHAR , usp.DateFilled , 101) AS TaskCompletedDate
   --                     ,usp.Comments Comments
   --                     ,'Closed Complete' TaskStatusText
   --                     ,csp.DrugName TypeName
   --                     ,'Medication Prescription' TaskTypeName
   --                     ,dbo.ufn_GetUserNameByID(usp.CareTeamUserID) AS AssignedCareProviderName
   --                  FROM
   --                      UserDrugCodes usp
   --                  INNER JOIN @t_PatientIdList p
   --                      ON p.tKeyId = usp.UserId    
   --                  INNER JOIN CodeSetDrug csp
   --                      ON usp.DrugCodeId = csp.DrugCodeId
   --                  WHERE
   --                      IsAdhoc = 1
   --                      AND DateFilled IS NOT NULL
   --                      AND NOT EXISTS ( SELECT
   --                                           1
   --                                       FROM
   --                                           Task t
   --                                       WHERE
   --                                           t.UserDrugID1 = usp.UserDrugId )


               END
      END TRY
--------------------------------------------------------------------------------------------------------------------------------------      
      BEGIN CATCH          
    -- Handle exception          
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_AdhocTask_ByPatients] TO [FE_rohit.r-ext]
    AS [dbo];

