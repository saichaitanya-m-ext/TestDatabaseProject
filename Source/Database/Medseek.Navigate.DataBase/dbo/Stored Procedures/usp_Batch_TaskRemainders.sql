/*    
----------------------------------------------------------------------------------------------   
Procedure Name: [usp_Batch_TaskRemainders]
Description   : This Stored procedure to Support Task Related Communication Template Generation
                for all open tasks.
Created By    : Rathnam   
Created Date  : 22-Nov-2012.    
----------------------------------------------------------------------------------------------
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 

-----------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Batch_TaskRemainders]
(
 @i_AppUserId KEYID
,@i_InputTaskID KEYID = NULL
,@d_TestingCurrentDate DATETIME = NULL
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END
            
            DECLARE
                   @i_TaskStatusID INT, @d_CurrentDate DATE 
            
            IF @d_TestingCurrentDate IS NOT NULL
               BEGIN
                     SET @d_CurrentDate = CONVERT(DATE,@d_TestingCurrentDate)
               END
               ELSE
               BEGIN
					SET @d_CurrentDate = CONVERT(DATE,GETDATE())
               END   
  
            SELECT
                @i_TaskStatusID = TaskStatusId
            FROM
                TaskStatus
            WHERE
                TaskStatusText = 'Open'

            INSERT INTO
                PatientCommunication
                (
                  PatientId
                ,CommunicationTypeId
                ,CommunicationTemplateId
                ,DateSent
                ,DateDue
                ,StatusCode
                ,CreatedByUserId
                ,CommunicationState
                ,ProgramID
                ,IsEnrollment
                ,IsSentIndicator
                )
                SELECT
                    Task.PatientId
                   ,Task.CommunicationTypeID
                   ,Task.CommunicationTemplateID
                   ,@d_CurrentDate
                   ,Task.TaskDueDate
                   ,'A'
                   ,@i_AppUserId
                   ,'Ready to Generate'
                   ,Task.ProgramID
                   ,0
                   ,0
                FROM
                    Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                    ON Task.TaskTypeId = TaskType.TaskTypeId
                INNER JOIN CommunicationType ct WITH ( NOLOCK )
                    ON ct.CommunicationTypeId = Task.CommunicationTypeID
                WHERE
                    Task.TaskStatusId = @i_TaskStatusID
                    AND ( TaskID = @i_InputTaskID 
                          OR @i_InputTaskID IS NULL
                        )
                    AND Task.IsEnrollment = 0
                    AND CONVERT(DATE , CASE
                                            WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                            AND RemainderState = 'B' THEN DATEADD(DD , -Task.RemainderDays , Task.TaskDueDate)
                                            WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                            AND RemainderState = 'A' THEN DATEADD(DD , Task.RemainderDays , Task.TaskDueDate)
                                       END) <= CONVERT(DATE , @d_CurrentDate)
                    AND ct.CommunicationType IN ( 'Fax' , 'SMS' , 'Email' , 'IVR' , 'Letter' )


            INSERT INTO
                TaskAttempts
                (
                  TaskId
                ,TaskTypeCommunicationID
                ,AttemptedContactDate
                ,Comments
                ,UserId
                ,NextContactDate
                ,TaskTerminationDate
                ,CommunicationTemplateID
                ,CommunicationSequence
                ,CommunicationTypeId
                ,AttemptStatus
                )
                SELECT
                    Task.TaskId
                   ,Task.RemainderID
                   ,CONVERT(DATE , CASE
                                            WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                            AND RemainderState = 'B' THEN DATEADD(DD , -Task.RemainderDays , Task.TaskDueDate)
                                            WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                            AND RemainderState = 'A' THEN DATEADD(DD , Task.RemainderDays , Task.TaskDueDate)
                                       END)
                   ,'Attempt as part of Automated scheduling'
                   ,@i_AppUserId
                   ,CASE
                         WHEN ISNULL(NextRemainderDays , 0) <> 0
                         AND NextRemainderState = 'B' THEN DATEADD(DD , -Task.NextRemainderDays , Task.TaskDueDate)
                         WHEN ISNULL(NextRemainderDays , 0) <> 0
                         AND NextRemainderState = 'A' THEN DATEADD(DD , Task.NextRemainderDays , Task.TaskDueDate)
                    END
                   ,CASE
                         WHEN TerminationDays IS NOT NULL THEN DATEADD(DD , TerminationDays , Task.TaskDueDate)
                    END
                   ,Task.CommunicationTemplateID
                   ,Task.CommunicationSequence
                   ,Task.CommunicationTypeID
                   ,1
                FROM
                    Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                    ON Task.TaskTypeId = TaskType.TaskTypeId
                INNER JOIN CommunicationType ct WITH ( NOLOCK )
                    ON ct.CommunicationTypeId = Task.CommunicationTypeID
                WHERE
                    Task.TaskStatusId = @i_TaskStatusID
                    AND TaskType.TaskTypeName NOT IN ( 'Cohort Pending Delete Update' , 'Evaluate Lab Results' )
					AND ( TaskID = @i_InputTaskID
					      OR @i_InputTaskID IS NULL
					    )
                    AND Task.IsEnrollment = 0
                    AND CONVERT(DATE , CASE
                                            WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                            AND RemainderState = 'B' THEN DATEADD(DD , -Task.RemainderDays , Task.TaskDueDate)
                                            WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                            AND RemainderState = 'A' THEN DATEADD(DD , Task.RemainderDays , Task.TaskDueDate)
                                       END) <= CONVERT(DATE , @d_CurrentDate)
                    --AND ct.CommunicationType IN ( 'Fax' , 'SMS' , 'Email' , 'IVR' , 'Letter' )

     --       INSERT INTO
     --           TaskAttempts
     --           (
     --             TaskId
     --           ,TaskTypeCommunicationID
     --           ,AttemptedContactDate
     --           ,Comments
     --           ,UserId
     --           ,NextContactDate
     --           ,TaskTerminationDate
     --           ,CommunicationTemplateID
     --           ,CommunicationSequence
     --           ,CommunicationTypeId
     --           ,AttemptStatus
     --           )
     --           SELECT
     --               Task.TaskId
     --              ,Task.RemainderID
     --              ,CONVERT(DATE , CASE
     --                                       WHEN ISNULL(Task.RemainderDays , 0) <> 0
     --                                       AND RemainderState = 'B' THEN DATEADD(DD , -Task.RemainderDays , Task.TaskDueDate)
     --                                       WHEN ISNULL(Task.RemainderDays , 0) <> 0
     --                                       AND RemainderState = 'A' THEN DATEADD(DD , Task.RemainderDays , Task.TaskDueDate)
     --                                  END)
     --              ,'Attempt as part of Automated scheduling'
     --              ,@i_AppUserId
     --              ,CASE
     --                    WHEN ISNULL(NextRemainderDays , 0) <> 0
     --                    AND NextRemainderState = 'B' THEN DATEADD(DD , -Task.NextRemainderDays , Task.TaskDueDate)
     --                    WHEN ISNULL(NextRemainderDays , 0) <> 0
     --                    AND NextRemainderState = 'A' THEN DATEADD(DD , Task.NextRemainderDays , Task.TaskDueDate)
     --               END
     --              ,CASE
     --                    WHEN TerminationDays IS NOT NULL THEN DATEADD(DD , TerminationDays , Task.TaskDueDate)
     --               END
     --              ,Task.CommunicationTemplateID
     --              ,Task.CommunicationSequence
     --              ,Task.CommunicationTypeID
     --              ,1
     --           FROM
     --               Task WITH ( NOLOCK )
     --           LEFT JOIN TaskType WITH ( NOLOCK )
     --               ON Task.TaskTypeId = TaskType.TaskTypeId
     --           INNER JOIN CommunicationType ct WITH ( NOLOCK )
     --               ON ct.CommunicationTypeId = Task.CommunicationTypeID
     --           WHERE
     --               Task.TaskStatusId = @i_TaskStatusID
     --               AND TaskType.TaskTypeName NOT IN ( 'Cohort Pending Delete Update' , 'Evaluate Lab Results' )
					--AND ( TaskID = @i_InputTaskID
					--      OR @i_InputTaskID IS NULL
					--    )
     --               AND Task.IsEnrollment = 0
     --               AND CONVERT(DATE , CASE
     --                                       WHEN ISNULL(Task.RemainderDays , 0) <> 0
     --                                       AND RemainderState = 'B' THEN DATEADD(DD , -Task.RemainderDays , Task.TaskDueDate)
     --                                       WHEN ISNULL(Task.RemainderDays , 0) <> 0
     --                                       AND RemainderState = 'A' THEN DATEADD(DD , Task.RemainderDays , Task.TaskDueDate)
     --                                  END) < CONVERT(DATE , @d_CurrentDate)
     --               AND ct.CommunicationType IN ( 'Phone Call' )



            UPDATE
                PatientCommunication
            SET
                DateSent = GETDATE()
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                INNER JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName = ( 'Communications' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE , CASE
                                        WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                        AND RemainderState = 'B' THEN DATEADD(DD , -Task.RemainderDays , Task.TaskDueDate)
                                        WHEN ISNULL(Task.RemainderDays , 0) <> 0
                                        AND RemainderState = 'A' THEN DATEADD(DD , Task.RemainderDays , Task.TaskDueDate)
                                   END) <= CONVERT(DATE , @d_CurrentDate)
                --AND ct.CommunicationType IN ( 'Fax' , 'SMS' , 'Email' , 'IVR' , 'Letter' )
                AND PatientCommunication.PatientCommunicationID = Task.PatientTaskID
                AND Task.TypeID = PatientCommunication.CommunicationTypeId

            INSERT INTO
                TaskAttempts
                (
                  TaskId
                ,TaskTypeCommunicationID
                ,AttemptedContactDate
                ,Comments
                ,UserId
                ,NextContactDate
                ,TaskTerminationDate
                ,CommunicationTemplateID
                ,CommunicationSequence
                ,CommunicationTypeId
                ,AttemptStatus
                )
                SELECT
                    Task.TaskId
                   ,Task.RemainderID
                   ,GETDATE()
                   ,'Attempt as part of Automated scheduling'
                   ,@i_AppUserId
                   ,CASE
                         WHEN ISNULL(NextRemainderDays , 0) <> 0
                         AND NextRemainderState = 'B' THEN DATEADD(DD , -Task.NextRemainderDays , Task.TaskDueDate)
                         WHEN ISNULL(NextRemainderDays , 0) <> 0
                         AND NextRemainderState = 'A' THEN DATEADD(DD , Task.NextRemainderDays , Task.TaskDueDate)
                    END
                   ,CASE
                         WHEN TerminationDays IS NOT NULL THEN DATEADD(DD , TerminationDays , Task.TaskDueDate)
                    END
                   ,Task.CommunicationTemplateID
                   ,Task.CommunicationSequence
                   ,Task.CommunicationTypeID
                   ,1
                FROM
                    Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                    ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                    ON ct.CommunicationTypeId = Task.CommunicationTypeID
                WHERE
                    Task.TaskStatusId = @i_TaskStatusID
					AND ( TaskID = @i_InputTaskID
					      OR @i_InputTaskID IS NULL
					    )
                    AND ISNULL(Task.IsEnrollment,0) = 0
                    AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                    AND Task.TerminationDays IS NOT NULL


            UPDATE
                PatientQuestionaire
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientQuestionaire.PatientQuestionaireId = Task.PatientTaskID
                AND TaskType.TaskTypeName = 'Questionnaire'
                AND Task.TypeID = PatientQuestionaire.QuestionaireId 


            UPDATE
                PatientGoal
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName IN ( 'Life Style Goal\Activity Follow Up' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientGoal.PatientGoalId = Task.PatientTaskID
                AND Task.TypeID = PatientGoal.LifeStyleGoalId

			/*
            UPDATE
                PatientEncounters
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName NOT IN ( 'Cohort Pending Delete Update' , 'Evaluate Lab Results' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientEncounters.PatientEncounterID = Task.PatientEncounterID
			*/
            UPDATE
                PatientProcedureGroupTask
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName IN ( 'Schedule Procedure' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , CONVERT(DATE,Task.TaskDueDate))) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientProcedureGroupTask.PatientProcedureGroupTaskID = Task.PatientTaskID
                AND Task.TypeID = PatientProcedureGroupTask.CodeGroupingID

            /*
            UPDATE
                PatientImmunizations
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName NOT IN ( 'Cohort Pending Delete Update' , 'Evaluate Lab Results' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientImmunizations.PatientImmunizationID = Task.PatientImmunizationID
                
                UPDATE
                PatientHealthStatusScore
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName NOT IN ( 'Cohort Pending Delete Update' , 'Evaluate Lab Results' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientHealthStatusScore.PatientHealthStatusId = Task.PatientHealthStatusId
                
			*/

            UPDATE
                PatientDrugCodes
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName IN ( 'Medication Prescription' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientDrugCodes.PatientDrugId = Task.PatientTaskID
                AND Task.TypeID = PatientDrugCodes.DrugCodeId


            UPDATE
                PatientOtherTask
            SET
                StatusCode = 'I'
               ,LastModifiedDate = GETDATE()
               ,LastModifiedByUserId = @i_AppUserId
            FROM
                Task WITH ( NOLOCK )
                LEFT JOIN TaskType WITH ( NOLOCK )
                ON Task.TaskTypeId = TaskType.TaskTypeId
                LEFT JOIN CommunicationType ct WITH ( NOLOCK )
                ON ct.CommunicationTypeId = Task.CommunicationTypeID
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
                AND TaskType.TaskTypeName IN ( 'Other Tasks' )
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND PatientOtherTask.PatientOtherTaskId = Task.PatientTaskID
                AND Task.TypeID = PatientOtherTask.AdhocTaskId


            UPDATE
                Task
            SET
                TaskStatusId = ( SELECT
                                     TaskStatusID
                                 FROM
                                     TaskStatus WITH ( NOLOCK )
                                 WHERE
                                     TaskStatusText = 'Closed Incomplete' )
               ,LastModifiedByUserId = @i_AppUserId
               ,LastModifiedDate = GETDATE()
            WHERE
                Task.TaskStatusId = @i_TaskStatusID
				AND ( TaskID = @i_InputTaskID
				      OR @i_InputTaskID IS NULL
				    )
                AND Task.IsEnrollment = 0
                AND CONVERT(DATE,DATEADD(DD , Task.TerminationDays , Task.TaskDueDate)) <= @d_CurrentDate
                AND Task.TerminationDays IS NOT NULL
                AND Task.ManualTaskName IS NOT NULL
      END TRY    
--------------------------------------------------------     
      BEGIN CATCH    
    -- Handle exception    
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
            RETURN @i_ReturnedErrorID
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_TaskRemainders] TO [FE_rohit.r-ext]
    AS [dbo];

