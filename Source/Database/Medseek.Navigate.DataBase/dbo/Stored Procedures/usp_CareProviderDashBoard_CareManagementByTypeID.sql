  
/*      
--------------------------------------------------------------------------------------------------------------      
Procedure Name: [usp_CareProviderDashBoard_CareManagementByTypeID] @i_AppUserId=10,@vc_TaskTypeName='Questionnaire',@vc_Status='Scheduled'  
,@i_TabRowId=54 ,@v_EnrollmentTaskType=null  
Description   : This proc is used to retive the patients from CareManagement report  
Created By    : Rathnam  
Created Date  : 18-Jan-2013  
---------------------------------------------------------------------------------------------------------------      
Log History   :       
DD-Mon-YYYY  BY  DESCRIPTION    
29/07/2013:Santosh Changed the Name 'Program Enrollment' to 'Managed Popolation Enrollment''     
21/08/2013:Mohan added Function to get the Taskname in the place of TaskTypeName.  
04/09/2013:Mohan added IF Condition  to get all records.   
02/18/2014:Santosh removed the distributed logic for caremanager 
02/20/2014:Santosh added the parameter @t_TaskTypeID and modified the logic with the respect to TaskType
---------------------------------------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_CareManagementByTypeID]  
(  
 @i_AppUserId KEYID  
,@vc_TaskTypeName VARCHAR(150)  
,@t_ProgramID TTYPEKEYID READONLY  
,@i_TabRowId KEYID  
,@vc_Status VARCHAR(30)  
,@t_CareTeamMembers TTYPEKEYID READONLY  
,@t_PrimaryCarePhysician TTYPEKEYID READONLY  
,@t_TaskTypeID TTYPEKEYID READONLY
,@i_DueDate KEYID = NULL  
,@i_StartIndex INT = 1  
,@i_EndIndex INT = 10
,@v_EnrollmentTaskType VARCHAR(150)  
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
  
 -------------------------------------------------------------------------------------------------------------------  
 
 ----IF @i_EndIndex = NULL
 ----BEGIN
 ---- SET @i_EndIndex = 10
 ----END 
      /*        
            CREATE TABLE #tblCareTeamMember  
    (  
    ProviderID INT  
    )  
     IF NOT EXISTS ( SELECT  
          1  
         FROM  
          @t_CareTeamMembers )  
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
         SELECT DISTINCT  
          tKeyId  
         FROM  
          @t_CareTeamMembers  
     END  */
     
            CREATE TABLE #Program  
           (  
              ProgramID INT  
           )  
            INSERT INTO  
                #Program  
                SELECT   
                    tKeyId  
                FROM  
                    @t_ProgramID  
                    
              CREATE TABLE #TaskType (TaskTypeID INT)
              
              INSERT INTO #TaskType
		    SELECT tKeyId
		    FROM @t_TaskTypeID   
  
            CREATE TABLE #tblTask  
           (  
              ID INT IDENTITY(1,1)  
             ,TaskID INT 
             ,TypeId INT 
             ,PatientID INT  
             ,TaskDueDate DATE  
             ,TaskCompletedDate DATE  
           )  
            DECLARE  
                    @v_Select VARCHAR(MAX)  
                   ,@v_WhereClause VARCHAR(MAX)  
                   ,@v_JoinClause VARCHAR(MAX) = ''  
                   ,@v_SQL VARCHAR(MAX) = ''  
                   ,@v_OrderByClause VARCHAR(500) = ' Order By t.PatientID '  
              
                 --ty.TaskTypeName = ''' + @vc_TaskTypeName + '''' + ' AND   
     
            IF @vc_TaskTypeName = 'Managed Population Enrollment'  
            BEGIN   
       
            SET @vc_TaskTypeName = @v_EnrollmentTaskType   
			
            SET @v_WhereClause = ' WHERE t.TypeID = ' + CONVERT(VARCHAR(10) , @i_TabRowId) +   
            CASE WHEN @vc_Status IN ('Scheduled','Open','Closed Complete','Closed Incomplete') THEN ' AND ts.TaskStatusText = ''' + @vc_Status + ''''   
            ELSE + ' AND t.AttemptedRemainderCount ' + CASE WHEN @vc_Status IN ('1','2') THEN ' = ' ELSE '>=' END + @vc_Status + ' AND ts.TaskStatusText = ''Open''' END  
            SET @v_WhereClause = @v_WhereClause + '  AND ISNULL(t.IsEnrollment,0) = 1 '  
       
            END  
            ELSE  
            BEGIN  
            --SET @v_WhereClause = ' WHERE ty.TaskTypeName = ''' + @vc_TaskTypeName + '''' + ' AND t.TypeID = ' + CONVERT(VARCHAR(10) , @i_TabRowId) + ' AND ts.TaskStatusText = ''' + @vc_Status + ''''  
            SET @v_WhereClause = ' WHERE ty.TaskTypeName = ''' + @vc_TaskTypeName + '''' + ' AND t.TypeID = ' + CONVERT(VARCHAR(10) , @i_TabRowId) +   
            CASE WHEN @vc_Status IN ('Scheduled','Open','Closed Complete','Closed Incomplete') THEN ' AND ts.TaskStatusText = ''' + @vc_Status + ''''   
            ELSE + ' AND t.AttemptedRemainderCount ' + CASE WHEN @vc_Status IN ('1','2') THEN ' = ' ELSE '>=' END +  @vc_Status  + ' AND ts.TaskStatusText = ''Open''' END  
            SET @v_WhereClause = @v_WhereClause + '  AND ISNULL(t.IsEnrollment,0) = 0 '  
            END  
            
           
              
            SET @v_Select = '  
            INSERT INTO #tblTask  
            SELECT DISTINCT  
                t.TaskId 
               ,t.TypeId  
               ,t.PatientID  
               ,t.TaskDuedate  
               ,t.TaskCompletedDate  
            FROM  
                Task t WITH(NOLOCK)  
            INNER JOIN #Program pr
                ON pr.ProgramID = t.ProgramID
		  INNER JOIN #TaskType ty1
			 ON ty1.TaskTypeID = t.TaskTypeID
            INNER JOIN TaskType ty WITH(NOLOCK)
                ON t.TaskTypeId = ty.TaskTypeId
            INNER JOIN TaskStatus ts WITH(NOLOCK)
                ON ts.TaskStatusId = t.TaskStatusId '  
           
   --        SET @v_Select = '
			--INSERT INTO #tblTask
   --         SELECT DISTINCT
   --             t.TaskId
   --            ,t.TypeID
   --            ,t.PatientID
   --            ,t.TaskDueDate
   --            ,t.TaskCompletedDate
   --         FROM
   --             Task t WITH(NOLOCK)
   --         INNER JOIN #TaskTemp Ty
   --             ON Ty.TaskID = t.TaskID
   --         INNER JOIN TaskStatus ts WITH(NOLOCK)
   --             ON ts.TaskStatusId = t.TaskStatusId '
  
            IF EXISTS ( SELECT  
                            1  
                        FROM  
                            @t_PrimaryCarePhysician )  
               BEGIN  
                     CREATE TABLE #PCP  
                    (  
                       PCPID INT  
                    )  
  
                     INSERT INTO  
                         #PCP  
                         SELECT  
                             tKeyId  
                         FROM  
                             @t_PrimaryCarePhysician  
  
                     SET @v_JoinClause = ' INNER JOIN Patients p with(nolock)  
                             ON p.PatientID = t.PatientID   
                             INNER JOIN #PCP pcp  
                             ON pcp.PCPID = ISNULL(p.PCPId , p.PCPId)  
       '  
               END  
            /*  
            IF EXISTS ( SELECT  
                            1  
                        FROM  
                            @t_CareTeamMembers )  
               BEGIN  
                     CREATE TABLE #CTM  
                    (  
                       CareTeamUserid INT  
                    )  
                     INSERT INTO  
                         #CTM  
                         SELECT  
                             tKeyId  
                         FROM  
                             @t_CareTeamMembers  
                     SET @v_WhereClause = @v_WhereClause + ' AND EXISTS (SELECT 1 FROM CareTeamTaskRights ctm with(nolock) INNER JOIN #CTM c ON c.CareTeamUserid = ctm.UserId WHERE ctm.TaskTypeId = ty.TaskTypeID ) '  
               END  
   */  
            IF @i_DueDate IS NOT NULL  
               BEGIN  
                     SET @v_WhereClause = @v_WhereClause + ' AND (  
     (  ts.TaskStatusText = ''Open'' AND   
       DATEDIFF(DAY , CASE    
                                         WHEN ISNULL(t.TerminationDays , 0) <> 0 THEN DATEADD(DD , t.TerminationDays , t.TaskDueDate)    
                                         WHEN ISNULL(t.RemainderDays , 0) <> 0    
                                         AND RemainderState = ''B'' THEN DATEADD(DD , -t.RemainderDays , t.TaskDueDate)    
                                         WHEN ISNULL(t.RemainderDays , 0) <> 0    
                                         AND RemainderState = ''A'' THEN DATEADD(DD , t.RemainderDays , t.TaskDueDate)    
                                         ELSE t.TaskDuedate    
                                    END , getdate()) BETWEEN ' + CONVERT(VARCHAR(10) , @i_DueDate) + ' AND 0   
                    )    
                    OR  
                    (  
       ts.TaskStatusText = ''Closed complete'' AND   
      DATEDIFF(DAY , t.TaskCompletedDate , getdate()) BETWEEN 0 AND ' + CONVERT(VARCHAR(10) , @i_DueDate) + '   
                      
                    )   
                      
                    OR  
                    (  
       ts.TaskStatusText = ''Closed Incomplete'' AND   
      DATEDIFF(DD,  DATEADD(DD , t.TerminationDays , t.TaskDueDate),GETDATE()) BETWEEN 0 AND ' + CONVERT(VARCHAR(10) , REPLACE(@i_DueDate , '-' , '')) + '  
                    )  
                                                 
                   )'  
               END  
  
            SET @v_SQL = @v_Select + ISNULL(@v_JoinClause , '') + ISNULL(@v_WhereClause , '') + ISNULL(@v_OrderByClause , '')  
            
            PRINT @v_WhereClause
            PRINT @v_SQL  
            EXEC ( @v_SQL )  
  IF @i_StartIndex = 0  AND @i_EndIndex  = 0 
  
   SELECT DISTINCT  
                p.PatientID  
               ,p.MemberNum  
               ,p.FullName PatientName  
               ,p.PrimaryPhoneNumber Phone  
               ,CONVERT(VARCHAR , p.Age) + '/' + ( p.Gender ) AS AgeGender  
               ,CONVERT(VARCHAR(10) , t.TaskDueDate , 101) TaskDueDate  
               --,@vc_TaskTypeName TaskTypeName
               ,dbo.ufn_GetTypeNamesByTypeId(@vc_TaskTypeName, t.TypeID) TaskTypeName   
               ,CONVERT(VARCHAR(10),t.TaskCompletedDate,101) AS DateTaken  
               ,t.TaskId  
            FROM  
                #tblTask t  
            INNER JOIN Patients p WITH (NOLOCK)  
                ON p.PatientID = t.PatientID  
    ELSE
  
            SELECT DISTINCT  
                p.PatientID  
               ,p.MemberNum  
               ,p.FullName PatientName  
               ,p.PrimaryPhoneNumber Phone  
               ,CONVERT(VARCHAR , p.Age) + '/' + ( p.Gender ) AS AgeGender  
               ,CONVERT(VARCHAR(10) , t.TaskDueDate , 101) TaskDueDate  
               --,@vc_TaskTypeName TaskTypeName
               ,dbo.ufn_GetTypeNamesByTypeId(@vc_TaskTypeName, t.TypeID) TaskTypeName   
               ,CONVERT(VARCHAR(10),t.TaskCompletedDate,101) AS DateTaken  
               ,t.TaskId  
            FROM  
                #tblTask t  
            INNER JOIN Patients p WITH (NOLOCK)  
                ON p.PatientID = t.PatientID  
            WHERE  
                t.ID BETWEEN @i_StartIndex  
                AND @i_EndIndex   
              
            SELECT COUNT(1) TotalCnt FROM  #tblTask     
              
              
              
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
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_CareManagementByTypeID] TO [FE_rohit.r-ext]
    AS [dbo];

