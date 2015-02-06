
/*  
------------------------------------------------------------------------------  
Procedure Name: usp_NPOLkupCodeSupplemental_DD 1,'S'
Description   : This procedure is used to getting the drop down values for NPOLkupSupplemental
Created By    : Rathnam
Created Date  : 10-June-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_NPOLkupCodeSupplemental_DD] (
	@i_AppUserId KeyID
	,@v_RecordType VARCHAR(2)
	,@i_CodeTypeID KEYID = NULL
	,@i_MeasureID KEYID = NULL
	,@b_ServiceType BIT = 0
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

	IF @v_RecordType IS NOT NULL
		AND @i_CodeTypeID IS NULL
		AND @i_MeasureID IS NULL
		AND @b_ServiceType = 0
	BEGIN
		IF @v_RecordType = 'S'
		BEGIN
			SELECT LkUpCodeID CodeTypeID
				,DESCRIPTION CodeTypeName
			FROM NPOLkup lm
			INNER JOIN NpoLkupType lt
				ON lm.NPOLkUpTypeID = lt.NPOLkUpTypeID
			WHERE LkUpTypeName = 'CodeType'
				AND DESCRIPTION IN (
					'CPT'
					,'CPT_CAT_II'
					,'HCPCS'
					,'REVENUE'
					)
		END
		ELSE
			IF @v_RecordType = 'R'
			BEGIN
				SELECT LkUpCodeID CodeTypeID
					,DESCRIPTION CodeTypeName
				FROM NPOLkup lm
				INNER JOIN NpoLkupType lt
					ON lm.NPOLkUpTypeID = lt.NPOLkUpTypeID
				WHERE LkUpTypeName = 'CodeType'
					AND DESCRIPTION IN ('LOINC')
			END
	END
	ELSE
		IF @i_CodeTypeID IS NOT NULL
			AND @i_MeasureID IS NULL
			AND @b_ServiceType = 0
		BEGIN
			SELECT DISTINCT Measure.LkUpCodeID MeasureID
				,Measure.LkUpCode MeasureName
			FROM NPOLkupSupplemental lks
			INNER JOIN NPOLkup Measure
				ON Measure.LkUpCodeID = lks.MeasureID
			INNER JOIN NPOLkupType lkt
				ON lkt.NPOLkUpTypeID = Measure.NPOLkUpTypeID
			WHERE lks.CodeTypeID = @i_CodeTypeID
				AND lkt.LkUpTypeName = 'Measure'
		END
		ELSE
			IF @i_CodeTypeID IS NOT NULL
				AND @i_MeasureID IS NOT NULL
				AND @b_ServiceType = 0
			BEGIN
				SELECT DISTINCT lks.CodeValue  
				FROM NPOLkupSupplemental lks
				INNER JOIN NPOLkup Measure
					ON Measure.LkUpCodeID = lks.MeasureID
				INNER JOIN NPOLkupType lkt
					ON lkt.NPOLkUpTypeID = Measure.NPOLkUpTypeID
				WHERE lks.CodeTypeID = @i_CodeTypeID
					AND lkt.LkUpTypeName = 'Measure'
					AND lks.MeasureID = @i_MeasureID
			END
			ELSE
				IF @i_CodeTypeID IS NOT NULL
					AND @i_MeasureID IS NOT NULL
					AND @b_ServiceType = 1
				BEGIN
					SELECT DISTINCT lks.ServiceCode
					FROM NPOLkupSupplemental lks
					INNER JOIN NPOLkup Measure
						ON Measure.LkUpCodeID = lks.MeasureID
					INNER JOIN NPOLkupType lkt
						ON lkt.NPOLkUpTypeID = Measure.NPOLkUpTypeID
					WHERE lks.CodeTypeID = @i_CodeTypeID
						AND lkt.LkUpTypeName = 'Measure'
						AND lks.MeasureID = @i_MeasureID
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
    ON OBJECT::[dbo].[usp_NPOLkupCodeSupplemental_DD] TO [FE_rohit.r-ext]
    AS [dbo];

