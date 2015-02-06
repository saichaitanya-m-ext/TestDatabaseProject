
/*          
----------------------------------------------------------------------------------          
Procedure Name: [usp_Measure_Search] 
Description   : This Procedure is used to search for Measures by a String
Created By    : NagaBabu
Created Date  : 25-July-2011
----------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION
08-Sept-2011 Rathnam added AND Measure.IsSynonym = 0 in where clause          
----------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_Measure_Search] (
	@i_AppUserId KEYID
	,@v_Measure VARCHAR(10)
	,@b_IsLabMeasure ISINDICATOR = 0
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @i_numberOfRecordsSelected INT

	----- Check if valid Application User ID is passed--------------          
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

	--------- search Measure from the MeasureTable ----------------          
	SELECT MeasureId
		,NAME AS MeasureName
		,Measure.RealisticMin
		,Measure.RealisticMax
		,Measure.StandardMeasureUOMId AS MeasureUOMID
		,ISNULL(MeasureUOM.UOMText, '') AS UOM
		,Measure.IsTextValueForControls
	FROM Measure
	LEFT OUTER JOIN MeasureUOM ON MeasureUOM.MeasureUOMId = Measure.StandardMeasureUOMId
	INNER JOIN MeasureType ON Measure.MeasureTypeId = MeasureType.MeasureTypeId
	WHERE (
			NAME LIKE '%' + @v_Measure + '%'
			OR @v_Measure IS NULL
			OR @v_Measure = ''
			)
		AND Measure.StatusCode = 'A'
		AND Measure.IsSynonym = 0
	ORDER BY Measure.SortOrder
		,Measure.NAME
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
    ON OBJECT::[dbo].[usp_Measure_Search] TO [FE_rohit.r-ext]
    AS [dbo];

