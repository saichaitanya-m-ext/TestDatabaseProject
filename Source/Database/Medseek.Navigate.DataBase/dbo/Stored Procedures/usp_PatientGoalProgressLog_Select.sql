/*          
------------------------------------------------------------------------------          
Procedure Name: usp_PatientGoalProgressLog_Select          
Description   : This procedure is used to get the list of details from   
    PatientGoalProgressLog table      
Created By    : Aditya          
Created Date  : 30-Apr-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
          
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_PatientGoalProgressLog_Select]
(
 @i_AppUserId KEYID ,
 @i_PatientGoalProgressLogId KEYID = NULL ,
 @i_PatientActivityId KEYID = NULL ,
 @v_StatusCode STATUSCODE = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON           
 -- Check if valid Application User ID is passed          
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

      SELECT
          PatientGoalProgressLogId ,
          PatientGoalId ,
          PatientActivityId ,
          ProgressPercentage ,
          FollowUpDate ,
          FollowUpCompleteDate ,
          Comments ,
          AttemptedContactDate,
		  ActivityCompletedDate,
          CASE StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
          END AS StatusDescription ,
          CreatedByUserId ,
          CreatedDate ,
          LastModifiedByUserId ,
          LastModifiedDate
      FROM
          PatientGoalProgressLog
      WHERE
          ( PatientGoalProgressLogId = @i_PatientGoalProgressLogId
          OR @i_PatientGoalProgressLogId IS NULL )
          AND ( @v_StatusCode IS NULL
                OR StatusCode = @v_StatusCode )
          AND ( PatientActivityId = @i_PatientActivityId
                OR @i_PatientActivityId IS NULL )
END TRY          
--------------------------------------------------------           
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientGoalProgressLog_Select] TO [FE_rohit.r-ext]
    AS [dbo];

