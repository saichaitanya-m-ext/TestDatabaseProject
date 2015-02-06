               
/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetNextCommunicationTypeCountForTask
Description   : This Function Returns Nextcommunication and attempts count
Created By    : Rathnam
Created Date  : 28-Oct-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
08-Nov-2010 Rathnam added fileds in the 2nd select statement
                    CommunicationTemplateID,CommunicationAttemptDays,NoOfDaysBeforeTaskClosedIncomplete
15-Nov-2010 Rathnam communication sequence order by changed in second select statement. 
30-Nov-2010 Rathnam added Exist Clause and @i_TaskTypeGeneralizedID,@v_TaskTypeName Two parameters 
                    & ufn_GetTypeIDByTaskGeneralizedId function for getting typeid. 
01-Dec-2010 Rathnam Added two values  TaskTypeCommunicationID, NextCommunicationSequence in return statement 
23-Dec-2010 Rathnam  Removed the Attemptedcontactdate and place 
                     TaskTypeCommunications.CommunicationSequence added in where clause. 
21-Apr-2011 Rathnam  added TaskTypeCommunications.StatusCode = 'A'  for getting active records. 
15-Aug-2011 NagaBabu Added 'AND TaskTypeCommunications.CommunicationTemplateID IS NOT NULL' and 
						AND TaskTypeCommunications.TaskTypeCommunicationID IS NOT NULL in where clause  
22-Nov-2011 Rathnam Added if clause	@i_TaskTypeCommunicationID is not null for getting the correct communication count	
24-Feb-2012 Rathnam added first selet statement				                                                
------------------------------------------------------------------------------                
*/
CREATE FUNCTION [dbo].[ufn_GetNextCommunicationTypeAndCountForTask]
(
  @i_TaskId KEYID
 ,@i_TasktypeId KEYID
 ,@i_TaskTypeGeneralizedID KEYID
 ,@v_TaskTypeName SOURCENAME
)
RETURNS VARCHAR(800)
AS
BEGIN
      DECLARE
              @v_CommunicationType SOURCENAME
             ,@i_CommunicationSequence INT
             ,@v_CommunicationCount INT
             ,@d_TaskTerminationDate DATETIME
             ,@v_ReturnValue VARCHAR(500)
             ,@i_CommunicationTemplateID KEYID
             ,@i_CommunicationAttemptDays INT
             ,@i_NoOfDaysBeforeTaskClosedIncomplete INT
             ,@i_TypeID KEYID
             ,@i_TaskTypeCommunicationID KEYID
             ,@i_NextCommunicationSequence INT
             ,@d_NextContactedDate DATE
             ,@d_TerminationDate DATE
             ,@i_CommunicationTypeID INT
             ,@d_AttemptedContactDate DATE
             ,@i_TotalFutureTasks INT
             ,@v_AdhocCommunicationType VARCHAR(100)
             ,@i_AdhocCommunicationTemplateID INT
             ,@d_AdhocNextContactedDate DATETIME
             ,@d_AdhocTaskTerminationDate DATETIME
             ,@i_AdhocNextCommunicationSequence INT
             ,@i_AdhocCommunicationTypeID INT
             ,@i_AdhocTasktypeCommunicationID INT
             ,@d_AdhocAttemptContactDate DATETIME

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
                   @i_AdhocTasktypeCommunicationID = NULL
                  ,@v_AdhocCommunicationType = CommunicationType.CommunicationType
                  ,@i_AdhocCommunicationTemplateID = TaskAttempts.CommunicationTemplateID
                  ,@d_AdhocNextContactedDate = TaskAttempts.NextContactDate
                  ,@d_AdhocTaskTerminationDate = TaskAttempts.TaskTerminationDate
                  ,@i_AdhocNextCommunicationSequence = TaskAttempts.CommunicationSequence
                  ,@i_AdhocCommunicationTypeID = CommunicationType.CommunicationTypeId
                  ,@d_AdhocAttemptContactDate = TaskAttempts.NextContactDate
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
                            @i_CommunicationSequence = TaskAttempts.CommunicationSequence
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                           ,@d_AttemptedContactDate = TaskAttempts.AttemptedContactDate
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
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
                            @i_TaskTypeCommunicationID = AdhocTaskSchduledAttempts.AdhocTaskSchduledAttemptsId
                           ,@v_CommunicationType = CommunicationType.CommunicationType
                           ,@i_CommunicationTemplateID = AdhocTaskSchduledAttempts.CommunicationTemplateID
                           ,@i_CommunicationAttemptDays = AdhocTaskSchduledAttempts.CommunicationAttemptDays
                           ,@i_NoOfDaysBeforeTaskClosedIncomplete = AdhocTaskSchduledAttempts.NoOfDaysBeforeTaskClosedIncomplete
                           ,@i_NextCommunicationSequence = AdhocTaskSchduledAttempts.CommunicationSequence
                           ,@i_CommunicationTypeID = CommunicationType.CommunicationTypeId
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
                            @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                           ,@d_AttemptedContactDate = TaskAttempts.AttemptedContactDate
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
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
                            @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID
                           ,@v_CommunicationType = CommunicationType.CommunicationType
                           ,@i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID
                           ,@i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays
                           ,@i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete
                           ,@i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence
                           ,@i_CommunicationTypeID = CommunicationType.CommunicationTypeId
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

               IF CONVERT(DATE , @d_AdhocNextContactedDate) <= CONVERT(DATE , @d_NextContactedDate)
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

                        SET @d_TaskTerminationDate = DATEADD(DD , @i_NoOfDaysBeforeTaskClosedIncomplete , isnull(@d_AttemptedContactDate,getdate()))
                  END

         END
      ELSE
         BEGIN
               SELECT
                   @i_TypeID = dbo.ufn_GetTypeIDByTaskGeneralizedId(@v_TaskTypeName , @i_TaskTypeGeneralizedID)

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
                            @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                           ,@d_AttemptedContactDate = TaskAttempts.AttemptedContactDate
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
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
                            @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID
                           ,@v_CommunicationType = CommunicationType.CommunicationType
                           ,@i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID
                           ,@i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays
                           ,@i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete
                           ,@i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence
                           ,@i_CommunicationTypeID = CommunicationType.CommunicationTypeId
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

                        IF CONVERT(DATE , @d_AdhocNextContactedDate) <= CONVERT(DATE , @d_NextContactedDate)
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

                                 SET @d_TaskTerminationDate = DATEADD(DD , @i_NoOfDaysBeforeTaskClosedIncomplete , isnull(@d_AttemptedContactDate,getdate()))
                           END
                  END
               ELSE
                  BEGIN
                        --PRINT 'SPECIFIC'
         ----------------Getting Next CommunicationType for Specific ---------------------
                        SELECT TOP 1
                            @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
                           ,@d_AttemptedContactDate = TaskAttempts.AttemptedContactDate
                           ,@d_TaskTerminationDate = TaskAttempts.TaskTerminationDate
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
                            @i_TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID
                           ,@v_CommunicationType = CommunicationType.CommunicationType
                           ,@i_CommunicationTemplateID = TaskTypeCommunications.CommunicationTemplateID
                           ,@i_CommunicationAttemptDays = TaskTypeCommunications.CommunicationAttemptDays
                           ,@i_NoOfDaysBeforeTaskClosedIncomplete = TaskTypeCommunications.NoOfDaysBeforeTaskClosedIncomplete
                           ,@i_NextCommunicationSequence = TaskTypeCommunications.CommunicationSequence
                           ,@i_CommunicationTypeID = CommunicationType.CommunicationTypeId
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

                        IF CONVERT(DATE , @d_AdhocNextContactedDate) <= CONVERT(DATE , @d_NextContactedDate)
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

                                 SET @d_TaskTerminationDate = DATEADD(DD , @i_NoOfDaysBeforeTaskClosedIncomplete , isnull(@d_AttemptedContactDate,getdate()))
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

		if exists (select 1 from TaskAttempts where CommunicationSequence is not null and TaskTerminationDate is not null)
	and @d_TaskTerminationDate < = (select top 1 max(TaskTerminationDate) from TaskAttempts where TaskId = @i_TaskId and CommunicationSequence is null AND AttemptedContactDate IS NOT NULL)
	begin
	 SELECT TOP 1
                   @i_AdhocTasktypeCommunicationID = NULL
                  ,@v_AdhocCommunicationType = null--CommunicationType.CommunicationType
                  ,@i_AdhocCommunicationTemplateID = null--TaskAttempts.CommunicationTemplateID
                  ,@d_AdhocNextContactedDate = TaskAttempts.NextContactDate
                  ,@d_AdhocTaskTerminationDate = TaskAttempts.TaskTerminationDate
                  ,@i_AdhocNextCommunicationSequence = null--TaskAttempts.CommunicationSequence
                  ,@i_AdhocCommunicationTypeID = null--CommunicationType.CommunicationTypeId
               FROM
                   TaskAttempts
               INNER JOIN CommunicationType
                   ON TaskAttempts.CommunicationTypeId = CommunicationType.CommunicationTypeId
               WHERE
                   TaskId = @i_TaskId
                   AND TasktypeCommunicationID IS NULL
                   and CommunicationSequence is null
                   ----AND AttemptedContactDate IS NULL
               ORDER BY
                   TaskTerminationDate desc
	end
		
		
      IF @i_TaskTypeCommunicationID IS NOT NULL
         BEGIN
               SET @v_CommunicationCount = @v_CommunicationCount + 1
         END
	
	 
	 --SELECT @d_AdhocNextContactedDate adochnextcontact, @d_NextContactedDate nextcontac, @d_TaskTerminationDate termination

      IF (( CONVERT(DATE , @d_AdhocNextContactedDate) <= CONVERT(DATE , @d_NextContactedDate)
           AND @i_NextCommunicationSequence <> 1
         ) or @i_NextCommunicationSequence is null--OR @d_NextContactedDate IS NULL 
      OR ( CONVERT(DATE , @d_AdhocNextContactedDate) <= CONVERT(DATE , @d_TaskTerminationDate)
           AND @i_NextCommunicationSequence <> 1
         )) and   @d_AdhocNextContactedDate is not null
          --or (CONVERT(DATE,@d_TaskTerminationDate)) <= CONVERT(DATE,@d_AdhocTaskTerminationDate)
         BEGIN
         
         
         if (select COUNT(*) from TaskAttempts where TaskId = @i_TaskId and CommunicationSequence is not null) < @i_TotalFutureTasks
	begin
	set @d_AdhocTaskTerminationDate = null
	end
               DECLARE
                       @i_Days INT
                      ,@d_PreviowsAttempteddate DATETIME
               SELECT TOP 1
                   @i_Days = tc.CommunicationAttemptDays
                  ,@d_PreviowsAttempteddate = ta.AttemptedContactDate
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
               SET @v_ReturnValue = ISNULL(@v_AdhocCommunicationType , '') + ' - ' + 
               CONVERT(VARCHAR(10) , ISNULL(@v_CommunicationCount , 0)) + ' * ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_AdhocCommunicationTemplateID , 0)) + ' & ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_CommunicationAttemptDays , 0)) + ' $ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_NoOfDaysBeforeTaskClosedIncomplete , 0)) + ' @ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_AdhocTasktypeCommunicationID , 0)) + ' ^ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_AdhocNextCommunicationSequence , 0)) + ' ~ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_AdhocCommunicationTypeID , 0)) + ' | ' + 
               ISNULL(CONVERT(VARCHAR(10) , @d_AdhocNextContactedDate , 101) , '') + ' % ' + 
               ISNULL(CONVERT(VARCHAR(10) , @d_AdhocTaskTerminationDate , 101) , '') + '_' + 
               ISNULL(CONVERT(VARCHAR(10) , @i_TotalFutureTasks) , '') + '!' +
               ISNULL(CONVERT(VARCHAR(10) , @d_AdhocAttemptContactDate , 101) , '')  
               
               
         END
      ELSE
         BEGIN
               --PRINT 'ManualReturn Value'
               SET @v_ReturnValue = ISNULL(@v_CommunicationType , '') + ' - ' + 
               CONVERT(VARCHAR(10) , ISNULL(@v_CommunicationCount , 0)) + ' * ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_CommunicationTemplateID , 0)) + ' & ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_CommunicationAttemptDays , 0)) + ' $ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_NoOfDaysBeforeTaskClosedIncomplete , 0)) + ' @ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_TaskTypeCommunicationID , 0)) + ' ^ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_NextCommunicationSequence , 0)) + ' ~ ' + 
               CONVERT(VARCHAR(10) , ISNULL(@i_CommunicationTypeID , 0)) + ' | ' + 
               ISNULL(CONVERT(VARCHAR(10) , @d_NextContactedDate , 101) , '') + ' % ' + 
               ISNULL(CONVERT(VARCHAR(10) , @d_TaskTerminationDate , 101) , '') + '_' + 
               ISNULL(CONVERT(VARCHAR(10) , @i_TotalFutureTasks) , '') +  '!' 
         END

      RETURN @v_ReturnValue
END