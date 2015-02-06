  
  
/*    
---------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_Batch_UpdateTaskStatus]    
Description   : This procedure is to be used to ->  update the status of the which are held in Scheduled state
Created By    : Rathnam    
Created Date  : 21-Dec-2012  
----------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY DESCRIPTION    
----------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Batch_UpdateTaskStatus]
(
 @i_AppUserId KEYID
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

            UPDATE
                Task
            SET
                TaskStatusId = CASE
                                    WHEN Task.TaskDueDate - TaskType.ScheduledDays > GETDATE() THEN
                                    ( SELECT
                                          TaskStatusId
                                      FROM
                                          TaskStatus WITH(NOLOCK)
                                      WHERE
                                          TaskStatusText = 'Scheduled' )
                                    ELSE
                                    ( SELECT
                                          TaskStatusId
                                      FROM
                                          TaskStatus WITH(NOLOCK)
                                      WHERE
                                          TaskStatusText = 'Open' )
                               END
            FROM
                TaskType WITH(NOLOCK)
            WHERE
                TaskType.TaskTypeId = Task.TaskTypeId
                AND Task.TaskStatusId = ( SELECT TaskStatusId FROM TaskStatus WITH(NOLOCK) WHERE TaskStatusText = 'Scheduled' )
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
    ON OBJECT::[dbo].[usp_Batch_UpdateTaskStatus] TO [FE_rohit.r-ext]
    AS [dbo];

