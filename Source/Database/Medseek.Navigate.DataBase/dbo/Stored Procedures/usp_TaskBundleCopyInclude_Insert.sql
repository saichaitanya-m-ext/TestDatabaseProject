
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_TaskBundleCopyInclude_Insert        
Description   : This procedure is used to insert record into TaskBundleCopyInclude table    
Created By    : Rathnam
Created Date  : 20-Sep-2012       
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_TaskBundleCopyInclude_Insert] (
	@i_AppUserId KEYID
	,@t_TaskBundleCopyInclude TASKBUNDLEDEPENDENCIES READONLY
	,@i_TaskBundleId KEYID
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
		END

		---------insert operation into TaskBundleCopyInclude table-----       
		DECLARE @l_TranStarted BIT = 0

		IF (@@TRANCOUNT = 0)
		BEGIN
			BEGIN TRANSACTION

			SET @l_TranStarted = 1 -- Indicator for start of transactions
		END
		ELSE
		BEGIN
			SET @l_TranStarted = 0
		END

		DELETE
		FROM TaskBundleCopyInclude
		WHERE TaskBundleID = @i_TaskBundleId

		IF EXISTS (
				SELECT 1
				FROM TaskBundle
				WHERE ConflictType = 'L' --Autometic
					AND TaskBundleId = @i_TaskBundleId
				)
		BEGIN
				;

			WITH cteTaskBundle
			AS (
				SELECT *
					,ROW_NUMBER() OVER (
						PARTITION BY TasktypeGeneralizedID
						,Tasktype ORDER BY CASE 
								WHEN Frequency = 'D'
									THEN frequencynumber * 1
								WHEN Frequency = 'W'
									THEN frequencynumber * 7
								WHEN Frequency = 'M'
									THEN frequencynumber * 30
								WHEN Frequency = 'Y'
									THEN frequencynumber * 365
								END
						) sno
				FROM @t_TaskBundleCopyInclude
				)
			INSERT TaskBundleCopyInclude (
				TaskBundleID
				,TaskType
				,TypeId
				,FrequencyNumber
				,Frequency
				,CopyInclude
				,CreatedByUserId
				,ParentTaskBundleId
				,GeneralizedID
				,IsConflictResolution
				)
			SELECT @i_TaskBundleId TaskBundleId
				,TaskType
				,TypeID
				,FrequencyNumber
				,Frequency
				,CopyInclude
				,@i_AppUserId
				,TaskBundleID ParentTaskbundleID
				,TasktypeGeneralizedID
				,CASE 
					WHEN (
							SELECT COUNT(*)
							FROM cteTaskBundle c
							WHERE c.TaskType = cteTaskBundle.TaskType
								AND c.TasktypeGeneralizedID = cteTaskBundle.TasktypeGeneralizedID
							) > 1
						THEN 1
					ELSE 0
					END IsConflictResolution
			--,sno
			FROM cteTaskBundle
			WHERE Sno = 1
				AND (
					TypeID IS NOT NULL
					OR TypeID <> ''
					)
		END
		ELSE
		BEGIN
			INSERT TaskBundleCopyInclude (
				TaskBundleID
				,TaskType
				,TypeId
				,FrequencyNumber
				,Frequency
				,CopyInclude
				,CreatedByUserId
				,ParentTaskBundleId
				,GeneralizedID
				,IsConflictResolution
				)
			SELECT @i_TaskBundleId
				,[TaskType]
				,[TypeID]
				,[FrequencyNumber]
				,[Frequency]
				,[CopyInclude]
				,@i_AppUserId
				,[TaskBundleID]
				,[TasktypeGeneralizedID]
				,IsConflict
			FROM @t_TaskBundleCopyInclude
			WHERE TypeID IS NOT NULL
		END

		DECLARE @Program TABLE (
			ProgramID INT
			,TaskBundleID INT
			)

		INSERT INTO @Program
		SELECT DISTINCT ptb.ProgramID
			,i.TaskBundleId
		FROM ProgramTaskBundle ptb
		INNER JOIN TaskBundleCopyInclude i ON ptb.TaskBundleID = i.TaskBundleId

		IF (
				SELECT COUNT(*)
				FROM @Program
				) > 0
		BEGIN
			UPDATE ProgramTaskBundle
			SET FrequencyNumber = i.FrequencyNumber
				,Frequency = i.Frequency
				,LastModifiedByUserId = i.CreatedByUserId
				,LastModifiedDate = GETDATE()
				,IsInclude = CASE 
					WHEN i.CopyInclude = 'I'
						THEN 1
					ELSE 0
					END
			FROM TaskBundleCopyInclude i
			INNER JOIN @Program tb ON tb.TaskBundleID = i.TaskBundleId
			WHERE ProgramTaskBundle.ProgramID = tb.ProgramID
				AND ProgramTaskBundle.GeneralizedID = i.GeneralizedID
				AND ProgramTaskBundle.TaskBundleID = i.TaskBundleId
				AND ProgramTaskBundle.TaskType = i.TaskType

			UPDATE ProgramTaskBundle
			SET StatusCode = 'A'
			FROM TaskBundleCopyInclude i
			INNER JOIN @Program tb ON tb.TaskBundleID = i.TaskBundleId
			WHERE ProgramTaskBundle.ProgramID = tb.ProgramID
				AND ProgramTaskBundle.GeneralizedID = i.GeneralizedID
				AND ProgramTaskBundle.TaskBundleID = i.TaskBundleId
				AND ProgramTaskBundle.TaskType = i.TaskType
				AND ProgramTaskBundle.StatusCode = 'I'

			INSERT INTO ProgramTaskBundle (
				ProgramID
				,TaskBundleID
				,TaskType
				,GeneralizedID
				,FrequencyNumber
				,Frequency
				,StatusCode
				,CreatedByUserId
				,IsInclude
				)
			SELECT DISTINCT tb.ProgramID
				,i.TaskBundleId
				,i.TaskType
				,i.GeneralizedID
				,i.FrequencyNumber
				,i.Frequency
				,'A'
				,i.CreatedByUserId
				,CASE 
					WHEN i.CopyInclude = 'I'
						THEN 1
					ELSE 0
					END
			FROM TaskBundleCopyInclude i
			INNER JOIN @Program tb ON tb.TaskBundleID = i.TaskBundleId
			WHERE NOT EXISTS (
					SELECT 1
					FROM ProgramTaskBundle ptb
					WHERE ptb.ProgramID = tb.ProgramID
						AND ptb.GeneralizedID = i.GeneralizedID
						AND ptb.TaskType = i.TaskType
						AND ptb.TaskBundleID = i.TaskBundleID
					)
				AND tb.ProgramID IS NOT NULL

			UPDATE ProgramTaskBundle
			SET StatusCode = 'I'
			WHERE NOT EXISTS (
					SELECT 1
					FROM TaskBundleCopyInclude i
					INNER JOIN @Program tb ON tb.TaskBundleID = i.TaskBundleId
					WHERE ProgramTaskBundle.ProgramID = tb.ProgramID
						AND ProgramTaskBundle.GeneralizedID = i.GeneralizedID
						AND ProgramTaskBundle.TaskBundleID = i.TaskBundleId
						AND ProgramTaskBundle.TaskType = i.TaskType
					)
		END

		--EXEC usp_TaskBundleCopyIncludeDependencies_Insert @i_AppUserId = @i_AppUserId
		--	,@i_TaskBundleId = @i_TaskBundleId

		--UPDATE
		--    TaskBundleHistory
		--SET
		--    CopyIncludeList = CASE
		--                           WHEN RIGHT(CopyIncludeList , 2) <> '$$' THEN '$$'
		--                           ELSE ''
		--                      END + STUFF(
		--    ( SELECT DISTINCT
		--          '$$' + CONVERT(VARCHAR(10) , c.ParentTaskBundleId) + ' - ' + CopyInclude
		--      FROM
		--          #include c
		--      WHERE
		--          c.TaskBundleID <> c.ParentTaskBundleId
		--      FOR
		--          XML PATH('') ) , 1 , 0 , '')
		--FROM
		--    #include
		--    INNER JOIN TaskBundle
		--    ON TaskBundle.TaskBundleId = #include.TaskBundleId
		--WHERE
		--    TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
		--    AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1)
		IF (@l_TranStarted = 1) -- If transactions are there, then commit
		BEGIN
			SET @l_TranStarted = 0

			COMMIT TRANSACTION
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
    ON OBJECT::[dbo].[usp_TaskBundleCopyInclude_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

