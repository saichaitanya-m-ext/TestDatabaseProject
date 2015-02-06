
--sp_helptext usp_UserPrograms_Select
/*            
------------------------------------------------------------------------------            
Procedure Name: usp_UserPrograms_Select            
Description   : This procedure is used to get the details from UserPrograms Table          
Created By    : Aditya            
Created Date  : 23-Mar-2010            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY         DESCRIPTION            
25-May-2010 NagaBabu   UserPrograms.DueDate, is added to select stament         
11-Jun-2010 Pramod   Added ProgramId as parameter  
15-Jun-2010 NagaBabu   Modified UserName field in select statement  
24-Aug-2010 NagaBabu   Added Program.StatusCode,UserPrograms.EnrollmentEndDate fields in where clause  
20-Sep-10 Pramod removed the faulty statement of UserPrograms.EnrollmentEndDate IS NULL from the select where clause  
14-Mar-2011 NagaBabu ProgramExcludeID Field and as well as perameter  
18-Mar-2011 NagaBabu Added ExclusionReason field and joined 'ProgramExclusionReasons' Table by LEFT OUTER JOIN   
22-Sep-2011 NagaBabu Added 'AND AllowAutoEnrollment = 1' to filter programs   
24-Oct-2011 NagaBabu Removed 'AND AllowAutoEnrollment = 1'   
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_UserPrograms_Select] --1,1,10,null,null,2,'A'  
	(
	@i_AppUserId KEYID
	,@i_StartIndex INT = 1
	,@i_EndIndex INT = 10
	,@i_UserProgramId KEYID = NULL
	,@i_UserId KEYID = NULL
	,@i_ProgramId KEYID = NULL
	,@v_StatusCode StatusCode = NULL
	,@v_SortBy VARCHAR(100) = 'EnrollmentStartDate'
	,@v_SortOrder VARCHAR(100) = 'DESC'
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

	DECLARE @v_SQL VARCHAR(MAX)

	--,@v_SQLForAll VARCHAR(MAX)
	CREATE TABLE #tUserPrograms (
		ID INT IDENTITY PRIMARY KEY
		,UserProgramId INT
		)

	SET @v_SQL = 'INSERT INTO #tUserPrograms
				(UserPrograms.UserProgramId)
		SELECT     
			  PatientProgram.PatientProgramID 
		 FROM        
			  PatientProgram WITH(NOLOCK)  
		 INNER JOIN Program WITH(NOLOCK)       
			  ON  Program.ProgramId = PatientProgram.ProgramId   
		 LEFT OUTER JOIN ProgramExclusionReasons WITH(NOLOCK)  
		ON ProgramExclusionReasons.ProgramExcludeID = PatientProgram.ProgramExcludeID
		WHERE 1 = 1 '

	IF @i_UserProgramId IS NOT NULL
		SET @v_SQL = @v_SQL + ' AND  PatientProgram.PatientProgramID = ' + CONVERT(VARCHAR(10), @i_UserProgramId)

	IF @i_ProgramId IS NOT NULL
		SET @v_SQL = @v_SQL + ' AND  PatientProgram.ProgramId = ' + CONVERT(VARCHAR(10), @i_ProgramId)

	IF @i_UserId IS NOT NULL
		SET @v_SQL = @v_SQL + ' AND  PatientProgram.PatientId = ' + CONVERT(VARCHAR(10), @i_UserId)

	IF @v_StatusCode IS NOT NULL
		SET @v_SQL = @v_SQL + ' AND  PatientProgram.StatusCode = ''' + CONVERT(VARCHAR(10), @v_StatusCode) + ''''

	DECLARE @v_SQLSort VARCHAR(max)

	IF @v_SortBy = 'UserName'
	BEGIN
		SET @v_SQLSort = ' ORDER BY dbo.ufn_GetPatientNameByID(PatientProgram.PatientId) ' + CONVERT(VARCHAR, @v_SortOrder)
	END
	ELSE
		IF @v_SortBy = 'StatusDescription'
		BEGIN
			SET @v_SQLSort = ' ORDER BY CASE PatientProgram.StatusCode WHEN ''A'' THEN ''Active'' WHEN ''I'' THEN ''InActive'' ELSE '''' END ' + CONVERT(VARCHAR, @v_SortOrder)
		END
		ELSE
			IF @v_SortBy = 'EnrollmentType'
			BEGIN
				SET @v_SQLSort = ' ORDER BY CASE WHEN ISNULL(PatientProgram.IsAutoEnrollment,0) = 0 THEN ''Manual'' when PatientProgram.IsAutoEnrollment = 1 THEN ''Auto'' END ' + CONVERT(VARCHAR, @v_SortOrder)
			END
			ELSE
			BEGIN
				SET @v_SQLSort = ' ORDER BY ' + CONVERT(VARCHAR, @v_SortBy) + ' ' + CONVERT(VARCHAR, @v_SortOrder)
			END

	SET @v_SQL = @v_SQL + ISNULL(@v_SQLSort, '')

	PRINT @v_SQL

	EXEC (@v_SQL)

	SELECT tUserProgram.[UserProgramId]
		,PatientProgram.[ProgramId]
		,Program.[ProgramName]
		,PatientProgram.PatientID AS UserId
		,p.FullName AS UserName
		,PatientProgram.[DueDate]
		,PatientProgram.[EnrollmentStartDate]
		,PatientProgram.[EnrollmentEndDate]
		,PatientProgram.[IsPatientDeclinedEnrollment]
		,PatientProgram.[DeclinedDate]
		,PatientProgram.[CreatedByUserId]
		,PatientProgram.[CreatedDate]
		,PatientProgram.[LastModifiedByUserId]
		,PatientProgram.[LastModifiedDate]
		,CASE PatientProgram.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS StatusDescription
		,PatientProgram.[ProgramExcludeID]
		,ProgramExclusionReasons.[ExclusionReason]
		,CASE 
			WHEN ISNULL(PatientProgram.IsAutoEnrollment, 0) = 0
				THEN 'Manual'
			WHEN PatientProgram.IsAutoEnrollment = 1
				THEN 'Auto'
			END AS EnrollmentType
		,PatientProgram.[IdentificationDate]
	FROM #tUserPrograms tUserProgram
	INNER JOIN PatientProgram WITH (NOLOCK) ON tUserProgram.UserProgramId = PatientProgram.PatientProgramID
	INNER JOIN Patients p ON p.PatientID = PatientProgram.PatientID
	INNER JOIN Program WITH (NOLOCK) ON Program.ProgramId = PatientProgram.ProgramID
	LEFT OUTER JOIN ProgramExclusionReasons WITH (NOLOCK) ON ProgramExclusionReasons.ProgramExcludeID = PatientProgram.ProgramExcludeID
	WHERE ID BETWEEN @i_StartIndex
			AND @i_EndIndex

	IF @v_StatusCode IS NULL
		SELECT COUNT(1)
		FROM PatientProgram
		WHERE ProgramId = @i_ProgramId
	ELSE
		SELECT COUNT(1)
		FROM PatientProgram
		WHERE ProgramId = @i_ProgramId
			AND StatusCode = 'A'
END TRY

--------------------------------------------------------             
BEGIN CATCH
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserPrograms_Select] TO [FE_rohit.r-ext]
    AS [dbo];

