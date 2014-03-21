
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Assignment_TaskBundleTreeView
Description   : This procedure is used to get the task bundle information related to cohorts , subcohorts, measures & Diseases information  
Created By    : Rathnam  
Created Date  : 04-Oct-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_TaskBundleTreeView] --64,107
	(
	@i_AppUserId KEYID
	,@i_ProgramID KEYID
	,@v_TaskBundleName VARCHAR(250) = NULL
	,@v_TaskBundleDescription VARCHAR(250) = NULL
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

		DECLARE @TaskBundles TABLE (TaskBundleID INT)

		INSERT INTO @TaskBundles
		SELECT DISTINCT TaskBundleID
		FROM TaskBundleCopyInclude
		
		UNION
		
		SELECT DISTINCT TaskBundleID
		FROM TaskBundleProcedureFrequency
		
		UNION
		
		SELECT DISTINCT TaskBundleID
		FROM TaskBundleQuestionnaireFrequency
		
		UNION
		
		SELECT DISTINCT TaskBundleID
		FROM TaskBundleAdhocFrequency
		
		UNION
		
		SELECT DISTINCT TaskBundleID
		FROM TaskBundleEducationMaterial

		SELECT tb.TaskBundleId
			,tb.TaskBundleName
		FROM TaskBundle tb
		INNER JOIN @TaskBundles t ON t.TaskBundleID = tb.TaskBundleId
		WHERE (StatusCode = 'A')
			AND (
				tb.TaskBundleName LIKE '%' + @v_TaskBundleName + '%'
				OR @v_TaskBundleName IS NULL
				)
			AND (
				tb.Description LIKE '%' + @v_TaskBundleDescription + '%'
				OR @v_TaskBundleDescription IS NULL
				)
			AND (ProductionStatus = 'F')

		SELECT DISTINCT TaskBundle.TaskBundleID
			,TaskBundle.TaskBundleName
			,TaskBundle.StatusCode
		FROM ProgramTaskBundle
		INNER JOIN TaskBundle ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
		WHERE ProgramID = @i_ProgramID
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
    ON OBJECT::[dbo].[usp_Assignment_TaskBundleTreeView] TO [FE_rohit.r-ext]
    AS [dbo];

