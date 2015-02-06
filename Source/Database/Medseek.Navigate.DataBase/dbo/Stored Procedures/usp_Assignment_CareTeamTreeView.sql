
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_Assignment_CareTeamTreeView
Description   : This procedure is used to get the careteams for tree view for assignment  
Created By    : Rathnam  
Created Date  : 08-Oct-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Assignment_CareTeamTreeView] --64,107
	(
	@i_AppUserId KEYID
	,@i_ProgramID KEYID = NULL
	,@v_CareTeamName VARCHAR(250) = NULL
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

		SELECT DISTINCT c.CareTeamId
			,c.CareTeamName
		FROM CareTeam c
		INNER JOIN CareTeamMembers ctm ON c.CareTeamId = ctm.CareTeamId
		WHERE (c.StatusCode = 'A')
			AND ctm.StatusCode = 'A'
			AND (
				CareTeamName LIKE '%' + @v_CareTeamName + '%'
				OR @v_CareTeamName IS NULL
				)

		SELECT DISTINCT CareTeam.CareTeamId
			,CareTeam.CareTeamName
		FROM ProgramCareTeam
		INNER JOIN CareTeam ON ProgramCareTeam.CareTeamId = CareTeam.CareTeamId
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
    ON OBJECT::[dbo].[usp_Assignment_CareTeamTreeView] TO [FE_rohit.r-ext]
    AS [dbo];

