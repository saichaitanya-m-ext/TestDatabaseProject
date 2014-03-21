

               
/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetAdhocRemaindersByTaskID
Description   : This Function Returns Nextcommunication Details for the task
Created By    : Rathnam
Created Date  : 17-Nov-2012
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
20-12-2012 Rathnam changed from inner join left join between following tables TaskRemainder, CommunicationType
------------------------------------------------------------------------------
SELECT * FROM ufn_GetAdhocRemaindersByTaskID (1916140, 1,3)   
*/
CREATE FUNCTION [dbo].[ufn_GetAdhocRemaindersByTaskID]
(
  @i_TaskId KEYID
 ,@i_CommunicationSequence SMALLINT
)
RETURNS @Results TABLE
(
  TaskID INT
 ,CommunicationCount INT
 ,CommunicationTemplateID INT
 ,CommunicationAttemptDays INT
 ,NoOfDaysBeforeTaskClosedIncomplete INT
 ,TaskTypeCommunicationID INT
 ,NextCommunicationSequence INT
 ,CommunicationTypeID INT
 ,TotalFutureTasks INT
 ,RemainderState VARCHAR(1)
 ,NextRemainderDays INT
 ,NextRemainderState VARCHAR(1)
)
AS
BEGIN
      DECLARE
              --@i_CommunicationSequence INT
              @v_CommunicationCount INT
             ,@v_ReturnValue VARCHAR(500)
             ,@i_CommunicationTemplateID KEYID
             ,@i_CommunicationAttemptDays INT
             ,@i_NoOfDaysBeforeTaskClosedIncomplete INT
             ,@i_TaskTypeCommunicationID KEYID
             ,@i_NextCommunicationSequence INT
             ,@i_CommunicationTypeID INT
             ,@i_TotalFutureTasks INT
             ,@v_RemainderState VARCHAR(1)
             ,@i_NextRemainderDays INT
             ,@i_NextRemainderState VARCHAR(1)
       

               SELECT TOP 1
                   @i_TaskTypeCommunicationID = TaskRemainder.TaskRemainderId
                  ,@i_CommunicationTemplateID = TaskRemainder.CommunicationTemplateID
                  ,@i_CommunicationAttemptDays = TaskRemainder.CommunicationAttemptDays
                  ,@i_NoOfDaysBeforeTaskClosedIncomplete = TaskRemainder.NoOfDaysBeforeTaskClosedIncomplete
                  ,@i_NextCommunicationSequence = TaskRemainder.CommunicationSequence
                  ,@i_CommunicationTypeID = CommunicationType.CommunicationTypeId
                  ,@v_RemainderState = TaskRemainder.RemainderState
               FROM
                   TaskRemainder WITH(NOLOCK)
               LEFT JOIN CommunicationType WITH(NOLOCK)
                   ON CommunicationType.CommunicationTypeId = TaskRemainder.CommunicationTypeID
               WHERE
                   TaskRemainder.TaskId = @i_TaskId
                   AND TaskRemainder.CommunicationSequence > ISNULL(@i_CommunicationSequence,0)
               ORDER BY
                   TaskRemainder.CommunicationSequence ASC

               SELECT
                   @i_TotalFutureTasks = COUNT(*)
               FROM
                   TaskRemainder WITH(NOLOCK)
               WHERE
				   TaskRemainder.TaskId = @i_TaskId
               
               SELECT TOP 1 @i_NextRemainderDays = ISNULL(CommunicationAttemptDays,NoOfDaysBeforeTaskClosedIncomplete)  ,
               @i_NextRemainderState = RemainderState
               FROM TaskRemainder  
               WHERE
                   TaskRemainder.TaskId = @i_TaskId
                   AND TaskRemainder.CommunicationSequence > ISNULL(@i_NextCommunicationSequence,0)
               ORDER BY
                   TaskRemainder.CommunicationSequence ASC
                   
         

      SELECT
          @v_CommunicationCount = COUNT(TaskId)
      FROM
          TaskAttempts WITH(NOLOCK)
      WHERE
          TaskAttempts.TaskId = @i_TaskId

      INSERT INTO
          @Results
          SELECT
              @i_TaskId
             ,@v_CommunicationCount
             ,@i_CommunicationTemplateID
             ,@i_CommunicationAttemptDays
             ,@i_NoOfDaysBeforeTaskClosedIncomplete
             ,@i_TaskTypeCommunicationID
             ,@i_NextCommunicationSequence
             ,@i_CommunicationTypeID
             ,@i_TotalFutureTasks
             ,@v_RemainderState
             ,@i_NextRemainderDays
             ,@i_NextRemainderState

      RETURN
END


