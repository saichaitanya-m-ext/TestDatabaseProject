
/*  
------------------------------------------------------------------------------  
Procedure Name: usp_ProgramType_Select  
Description   : This procedure is used to get the list of all Program Types
				for a particular program Type or get lsit of all the types
Created By    : Pramod  
Created Date  : 24-Feb-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
07-Oct-2011 Rathnam added IsPrograms column to the select statement for checking the programs for a 
					particular programtype  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_ProgramType_Select] (
	@i_AppUserId INT
	,@i_ProgramTypeId INT = NULL
	,@v_StatusCode StatusCode = NULL
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

	SELECT ProgramTypeId
		,NAME
		,Description
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
		,CASE 
			WHEN (
					SELECT TOP 1 1
					FROM Program
					WHERE ProgramTypeId = ProgramType.ProgramTypeId
					) = 1
				THEN 1
			ELSE 0
			END IsPrograms
	FROM ProgramType WITH (NOLOCK)
	WHERE (
			ProgramTypeId = @i_ProgramTypeId
			OR @i_ProgramTypeId IS NULL
			)
		AND (
			@v_StatusCode IS NULL
			OR StatusCode = @v_StatusCode
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
    ON OBJECT::[dbo].[usp_ProgramType_Select] TO [FE_rohit.r-ext]
    AS [dbo];

