
/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_PatientGoalProgressLog_Select_ByGoal]  
Description   : This procedure used to get Activity details for a specific PatientGoal    
Created By    : NagaBabu  
Created Date  : 28-Feb-2012  
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
20-03-2012  :Sivakrishna Added Pivot statement to get the followupPercentages Based On Dates
--------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_PatientGoalProgressLog_Select_ByGoal] -- 23,168
	(
	@i_AppUserId KeyID
	,@i_PatientGoalId KeyId
	,@i_IsAdhoc INT = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @v_columns VARCHAR(1000)
	DECLARE @v_query VARCHAR(1000)
	DECLARE @t_FollowUpdates TABLE (FollowUpdate VARCHAR(10))

	IF @i_IsAdhoc IS NULL
	BEGIN
		SELECT DISTINCT PatientActivity.PatientActivityId
			,Activity.NAME AS ActivityName
			,PatientGoal.StartDate
			,PatientGoal.GoalCompletedDate
			,(
				SELECT CONVERT(VARCHAR(10), MAX(FollowUpDate), 101)
				FROM PatientGoalProgressLog
				WHERE PatientActivityId = PatientActivity.PatientActivityId
					AND PatientGoalId = @i_PatientGoalId
				) AS FollowUpDate
			,(
				SELECT CONVERT(VARCHAR(10), MAX(FollowUpCompleteDate), 101)
				FROM PatientGoalProgressLog
				WHERE PatientActivityId = PatientActivity.PatientActivityId
					AND PatientGoalId = @i_PatientGoalId
				) AS FollowUpCompleteDate
			,PatientActivity.ProgressPercentage
		FROM PatientGoal WITH (NOLOCK)
		INNER JOIN PatientActivity WITH (NOLOCK) ON PatientGoal.PatientGoalId = PatientActivity.PatientGoalId
		INNER JOIN Activity WITH (NOLOCK) ON Activity.ActivityId = PatientActivity.ActivityId
		WHERE PatientGoal.PatientGoalId = @i_PatientGoalId
		GROUP BY PatientActivity.PatientActivityId
			,Activity.NAME
			,PatientGoal.StartDate
			,PatientGoal.GoalCompletedDate
			,PatientActivity.ProgressPercentage
		ORDER BY PatientActivity.PatientActivityId DESC
	END
	ELSE
	BEGIN
		SELECT DISTINCT PatientActivity.PatientActivityId
			,Activity.NAME AS ActivityName
			,PatientGoal.StartDate
			,PatientGoal.GoalCompletedDate
			,(
				SELECT CONVERT(VARCHAR(10), MAX(FollowUpDate), 101)
				FROM PatientGoalProgressLog
				WHERE PatientActivityId = PatientActivity.PatientActivityId
					AND PatientGoalId = @i_PatientGoalId
				) AS FollowUpDate
			,(
				SELECT CONVERT(VARCHAR(10), MAX(FollowUpCompleteDate), 101)
				FROM PatientGoalProgressLog
				WHERE PatientActivityId = PatientActivity.PatientActivityId
					AND PatientGoalId = @i_PatientGoalId
				) AS FollowUpCompleteDate
			,PatientActivity.ProgressPercentage
		FROM PatientGoal WITH (NOLOCK)
		INNER JOIN PatientActivity WITH (NOLOCK) ON PatientGoal.PatientGoalId = PatientActivity.PatientGoalId
		INNER JOIN Activity WITH (NOLOCK) ON Activity.ActivityId = PatientActivity.ActivityId
		WHERE PatientGoal.PatientGoalId = @i_PatientGoalId
		GROUP BY PatientActivity.PatientActivityId
			,Activity.NAME
			,PatientGoal.StartDate
			,PatientGoal.GoalCompletedDate
			,PatientActivity.ProgressPercentage
		ORDER BY PatientActivity.PatientActivityId DESC
	END
			
END TRY

------------------------------------------------------------------------------------------------------------------
BEGIN CATCH
	-- Handle exception    
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientGoalProgressLog_Select_ByGoal] TO [FE_rohit.r-ext]
    AS [dbo];

