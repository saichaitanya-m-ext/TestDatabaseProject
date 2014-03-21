
-- exec [usp_CareProviderDashBoard_MyTasks_ByCareTeamMember] 23
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyTasks_ByCareTeamMember]
(
 @i_AppUserId KEYID
,@v_PatientNameOrMemberNum VARCHAR(250) = NULL
,@i_RemainderCount INT = NULL
,@t_CommunicationType TTYPEKEYID READONLY
,@t_CallPreference TTYPEKEYID READONLY
,@v_Duedate VARCHAR(5) = NULL
,@t_TaskTypeID TTYPEKEYID READONLY
,@t_PCPID TTYPEKEYID READONLY
,@t_tblTaskTypeIDAndTypeID TBSOURCENAME READONLY
,@t_CareTeamMemberId TTYPEKEYID READONLY
,@b_IscareGap BIT = 0
,@b_IsAdhoc BIT = 0
,@i_PatientID KEYID = NULL
)
AS
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


      CREATE TABLE #tblCareTeamMember
     (
        ProviderID INT
     )
      IF NOT EXISTS ( SELECT
                          1
                      FROM
                          @t_CareTeamMemberId )
         BEGIN

               INSERT INTO
                   #tblCareTeamMember
                   SELECT
                       @i_AppUserId
         END
      ELSE
         BEGIN
               INSERT INTO
                   #tblCareTeamMember
                   SELECT
                       tKeyId
                   FROM
                       @t_CareTeamMemberId
         END

      CREATE TABLE #tblPriorityTasks
     (
        TaskID INT
       ,PatientId INT
       ,Sort INT
     )


      CREATE TABLE #tblTask
     (
        UserId INT
       ,MemberNum VARCHAR(50)
       ,FullName VARCHAR(500)
       ,Age INT
       ,Gender VARCHAR(2)
       ,CallTimePreference VARCHAR(150)
       ,CallTimePreferenceID INT
       ,PhoneNumber VARCHAR(50)
       ,TaskID INT
       ,TaskDueDate DATETIME
       ,AttemptsAndLastDate VARCHAR(150)
       ,TasktypeName VARCHAR(150)
       ,TaskTypeID INT
       ,TypeID INT
       ,TypeName VARCHAR(500)
       ,IsCareGap BIT
       ,AssignedCareProviderID INT
       ,PCPName VARCHAR(500)
       ,PCPID INT
       ,IsAdhoc BIT
       ,CommunicationType VARCHAR(50)
       ,CommunicationTypeID INT
       ,AttemptsDate DATETIME
       ,CommunicationCount INT
       ,NextContactedDate DATETIME
       ,TaskTerminationDate DATETIME
       ,DaysLate INT
     )


      DECLARE @ParmDefinition NVARCHAR(MAX) = N'@b_IscareGap bit,@b_IsAdhoc bit, @v_PatientNameOrMemberNum varchar(250)'
      DECLARE @v_SQLQuery NVARCHAR(MAX)

      SET @v_SQLQuery = 'insert into #tblTask
        SELECT
            p.UserId
           ,UPPER(p.MemberNum) MemberNum
           ,p.FullName
           ,p.Age 
           ,p.Gender
           ,ctp.CallTimeName CallTimePreference
           ,ISNULL(p.CallTimePreferenceId , '''') CallTimePreferenceId
           ,ISNULL(p.PhoneNumberPrimary , 0) PhoneNumberPrimary
           ,t.TaskID
           ,CAST(t.TaskDueDate AS DATE) TaskDueDate
           ,( SELECT
                  isnull(CONVERT(VARCHAR , COUNT(ts.AttemptedContactDate)) , '''') + ''$$'' + isnull(CONVERT(VARCHAR(10) , MAX(ts.AttemptedContactDate) , 101) , '''')
              FROM
                  TaskAttempts ts  with(nolock)
              WHERE
                  ts.TaskId = t.TaskId
            ) AttemptsAndLastDate
            ,ISNULL(ty.TaskTypeName , ''Manual Task'') TaskTypeName
            ,ty.TaskTypeId
           ,t.TypeID 
           ,ISNULL(dbo.ufn_GetTypeNamesByTypeId(ty.TaskTypeName , t.TypeID),ManualTaskName) TypeName
           ,t.IsCareGap
           ,t.AssignedCareProviderId
           ,dbo.ufn_GetUserNameByID(p.PCPId) PCPName
           ,p.PCPId
           ,t.Isadhoc
           ,(CASE WHEN t.CommunicationType = ''Phone Call'' THEN ''Phone'' ELSE t.CommunicationType  END)AS CommunicationType 
           ,t.CommunicationTypeID
           ,NULL
           ,t.CommunicationCount 
           ,t.NextContactDate 
		   ,t.TaskTerminationDate
           ,null
        FROM
            Patients p with(nolock)
        INNER JOIN Task t  with(nolock)
            ON P.UserID = t.PatientUserID
        INNER JOIN #tblCareTeamMember Provider
            ON t.AssignedCareProviderId = Provider.ProviderID
        INNER JOIN TaskStatus ts  with(nolock)
            ON ts.TaskStatusId = t.TaskStatusId
        LEFT OUTER JOIN TaskType ty  with(nolock)
            ON ty.TaskTypeID = t.TaskTypeID
        LEFT OUTER JOIN CallTimePreference ctp  with(nolock)
            ON ctp.CallTimePreferenceId = p.CallTimePreferenceId '

      DECLARE @v_JoinClause NVARCHAR(MAX) = ''
      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_TaskTypeID )
         BEGIN
               SELECT
                   *
               INTO
                   #TaskTypeID
               FROM
                   @t_TaskTypeID
               SET @v_JoinClause = @v_JoinClause + ' inner join #TaskTypeID tt
            on tt.tKeyId = ty.TaskTypeId '
         END
      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_PCPID )
         BEGIN
               SELECT
                   *
               INTO
                   #PCPID
               FROM
                   @t_PCPID
               SET @v_JoinClause = @v_JoinClause + ' inner join #PCPID pcp
            on pcp.tKeyId = isnull(p.PCPId , p.PCP2Id) '
         END

      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_CommunicationType )
         BEGIN
               SELECT
                   *
               INTO
                   #CommunicationType
               FROM
                   @t_CommunicationType
               SET @v_JoinClause = @v_JoinClause + ' inner join #CommunicationType cnt
            on cnt.tKeyId = t.CommunicationTypeID '
         END


      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_CallPreference )
         BEGIN
               SELECT
                   *
               INTO
                   #CallPreference
               FROM
                   @t_CallPreference
               SET @v_JoinClause = @v_JoinClause + ' inner join #CallPreference cp
            on cp.tKeyId = p.CallTimePreferenceId '
         END


      IF EXISTS ( SELECT
                      1
                  FROM
                      @t_tblTaskTypeIDAndTypeID )
         BEGIN
               SELECT
                   SUBSTRING(SOURCENAME , 1 , CHARINDEX('-' , SOURCENAME) - 1) TaskTypeId
                  ,SUBSTRING(SOURCENAME , CHARINDEX('-' , SOURCENAME) + 1 , LEN(SOURCENAME)) TypeID
               INTO
                   #TaskTypeIDAndTypeID
               FROM
                   @t_tblTaskTypeIDAndTypeID

               SET @v_JoinClause = @v_JoinClause + ' inner join #TaskTypeIDAndTypeID ttt
            on ttt.TaskTypeId = ty.TaskTypeId 
            and ttt.TypeID = t.TypeID '
         END
      DECLARE @v_WhereClause NVARCHAR(MAX) = ' WHERE
            ts.TaskStatusText = ''Open''
            AND ( t.IsCareGap = @b_IscareGap
                  OR @b_IscareGap = 0
                )
            AND ( t.Isadhoc = @b_IsAdhoc
                  OR @b_IsAdhoc = 0
                )
             AND (MemberNum LIKE ''%''+ @v_PatientNameOrMemberNum + ''%'' OR FullName  LIKE ''%'' + @v_PatientNameOrMemberNum + ''%'' OR @v_PatientNameOrMemberNum IS NULL)   	    
                '

      SET @v_SQLQuery = @v_SQLQuery + @v_JoinClause + @v_WhereClause
      PRINT @v_SQLQuery
      
      EXECUTE SP_EXECUTESQL 
			  @v_SQLQuery , 
			  @ParmDefinition , 
			  @b_IscareGap = @b_IscareGap , 
			  @b_IsAdhoc = @b_IsAdhoc , 
			  @v_PatientNameOrMemberNum = @v_PatientNameOrMemberNum


      UPDATE
          #tblTask
      SET
          AttemptsDate = CASE
                              WHEN SUBSTRING(AttemptsAndLastDate , 1 , CHARINDEX('$$' , AttemptsAndLastDate , 1) - 1) = 0 THEN TaskDueDate
                              ELSE CASE
                                        WHEN CommunicationCount = 0 THEN TaskDueDate
                                        WHEN NextContactedDate <> '' THEN NextContactedDate
                                        WHEN TaskTerminationDate <> '' THEN TaskTerminationDate
                                        ELSE TaskDueDate
                                   END
                         END 

      INSERT INTO
          #tblPriorityTasks
          SELECT
              MAX(TaskId)
             ,UserId
             ,3
          FROM
              #tblTask
          WHERE
              DATEDIFF(DAY , AttemptsDate , GETDATE()) = 0
          GROUP BY
              UserId

      INSERT INTO
          #tblPriorityTasks
          SELECT
              MAX(TaskId)
             ,UserId
             ,2
          FROM
              #tblTask
          WHERE
              DATEDIFF(DAY , AttemptsDate , GETDATE()) > 0
              AND NOT EXISTS ( SELECT
                                   1
                               FROM
                                   #tblPriorityTasks tpt
                               WHERE
                                   tpt.PatientId = #tblTask.UserId )
          GROUP BY
              UserId

      INSERT INTO
          #tblPriorityTasks
          SELECT
              MAX(TaskId)
             ,UserId
             ,1
          FROM
              #tblTask
          WHERE
              DATEDIFF(DAY , AttemptsDate , GETDATE()) < 0
              AND NOT EXISTS ( SELECT
                                   1
                               FROM
                                   #tblPriorityTasks tpt
                               WHERE
                                   tpt.PatientId = #tblTask.UserId )
          GROUP BY
              UserId

      SELECT
          t1.Sort SortID
         ,DATEDIFF(DAY , t.AttemptsDate , GETDATE()) DaysLate
         ,t.UserId
         ,t.MemberNum
         ,t.FullName
         ,t.Age
         ,t.Gender
         ,t.CallTimePreference
         ,t.CallTimePreferenceID
         ,t.PhoneNumber
         ,t.TaskID
         ,t.TaskDueDate
         ,t.AttemptsAndLastDate
         ,t.TasktypeName
         ,t.TaskTypeID
         ,t.IsCareGap
         ,t.AssignedCareProviderID
         ,t.PCPName
         ,t.PCPID
         ,t.IsAdhoc
         ,t.TypeID
         ,t.TypeName
         ,CommunicationType
         ,t.CommunicationTypeID
         ,t.AttemptsDate
         ,'' AssginmentName
         ,'' LastMeasureValue
      FROM
          #tblTask t
      INNER JOIN #tblPriorityTasks t1
          ON t.TaskId = t1.TaskID
      WHERE
          ( Sort = @i_RemainderCount
          OR @i_RemainderCount IS NULL
          )
          AND ( ( DATEDIFF(DAY , AttemptsDate , GETDATE()) BETWEEN 0
                  AND @v_Duedate
                  AND CONVERT(INT , @v_Duedate) BETWEEN 0
                  AND 98
                )
                OR ( CONVERT(INT , @v_Duedate) = -1
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) < 0
                   )
                OR ( CONVERT(INT , @v_Duedate) = 99
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) > 0
                   )
                OR @v_Duedate IS NULL
              )
      ORDER BY
          SORT DESC

      SELECT
          COUNT(DISTINCT t.Taskid) TodayTasks
      FROM
          #tblTask t
      INNER JOIN #tblPriorityTasks p
          ON t.TaskId = p.TaskID
      WHERE
          DATEDIFF(DAY , AttemptsDate , GETDATE()) = 0
          AND ( ( DATEDIFF(DAY , AttemptsDate , GETDATE()) BETWEEN 0
                  AND @v_Duedate
                  AND CONVERT(INT , @v_Duedate) BETWEEN 0
                  AND 98
                )
                OR ( CONVERT(INT , @v_Duedate) = -1
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) < 0
                   )
                OR ( CONVERT(INT , @v_Duedate) = 99
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) > 0
                   )
                OR @v_Duedate IS NULL
              )

      SELECT
          COUNT(t.Taskid) PastDueTasks
      FROM
          #tblTask t
      INNER JOIN #tblPriorityTasks p
          ON t.TaskId = p.TaskID
      WHERE
          DATEDIFF(DAY , AttemptsDate , GETDATE()) > 0
          AND ( ( DATEDIFF(DAY , AttemptsDate , GETDATE()) BETWEEN 0
                  AND @v_Duedate
                  AND CONVERT(INT , @v_Duedate) BETWEEN 0
                  AND 98
                )
                OR ( CONVERT(INT , @v_Duedate) = -1
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) < 0
                   )
                OR ( CONVERT(INT , @v_Duedate) = 99
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) > 0
                   )
                OR @v_Duedate IS NULL
              )

      SELECT
          COUNT(t.Taskid) FutureTasks
      FROM
          #tblTask t
      INNER JOIN #tblPriorityTasks p
          ON t.TaskId = p.TaskID
      WHERE
          DATEDIFF(DAY , AttemptsDate , GETDATE()) < 0
          AND ( ( DATEDIFF(DAY , AttemptsDate , GETDATE()) BETWEEN 0
                  AND @v_Duedate
                  AND CONVERT(INT , @v_Duedate) BETWEEN 0
                  AND 98
                )
                OR ( CONVERT(INT , @v_Duedate) = -1
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) < 0
                   )
                OR ( CONVERT(INT , @v_Duedate) = 99
                     AND DATEDIFF(DAY , AttemptsDate , GETDATE()) > 0
                   )
                OR @v_Duedate IS NULL
              ) 
END TRY 
BEGIN CATCH        
----------------------------------------------------------------------------------------------------------       
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID 
END CATCH
                         
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyTasks_ByCareTeamMember] TO [FE_rohit.r-ext]
    AS [dbo];

