/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_EnrollmentTasks]239
Description   : This procedure is to be used to ->  enroll the tasks for communications & questionnaires for assignment
Created By    : Rathnam  
Created Date  : 22-Oct-2012
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_EnrollmentTasks]
(
 @i_AppUserId KEYID
,@i_ProgramID1 KEYID = NULL
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

            DECLARE @i_ProgramID INT
            DECLARE @l_TranStarted BIT = 0
            DECLARE
                    @i_EnrollmentTaskExist BIT = 0
                   ,@b_IsAutoEnrollment BIT = 0, @i_RecCount INT
            CREATE TABLE  #Prov
            (
            UserID INT
            )      
            DECLARE
                    @i_UserId INT
                   ,@dt_EnrollmentStartDate DATETIME
                   ,@i_CommunicationTypeId INT
                   ,@i_TemplateId INT
                   ,@i_Return_UserCommunicationId INT
                   ,@v_CommunicationType VARCHAR(50)
                   ,@dt_DateSent DATETIME
                   ,@v_CommunicationState VARCHAR(50)
                   ,@d_Currentdate  DATETIME = GETDATE() + 1
                   ,@v_Message VARCHAR(2000)

            DECLARE curProgram CURSOR
                    FOR SELECT
                            ProgramID
                           ,ISNULL(AllowAutoEnrollment,0)
                        FROM
                            Program
                        WHERE
                            StatusCode = 'A'
                            AND PopulationDefinitionID IS NOT NULL
                            AND ( ProgramID = @i_ProgramID1
                                  OR @i_ProgramID1 IS NULL
                                )
            OPEN curProgram
            FETCH NEXT FROM curProgram INTO @i_ProgramID,@b_IsAutoEnrollment
            WHILE @@FETCH_STATUS = 0
                  BEGIN  -- Begin for cursor
			SET @v_Message = 'DATE : ' + CONVERT(VARCHAR , GETDATE()) + ' - Creating the Enrollment Tasks for : ProgramID - ' + CONVERT(VARCHAR , @i_ProgramID) 
			RAISERROR ( @v_Message ,0 ,1 ) WITH NOWAIT
									IF EXISTS ( SELECT
													1
												FROM
													ProgramCareTeam
												WHERE
													ProgramId = @i_ProgramID )
									   BEGIN
									        
											 INSERT INTO
												 #Prov
												 SELECT DISTINCT
													 ctm.ProviderID 
												 FROM
													 CareTeamMembers ctm
												 INNER JOIN CareTeam ct
													 ON ctm.CareTeamId = ct.CareTeamId
												 INNER JOIN ProgramCareTeam pct
													 ON pct.CareTeamId = ct.CareTeamId
												 WHERE
													 pct.ProgramId = @i_ProgramID
													 AND ctm.StatusCode = 'A'
													 AND ct.StatusCode = 'A'


											 DECLARE
													 @i_ProgramCnt INT
													,@i_ProviderCnt INT

											 SELECT
												 @i_ProgramCnt = COUNT(1)
											 FROM
												 PatientProgram
											 WHERE
												 ProgramId = @i_ProgramID
											 AND ProviderID IS NULL    
									             
											 SELECT @i_ProviderCnt = COUNT(*) FROM #Prov

											 

											 DECLARE @i_min INT
											 SELECT @i_min = ISNULL(MIN(UserId) , 0) FROM #Prov

											 IF @i_ProviderCnt > 0
												BEGIN
												      DECLARE @i_cnt INT
													  SELECT @i_cnt = CEILING(CONVERT(DECIMAL(10,2) , @i_ProgramCnt) / CONVERT(DECIMAL(10,2) , @i_ProviderCnt))
													  WHILE ( @i_min ) > 0
															BEGIN
															PRINT @i_ProgramID
																  UPDATE
																	  PatientProgram
																  SET
																	  ProviderID = @i_min
																  FROM
																	  ( SELECT TOP (@i_cnt)
																			PatientProgamID
																		FROM
																			PatientProgram
																		WHERE
																			ProviderID IS NULL
																			AND ProgramId = @i_ProgramID ) x
																  WHERE
																	  x.PatientProgamID = PatientProgram.PatientProgamID
																	  AND ProviderID IS NULL   
																  DELETE  FROM #Prov WHERE UserId = @i_min
																  SELECT @i_min = isnull(MIN(UserId) , 0) FROM #Prov
															END
												END

									   END
                        IF @b_IsAutoEnrollment = 0
                           BEGIN
                                SET @v_Message = 'DATE : ' + CONVERT(VARCHAR , GETDATE()) + ' - Creating the Manual Enrollment Tasks for : ProgramID - ' + CONVERT(VARCHAR , @i_ProgramID) 
                                RAISERROR ( @v_Message ,0 ,1 ) WITH NOWAIT
                           ---> Conformation call before sending the enroll ment tasks which are defined in ProgramQuestionaire, ProgramCommunication table tasks
                                 
								SELECT
                                     @i_CommunicationTypeId = CommunicationTypeId
                                 FROM
                                     CommunicationType
                                 WHERE
                                     CommunicationType = 'Phone Call'
                                     
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
									,AssignedCareProviderId
									)
                                 
                                 SELECT
                                     PatientID,
                                     @i_CommunicationTypeId,
                                     NULL,
                                     NULL,
                                     @d_Currentdate,
                                     'A',
                                     @i_AppUserId,
                                     NULL,
                                     @i_ProgramID,
                                     1,
                                     0,
                                     ups.ProviderID
                                 FROM
                                     PatientProgram ups
                                 WHERE
                                     ISNULL(ups.IsCommunicated , 0) = 0
                                     AND ups.StatusCode = 'A'
                                     AND ups.ProgramId = @i_ProgramID
                                     AND ups.PatientID IS NOT NULL
                                     AND ups.EnrollmentStartDate IS NULL
                                     AND ups.IsPatientDeclinedEnrollment = 0
                                     AND ISNULL(ups.IsEnrollConfirmationSent,0) = 0
                                     
                                UPDATE
                                     PatientProgram
                                 SET
                                     IsEnrollConfirmationSent = 1
                                    ,LastModifiedByUserId = @i_AppUserId
                                    ,LastModifiedDate = GETDATE()
                                WHERE
                                     ISNULL(IsCommunicated , 0) = 0
                                     AND StatusCode = 'A'
                                     AND ProgramId = @i_ProgramID
                                     AND PatientID IS NOT NULL
                                     AND EnrollmentStartDate IS NULL
                                     AND IsPatientDeclinedEnrollment = 0
                                     AND ISNULL(IsEnrollConfirmationSent,0) = 0
                           END

                        SET @i_EnrollmentTaskExist = 0
                        IF EXISTS ( SELECT
                                        1
                                    FROM
                                        ProgramQuestionaire
                                    WHERE
                                        ProgramId = @i_ProgramID
                                        AND StatusCode = 'A' )
                           BEGIN
                                 SET @i_EnrollmentTaskExist = 1
                           END
                        ELSE
                           BEGIN
                                 IF EXISTS ( SELECT
                                                 1
                                             FROM
                                                 ProgramCommunication
                                             WHERE
                                                 ProgramId = @i_ProgramID
                                                 AND StatusCode = 'A' )
                                    BEGIN
                                          SET @i_EnrollmentTaskExist = 1
                                    END
                           END
                        IF @i_EnrollmentTaskExist = 1
                           BEGIN
                           
                                 IF ( @@TRANCOUNT = 0 )
                                    BEGIN
                                          BEGIN TRANSACTION
                                          SET @l_TranStarted = 1  -- Indicator for start of transactions
                                    END
                                 ELSE
                                    BEGIN
                                          SET @l_TranStarted = 0
                                    END
                                 SET @v_Message = 'DATE : ' + CONVERT(VARCHAR , GETDATE()) + ' - Creating the Autometic Enrollment Tasks for : ProgramID - ' + CONVERT(VARCHAR , @i_ProgramID)    
                                 RAISERROR ( @v_Message ,0 ,1 ) WITH NOWAIT
                                 INSERT INTO
                                     PatientQuestionaire
                                     (
                                       PatientId
                                     ,QuestionaireId
                                     ,DateDue
                                     ,DateAssigned
                                     ,Comments
                                     ,CreatedByUserId
                                     ,ProgramId
                                     ,IsEnrollment
                                     ,AssignedCareProviderId
                                     )
                                     SELECT DISTINCT
                                         ups.PatientID
                                        ,pq.QuestionaireId
                                        ,ISNULL(ups.EnrollmentStartDate , GETDATE()) + 1
                                        ,GETDATE()
                                        ,'Auto Enrollment Task'
                                        ,@i_AppUserId
                                        ,ups.ProgramId
                                        ,1
                                        ,ups.ProviderID
                                     FROM
                                         PatientProgram ups
                                     INNER JOIN ProgramQuestionaire pq
                                         ON ups.ProgramId = pq.ProgramId
                                     WHERE
                                         pq.StatusCode = 'A'
                                         AND ups.StatusCode = 'A'
                                         AND pq.ProgramId = @i_ProgramID
                                         AND isnull(ups.IsCommunicated , 0) = 0
                                         AND ups.EnrollmentStartDate IS NOT NULL
                                         AND ups.IsPatientDeclinedEnrollment = 0
                                         AND NOT EXISTS ( SELECT
                                                              1
                                                          FROM
                                                              PatientQuestionaire uq
                                                          WHERE
                                                              uq.PatientId = ups.PatientID
                                                              AND ups.ProgramId = uq.ProgramId )
								SET @i_RecCount = @@ROWCOUNT
								 
								 SET @v_Message = 'DATE : ' + CONVERT(VARCHAR , GETDATE()) + ' - Successfully Completed Questionnaire Autometic Enrollment Tasks for : ProgramID - ' + CONVERT(VARCHAR , @i_ProgramID) + ' For ' + CONVERT(varchar(50),@i_RecCount)
								 RAISERROR ( @v_Message ,0 ,1 ) WITH NOWAIT
								 
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
									,AssignedCareProviderId
									)
                                SELECT
                                     PatientID
                                    ,pc.CommunicationTypeId
                                    ,pc.TemplateId
                                    ,CASE WHEN ct.CommunicationType IN ( 'Email' , 'SMS' ) THEN GETDATE() ELSE NULL END
                                    ,ISNULL(EnrollmentStartDate , GETDATE()) + 1 EnrollmentStartDate
                                    ,'A'
                                    ,@i_AppUserId
                                    ,'Ready to Generate'
                                    ,@i_ProgramID
                                    ,1
                                    ,0
                                    ,ups.ProviderID
                                 FROM
                                     PatientProgram ups
                                 INNER JOIN ProgramCommunication pc
                                     ON ups.ProgramId = pc.ProgramId
                                 INNER JOIN CommunicationType ct
                                     ON ct.CommunicationTypeId = pc.CommunicationTypeId         
                                 WHERE
                                     ISNULL(ups.IsCommunicated , 0) = 0
                                     AND ups.StatusCode = 'A'
                                     AND pc.ProgramId = @i_ProgramID
                                     AND pc.StatusCode = 'A'
                                     AND ups.PatientID IS NOT NULL
                                     AND ups.EnrollmentStartDate IS NOT NULL
                                     AND ups.IsPatientDeclinedEnrollment = 0
                                     
                                SET @i_RecCount = @@ROWCOUNT     

                                 UPDATE
                                     PatientProgram
                                 SET
                                     IsCommunicated = 1
                                    ,LastModifiedByUserId = @i_AppUserId
                                    ,LastModifiedDate = GETDATE()
                                 WHERE
                                     ISNULL(IsCommunicated , 0) = 0
                                     AND StatusCode = 'A'
                                     AND ProgramId = @i_ProgramID
                                     AND StatusCode = 'A'
                                     AND PatientID IS NOT NULL
                                     AND EnrollmentStartDate IS NOT NULL
                                     AND IsPatientDeclinedEnrollment = 0
								 
									   
								    UPDATE Task
									SET AssignedCareProviderId = PatientProgram.ProviderID
									FROM PatientProgram
									WHERE PatientProgram.ProgramId = Task.ProgramID
									AND PatientProgram.PatientID = Task.PatientId
									AND PatientProgram.ProgramId = @i_ProgramID
									AND Task.AssignedCareProviderId IS NULL
                                 SET @v_Message = 'DATE : ' + CONVERT(VARCHAR , GETDATE()) + ' - Succesfully completed Auto Enrollment Tasks for : ProgramID - ' + CONVERT(VARCHAR , @i_ProgramID) + ' For ' + CONVERT(varchar(50),@i_RecCount)
                                 RAISERROR ( @v_Message ,0 ,1 ) WITH NOWAIT
                                 IF ( @l_TranStarted = 1 )  -- If transactions are there, then commit
                                    BEGIN
                                          SET @l_TranStarted = 0
                                          COMMIT TRANSACTION
                                    END
                           END
                        FETCH NEXT FROM curProgram INTO @i_ProgramID,@b_IsAutoEnrollment
                  END
            CLOSE curProgram
            DEALLOCATE curProgram
      END TRY
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
      BEGIN CATCH  
    -- Handle exception  
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_EnrollmentTasks] TO [FE_rohit.r-ext]
    AS [dbo];

