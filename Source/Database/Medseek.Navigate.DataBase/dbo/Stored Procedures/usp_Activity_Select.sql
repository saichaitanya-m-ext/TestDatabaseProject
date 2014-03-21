
/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Activity_Select]
Description	  : This procedure is used to select the details from Activity table.
Created By    :	Aditya 
Created Date  : 19-Jan-2010
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION

---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Activity_Select] (
	@i_AppUserId KEYID
	,@i_ActivityId KEYID = NULL
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
	SELECT ActivityId
		,NAME
		,Description
		,ParentActivityId
		,CreatedByUserId
		,CreatedDate
		,LastModifiedByUserId
		,LastModifiedDate
		,CASE StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS StatusDescription
	FROM Activity
	WHERE (
			ActivityId = @i_ActivityId
			OR @i_ActivityId IS NULL
			)
		AND (
			@v_StatusCode IS NULL
			OR StatusCode = @v_StatusCode
			)
	ORDER BY NAME
		,StatusCode
END TRY

BEGIN CATCH
	-- Handle exception
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Activity_Select] TO [FE_rohit.r-ext]
    AS [dbo];

