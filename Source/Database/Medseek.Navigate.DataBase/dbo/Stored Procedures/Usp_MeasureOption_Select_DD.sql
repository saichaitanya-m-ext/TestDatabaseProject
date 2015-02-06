
/*  
--------------------------------------------------------------------------------  
Procedure Name: [dbo].[Usp_MeasureOption_Select_DD]  
Description   : This procedure is used to select  data from  table.  
Created By    : NagaBabu
Created Date  : 27-July-2011
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
04-Aug-2011 NagaBabu Added Union query to get the value NoResult
23-Aug-2011 NagaBabu Added AND IsTextValueForControls = 1 in where clause
---------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[Usp_MeasureOption_Select_DD] (
	@i_AppUserId KEYID
	,@i_MeasureId KEYID
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

	----------- Select all the active Measure details ---------------  
	SELECT MeasureOptionId
		,MeasureText
	FROM Measure WITH (NOLOCK)
	INNER JOIN MeasureTextOption WITH (NOLOCK) ON MeasureTextOption.MeasureTextOptionId = Measure.MeasureTextOptionId
	INNER JOIN MeasureOption WITH (NOLOCK) ON MeasureOption.MeasureTextOptionId = MeasureTextOption.MeasureTextOptionId
	WHERE Measure.MeasureId = @i_MeasureId
		AND IsTextValueForControls = 1
			  
END TRY

BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Usp_MeasureOption_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

