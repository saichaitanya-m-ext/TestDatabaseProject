
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Assignment_CareTeamTaskRights
Description   : This procedure is used to get the task rights which are not assigned to careteam members
Created By    : Rathnam  
Created Date  : 18-Oct-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_CareTeamTaskRights] (
	@i_AppUserId KEYID
	,@i_ProgramID KEYID
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		-- Check if valid Application User ID is passed  
		IF (@i_AppUserId IS NULL)
			OR (@i_AppUserId <= 0)
		BEGIN
			RAISERROR (
					N'Invalid Application User ID %d passed.'
					,17
					,1
					,@i_AppUserId
					)
		END;

		WITH cteTask
		AS (
			SELECT DISTINCT CASE 
					WHEN TaskType = 'Q'
						THEN 'Questionnaire'
					WHEN TaskType = 'E'
						THEN 'Patient Education Material'
					WHEN TaskType = 'P'
						THEN 'Schedule Procedure'
					WHEN TaskType = 'O'
						THEN 'Other Tasks'
					END TaskTypeName
			FROM ProgramTaskBundle
			WHERE ProgramID = @i_ProgramID
				AND StatusCode = 'A'
				AND TaskType NOT IN (
					SELECT DISTINCT CASE 
							WHEN TaskType.TaskTypeName = 'Questionnaire'
								THEN 'Q'
							WHEN TaskType.TaskTypeName = 'Patient Education Material'
								THEN 'E'
							WHEN TaskType.TaskTypeName = 'Schedule Procedure'
								THEN 'P'
							WHEN TaskType.TaskTypeName = 'Other Tasks'
								THEN 'O'
							END
					FROM CareTeamTaskRights pctr
					INNER JOIN ProgramCareTeam pct ON pct.CareTeamId = pctr.CareTeamId
					INNER JOIN TaskType ON TaskType.TaskTypeId = pctr.TaskTypeId
					INNER JOIN CareTeam c ON c.CareTeamId = pct.CareTeamId
					INNER JOIN CareTeamMembers ctm ON ctm.CareTeamId = c.CareTeamId
					WHERE pct.ProgramId = @i_ProgramID
						AND pctr.StatusCode = 'A'
						AND ctm.StatusCode = 'A'
						AND c.StatusCode = 'A'
						AND pctr.StatusCode = 'A'
						AND TaskType.TaskTypeName IN (
							'Questionnaire'
							,'Patient Education Material'
							,'Schedule Procedure'
							,'Other Tasks'
							)
					)
			)
		SELECT ROW_NUMBER() OVER (
				ORDER BY TaskTypeName
				) Sno
			,*
		FROM cteTask
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
    ON OBJECT::[dbo].[usp_Assignment_CareTeamTaskRights] TO [FE_rohit.r-ext]
    AS [dbo];

