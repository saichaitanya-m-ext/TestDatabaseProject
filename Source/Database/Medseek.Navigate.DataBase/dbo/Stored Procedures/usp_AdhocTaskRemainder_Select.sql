/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_AdhocTaskRemainder_Select] 
Description   : This procedure is used to get the remainders for the set of patients based on tasktype generalizedid
Created By    : Rathnam
Created Date  : 07-Nov-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY  

----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_AdhocTaskRemainder_Select]
(
 @i_AppUserId KEYID
,@t_PatientIdList TTYPEKEYID READONLY
,@i_TaskTypeName VARCHAR(150)
,@i_TaskTypeGeneralizedID KEYID = NULL
,@d_TaskDuedate DATETIME
,@i_ManualTaskName VARCHAR(300) = NULL
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
            IF ( @i_ManualTaskName IS NULL )
               BEGIN
					 --IF @i_TaskTypeName = 'Medication Titration'
						--			   BEGIN
						--			   SET @i_TaskTypeName = 'Questionnaire'
						--			   END

                     SELECT DISTINCT
                         ct.CommunicationTypeId
                        ,tr.CommunicationSequence
                        ,ct.CommunicationType ContactType
                        ,cte.CommunicationTemplateId TemplateNameID
                        ,cte.TemplateName
                        ,( CASE
                                WHEN tr.CommunicationAttemptDays = 0 THEN NULL
                                ELSE tr.CommunicationAttemptDays
                           END ) AS CommunicationAttemptDays
                        ,( CASE
                                WHEN tr.NoOfDaysBeforeTaskClosedIncomplete = 0 THEN NULL
                                ELSE tr.NoOfDaysBeforeTaskClosedIncomplete
                           END ) AS NoOfDaysBeforeTaskClosedIncomplete
                        ,tr.RemainderState
                        ,CASE WHEN tr.RemainderState = 'B' THEN tr.CommunicationAttemptDays END DaysBeforeDueDate
                        ,CASE WHEN tr.RemainderState = 'A' THEN tr.CommunicationAttemptDays END DaysAfterDueDate
                     FROM
                         Task t WITH (NOLOCK)
                     INNER JOIN @t_PatientIdList p
                         ON t.PatientId = p.tKeyId
                     INNER JOIN TaskRemainder tr  WITH (NOLOCK)
                         ON tr.TaskId = t.TaskId
                     INNER JOIN TaskStatus tss WITH (NOLOCK)
                         ON tss.TaskStatusId = t.TaskStatusId    
                     LEFT JOIN CommunicationType ct WITH (NOLOCK)
                         ON ct.CommunicationTypeId = tr.CommunicationTypeID
                     LEFT JOIN CommunicationTemplate cte WITH (NOLOCK)
                         ON cte.CommunicationTemplateId = tr.CommunicationTemplateID
                     LEFT JOIN TaskType te 
                         ON te.TaskTypeId = t.TaskTypeId
                     WHERE
                         t.TypeID = @i_TaskTypeGeneralizedID
                         AND CONVERT(DATE,t.TaskDueDate) = CONVERT(DATE,@d_TaskDuedate)
                         AND te.TaskTypeName = @i_TaskTypeName
                         AND tss.TaskStatusText IN ( 'Open' , 'Scheduled' )
                     ORDER BY CommunicationSequence

               END
            ELSE
               BEGIN
                     SELECT DISTINCT
                         ct.CommunicationTypeId
                        ,tr.CommunicationSequence
                        ,ct.CommunicationType ContactType
                        ,cte.CommunicationTemplateId TemplateNameID
                        ,cte.TemplateName
                        ,( CASE
                                WHEN tr.CommunicationAttemptDays = 0 THEN NULL
                                ELSE tr.CommunicationAttemptDays
                           END ) AS CommunicationAttemptDays
                        ,( CASE
                                WHEN tr.NoOfDaysBeforeTaskClosedIncomplete = 0 THEN NULL
                                ELSE tr.NoOfDaysBeforeTaskClosedIncomplete
                           END ) AS NoOfDaysBeforeTaskClosedIncomplete
                        ,tr.RemainderState   
                        ,CASE WHEN tr.RemainderState = 'B' THEN tr.CommunicationAttemptDays END DaysBeforeDueDate
                        ,CASE WHEN tr.RemainderState = 'A' THEN tr.CommunicationAttemptDays END DaysAfterDueDate
                     FROM
                         Task t  WITH (NOLOCK)
                     INNER JOIN @t_PatientIdList p
                         ON t.PatientId = p.tKeyId
                     INNER JOIN TaskRemainder tr WITH (NOLOCK)
                         ON tr.TaskId = t.TaskId
                     INNER JOIN TaskStatus tss WITH (NOLOCK)
                         ON tss.TaskStatusId = t.TaskStatusId    
                     LEFT JOIN CommunicationType ct WITH (NOLOCK)
                         ON ct.CommunicationTypeId = tr.CommunicationTypeID
                     LEFT JOIN CommunicationTemplate cte WITH (NOLOCK)
                         ON cte.CommunicationTemplateId = tr.CommunicationTemplateID
                     WHERE
                          CONVERT(DATE,t.TaskDueDate) = CONVERT(DATE,@d_TaskDuedate)
                         AND t.ManualTaskName = @i_ManualTaskName
                         AND tss.TaskStatusText IN ( 'Open' , 'Scheduled' )
                         ORDER BY CommunicationSequence
               END
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
    ON OBJECT::[dbo].[usp_AdhocTaskRemainder_Select] TO [FE_rohit.r-ext]
    AS [dbo];

