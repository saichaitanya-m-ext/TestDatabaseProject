/*        
------------------------------------------------------------------------------        
Procedure Name: usp_PatientActivity_BulkInsert        
Description   : This procedure is used to insert record into PatientActivity table    
Created By    : Rathnam        
Created Date  : 06-Nov-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PatientActivity_BulkInsert]
(
 @i_AppUserId KEYID
,@d_StartDate DATETIME
,@i_TaskTypeGeneralizedID INT
,@t_PatientIdList TTYPEKEYID READONLY
,@t_Activity TTYPEKEYID READONLY
,@v_StatusCode VARCHAR(1) = 'A'
,@i_AcitivityID INT = NULL
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

            DECLARE @tblActivity TABLE
           (
              ActivityID INT
             ,TypeID INT
           )
            INSERT INTO
                @tblActivity
                SELECT
                    tKeyId
                   ,@i_TaskTypeGeneralizedID
                FROM
                    @t_Activity

            IF @v_StatusCode = 'A'
               BEGIN
                     INSERT INTO
                         PatientActivity
                         (
                           ActivityId
                         ,PatientGoalId
                         ,Description
                         ,StatusCode
                         ,CreatedByUserId
                         ,IsAdhoc
                         )
                         SELECT DISTINCT
                             ac.ActivityID
                            ,pg.PatientGoalId
                            ,NULL
                            ,'A'
                            ,@i_AppUserId
                            ,1
                         FROM
                             PatientGoal pg
                         INNER JOIN @t_PatientIdList p
                             ON pg.PatientId = p.tKeyId
                         INNER JOIN @tblActivity ac
                             ON pg.LifeStyleGoalId = ac.TypeID
                         WHERE
                             CONVERT(DATE , pg.StartDate) = CONVERT(DATE , @d_StartDate)
                             AND pg.IsAdhoc = 1
                             AND pg.LifeStyleGoalId = @i_TaskTypeGeneralizedID
                             AND pg.GoalCompletedDate IS NULL
                             AND NOT EXISTS ( SELECT
                                                  1
                                              FROM
                                                  PatientActivity pa
                                              WHERE
                                                  pa.PatientGoalId = pg.PatientGoalId
                                                  AND pa.ActivityId = ac.ActivityID )
               END
            ELSE
               BEGIN
                     UPDATE
                         PatientActivity
                     SET
                         StatusCode = 'I'
                        ,LastModifiedByUserID = @i_AppUserId
                        ,LastModifiedDate = GETDATE()
                     FROM
                         PatientGoal pg
                         INNER JOIN @t_PatientIdList p
                         ON pg.PatientId = p.tKeyId
                     WHERE
                         CONVERT(DATE , pg.StartDate) = CONVERT(DATE , @d_StartDate)
                         AND pg.IsAdhoc = 1
                         AND pg.LifeStyleGoalId = @i_TaskTypeGeneralizedID
                         AND pg.GoalCompletedDate IS NULL
                         AND PatientActivity.ActivityId = @i_AcitivityID 
                         AND @v_StatusCode = 'I'
                         AND @i_AcitivityID IS NOT NULL
                        
                                              
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
    ON OBJECT::[dbo].[usp_PatientActivity_BulkInsert] TO [FE_rohit.r-ext]
    AS [dbo];

