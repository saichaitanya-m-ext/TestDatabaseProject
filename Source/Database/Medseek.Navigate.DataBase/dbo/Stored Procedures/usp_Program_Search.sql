
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_Program_Search 23  
Description   : This procedure is used to get the details from Program table    
    or a complete list of all the Programs    
Created By    : Rathnam      
Created Date  : 27-Sep-2012
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION
27-Nov-2012 P.V.P.Mohan changed parameters and added Like Condition for Disease Name and CohortList in 
            the place of CohortListID and PopulationDefinitionUsers        
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_Program_Search] --23,NULL,NULL,NULL,NULL,NULL,NULL,'DEF',NULL
	(
	@i_AppUserId KEYID
	,@i_ProgramId KEYID = NULL
	,@v_StatusCode STATUSCODE = NULL
	,@v_ProgramName VARCHAR(250) = NULL
	,@vc_DiseaseName VARCHAR(100) = NULL
	,@v_Description VARCHAR(250) = NULL
	,@vc_CareTeamName SOURCENAME = NULL
	,@vc_TaskBundleName SOURCENAME = NULL
	,@vc_CohortListName VARCHAR(100) = NULL
	,@b_AllowAutoEnrollment ISINDICATOR = NULL
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
	END;

	WITH cteProgram
	AS (
		SELECT Program.ProgramId
			,Program.ProgramName
			,Program.Description
			,CASE Program.AllowAutoEnrollment
				WHEN 1
					THEN 'Yes'
				WHEN 0
					THEN 'No'
				END AS AllowAutoEnrollment
			,CONVERT(VARCHAR(10), Program.CreatedDate, 101) CreatedOn
			,Program.CreatedDate
			,CONVERT(VARCHAR(10), Program.LastModifiedDate, 101) UpdatedOn
			,CASE Program.StatusCode
				WHEN 'A'
					THEN 'Active'
				WHEN 'I'
					THEN 'InActive'
				ELSE ''
				END AS StatusDescription
			,Program.PopulationDefinitionID
			,PopulationDefinition.PopulationDefinitionName
			,Condition.ConditionID
			,dbo.ufn_GetDiseaseNameByID(Condition.ConditionID) AS DiseaseName
			,STUFF((
					SELECT DISTINCT ', ' + c.CareTeamName
					FROM ProgramCareTeam pct WITH (NOLOCK)
					INNER JOIN CareTeam c WITH (NOLOCK) ON pct.CareTeamId = c.CareTeamId
					WHERE pct.ProgramId = Program.ProgramId
					FOR XML PATH('')
					), 1, 2, '') AS CareTeamList
			,(
				SELECT COUNT(DISTINCT ProgramCareTeam.ProgramId)
				FROM ProgramCareTeam WITH (NOLOCK)
				WHERE ProgramId = Program.ProgramId
				) CareTeamCount
			,STUFF((
					SELECT DISTINCT ', ' + tb.TaskBundleName
					FROM TaskBundle tb WITH (NOLOCK)
					INNER JOIN ProgramTaskBundle pb WITH (NOLOCK) ON pb.TaskBundleID = tb.TaskBundleId
					WHERE pb.ProgramID = Program.ProgramId
					FOR XML PATH('')
					), 1, 2, '') AS TaskBundleList
			,(
				SELECT COUNT(DISTINCT TaskBundleID)
				FROM ProgramTaskBundle WITH (NOLOCK)
				WHERE ProgramID = Program.ProgramId
				) TaskBundleCount
			,dbo.ufn_GetUserNameByID(Program.CreatedByUserId) CreatedBy
			,dbo.ufn_GetUserNameByID(Program.LastModifiedByUserId) UpdatedBy
			,CASE ISNULL(Program.IsAutomaticTermination, 0)
				WHEN 1
					THEN 'Yes'
				WHEN 0
					THEN 'No'
				END AS IsAutomaticTermination
			,ConflictType
		FROM Program WITH (NOLOCK)
		LEFT OUTER JOIN PopulationDefinition WITH (NOLOCK) ON PopulationDefinition.PopulationDefinitionId = Program.PopulationDefinitionId
		LEFT OUTER JOIN Condition ON Condition.ConditionID = PopulationDefinition.ConditionID
		WHERE (
				Program.ProgramId = @i_ProgramId
				OR @i_ProgramId IS NULL
				)
			AND (
				ProgramName LIKE '%' + @v_ProgramName + '%'
				OR @v_ProgramName IS NULL
				)
			AND (
				Program.StatusCode = @v_StatusCode
				OR @v_StatusCode IS NULL
				)
			AND (
				PopulationDefinition.PopulationDefinitionName LIKE '%' + @vc_CohortListName + '%'
				OR @vc_CohortListName IS NULL
				)
			AND (
				Condition.ConditionName LIKE '%' + @vc_DiseaseName + '%'
				OR @vc_DiseaseName IS NULL
				)
			AND (
				Program.Description LIKE '%' + @v_Description + '%'
				OR @v_Description IS NULL
				)
			AND (
				Program.AllowAutoEnrollment = @b_AllowAutoEnrollment
				OR @b_AllowAutoEnrollment IS NULL
				)
			
		)
	SELECT *
	FROM cteProgram
	WHERE (
			CareTeamList LIKE '%' + @vc_CareTeamName + '%'
			OR @vc_CareTeamName IS NULL
			)
		AND (
			TaskBundleList LIKE '%' + @vc_TaskBundleName + '%'
			OR @vc_TaskBundleName IS NULL
			)
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
    ON OBJECT::[dbo].[usp_Program_Search] TO [FE_rohit.r-ext]
    AS [dbo];

