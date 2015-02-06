
/*    
------------------------------------------------------------------------------    
Procedure Name: [USP_PDCodeGroups_Search] @i_AppUserId=1 ,@i_CodeTypeGroupersID=5
Description   : Procedure to search code groups based on provided search criteria
Created By    : Praveen Takasi
Created Date  : 05-July-2013
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_PDCodeGroups_Search] (
	@i_AppUserId KEYID
	,@i_IsPrimary KEYID = NULL
	,@i_CodeTypeGroupersID KEYID = NULL
	,@vc_CodeGroupingName VARCHAR(100) = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

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

	DECLARE @V_SourceName VARCHAR(20)

	SET @V_SourceName = (
			SELECT DISTINCT CodeTypeGroupersName
			FROM CodeTypeGroupers
			WHERE CodeTypeGroupersID = @i_CodeTypeGroupersID
			)

	IF @V_SourceName <> 'HEDIS-ECT'
	BEGIN
		SELECT CodeGroupingID
			,CodeGroupingName + ' (Source: ' + CTG.CodeTypeGroupersName + ')' AS CodeGroupingName
			,ISNULL((
					SELECT STUFF((
								SELECT DISTINCT ', ' + cgct.CodeTypeCode
								FROM CodeGroupingDetailInternal cgdi
								INNER JOIN LkUpCodeType cgct ON cgct.CodeTypeID = cgdi.CodeGroupingCodeTypeID
								WHERE CodeGroupingID = CodeGrouping.CodeGroupingID
								FOR XML PATH('')
								), 1, 2, '')
					), '') AS CodeTypes
		FROM CodeGrouping
		INNER JOIN CodeTypeGroupers CTG ON CodeGrouping.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		WHERE (
				IsPrimary = @i_IsPrimary
				OR @i_IsPrimary IS NULL
				)
			AND (
				CodeGrouping.CodeTypeGroupersID = @i_CodeTypeGroupersID
				OR @i_CodeTypeGroupersID IS NULL
				)
			AND (
				CodeGroupingName LIKE '%' + @vc_CodeGroupingName + '%'
				OR @vc_CodeGroupingName IS NULL
				)
			AND ProductionStatus = 'F'
			AND CodeGrouping.StatusCode = 'A'
	END
	ELSE
	BEGIN
		SELECT CodeGroupingID
			,CodeGroupingName + ' (Source: ' + CTG.CodeTypeGroupersName + ')' AS CodeGroupingName
			,ISNULL((
					SELECT STUFF((
								SELECT DISTINCT ', ' + cgct.ECTHedisCodeTypeCode
								FROM CodeGroupingECTTable CET
								INNER JOIN CodeSetHEDIS_ECTCode cgdi ON CET.ECThedisTableID = cgdi.ECTHedisTableID
								INNER JOIN CodeSetECTHedisCodeType cgct ON cgct.ECTHedisCodeTypeID = cgdi.ECTHedisCodeTypeID
								WHERE CET.CodeGroupingID = CodeGrouping.CodeGroupingID
								FOR XML PATH('')
								), 1, 2, '')
					), '') AS CodeTypes
		FROM CodeGrouping
		INNER JOIN CodeTypeGroupers CTG ON CodeGrouping.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		WHERE (
				IsPrimary = @i_IsPrimary
				OR @i_IsPrimary IS NULL
				)
			AND (
				CodeGrouping.CodeTypeGroupersID = @i_CodeTypeGroupersID
				OR @i_CodeTypeGroupersID IS NULL
				)
			AND (
				CodeGroupingName LIKE '%' + @vc_CodeGroupingName + '%'
				OR @vc_CodeGroupingName IS NULL
				)
			AND ProductionStatus = 'F'
			AND CodeGrouping.StatusCode = 'A'
	END
END TRY

---------------------------------------------------------------------------------------------------------------------     
BEGIN CATCH
	-- Handle exception    
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PDCodeGroups_Search] TO [FE_rohit.r-ext]
    AS [dbo];

