



               
/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetNextCommunicationDetials
Description   : This Function Returns Nextcommunication Details for the task
Created By    : Rathnam
Created Date  : 26-June-2011
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
------------------------------------------------------------------------------
SELECT * FROM ufn_GetNextCommunicationDetials_1 (793273, 3)   
*/
CREATE FUNCTION [dbo].[ufn_GetNextCommunicationDetials]
(
  @i_TaskId keyid
)
RETURNS @Results TABLE
(
  TaskID int ,
  CommunicationType sourcename ,
  CommunicationCount int ,
  CommunicationTemplateID int ,
  CommunicationAttemptDays int ,
  NoOfDaysBeforeTaskClosedIncomplete int ,
  TaskTypeCommunicationID int ,
  NextCommunicationSequence int ,
  CommunicationTypeID int ,
  NextContactedDate datetime ,
  TaskTerminationDate datetime ,
  TotalFutureTasks int ,
  AdhocAttemptContactDate datetime
)
AS
BEGIN
      DECLARE
              @v_CommunicationType sourcename ,
              @i_CommunicationSequence int ,
              @v_CommunicationCount int ,
              @d_TaskTerminationDate datetime ,
              @v_ReturnValue varchar(500) ,
              @i_CommunicationTemplateID keyid ,
              @i_CommunicationAttemptDays int ,
              @i_NoOfDaysBeforeTaskClosedIncomplete int ,
              @i_TaskTypeCommunicationID keyid ,
              @i_NextCommunicationSequence int ,
              @d_NextContactedDate date ,
              @d_TerminationDate date ,
              @i_CommunicationTypeID int ,
              @d_AttemptedContactDate date ,
              @i_TotalFutureTasks int ,
              @v_AdhocCommunicationType varchar(100) ,
              @i_AdhocCommunicationTemplateID int ,
              @d_AdhocNextContactedDate datetime ,
              @d_AdhocTaskTerminationDate datetime ,
              @i_AdhocNextCommunicationSequence int ,
              @i_AdhocCommunicationTypeID int ,
              @i_AdhocTasktypeCommunicationID int ,
              @d_AdhocAttemptContactDate datetime ,
              @i_TypeID int ,
              @i_TasktypeId int

      SELECT
          @i_TypeID = TypeID ,
          @i_TasktypeId = TasktypeId
      FROM
          Task
      WHERE
          TaskId = @i_TaskId

		  	 ---- Getting the Next communications from the manually added taskattempts communicationtypes insted of getting from the 
	  --    tasktypecommunications
      IF EXISTS ( SELECT
                      1
                  FROM
                      TaskAttempts
                  WHERE
                      TaskId = @i_TaskId
                      AND CommunicationSequence IS NULL
                      AND AttemptedContactDate IS NULL )

         BEGIN

               SELECT TOP 1
                   @i_AdhocTasktypeCommunicationID = NULL ,
                   @v_AdhocCommunicationType = CommunicationType.CommunicationType ,
                   @i_AdhocCommunicationTemplateID = TaskAttempts.CommunicationTemplateID ,
                   @d_AdhocNextContactedDate = TaskAttempts.NextContactDate ,
                   @d_AdhocTaskTerminationDate = TaskAttempts.TaskTerminationDate ,
                   @i_AdhocNextCommunicationSequence = TaskAttempts.CommunicationSequence ,
                   @i_AdhocCommunicationTypeID = CommunicationType.CommunicationTypeId ,
                   @d_AdhocAttemptContactDate = TaskAttempts.NextContactDate
               FROM
                   TaskAttempts
               INNER JOIN CommunicationType
                   ON TaskAttempts.CommunicationTypeId = CommunicationType.CommunicationTypeId
               WHERE
                   TaskId = @i_TaskId
                   AND TasktypeCommunicationID IS NULL
                   AND AttemptedContactDate IS NULL
               ORDER BY
                   NextContactDate
                   
                   --PRINT 'ADHOC REMAINDER'

               --SELECT
               --    @i_TotalFutureTasks = COUNT(TaskId)
               --FROM
               --    TaskAttempts
               --WHERE
               --    TaskId = @i_TaskId

         END
      ---------------- Getting IsAhoc related communications


      IF EXISTS ( SELECT
                      1
                  FROM
                      Task
                  WHERE
                      TaskId = @i_TaskId
                      AND Isadhoc = 1 )
         BEGIN
               IF EXISTS ( SELECT
                               1
                           FROM
                               AdhocTaskSchduledAttempts
                           WHERE
                               TaskId = @i_TaskId )
                  BEGIN


                        SELECT TOP 1
                            @i_CommunicationSequence = TaskAttempts.CommunicationSequence ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate ,
                            @d_AttemptedContactDate = TaskAttempts.AttemptedContactDate ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                        FROM
                            TaskAttempts
                        INNER JOIN AdhocTaskSchduledAttempts
                            ON AdhocTaskSchduledAttempts.TaskId = TaskAttempts.TaskId
                        WHERE
                            TaskAttempts.TaskId = @i_TaskId
                            AND TaskAttempts.CommunicationSequence IS NOT NULL
                        ORDER BY
                            TaskAttempts.CommunicationSequence DESC

                        SELECT TOP 1
                            @i_TaskTypeCommunicationID = AdhocTaskSchduledAttempts.AdhocTaskSchduledAttemptsId ,
                            @v_CommunicationType = CommunicationType.CommunicationType ,
                            @i_CommunicationTemplateID = AdhocTaskSchduledAttempts.CommunicationTemplateID ,
                            @i_CommunicationAttemptDays = AdhocTaskSchduledAttempts.CommunicationAttemptDays ,
                            @i_NoOfDaysBeforeTaskClosedIncomplete = AdhocTaskSchduledAttempts.NoOfDaysBeforeTaskClosedIncomplete ,
                            @i_NextCommunicationSequence = AdhocTaskSchduledAttempts.CommunicationSequence ,
                            @i_CommunicationTypeID = CommunicationType.CommunicationTypeId
                        FROM
                            AdhocTaskSchduledAttempts
                        INNER JOIN CommunicationType
                            ON CommunicationType.CommunicationTypeId = AdhocTaskSchduledAttempts.CommunicationTypeID
                        WHERE
                            AdhocTaskSchduledAttempts.CommunicationSequence > ISNULL(@i_CommunicationSequence , 0)
                            AND AdhocTaskSchduledAttempts.CommunicationTemplateID IS NOT NULL
                            AND AdhocTaskSchduledAttempts.TaskId = @i_TaskId
                        ORDER BY
                            AdhocTaskSchduledAttempts.CommunicationSequence ASC

                        SELECT
                            @i_TotalFutureTasks = COUNT(TaskId)
                        FROM
                            AdhocTaskSchduledAttempts
                        WHERE
                            TaskId = @i_TaskId


                        SELECT
                            @i_TotalFutureTasks = COUNT(AdhocTaskSchduledAttemptsId)
                        FROM
                            AdhocTaskSchduledAttempts
                        WHERE
                            TaskId = @i_TaskId

						--PRINT 'ADHOC SCHEDULE'
                  END
                        
	                -- IF NOT Found need to get defualt schedule from organization level

               ELSE
                  BEGIN

                        SELECT TOP 1
                            @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate ,
                            @d_AttemptedContactDate = TaskAttempts.AttemptedContactDate ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                        FROM
                            TaskAttempts
                        INNER JOIN TaskTypeCommunications
                            ON TaskTypeCommunications.TasktypeCommunicationID = TaskAttempts.TasktypeCommunicationID
                        WHERE
                            TaskAttempts.TaskId = @i_TaskId
                            AND TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
                            AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
                            AND TaskTypeCommunications.StatusCode = 'A'
                            AND TaskAttempts.CommunicationSequence IS NOT NULL
                        ORDER BY
                            TaskTypeCommunications.CommunicationSequence DESC

                        SELECT TOP 1
                            @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID ,
                            @v_CommunicationType = CommunicationType.CommunicationType ,
                            @i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID ,
                            @i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays ,
                            @i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete ,
                            @i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence ,
                            @i_CommunicationTypeID = CommunicationType.CommunicationTypeId
                        FROM
                            TaskTypeCommunications
                        INNER JOIN CommunicationType
                            ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
                        WHERE
                            TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
                            AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_CommunicationSequence , 0)
                            AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
                            AND TaskTypeCommunications.StatusCode = 'A'
                            AND TaskTypeCommunications.CommunicationTemplateID IS NOT NULL
                            AND TaskTypeCommunications.TaskTypeCommunicationID IS NOT NULL
                        ORDER BY
                            TaskTypeCommunications.CommunicationSequence ASC

                        SELECT
                            @i_TotalFutureTasks = COUNT(TaskTypeCommunicationID)
                        FROM
                            TaskTypeCommunications
                        WHERE
                            TaskTypeGeneralizedID IS NULL
                            AND TaskTypeID = @i_TasktypeId
                            AND StatusCode = 'A'
                             --PRINT 'ADHOC DEFAULT'
                  END



         --                IF @i_CommunicationAttemptDays IS NOT NULL
         --                        BEGIN
									--SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , CASE WHEN @i_NextCommunicationSequence  = 1 THEN GETDATE() ELSE @d_AttemptedContactDate END)
         --                        END
         --                         SELECT @d_NextContactedDate
               IF @i_CommunicationAttemptDays IS NOT NULL
                  BEGIN
                        SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , CASE
                                                                                                   WHEN @i_NextCommunicationSequence = 1 THEN GETDATE()
                                                                                                   ELSE @d_AttemptedContactDate
                                                                                              END)
                  END

               IF CONVERT(date , @d_AdhocNextContactedDate) <= CONVERT(date , @d_NextContactedDate)
               AND @i_NextCommunicationSequence = 1
                  BEGIN
                        SET @d_NextContactedDate = @d_AdhocNextContactedDate
                  END
                                 
                                 --IF @d_AttemptedContactDate IS NOT NULL
                                 --   BEGIN
                                 --         SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , @d_AttemptedContactDate)
                                 --   END
                                 --ELSE
                                 --   BEGIN
                                 --         SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , GETDATE())
                                 --   END

               IF @i_NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL
                  BEGIN

                        SET @d_TaskTerminationDate = DATEADD(DD , @i_NoOfDaysBeforeTaskClosedIncomplete , isnull(@d_AttemptedContactDate , getdate()))
                  END

         END
      ELSE
         BEGIN


               IF NOT EXISTS ( SELECT
                                   1
                               FROM
                                   TaskTypeCommunications
                               WHERE
                                   TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
                                   AND ( TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID )
                                   AND TaskTypeCommunications.StatusCode = 'A' )
                  BEGIN
         -------------------------Getting Next Communication Type for Default ---------------------
                        --PRINT 'DEFAULT'
                        SELECT TOP 1
                            @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate ,
                            @d_AttemptedContactDate = TaskAttempts.AttemptedContactDate ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                        FROM
                            TaskAttempts
                        INNER JOIN TaskTypeCommunications
                            ON TaskTypeCommunications.TasktypeCommunicationID = TaskAttempts.TasktypeCommunicationID
                        WHERE
                            TaskAttempts.TaskId = @i_TaskId
                            AND TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
                            AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
                            AND TaskTypeCommunications.StatusCode = 'A'
                            AND TaskAttempts.CommunicationSequence IS NOT NULL
                        ORDER BY
                            TaskTypeCommunications.CommunicationSequence DESC


                        SELECT TOP 1
                            @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID ,
                            @v_CommunicationType = CommunicationType.CommunicationType ,
                            @i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID ,
                            @i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays ,
                            @i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete ,
                            @i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence ,
                            @i_CommunicationTypeID = CommunicationType.CommunicationTypeId
                        FROM
                            TaskTypeCommunications
                        INNER JOIN CommunicationType
                            ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
                        WHERE
                            TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
                            AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_CommunicationSequence , 0)
                            AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
                            AND TaskTypeCommunications.StatusCode = 'A'
                            AND TaskTypeCommunications.CommunicationTemplateID IS NOT NULL
                            AND TaskTypeCommunications.TaskTypeCommunicationID IS NOT NULL
                        ORDER BY
                            TaskTypeCommunications.CommunicationSequence ASC



                        SELECT
                            @i_TotalFutureTasks = COUNT(TaskTypeCommunicationID)
                        FROM
                            TaskTypeCommunications
                        WHERE
                            TaskTypeGeneralizedID IS NULL
                            AND TaskTypeID = @i_TasktypeId
                            AND StatusCode = 'A'

                                 
                                 
                                 --DECLARE @i_CommunicationAttemptDays INT , @d_AttemptedContactDate DATE = GETDATE(), @d_NextContactedDate DATETIME

                        IF @i_CommunicationAttemptDays IS NOT NULL
                           BEGIN
                                 SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , CASE
                                                                                                            WHEN @i_NextCommunicationSequence = 1 THEN GETDATE()
                                                                                                            ELSE @d_AttemptedContactDate
                                                                                                       END)
                           END

                        IF CONVERT(date , @d_AdhocNextContactedDate) <= CONVERT(date , @d_NextContactedDate)
                        AND @i_NextCommunicationSequence = 1
                           BEGIN
                                 SET @d_NextContactedDate = @d_AdhocNextContactedDate
                           END
                                 
                                 --IF @d_AttemptedContactDate IS NOT NULL
                                 --   BEGIN
                                 --         SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , @d_AttemptedContactDate)
                                 --   END
                                 --ELSE
                                 --   BEGIN
                                 --         SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , GETDATE())
                                 --   END

                        IF @i_NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL
                           BEGIN

                                 SET @d_TaskTerminationDate = DATEADD(DD , @i_NoOfDaysBeforeTaskClosedIncomplete , isnull(@d_AttemptedContactDate , getdate()))
                           END
                  END
               ELSE
                  BEGIN
                        --PRINT 'SPECIFIC'
         ----------------Getting Next CommunicationType for Specific ---------------------
                        SELECT TOP 1
                            @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate ,
                            @d_AttemptedContactDate = TaskAttempts.AttemptedContactDate ,
                            @d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                        FROM
                            TaskAttempts
                        INNER JOIN TaskTypeCommunications
                            ON TaskTypeCommunications.TasktypeCommunicationID = TaskAttempts.TasktypeCommunicationID
                        WHERE
                            TaskAttempts.TaskId = @i_TaskId
                            AND TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
                            AND ( TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID )
                            AND TaskTypeCommunications.StatusCode = 'A'
                            AND TaskAttempts.CommunicationSequence IS NOT NULL
                        ORDER BY
                            TaskTypeCommunications.CommunicationSequence DESC
                        SELECT TOP 1
                            @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID ,
                            @v_CommunicationType = CommunicationType.CommunicationType ,
                            @i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID ,
                            @i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays ,
                            @i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete ,
                            @i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence ,
                            @i_CommunicationTypeID = CommunicationType.CommunicationTypeId
                        FROM
                            TaskTypeCommunications
                        INNER JOIN CommunicationType
                            ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
                        WHERE
                            TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
                            AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_CommunicationSequence , 0)
                            AND ( TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID )
                            AND TaskTypeCommunications.StatusCode = 'A'
                            AND TaskTypeCommunications.CommunicationTemplateID IS NOT NULL
                            AND TaskTypeCommunications.TaskTypeCommunicationID IS NOT NULL
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

         --                         IF @i_CommunicationAttemptDays IS NOT NULL
         --                        BEGIN
									--SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , CASE WHEN @i_NextCommunicationSequence  = 1 THEN GETDATE() ELSE @d_AttemptedContactDate END)
         --                        END
         --                         SELECT @d_NextContactedDate
                        IF @i_CommunicationAttemptDays IS NOT NULL
                           BEGIN
                                 SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , CASE
                                                                                                            WHEN @i_NextCommunicationSequence = 1 THEN GETDATE()
                                                                                                            ELSE @d_AttemptedContactDate
                                                                                                       END)
                           END

                        IF CONVERT(date , @d_AdhocNextContactedDate) <= CONVERT(date , @d_NextContactedDate)
                        AND @i_NextCommunicationSequence = 1
                           BEGIN
                                 SET @d_NextContactedDate = @d_AdhocNextContactedDate
                           END
                                 
                                 --IF @d_AttemptedContactDate IS NOT NULL
                                 --   BEGIN
                                 --         SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , @d_AttemptedContactDate)
                                 --   END
                                 --ELSE
                                 --   BEGIN
                                 --         SET @d_NextContactedDate = DATEADD(DD , @i_CommunicationAttemptDays , GETDATE())
                                 --   END

                        IF @i_NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL
                           BEGIN

                                 SET @d_TaskTerminationDate = DATEADD(DD , @i_NoOfDaysBeforeTaskClosedIncomplete , isnull(@d_AttemptedContactDate , getdate()))
                           END
                  END
         END
        

      --IF @d_TaskTerminationDate IS NULL
      --   BEGIN
      --         SELECT TOP 1
      --             @d_TaskTerminationDate = TaskTerminationDate
      --         FROM
      --             TaskAttempts
      --         WHERE
      --             TaskId = @i_TaskId
      --         ORDER BY
      --             CommunicationSequence DESC
      --   END

      SELECT
          @v_CommunicationCount = COUNT(TaskId)
      FROM
          TaskAttempts
      WHERE
          TaskAttempts.TaskId = @i_TaskId
          AND TaskAttempts.AttemptedContactDate IS NOT NULL
          AND TaskAttempts.CommunicationSequence IS NOT NULL

      IF EXISTS ( SELECT
                      1
                  FROM
                      TaskAttempts
                  WHERE
                      CommunicationSequence IS NOT NULL
                      AND TaskTerminationDate IS NOT NULL )
      AND @d_TaskTerminationDate <= ( SELECT TOP 1
                                          max(TaskTerminationDate)
                                      FROM
                                          TaskAttempts
                                      WHERE
                                          TaskId = @i_TaskId
                                          AND CommunicationSequence IS NULL
                                          AND AttemptedContactDate IS NOT NULL )
         BEGIN
               SELECT TOP 1
                   @i_AdhocTasktypeCommunicationID = NULL ,
                   @v_AdhocCommunicationType = NULL--CommunicationType.CommunicationType
                   ,
                   @i_AdhocCommunicationTemplateID = NULL--TaskAttempts.CommunicationTemplateID
                   ,
                   @d_AdhocNextContactedDate = TaskAttempts.NextContactDate ,
                   @d_AdhocTaskTerminationDate = TaskAttempts.TaskTerminationDate ,
                   @i_AdhocNextCommunicationSequence = NULL--TaskAttempts.CommunicationSequence
                   ,
                   @i_AdhocCommunicationTypeID = NULL--CommunicationType.CommunicationTypeId
               FROM
                   TaskAttempts
               INNER JOIN CommunicationType
                   ON TaskAttempts.CommunicationTypeId = CommunicationType.CommunicationTypeId
               WHERE
                   TaskId = @i_TaskId
                   AND TasktypeCommunicationID IS NULL
                   AND CommunicationSequence IS NULL
                   ----AND AttemptedContactDate IS NULL
               ORDER BY
                   TaskTerminationDate DESC
         END


      IF @i_TaskTypeCommunicationID IS NOT NULL
         BEGIN
               SET @v_CommunicationCount = @v_CommunicationCount + 1
         END
	
	 
	 --SELECT @d_AdhocNextContactedDate adochnextcontact, @d_NextContactedDate nextcontac, @d_TaskTerminationDate termination

      IF ( ( CONVERT(date , @d_AdhocNextContactedDate) <= CONVERT(date , @d_NextContactedDate)
             AND @i_NextCommunicationSequence <> 1 )
           OR @i_NextCommunicationSequence IS NULL--OR @d_NextContactedDate IS NULL 
           OR ( CONVERT(date , @d_AdhocNextContactedDate) <= CONVERT(date , @d_TaskTerminationDate)
                AND @i_NextCommunicationSequence <> 1 ) )
      AND @d_AdhocNextContactedDate IS NOT NULL
          --or (CONVERT(DATE,@d_TaskTerminationDate)) <= CONVERT(DATE,@d_AdhocTaskTerminationDate)
         BEGIN


               IF
               ( SELECT
                     COUNT(*)
                 FROM
                     TaskAttempts
                 WHERE
                     TaskId = @i_TaskId
                     AND CommunicationSequence IS NOT NULL ) < @i_TotalFutureTasks
                  BEGIN
                        SET @d_AdhocTaskTerminationDate = NULL
                  END
               DECLARE
                       @i_Days int ,
                       @d_PreviowsAttempteddate datetime
               SELECT TOP 1
                   @i_Days = tc.CommunicationAttemptDays ,
                   @d_PreviowsAttempteddate = ta.AttemptedContactDate
               FROM
                   TaskTypeCommunications tc
               INNER JOIN TaskAttempts ta
                   ON ta.TasktypeCommunicationID = tc.TaskTypeCommunicationID
               WHERE
                   TaskId = @i_TaskId
               ORDER BY
                   ta.CommunicationSequence DESC

               SET @d_AdhocNextContactedDate = dateadd(dd , @i_Days , @d_PreviowsAttempteddate)
               --PRINT 'AdhocReturn Value'
               INSERT INTO
                   @Results
                   SELECT
                       @i_TaskId ,
                       ISNULL(@v_AdhocCommunicationType , '') ,
                       ISNULL(@v_CommunicationCount , 0) ,
                       ISNULL(@i_AdhocCommunicationTemplateID , 0) ,
                       ISNULL(@i_CommunicationAttemptDays , 0) ,
                       ISNULL(@i_NoOfDaysBeforeTaskClosedIncomplete , 0) ,
                       ISNULL(@i_AdhocTasktypeCommunicationID , 0) ,
                       ISNULL(@i_AdhocNextCommunicationSequence , 0) ,
                       ISNULL(@i_AdhocCommunicationTypeID , 0) ,
                       @d_AdhocNextContactedDate ,
                       @d_AdhocTaskTerminationDate ,
                       @i_TotalFutureTasks ,
                       @d_AdhocAttemptContactDate


         END
      ELSE
         BEGIN
               --PRINT 'ManualReturn Value'
               INSERT INTO
                   @Results
                   SELECT
                       @i_TaskId ,
                       ISNULL(@v_CommunicationType , '') ,
                       ISNULL(@v_CommunicationCount , 0) ,
                       ISNULL(@i_CommunicationTemplateID , 0) ,
                       ISNULL(@i_CommunicationAttemptDays , 0) ,
                       ISNULL(@i_NoOfDaysBeforeTaskClosedIncomplete , 0) ,
                       ISNULL(@i_TaskTypeCommunicationID , 0) ,
                       ISNULL(@i_NextCommunicationSequence , 0) ,
                       ISNULL(@i_CommunicationTypeID , 0) ,
                       @d_NextContactedDate ,
                       @d_TaskTerminationDate ,
                       @i_TotalFutureTasks ,
                       @d_AdhocAttemptContactDate
         END
      RETURN
END



