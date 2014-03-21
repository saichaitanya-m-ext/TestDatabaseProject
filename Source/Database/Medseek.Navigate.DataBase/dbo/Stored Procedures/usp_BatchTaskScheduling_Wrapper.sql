/*
-------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_BatchTaskScheduling_Wrapper]
Description	  : All the Batch maintenance SP's are executed through this wrapper. 
Created By    :	P.V.P.Mohan
Created Date  : 26-Dec-2012
--------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

--------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_BatchTaskScheduling_Wrapper]
(
 @i_AppUserId KEYID 
)
AS
BEGIN TRY

      SET NOCOUNT ON	
	-- Check if valid Application User ID is passed

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )

         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

      
      EXEC usp_Batch_EnrollmentTasks @i_AppUserId 
      EXEC usp_Batch_UpdateTaskStatus @i_AppUserId
      EXEC usp_Batch_AssignmentTasks @i_AppUserId
      EXEC usp_Batch_TaskRemainders @i_AppUserId
      EXEC usp_Batch_SendIVRForTaskAttempts @i_AppUserId
      EXEC usp_Batch_SendLetterForTaskAttempts @i_AppUserId
      EXEC usp_Batch_SendMailsForTaskAttempts @i_AppUserId
      EXEC usp_Batch_SendSMSForTaskAttempts @i_AppUserId
      

END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_BatchTaskScheduling_Wrapper] TO [FE_rohit.r-ext]
    AS [dbo];

