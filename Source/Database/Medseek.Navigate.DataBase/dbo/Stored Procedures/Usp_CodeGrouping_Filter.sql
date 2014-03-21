
/*  
------------------------------------------------------------------------------  
Procedure Name:   [Usp_CodeGrouping_Filter] @i_AppUserId=2,@i_CodeGroupingID=373
Description   : This procedure is used to get the details from codegroupingcodetype table
Created By    : Gurumoorthy V  
Created Date  : 22-May-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[Usp_CodeGrouping_Filter] (
	@i_AppUserId KEYID
	,@v_CodeGroupingName VARCHAR(20) = NULL
	,@i_CodeGroupingID KEYID
	,@v_CodeGroupingTypeID KEYID = NULL
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
				,24
				,@i_AppUserId
				)
	END

	SELECT CG.CodeGroupingID
		,CodeGroupingName
	FROM CodeGrouping CG
	LEFT JOIN CodeGroupingSynonyms CGS ON CG.CodeGroupingID = CGS.CodeGroupingID
	INNER JOIN CodeTypeGroupers CTG ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
	WHERE (
			CG.CodeGroupingName LIKE '%' + @v_CodeGroupingName + '%'
			OR CGS.CodeGroupingSynonym LIKE '%' + @v_CodeGroupingName + '%'
			OR @v_CodeGroupingName IS NULL
			)
		AND (
			CTG.CodeGroupingTypeID = @v_CodeGroupingTypeID
			OR @v_CodeGroupingTypeID IS NULL
			)
		AND (CTG.CodeTypeGroupersName <> 'HEDIS-ECT')
		AND CG.StatusCode = 'A'
		AND IsPrimary = 1
		AND ProductionStatus = 'F'
		AND CG.CodeGroupingID <> @i_CodeGroupingID
		AND DisplayStatus = 1
	
	UNION ALL
	
	SELECT CG.CodeGroupingID
		,CodeGroupingName
	FROM CodeGrouping CG
	LEFT JOIN CodeGroupingSynonyms CGS ON CG.CodeGroupingID = CGS.CodeGroupingID
	INNER JOIN CodeTypeGroupers CTG ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
	WHERE (
			CG.CodeGroupingName LIKE '%' + @v_CodeGroupingName + '%'
			OR CGS.CodeGroupingSynonym LIKE '%' + @v_CodeGroupingName + '%'
			OR @v_CodeGroupingName IS NULL
			)
		AND (
			CTG.CodeGroupingTypeID = @v_CodeGroupingTypeID
			OR @v_CodeGroupingTypeID IS NULL
			)
		AND (CTG.CodeTypeGroupersName <> 'HEDIS-ECT')
		AND CG.StatusCode = 'A'
		AND IsPrimary = 1
		AND ProductionStatus = 'F'
		AND CG.CodeGroupingID <> @i_CodeGroupingID
		AND DisplayStatus = 0
		AND CG.CreatedByUserId = @i_AppUserId
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
    ON OBJECT::[dbo].[Usp_CodeGrouping_Filter] TO [FE_rohit.r-ext]
    AS [dbo];

