
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_Measure_Select        
Description   : This procedure is used to get the details from Measure table       
Created By    : Aditya        
Created Date  : 15-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
01-Mar-2011 NagaBabu Added RealisticMin,RealisticMax fields in Select statement  
27-July-2011 NagaBabu Added JOIN with MeasureTextOption Table to get MeasureTextOption field   
07-Sept-2011 Rathnam added Issysnonym column to the select statement
12-Sept-2011 Rathnam added SynonymName column to the select statement   
25-July-2013 NagaBabu Replaced table CodeSetLoincCodes with CodeSetLoinc
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Measure_Select] (
	@i_AppUserId KeyID
	,@i_MeasureId KeyID = NULL
	,@v_StatusCode StatusCode = NULL
	,@b_IsSynonym ISINDICATOR = 0
	,@b_IsTextValueControl ISINDICATOR = NULL
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

	SELECT Measure.MeasureId
		,Measure.NAME
		,Measure.Description
		,Measure.MeasureTypeId
		,MeasureType.MeasureTypeName
		,Measure.SortOrder
		,Measure.CreatedByUserId
		,Measure.CreatedDate
		,Measure.LastModifiedByUserId
		,Measure.LastModifiedDate
		,Measure.StandardMeasureUOMId
		,MeasureUOM.UOMText
		,Measure.isVital
		,Measure.IsTextValueForControls
		,CASE Measure.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS StatusDescription
		,MeasureUOM.UOMText
		,MeasureUOM.UOMDescription
		,Measure.RealisticMin
		,Measure.RealisticMax
		,Measure.MeasureTextOptionId
		,MeasureTextOption.MeasureTextOption
		,ISNULL((
				SELECT COUNT(ms.SynonymMeasureID)
				FROM MeasureSynonyms ms
				INNER JOIN Measure m ON m.MeasureId = ms.SynonymMeasureID
				WHERE SynonymMasterMeasureID = Measure.MeasureID
					AND m.StatusCode = 'A'
				), 0) AS NoOfSynonym
		,ISNULL(Measure.IsSynonym, 0) AS IsSynonym
		,(
			SELECT NAME
			FROM Measure m
			WHERE m.MeasureId = (
					SELECT DISTINCT SynonymMasterMeasureID
					FROM MeasureSynonyms
					WHERE SynonymMeasureID = Measure.MeasureId
					)
			) AS SynonymName
	FROM Measure WITH (NOLOCK)
	LEFT OUTER JOIN MeasureUOM WITH (NOLOCK) ON MeasureUOM.MeasureUOMId = Measure.StandardMeasureUOMId
	INNER JOIN MeasureType WITH (NOLOCK) ON MeasureType.MeasureTypeId = Measure.MeasureTypeId
	LEFT OUTER JOIN MeasureTextOption WITH (NOLOCK) ON MeasureTextOption.MeasureTextOptionId = Measure.MeasureTextOptionId
	WHERE (
			Measure.MeasureId = @i_MeasureId
			OR @i_MeasureId IS NULL
			)
		AND (
			Measure.StatusCode = @v_StatusCode
			OR @v_StatusCode IS NULL
			)
		AND (
			Measure.IsTextValueForControls = @b_IsTextValueControl
			OR @b_IsTextValueControl IS NULL
			)
		AND IsSynonym = @b_IsSynonym
	ORDER BY CASE 
			WHEN @b_IsSynonym = 0
				THEN Measure.NAME
			END
		,CASE 
			WHEN @b_IsSynonym = 1
				THEN (
						SELECT NAME
						FROM Measure m
						WHERE m.MeasureId = (
								SELECT DISTINCT SynonymMasterMeasureID
								FROM MeasureSynonyms
								WHERE SynonymMeasureID = Measure.MeasureId
								)
						)
			END

	IF @i_MeasureId IS NOT NULL
	BEGIN
		
		SELECT csp.ProcedureCodeID
			,csp.ProcedureCode + '-' + csp.ProcedureName ProcedureCode
		FROM ProcedureMeasure pm WITH (NOLOCK)
		INNER JOIN CodeSetProcedure csp WITH (NOLOCK) ON pm.ProcedureId = csp.ProcedureCodeID
		WHERE pm.MeasureId = @i_MeasureId
			AND pm.StatusCode = 'A'

		SELECT CONVERT(VARCHAR, cl.LoincCodeId) LoincCodeId
			,cl.LoincCode + '-' + cl.ShortDescription LoincCode
		FROM LoinCodeMeasure lm WITH (NOLOCK)
		INNER JOIN CodeSetLoinc cl WITH (NOLOCK) ON cl.LoincCodeId = lm.LoinCodeId
		WHERE lm.MeasureId = @i_MeasureId
			AND lm.StatusCode = 'A'
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
    ON OBJECT::[dbo].[usp_Measure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

