
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_TaskBundle_Select 64, 'A', NULL, NULL, NULL,NULL, NULL, NULL,248
Description   : This procedure is used to get the task bundle information related to cohorts , subcohorts, measures & Diseases information  
Created By    : Rathnam  
Created Date  : 22-Dec-2011  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
29-Aug-2012 P.V.P.Mohan added Case Condition for  InCaseOfConflict parameters and Added Case Condition For StatusCode  
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_TaskBundle_Select] --64,'A',NULL,NULL,NULL,'N'
	(
	@i_AppUserId KEYID
	,@v_StatusCode STATUSCODE = 'A'
	,@v_TaskBundleName VARCHAR(250) = NULL
	,@v_TaskBundleDescription VARCHAR(250) = NULL
	,@i_TaskBundleID KEYID = NULL
	,@v_TaskBuildingBlock VARCHAR(1) = NULL --> Y-Yes, N-No, B-Both
	,@v_ProductionStatus VARCHAR(1) = NULL --> f-> Final, d-> Draft , B-Both
	,@v_IsEdit VARCHAR(1) = NULL --> Y-Yes, N-No, B-Both
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

	IF @v_TaskBuildingBlock = 'B'
	BEGIN
		SET @v_TaskBuildingBlock = NULL
	END

	IF @v_ProductionStatus = 'B'
	BEGIN
		SET @v_ProductionStatus = NULL
	END

	IF @v_IsEdit = 'B'
	BEGIN
		SET @v_IsEdit = NULL
	END

	SELECT TaskBundleId
		,TaskBundleName
		,Description
		,StatusCode
		,dbo.ufn_GetUserNameByID(tb.CreatedByUserId) AS CreatedBy
		,CONVERT(VARCHAR(10), CreatedDate, 101) CreatedDate
		,dbo.ufn_GetUserNameByID(tb.LastModifiedByUserId) AS ModifiedBy
		,CONVERT(VARCHAR(10), LastModifiedDate, 101) LastModifiedDate
		,CASE 
			WHEN IsEdit = 0
				THEN 'No'
			ELSE 'Yes'
			END IsEdit
		,DefinitionVersion
		--,CASE
		--      WHEN IsBuildingBlock = 0 THEN 'No'
		--      ELSE 'Yes'
		-- END IsBuildingBlock
		,CASE 
			WHEN ProductionStatus = 'D'
				THEN 'Draft'
			ELSE 'Final'
			END ProductionStatus
		,CASE 
			WHEN ConflictType = 'R'
				THEN 'ResolveManually'
			ELSE 'ChooseLowestFrequency'
			END ConflictType
	--                  CASE tb.InCaseOfConflict
	--WHEN 'L' THEN 'LowestFrequency'  
	--WHEN 'R' THEN 'ResolveManually'  
	--END AS InCaseOfConflict
	FROM TaskBundle tb WITH (NOLOCK)
	WHERE (StatusCode = @v_StatusCode)
		AND (
			tb.TaskBundleName LIKE '%' + @v_TaskBundleName + '%'
			OR @v_TaskBundleName IS NULL
			)
		AND (
			tb.Description LIKE '%' + @v_TaskBundleDescription + '%'
			OR @v_TaskBundleDescription IS NULL
			)
		--            AND (IsBuildingBlock = CASE WHEN @v_TaskBuildingBlock = 'Y' THEN 1 
		--WHEN @v_TaskBuildingBlock = 'N' THEN 0
		-- END	OR @v_TaskBuildingBlock IS NULL)
		AND (
			IsEdit = CASE 
				WHEN @v_IsEdit = 'Y'
					THEN 1
				WHEN @v_IsEdit = 'N'
					THEN 0
				END
			OR @v_IsEdit IS NULL
			)
		AND (
			ProductionStatus = @v_ProductionStatus
			OR @v_ProductionStatus IS NULL
			)
		--IF @i_ProgramID IS NOT NULL
		--BEGIN
		--         SELECT DISTINCT TaskBundle.TaskBundleID, TaskBundle.TaskBundleName FROM ProgramTaskBundle
		--         INNER JOIN TaskBundle
		--         ON TaskBundle.TaskBundleId = ProgramTaskBundle.TaskBundleID
		--          WHERE ProgramID = @i_ProgramID
		--END													   
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
    ON OBJECT::[dbo].[usp_TaskBundle_Select] TO [FE_rohit.r-ext]
    AS [dbo];

