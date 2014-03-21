
/*  
------------------------------------------------------------------------------  
Procedure Name:   usp_CodeGroupingSource_DD 1,5,0
Description   : Created for getting all active CodeGroupingSoruces
Created By    : Praveen Takasi
Created Date  : 04-June-2013
------------------------------------------------------------------------------
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
06-07-2013 Gurumoorthy V Added Parameter as @i_CodeGroupingTypeID to get 
*/
CREATE PROCEDURE [dbo].[usp_CodeGroupingSource_DD] (
	@i_AppUserId KEYID
	,@i_CodeGroupingTypeID KEYID
	,@i_DisplaySource KEYID
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

	IF @i_DisplaySource = 1
	BEGIN
		SELECT DISTINCT CodeTypeGroupersID
			,CodeTypeGroupersName
		FROM CodeTypeGroupers
		WHERE StatusCode = 'A'
			AND CodeGroupingTypeID = @i_CodeGroupingTypeID
	END
	ELSE
	BEGIN
		SELECT DISTINCT CodeTypeGroupersID
			,CodeTypeGroupersName
		FROM CodeTypeGroupers
		WHERE StatusCode = 'A'
			AND CodeGroupingTypeID = @i_CodeGroupingTypeID
			AND CodeTypeGroupersName NOT IN (
				'CCS Diagnosis Group'
				,'CCS Chronic Diagnosis Group'
				)
	END
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
    ON OBJECT::[dbo].[usp_CodeGroupingSource_DD] TO [FE_rohit.r-ext]
    AS [dbo];

