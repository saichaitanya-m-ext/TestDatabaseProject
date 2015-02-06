
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UserActivityLog_select] 23, 1,null,null,null,null
Description   : This procedure is used to get UserActivityLog Records
Created By    : Chaitanya
Created Date  : 01-Oct-2013  
------------------------------------------------------------------------------    
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
10/28/2013    : Santosh added the activity details result set
10/31/2013    : prathyusha added firstnem,lastname to  result set
11/05/2013    : prathyusha added @i_Providerid parameter and changed sort
12/11/2013	  : Chaitanya renamed Click_Event column in UserActivityLog to ActivityType
12/13/2013	  : Chaitanya added two parameters @vc_PageAccessed and @vc_OperationPerformed
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UserActivityLog_select] (
	@i_AppUserId INT
	, @i_RoleID INT = NULL
	, @dt_ActivityDatefrom DATETIME = NULL
	, @dt_ActivityDateto DATETIME = NULL
	, @vc_PageAccessed VARCHAR(100) = NULL
	, @vc_OperationPerformed VARCHAR(100) = NULL
	, @i_StartIndex INT = 1
	, @i_endindex INT = 20
	, @i_Providerid INT = NULL
	, @v_SortBy VARCHAR(50) = NULL
	, @v_SortType VARCHAR(5) = NULL
	)
AS
BEGIN TRY
	--SET NOCOUNT ON    
	-- Check if valid Application User ID is passed        
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				, 17
				, 1
				, @i_AppUserId
				)
	END

	CREATE TABLE #Activity (
		ActivityID INT IDENTITY(1, 1)
		, LoginName VARCHAR(100)
		, Name VARCHAR(100)
		, RoleName VARCHAR(100)
		, PageAccessed VARCHAR(100)
		, OperationPerformed VARCHAR(500)
		, DataAccessDetails VARCHAR(MAX)
		, [DateandTime] DATETIME
		, [Excel] VARCHAR(MAX)
		)

	INSERT INTO #Activity (
		LoginName
		, Name
		, RoleName
		, PageAccessed
		, OperationPerformed
		, DataAccessDetails
		, [DateandTime]
		, [Excel]
		)
	SELECT U.UserLoginName AS LoginName
		, P.LastName + ' ' + P.FirstName AS Name
		, S.RoleName AS [Role]
		, UA.PageName AS [PageAccessed]
		, UA.ActivityType AS [OperationPerformed]
		, UA.ActivityDetails AS [DataAccessDetails]
		, UA.[DateTime] AS [DateandTime]
		, REPLACE(REPLACE(REPLACE(REPLACE(UA.ActivityDetails,'<b>',''),'</br>',''),'<br />',''),'</b>','') AS [Excel]
	FROM UserActivityLog UA
	INNER JOIN UserGroup UG
		ON UA.UserID = UG.UserID
	INNER JOIN Users U
		ON U.UserId = UG.UserId
	INNER JOIN UsersSecurityRoles USR
		ON USR.ProviderID = UG.ProviderID
	INNER JOIN SecurityRole S
		ON S.SecurityRoleId = USR.SecurityRoleId
	INNER JOIN Provider P
		ON P.ProviderID = UG.ProviderID
	WHERE (
			S.SecurityRoleId = @i_RoleID
			OR @i_RoleID IS NULL
			OR @i_RoleID = 0
			)
		AND (
			UG.UserID = @i_Providerid
			OR @i_Providerid IS NULL
			) 		
		AND (
			UA.PageName = @vc_PageAccessed
			OR @vc_PageAccessed IS NULL
			)
		AND (
			UA.ActivityType = @vc_OperationPerformed
			OR @vc_OperationPerformed IS NULL
			)
		AND (
			CAST(UA.[DateTime] AS DATE) BETWEEN CAST(ISNULL(@dt_ActivityDatefrom, '1900-01-01') AS DATE)
				AND CAST(ISNULL(@dt_ActivityDateto, GETDATE()) AS DATE)
			)
	ORDER BY [DateTime] DESC

	--SELECT * FROM #Activity
	IF @v_SortBy IS NULL
		AND @v_SortType IS NULL
	BEGIN
		WITH CTE
		AS (
			SELECT ActivityID
				, LoginName
				, Name
				, RoleName
				, PageAccessed
				, OperationPerformed
				, DataAccessDetails
				, [Excel]
				, [DateandTime]				
			FROM #Activity
			)
		SELECT *
		FROM CTE
		WHERE ActivityID BETWEEN @i_StartIndex
				AND @i_endindex
	END
	ELSE
	BEGIN
		BEGIN
			IF @v_SortType = 'ASC'
			BEGIN
				WITH CTE
				AS (
					SELECT ActivityID
						, LoginName
						, Name
						, RoleName
						, PageAccessed
						, OperationPerformed
						, DataAccessDetails
						, [Excel]
						, [DateandTime]						
					FROM #Activity
					)
				SELECT *
				FROM CTE
				ORDER BY CASE 
						WHEN @v_SortBy = 'LoginName'
							THEN LoginName
						WHEN @v_SortBy = 'Name'
							THEN Name
						WHEN @v_SortBy = 'RoleName'
							THEN RoleName
						WHEN @v_SortBy = 'PageAccessed'
							THEN PageAccessed
						WHEN @v_SortBy = 'OperationPerformed'
							THEN OperationPerformed
						WHEN @v_SortBy = 'DateandTime'
							THEN CAST([DateandTime] AS VARCHAR)
						END ASC
			END
			ELSE
			BEGIN
				WITH CTE
				AS (
					SELECT ActivityID
						, LoginName
						, Name
						, RoleName
						, PageAccessed
						, OperationPerformed
						, DataAccessDetails
						, [Excel]
						, [DateandTime]						
					FROM #Activity
					)
				SELECT *
				FROM CTE
				ORDER BY CASE 
						WHEN @v_SortBy = 'LoginName'
							THEN LoginName
						WHEN @v_SortBy = 'Name'
							THEN Name
						WHEN @v_SortBy = 'RoleName'
							THEN RoleName
						WHEN @v_SortBy = 'PageAccessed'
							THEN PageAccessed
						WHEN @v_SortBy = 'OperationPerformed'
							THEN OperationPerformed
						WHEN @v_SortBy = 'DateandTime'
							THEN CAST([DateandTime] AS VARCHAR)
						END DESC
			END
					--DECLARE @vc_SQL VARCHAR(MAX)
					--SET @vc_SQL = ' SELECT  ActivityID
					--		, ID
					--		, LoginName
					--		, pageName
					--		, ControlName
					--		, EventName
					--		, Eventtime
					--	FROM #Activity WHERE ActivityID BETWEEN '+CAST(@i_StartIndex  AS VARCHAR)
					--		 +' AND '+CAST( @i_endindex AS VARCHAR)+'ORDER BY '+ @v_SortBy
					--print @VC_sql
					--exec @vc_SQL		 
		END
	END

	SELECT DISTINCT S.SecurityRoleId AS UserID
		, S.RoleName AS UserLoginName
	FROM SecurityRole S
	INNER JOIN UsersSecurityRoles USR
		ON USR.SecurityRoleId = S.SecurityRoleId

	SELECT COUNT(1) AS TotalCount
	FROM #Activity

	SELECT DISTINCT PageName AS PGValue
		, PageName AS PGText
	FROM UserActivityLog
	ORDER BY PGText

	SELECT DISTINCT ActivityType AS ActivityValue
		, ActivityType AS ActivityText
	FROM UserActivityLog
	WHERE ActivityType <> ''
	AND ActivityType <> ''
END TRY

---------------------------------------------------------------------------------------------------------------------     
BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserActivityLog_select] TO [FE_rohit.r-ext]
    AS [dbo];

