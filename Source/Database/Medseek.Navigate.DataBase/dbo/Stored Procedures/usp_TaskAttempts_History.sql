
/*          
------------------------------------------------------------------------------          
Procedure Name:[usp_TaskAttempts_History]10941,14041,684,3
Description   : This procedure is used to get the records from Taskattempts history based on taskid    
    table.        
Created By    : Rathnam 
Created Date  : 01-March-2012          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
28-Mar-2012 NagaBabu Added 'AND TaskTypeCommunications.StatusCode = 'A'' Condition in where clause
26-Aug-2013 Mohan Added CommunicationType Is Not Null in last Statement
18-Feb-2014 Rathnam fixed the issue for programtasktypecommunication passing programid as a parameter for 
fetching the related missed opp dates
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_TaskAttempts_History] (
	@i_AppUserId INT
	,@i_TaskID INT
	,@i_TaskTypeGeneralizedID INT = NULL
	,@i_TaskTypeID INT = NULL
	--,@b_IsAdhoc BIT
	)
AS
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
	END

	--IF NOT EXISTS ( SELECT
	--                    1
	--                FROM
	--                    TaskTypeCommunications
	--                WHERE
	--                    TaskTypeGeneralizedID = @i_TaskTypeGeneralizedID
	--                    AND TaskTypeID = @i_TaskTypeID )
	--   BEGIN
	--         SET @i_TaskTypeGeneralizedID = NULL
	--   END
	DECLARE @d_DueDate DATETIME, @i_ProgramID int
		,@d_TerminationDate DATETIME

	SELECT @d_DueDate = TaskDueDate, @i_ProgramID = ProgramId
	FROM Task WITH (NOLOCK)
	WHERE TaskId = @i_TaskID

	CREATE TABLE #Attempts (
		TaskId INT
		,AttemptedContactDate DATE
		,Comments VARCHAR(1000)
		,CommunicationType VARCHAR(500)
		,AttemptStatus VARCHAR(100)
		,CommunicationSequence INT
		,Gap VARCHAR(20)
		,TasktypeCommunicationID INT
		)

	INSERT INTO #Attempts
	SELECT TaskAttempts.TaskId
		,AttemptedContactDate
		,TaskAttempts.Comments
		,CommunicationType
		,CASE 
			WHEN AttemptStatus = 0
				THEN 'Not Contacted'
			WHEN AttemptStatus = 1
				THEN 'Contacted'
			ELSE NULL
			END AttemptStatus
		,TaskAttempts.CommunicationSequence
		,CASE 
			WHEN Task.IsProgramTask = 1
				THEN CASE 
						WHEN RemainderState = 'A'
							THEN '+'
						ELSE '-'
						END + CONVERT(VARCHAR(10), (
							SELECT ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete)
							FROM ProgramTaskTypeCommunication pttc WITH (NOLOCK)
							WHERE pttc.ProgramTaskTypeCommunicationID = Taskattempts.TasktypeCommunicationID
							))
			ELSE CASE 
					WHEN RemainderState = 'A'
						THEN '+'
					ELSE '-'
					END + CONVERT(VARCHAR(10), (
						SELECT ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete)
						FROM TaskRemainder tr WITH (NOLOCK)
						WHERE tr.TaskRemainderId = Taskattempts.TasktypeCommunicationID
						))
			END
		--,CASE WHEN DATEDIFF(DD , AttemptedContactDate , ISNULL(NextContactDate , TaskTerminationDate)) = 0 THEN '0'
		--      WHEN AttemptedContactDate > TaskDueDate THEN '+'+CAST(DATEDIFF(DD , AttemptedContactDate , ISNULL(NextContactDate , TaskTerminationDate)) AS VARCHAR)
		--      WHEN AttemptedContactDate < TaskDueDate THEN '-'+CAST(DATEDIFF(DD , AttemptedContactDate , ISNULL(NextContactDate , TaskTerminationDate)) AS VARCHAR) 
		--       END Gap
		,TasktypeCommunicationID
	--INTO
	--    #Attempts
	FROM TaskAttempts WITH (NOLOCK)
	INNER JOIN Task WITH (NOLOCK)
		ON Task.TaskId = TaskAttempts.TaskId
	INNER JOIN CommunicationType WITH (NOLOCK)
		ON CommunicationType.CommunicationTypeId = TaskAttempts.CommunicationTypeId
	WHERE TaskAttempts.TaskId = @i_TaskID

	IF EXISTS (
			SELECT 1
			FROM TaskRemainder WITH (NOLOCK)
			WHERE TaskId = @i_TaskID
			) --Adhoc Remainders
	BEGIN
		INSERT INTO #Attempts
		SELECT TaskID
			,NULL
			,NULL
			,CommunicationType
			,NULL
			,CommunicationSequence
			,CASE 
				WHEN RemainderState = 'A'
					THEN '+' + CAST(ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete) AS VARCHAR)
				WHEN RemainderState = 'B'
					THEN '-' + CAST(ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete) AS VARCHAR)
				END
			,TaskRemainderId
		FROM TaskRemainder WITH (NOLOCK)
		INNER JOIN CommunicationType WITH (NOLOCK)
			ON CommunicationType.CommunicationTypeId = TaskRemainder.CommunicationTypeId
		WHERE TaskID = @i_TaskID
			AND NOT EXISTS (
				SELECT 1
				FROM #Attempts a
				WHERE a.TasktypeCommunicationID = TaskRemainder.TaskRemainderId
				)

		SELECT @d_TerminationDate = DATEADD(DD, NoOfDaysBeforeTaskClosedIncomplete, @d_DueDate)
		FROM TaskRemainder WITH (NOLOCK)
		WHERE TaskId = @i_TaskID
			AND NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL
	END
	ELSE
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM Task WITH (NOLOCK)
				WHERE ISNULL(IsProgramTask, 0) = 1
					AND TaskId = @i_TaskID
				)
		BEGIN
			

			INSERT INTO #Attempts
			SELECT @i_TaskID
				,NULL
				,NULL
				,CommunicationType
				,NULL
				,CommunicationSequence
				,CASE 
					WHEN RemainderState = 'A'
						THEN '+' + CAST(ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete) AS VARCHAR)
					WHEN RemainderState = 'B'
						THEN '-' + CAST(ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete) AS VARCHAR)
					END GAP
				,ProgramTaskTypeCommunicationID
			FROM ProgramTaskTypeCommunication WITH (NOLOCK)
			LEFT JOIN CommunicationType WITH (NOLOCK)
				ON CommunicationType.CommunicationTypeId = ProgramTaskTypeCommunication.CommunicationTypeId
			WHERE ((ProgramTaskTypeCommunication.GeneralizedID = @i_TaskTypeGeneralizedID))
				AND ProgramTaskTypeCommunication.StatusCode = 'A'
				AND TaskTypeID = @i_TaskTypeID
				AND ProgramTaskTypeCommunication.ProgramID = @i_ProgramID
				AND NOT EXISTS (
					SELECT 1
					FROM #Attempts a
					WHERE a.TaskTypeCommunicationID = ProgramTaskTypeCommunication.ProgramTaskTypeCommunicationID
					)

			
			
			SELECT @d_TerminationDate = DATEADD(DD, NoOfDaysBeforeTaskClosedIncomplete, @d_DueDate)
			FROM ProgramTaskTypeCommunication WITH (NOLOCK)
			WHERE ((ProgramTaskTypeCommunication.GeneralizedID = @i_TaskTypeGeneralizedID))
				AND ProgramTaskTypeCommunication.StatusCode = 'A'
				AND TaskTypeID = @i_TaskTypeID
				AND NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL
				AND ProgramTaskTypeCommunication.ProgramID = @i_ProgramID
				
		END
		ELSE
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM Task
					WHERE ISNULL(IsProgramTask, 0) = 0
						AND ISNULL(Isadhoc, 0) = 0
						AND TaskId = @i_TaskID
					)
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM TaskTypeCommunications WITH (NOLOCK)
						WHERE TaskTypeID = @i_TaskTypeID
							AND TaskTypeGeneralizedID = @i_TaskTypeGeneralizedID
							AND StatusCode = 'A'
						)
				BEGIN
					SET @i_TaskTypeGeneralizedID = NULL
				END

				INSERT INTO #Attempts
				SELECT @i_TaskID
					,NULL
					,NULL
					,CommunicationType
					,NULL
					,CommunicationSequence
					,CASE 
						WHEN RemainderState = 'A'
							THEN '+' + CAST(ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete) AS VARCHAR)
						WHEN RemainderState = 'B'
							THEN '-' + CAST(ISNULL(CommunicationAttemptDays, NoOfDaysBeforeTaskClosedIncomplete) AS VARCHAR)
						END GAP
					,TaskTypeCommunicationID
				FROM TaskTypeCommunications WITH (NOLOCK)
				LEFT JOIN CommunicationType WITH (NOLOCK)
					ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeId
				WHERE (
						(
							TaskTypeGeneralizedID = @i_TaskTypeGeneralizedID
							AND @i_TaskTypeGeneralizedID IS NOT NULL
							)
						OR (
							TaskTypeGeneralizedID IS NULL
							AND @i_TaskTypeGeneralizedID IS NULL
							)
						)
					AND TaskTypeCommunications.StatusCode = 'A'
					AND TaskTypeID = @i_TaskTypeID
					AND NOT EXISTS (
						SELECT 1
						FROM #Attempts a
						WHERE a.TaskTypeCommunicationID = TaskTypeCommunications.TaskTypeCommunicationID
						)

				SELECT @d_TerminationDate = DATEADD(DD, NoOfDaysBeforeTaskClosedIncomplete, @d_DueDate)
				FROM TaskTypeCommunications WITH (NOLOCK)
				WHERE (
						(
							TaskTypeGeneralizedID = @i_TaskTypeGeneralizedID
							AND @i_TaskTypeGeneralizedID IS NOT NULL
							)
						OR (
							TaskTypeGeneralizedID IS NULL
							AND @i_TaskTypeGeneralizedID IS NULL
							)
						)
					AND TaskTypeCommunications.StatusCode = 'A'
					AND TaskTypeID = @i_TaskTypeID
					AND NoOfDaysBeforeTaskClosedIncomplete IS NOT NULL
			END
		END
	END

	SELECT TaskId
		,AttemptedContactDate
		,Comments
		,CommunicationType
		,AttemptStatus
		,CommunicationSequence
		,Gap
		,TaskTypeCommunicationID
	FROM #Attempts
	WHERE CommunicationType IS NOT NULL
	ORDER BY CommunicationSequence

	--END
	SELECT @d_TerminationDate TaskTerminationDate
		--SELECT TOP 1
		--    TaskTerminationDate
		--FROM
		--    TaskAttempts
		--WHERE
		--    TaskId = @i_TaskID
		--ORDER BY
		--    CommunicationSequence DESC
END TRY

BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskAttempts_History] TO [FE_rohit.r-ext]
    AS [dbo];

