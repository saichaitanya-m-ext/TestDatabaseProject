CREATE FUNCTION [dbo].[Udf_GetprogressPercentage_PatientGoal]
(
  @i_PatientGoalId KeyId ,
  @dt_FollowUpdate DATETIME
)
RETURNS INT
AS
BEGIN
      DECLARE @return INT
      SELECT
          @return = MAX(ProgressPercentage)
          FROM PatientGoalProgressLog
      WHERE PatientGoalId = @i_PatientGoalId
        AND CONVERT(Varchar,FollowUpdate,101)=CONVERT(Varchar,@dt_FollowUpdate,101)
    
      RETURN @return
END