/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_Reports_PatientAudit] 123,4291,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'PatientName','ASC'
Description   : This procedure is used to get UserActivityLog Records
Created By    : Chaitanya
Created Date  : 12-DEC-2013  
------------------------------------------------------------------------------    
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
-------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Reports_PatientAudit] (
	@i_AppUserId INT
	, @i_PatientID KeyID = NULL
	, @vc_MRNNumber VARCHAR(80) = NULL
	, @dt_ActivityDatefrom DATETIME = NULL
	, @dt_ActivityDateto DATETIME = NULL
	, @vc_PageAccessed VARCHAR(100) = NULL
	, @vc_OperationPerformed VARCHAR(100) = NULL
	, @i_StartIndex INT = 1
	, @i_EndIndex INT = 20
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

	CREATE TABLE #PatientAudit (
		AuditID INT IDENTITY(1, 1) NOT NULL
		, PatientName VARCHAR(100)
		, [MRNNumber] VARCHAR(80)
		, [Age/Gender] VARCHAR(12)
		, [PCP] VARCHAR(100)
		, [PageAccessed] VARCHAR(100)
		, [AccessedBy] VARCHAR(200)
		, [ActionsPerformed] VARCHAR(500)
		, [DataAccessDetails] VARCHAR(MAX)
		, [DateandTime] DATETIME
		, [Excel] VARCHAR(MAX)
		)

	INSERT INTO #PatientAudit (
		PatientName
		, [MRNNumber]
		, [Age/Gender]
		, [PCP]
		, [PageAccessed]
		, [AccessedBy]
		, [ActionsPerformed]
		, [DataAccessDetails]
		, [DateandTime]
		, [Excel] 
		)
	SELECT CAST(ISNULL(P.LastName, NULL) + ', ' + ISNULL(P.FirstName, NULL) AS VARCHAR(100)) AS PatientName
		, P.MedicalRecordNumber AS [MRNNumber]
		, CAST(CAST(dbo.ufn_GetAgeByDOB(DateOfBirth) AS VARCHAR(3)) + '/' + CAST(CASE 
					WHEN P.Gender = 'M'
						THEN 'Male'
					WHEN P.Gender = 'F'
						THEN 'Female'
					END AS VARCHAR(6)) AS VARCHAR(9)) AS [Age/Gender]
	--	, ISNULL(PR.LastName, NULL) + ', ' + ISNULL(PR.FirstName, NULL) AS [PCP]	
		, ISNULL(LEFT(P.PCPName,CHARINDEX('PCP',P.PCPName)-2),NULL) + ', ' + REPLACE(SUBSTRING(P.PCPName,CHARINDEX('PCP',P.PCPName),LEN(P.PCPName)),'PCP','') AS [PCP]
		, UA.PageName AS [PageAccessed]
	--	, CAST(ISNULL(PR.LastName, NULL) + ' ' + ISNULL(PR.FirstName, NULL) + '/' + S.RoleName AS VARCHAR(200)) AS [AccessedBy]
		, CAST(U.UserLoginName + '/' + S.RoleName AS VARCHAR(200)) AS [AccessedBy]
		, UA.ActivityType AS [ActionsPerformed]
		, UA.ActivityDetails AS [DataAccessDetails]
		, CAST(UA.[DateTime] AS DATETIME) AS [DateandTime]
		, REPLACE(REPLACE(REPLACE(REPLACE(UA.ActivityDetails,'<b>',''),'</br>',''),'<br />',''),'</b>','') AS [Excel]
	FROM UserActivityLog UA
	INNER JOIN Patient P
		ON P.PatientID = UA.PatientID		
	INNER JOIN UserGroup UG
		ON UG.UserID = UA.UserID
	INNER JOIN Users U
		ON U.UserId = UG.UserID	
	INNER JOIN Provider PR
		ON PR.ProviderID = UG.ProviderID
	INNER JOIN UsersSecurityRoles USR
		ON USR.ProviderID = UG.ProviderID
	INNER JOIN SecurityRole S
		ON USR.SecurityRoleId = S.SecurityRoleId
	WHERE (
			UA.PatientID = @i_PatientID
			OR @i_PatientID IS NULL
			)
		AND (
			P.MedicalRecordNumber = @vc_MRNNumber 
			OR @vc_MRNNumber IS NULL
			)
		AND (
			CAST(UA.[DateTime] AS DATE) BETWEEN CAST(ISNULL(@dt_ActivityDatefrom, '1900-01-01') AS DATETIME)
				AND CAST(ISNULL(@dt_ActivityDateto, GETDATE()) AS DATETIME)
			)
		AND (
			UA.PageName = @vc_PageAccessed
			OR @vc_PageAccessed IS NULL
			)
		AND (
			UA.ActivityType = @vc_OperationPerformed
			OR @vc_OperationPerformed IS NULL
			)
	--AND UA.MRNNumber IS NOT NULL
	ORDER BY UA.[DateTime] DESC
	

	PRINT @dt_ActivityDatefrom
	PRINT @dt_ActivityDateTo

	IF @v_SortBy IS NULL
		AND @v_SortType IS NULL
	BEGIN
		;WITH CTE
			AS (
			SELECT AuditID
				, PatientName
				, [MRNNumber]
				, [Age/Gender]
				, [PCP]
				, [PageAccessed]
				, [AccessedBy]
				, [ActionsPerformed]
				, [DataAccessDetails]
				, [Excel]
				, [DateandTime]				
			FROM #PatientAudit
			)
		SELECT *
		FROM CTE
		WHERE AuditID BETWEEN @i_StartIndex
				AND @i_endindex
	END
	ELSE
	BEGIN
		BEGIN
			IF @v_SortType = 'ASC'
			BEGIN
				;WITH CTE
				AS (
					SELECT AuditID
						, PatientName
						, [MRNNumber]
						, [Age/Gender]
						, [PCP]
						, [PageAccessed]
						, [AccessedBy]
						, [ActionsPerformed]
						, [DataAccessDetails]
						, [Excel]
						, [DateandTime]						
					FROM #PatientAudit
					)
				SELECT *
				FROM CTE
				ORDER BY CASE 
						WHEN @v_SortBy = 'PatientName'
							THEN PatientName
						WHEN @v_SortBy = 'PCP'
							THEN PCP
						WHEN @v_SortBy = 'PageAccessed'
							THEN PageAccessed
						WHEN @v_SortBy = 'ActionsPerformed'
							THEN ActionsPerformed
						WHEN @v_SortBy = 'DateandTime'
							THEN CAST([DateandTime] AS VARCHAR(20))
						END ASC
			END
			ELSE
			BEGIN
				;WITH CTE
				AS (
					SELECT AuditID
						, PatientName
						, [MRNNumber]
						, [Age/Gender]
						, [PCP]
						, [PageAccessed]
						, [AccessedBy]
						, [ActionsPerformed]
						, [DataAccessDetails]
						, [Excel]
						, [DateandTime]						
					FROM #PatientAudit
					)
				SELECT *
				FROM CTE
				ORDER BY CASE 
						WHEN @v_SortBy = 'PatientName'
							THEN PatientName
						WHEN @v_SortBy = 'PCP'
							THEN PCP
						WHEN @v_SortBy = 'PageAccessed'
							THEN PageAccessed
						WHEN @v_SortBy = 'ActionsPerformed'
							THEN ActionsPerformed
						WHEN @v_SortBy = 'DateandTime'
							THEN CAST([DateandTime] AS VARCHAR(20))
						END DESC
			END
		END
	END

	SELECT COUNT(1) AS TotalCount
	FROM #PatientAudit
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
    ON OBJECT::[dbo].[usp_Reports_PatientAudit] TO [FE_rohit.r-ext]
    AS [dbo];

