/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_AdhocPatientActivity_Select] 
Description   : This procedure is used to get the Activities for the set of patients based on generalizedid
Created By    : Rathnam
Created Date  : 07-Nov-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY  
----------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_AdhocPatientActivity_Select]
(
 @i_AppUserId KEYID
,@t_PatientIdList TTYPEKEYID READONLY
,@i_LifeStyleGoaldID KEYID
,@d_TaskDuedate DATETIME
,@i_ActivityID KEYID = NULL
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
            IF @i_ActivityID IS NOT NULL
               BEGIN
                     UPDATE
                         PatientActivity
                     SET
                         StatusCode = 'I',
                         LastModifiedByUserId = @i_AppUserId,
                         LastModifiedDate = GETDATE()
                     FROM
                         PatientGoal pg WITH (NOLOCK)
                         INNER JOIN @t_PatientIdList p
                         ON pg.PatientId = p.tKeyId
                     WHERE
                         PatientActivity.PatientGoalId = pg.PatientGoalId
                         AND pg.LifeStyleGoalId = @i_LifeStyleGoaldID
                         AND CONVERT(DATE , pg.StartDate) = CONVERT(DATE , @d_TaskDuedate)
                         AND PatientActivity.ActivityId = @i_ActivityID
               END
            SELECT DISTINCT
                a.ActivityId
               ,a.Name AS ActivityName
               ,@i_LifeStyleGoaldID LifeStyleGoaldID
               ,@d_TaskDuedate TaskDuedate 
            FROM
                PatientGoal pg WITH (NOLOCK)
            INNER JOIN @t_PatientIdList p
                ON pg.PatientId = p.tKeyId
            INNER JOIN PatientActivity pa WITH (NOLOCK)
                ON pa.PatientGoalId = pg.PatientGoalId
            INNER JOIN Activity a
                ON a.ActivityId = pa.ActivityId
            WHERE
                CONVERT(DATE , pg.StartDate) = CONVERT(DATE , @d_TaskDuedate)
                AND pg.GoalCompletedDate IS NULL
                AND pg.LifeStyleGoalId = @i_LifeStyleGoaldID
                AND pg.StatusCode = 'A'
                AND pa.StatusCode = 'A'
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
    ON OBJECT::[dbo].[usp_AdhocPatientActivity_Select] TO [FE_rohit.r-ext]
    AS [dbo];

