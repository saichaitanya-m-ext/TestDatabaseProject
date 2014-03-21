
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UserActivityLog_select_test]23, null,'11/05/2013','11/05/2013',null,null
Description   : This procedure is used to get UserActivityLog Records
Created By    : Chaitanya
Created Date  : 01-Oct-2013  
10/28/2013    : Santosh added the activity details result set
10/31/2013    : prathyusha added firstnem,lastname to  result set
11/05/2013    : prathyusha added @i_Providerid parameter and changed sort
12/11/2013	  : Chaitanya renamed Click_Event column in UserActivityLog to ActivityType
12/13/2013	  : Chaitanya added two parameters @vc_PageAccessed and @vc_OperationPerformed
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_UserActivityLog_Select_Test] (
	  @i_AppUserId INT
	, @v_LoginName VARCHAR(100) = NULL
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

	CREATE TABLE #LOGIN (
	   ActivityID INT IDENTITY(1,1)
		,ID INT 
		, LoginName VARCHAR(50)
		, pageName VARCHAR(50)
		, ControlName VARCHAR(50)
		, EventName VARCHAR(50)
		, Eventtime DATETIME
		, activitydetails VARCHAR(500)
		, FirstName varchar(100)
		, LastName varchar(100)
		)

	
					IF (
							@v_LoginName IS NULL
							AND @dt_ActivityDatefrom IS NOT NULL
							AND @dt_ActivityDateto IS NOT NULL	
							AND @i_Providerid IS NOT NULL						
							)
					BEGIN
						INSERT INTO #LOGIN (
							ID
							, LoginName
							, pageName
							, ControlName
							, EventName
							, Eventtime
							,activitydetails
							,FirstName
							,LastName
							)
						SELECT '' AS SNO
							, U.UserLoginName AS LoginName
							, UA.PageName AS PageName
							, UA.ControlType AS ControlName
							, UA.ActivityType AS EventName
							, UA.DATETIME AS EventTime
							,UA.ActivityDetails
							,p.FirstName
							,p.LastName
						FROM UserActivityLog UA
						INNER JOIN UserGroup UG
							ON UA.UserID = UG.ProviderID
						INNER JOIN Users U
							ON U.UserId = Ug.UserId
						INNER JOIN Provider p on
							p.ProviderID=UG.ProviderID
						WHERE CAST(UA.DATETIME AS DATE) BETWEEN @dt_ActivityDatefrom
								AND @dt_ActivityDateto
								AND p.ProviderID=@i_Providerid
						GROUP BY UserLoginName
							, PageName
							, ControlType
							, ActivityType
							, DATETIME
							,ActivityDetails
							,p.FirstName
							,p.LastName
						ORDER BY EventTime DESC
					END
					ELSE
						IF (
								@v_LoginName IS NOT NULL
								AND @dt_ActivityDatefrom IS NOT NULL
								AND @dt_ActivityDateto IS NOT NULL
								AND @i_Providerid IS NOT NULL
								)
						BEGIN
							INSERT INTO #LOGIN (
								ID
								, LoginName
								, pageName
								, ControlName
								, EventName
								, Eventtime
								,activitydetails
								,FirstName
								,LastName
								)
							SELECT '' AS SNO
								, U.UserLoginName AS LoginName
								, UA.PageName AS PageName
								, UA.ControlType AS ControlName
								, UA.ActivityType AS EventName
								, UA.DATETIME AS EventTime
								,UA.ActivityDetails
								,P.FirstName
								,P.LastName
							FROM UserActivityLog UA
							INNER JOIN UserGroup UG
								ON UA.UserID = UG.ProviderID
							INNER JOIN Users U
								ON U.UserId = Ug.UserId
								INNER JOIN Provider P ON
								P.ProviderID=UG.ProviderID
								
							WHERE u.UserLoginName = @v_LoginName							
								    AND CAST(UA.DATETIME AS DATE) BETWEEN @dt_ActivityDatefrom
									AND @dt_ActivityDateto
									AND P.ProviderID=@i_Providerid
									
							GROUP BY UserLoginName
								, PageName
								, ControlType
								, ActivityType
								, DATETIME
								,ActivityDetails
								,P.FirstName
								,P.LastName
							ORDER BY  EventTime DESC
						END
						ELSE
						IF (
							@v_LoginName IS NULL
							AND @dt_ActivityDatefrom IS NOT NULL
							AND @dt_ActivityDateto IS NOT NULL	
							AND @i_Providerid IS  NULL						
							)
					BEGIN
						INSERT INTO #LOGIN (
							ID
							, LoginName
							, pageName
							, ControlName
							, EventName
							, Eventtime
							,activitydetails
							,FirstName
							,LastName
							)
						SELECT '' AS SNO
							, U.UserLoginName AS LoginName
							, UA.PageName AS PageName
							, UA.ControlType AS ControlName
							, UA.ActivityType AS EventName
							, UA.DATETIME AS EventTime
							,UA.ActivityDetails
							,p.FirstName
							,p.LastName
						FROM UserActivityLog UA
						INNER JOIN UserGroup UG
							ON UA.UserID = UG.ProviderID
						INNER JOIN Users U
							ON U.UserId = Ug.UserId
						INNER JOIN Provider p on
							p.ProviderID=UG.ProviderID
						WHERE CAST(UA.DATETIME AS DATE) BETWEEN @dt_ActivityDatefrom
								AND @dt_ActivityDateto
								
						GROUP BY UserLoginName
							, PageName
							, ControlType
							, ActivityType
							, DATETIME
							,ActivityDetails
							,p.FirstName
							,p.LastName
						ORDER BY EventTime DESC
						END
					ELSE
					IF	
					(
							@v_LoginName IS NOT NULL
							AND @dt_ActivityDatefrom IS NOT NULL
							AND @dt_ActivityDateto IS NOT NULL	
							AND @i_Providerid IS  NULL						
							)
					BEGIN
						INSERT INTO #LOGIN (
							ID
							, LoginName
							, pageName
							, ControlName
							, EventName
							, Eventtime
							,activitydetails
							,FirstName
							,LastName
							)
						SELECT '' AS SNO
							, U.UserLoginName AS LoginName
							, UA.PageName AS PageName
							, UA.ControlType AS ControlName
							, UA.ActivityType AS EventName
							, UA.DATETIME AS EventTime
							,UA.ActivityDetails
							,p.FirstName
							,p.LastName
						FROM UserActivityLog UA
						INNER JOIN UserGroup UG
							ON UA.UserID = UG.ProviderID
						INNER JOIN Users U
							ON U.UserId = Ug.UserId
						INNER JOIN Provider p on
							p.ProviderID=UG.ProviderID
						WHERE 
						 u.UserLoginName = @v_LoginName
						 AND
						 CAST(UA.DATETIME AS DATE) BETWEEN @dt_ActivityDatefrom
								AND @dt_ActivityDateto
								
						GROUP BY UserLoginName
							, PageName
							, ControlType
							, ActivityType
							, DATETIME
							,ActivityDetails
							,p.FirstName
							,p.LastName
						ORDER BY EventTime DESC
						END
						--SELECT * FROM #LOGIN

   IF @v_SortBy IS NULL AND @v_SortType IS NULL
   BEGIN		

	WITH CTE
	AS (
		SELECT  ActivityID
			, ID
			, LoginName
			,(LastName + +' '+ firstname) as FirstName
			,LastName
			, pageName
			, ControlName
			, EventName
			,activitydetails
			, Eventtime
			
		FROM #LOGIN
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
		SELECT  ActivityID
			, ID
			, LoginName
			,(LastName + +' '+ firstname) as FirstName
			,LastName
			, pageName
			, ControlName
			, EventName
			, ActivityDetails
			, Eventtime
			
		FROM #LOGIN
		)
	SELECT *
	FROM CTE
	  ORDER BY  CASE WHEN @v_SortBy = 'LoginName' 
			                                 THEN LoginName 
			                                 WHEN @v_SortBy = 'pageName'
			                                 THEN pageName
			                                 WHEN @v_SortBy = 'ControlName'
			                                 THEN ControlName
			                                 WHEN @v_SortBy = 'EventName'
			                                 THEN EventName
			                                 WHEN @v_SortBy = 'FirstName'
			                                 THEN FirstName
			                                 WHEN @v_SortBy = 'Eventtime'
			                                 THEN CAST(Eventtime AS VARCHAR)
			                                  END ASC
END			                                  
 ELSE
 
   BEGIN
   
   
   WITH CTE
	AS (
		SELECT  ActivityID
			, ID
			, LoginName
			,(LastName + +' '+ firstname) as FirstName
			,LastName
			, pageName
			, ControlName
			, EventName
			,ActivityDetails
			, Eventtime
			
		FROM #LOGIN
		)
	SELECT *
	FROM CTE
	 ORDER BY  CASE WHEN @v_SortBy = 'LoginName' 
			                                 THEN LoginName 
			                                 WHEN @v_SortBy = 'pageName'
			                                 THEN pageName
			                                 WHEN @v_SortBy = 'ControlName'
			                                 THEN ControlName
			                                 WHEN @v_SortBy = 'EventName'
			                                 THEN EventName
			                                 WHEN @v_SortBy = 'FirstName'
			                                 THEN FirstName
			                                 WHEN @v_SortBy = 'Eventtime'
			                                 THEN CAST(Eventtime AS VARCHAR)
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
	--	FROM #LOGIN WHERE ActivityID BETWEEN '+CAST(@i_StartIndex  AS VARCHAR)
	--		 +' AND '+CAST( @i_endindex AS VARCHAR)+'ORDER BY '+ @v_SortBy
			 
	--print @VC_sql
	--exec @vc_SQL		 
		
		
	END
	  END
	  		

	SELECT DISTINCT S.RoleName FROM SecurityRole S
INNER JOIN UsersSecurityRoles USR
ON USR.SecurityRoleId = S.SecurityRoleId

		
	SELECT COUNT(1) AS TotalCount FROM #LOGIN
	
	SELECT DISTINCT PageName AS PGValue
		, PageName AS PGText		
	FROM UserActivityLog
	
	SELECT DISTINCT ActivityType AS ActivityValue
	, ActivityType AS ActivityText
	FROM UserActivityLog
	
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
    ON OBJECT::[dbo].[usp_UserActivityLog_Select_Test] TO [FE_rohit.r-ext]
    AS [dbo];

