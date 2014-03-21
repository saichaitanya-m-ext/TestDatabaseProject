
/*
-------------------------------------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PopulationDefinitionUserCount_Select]23,53
Description	  : This procedure is used to select the details from CohortList,CohortListUsers tables.
Created By    :	Kalyan
Created Date  : 10/July/2012
--------------------------------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
15-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers	
27-Mar-2013 P.V.P.Mohan changed table name PopulationDefinitionUsers	to PopulationDefinitionPatients
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionUserCount_Select] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KeyID = NULL
	,@v_StatusCode StatusCode = NULL
	)
AS
BEGIN TRY
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

	----------- Select all the Activity details ---------------
	SELECT TOP 10 -- For showing the top 10 records
		pt.PatientID UserId
		,UPPER(COALESCE(ISNULL(pt.LastName, '') + ', ' + ISNULL(pt.FirstName, '') + '. ' + ISNULL(pt.MiddleName, '') + ' ' + ISNULL(pt.NameSuffix, ''), '')) AS FullName
		,CASE pt.Gender
			WHEN 'M'
				THEN 'Male'
			WHEN 'F'
				THEN 'Female'
			END AS Gender
		,DATEDIFF(YEAR, pt.DateOfBirth, GETDATE()) AS Age
		,pt.MedicalRecordNumber AS MemberNum
		,pt.AccountStatusCode AS UserStatusCode
		,CASE PopulationDefinitionPatients.LeaveInList
			WHEN 0
				THEN 'NO'
			WHEN 1
				THEN 'YES'
			END AS LeaveInList
		,CASE PopulationDefinitionPatients.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			WHEN 'P'
				THEN 'Pending Delete'
			END AS StatusCode
	FROM PopulationDefinitionPatients WITH (NOLOCK)
	INNER JOIN Patient pt WITH (NOLOCK) ON pt.PatientID = PopulationDefinitionPatients.PatientID
	WHERE PopulationDefinitionPatients.PopulationDefinitionID = @i_PopulationDefinitionID
		AND ISNULL(IsDeceased, 0) = 0
		AND (
			PopulationDefinitionPatients.StatusCode = @v_StatusCode
			OR @v_StatusCode IS NULL
			)
		AND pt.AccountStatusCode = 'A'
	ORDER BY PopulationDefinitionPatients.StatusCode
		,FullName
		,MemberNum

	SELECT COUNT(pt.PatientID) AS TotalPatients
	FROM PopulationDefinitionPatients WITH (NOLOCK)
	INNER JOIN Patient pt WITH (NOLOCK) ON pt.PatientID = PopulationDefinitionPatients.PatientID
		AND pt.AccountStatusCode = 'A'
	WHERE PopulationDefinitionPatients.PopulationDefinitionID = @i_PopulationDefinitionID
		--AND U.EndDate is NULL
		AND ISNULL(IsDeceased, 0) = 0
		AND StatusCode = @v_StatusCode
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionUserCount_Select] TO [FE_rohit.r-ext]
    AS [dbo];

