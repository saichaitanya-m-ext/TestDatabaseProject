


               
/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetRemainderByTaskID
Description   : This Function Returns Nextcommunication Details for the task
Created By    : Rathnam
Created Date  : 17-Nov-2012
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
20-12-2012 Rathnam commented the Communicationtempate & communiationtype where clauses
------------------------------------------------------------------------------
SELECT * FROM ufn_GetRemaindersByTaskID (15684,5,494,1)   
*/

CREATE FUNCTION [dbo].[ufn_GetRemaindersByTaskID]
(
  @i_TaskId KEYID
 ,@i_TasktypeId KEYID
 ,@i_TypeID KEYID
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
       
       
      IF NOT EXISTS ( SELECT
                          1
                      FROM
                          TaskTypeCommunications WITH(NOLOCK)
                      WHERE
                          TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
                          AND ( TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID )
                          AND TaskTypeCommunications.StatusCode = 'A' )
         BEGIN
         -------------------------Getting Next Communication Type for Default ---------------------


			   

               SELECT TOP 1
                   @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID
                           --,@v_CommunicationType = CommunicationType.CommunicationType
                  ,@i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID
                  ,@i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays
                  ,@i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete
                  ,@i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence
                  ,@i_CommunicationTypeID = CommunicationType.CommunicationTypeId
                  ,@v_RemainderState = TaskTypeCommunications.RemainderState
               FROM
                   TaskTypeCommunications WITH(NOLOCK)
               LEFT JOIN CommunicationType WITH(NOLOCK)
                   ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
               WHERE
                   TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
                   AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_CommunicationSequence,0)
                   AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
                   AND TaskTypeCommunications.StatusCode = 'A'
                   --AND TaskTypeCommunications.CommunicationTemplateID IS NOT NULL
                   --AND TaskTypeCommunications.TaskTypeCommunicationID IS NOT NULL
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence ASC

               SELECT
                   @i_TotalFutureTasks = COUNT(TaskTypeCommunicationID)
               FROM
                   TaskTypeCommunications WITH(NOLOCK)
               WHERE
                   TaskTypeGeneralizedID IS NULL
                   AND TaskTypeID = @i_TasktypeId
                   AND StatusCode = 'A'
                   AND CommunicationtypeID IS NOT NULL
                   
 
               
               SELECT TOP 1 @i_NextRemainderDays = ISNULL(CommunicationAttemptDays,NoOfDaysBeforeTaskClosedIncomplete),
                @i_NextRemainderState = RemainderState  FROM TaskTypeCommunications  
               WHERE
                   TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
                   AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_NextCommunicationSequence,0)
                   AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
                   AND TaskTypeCommunications.StatusCode = 'A'
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence ASC
                   
         END
      ELSE
         BEGIN
                       
         ----------------Getting Next CommunicationType for Specific ---------------------

               SELECT TOP 1
                   @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID
                  --,@v_CommunicationType = CommunicationType.CommunicationType
                  ,@i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID
                  ,@i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays
                  ,@i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete
                  ,@i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence
                  ,@i_CommunicationTypeID = CommunicationType.CommunicationTypeId
                  ,@v_RemainderState = TaskTypeCommunications.RemainderState
               FROM
                   TaskTypeCommunications WITH(NOLOCK)
               LEFT JOIN CommunicationType WITH(NOLOCK)
                   ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
               WHERE
                   TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
                   AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_CommunicationSequence,0)
                   AND ( TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID )
                   AND TaskTypeCommunications.StatusCode = 'A'
                   --AND TaskTypeCommunications.CommunicationTemplateID IS NOT NULL
                   --AND TaskTypeCommunications.TaskTypeCommunicationID IS NOT NULL
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence ASC

			   
			   SELECT TOP 1 @i_NextRemainderDays = ISNULL(CommunicationAttemptDays,NoOfDaysBeforeTaskClosedIncomplete),  @i_NextRemainderState = RemainderState  FROM TaskTypeCommunications  
               WHERE
                   TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
                   AND ( TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID )
                   AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_NextCommunicationSequence,0)
                   AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
                   AND TaskTypeCommunications.StatusCode = 'A'
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence ASC
			   
               SELECT
                   @i_TotalFutureTasks = COUNT(TaskTypeCommunicationID)
               FROM
                   TaskTypeCommunications
               WHERE
                   TaskTypeGeneralizedID = @i_TypeID
                   AND TaskTypeID = @i_TasktypeId
                   AND StatusCode = 'A'
                    AND CommunicationtypeID IS NOT NULL


         END

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



