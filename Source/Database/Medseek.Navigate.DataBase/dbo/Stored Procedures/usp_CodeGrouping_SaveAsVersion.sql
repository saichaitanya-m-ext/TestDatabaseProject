
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_CodeGrouping_SaveAsVersion]
Description   : This proc is used to store the history information of a CodeGrouping
Created By    : Rathnam
Created Date  : 30-May-2013
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
--------------------------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CodeGrouping_SaveAsVersion] (
	@i_AppUserId KEYID
	,@i_CodeGroupingID KEYID
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

	DECLARE @v_Version VARCHAR(5)

	SELECT @v_Version = DefinitionVersion
	FROM CodeGrouping
	WHERE CodeGroupingID = @i_CodeGroupingID

	INSERT INTO CodeGroupingHistory (
		CodeGroupingID
		,DefinitionVersion
		,CodeGroupingName
		,ECTHedisTableID
		,ECTTableDescription
		,CodeGroupingDescription
		,CodeGroupingTypeID
		,CodeGroupingSynonym
		,CodeGroupingSource
		,NonModifiable
		,IsPrimary
		,ProductionStatus
		,DisplayStatus
		,StatusCode
		,CreatedByUserId
		,CreatedDate
		)
	SELECT cg.CodeGroupingID
		,cg.DefinitionVersion
		,cg.CodeGroupingName
		,cget.ECTHedisTableID
		,cget.ECTTableDescription
		,cg.CodeGroupingDescription
		,CTG.CodeGroupingTypeID
		,syn.CodeGroupingSynonym
		,CTG.CodeTypeGroupersName
		,cg.NonModifiable
		,cg.IsPrimary
		,cg.ProductionStatus
		,cg.DisplayStatus
		,cg.StatusCode
		,@i_AppUserId
		,GETDATE()
	FROM CodeGrouping cg
	LEFT OUTER JOIN CodeGroupingECTTable cget ON cg.CodeGroupingId = cget.CodeGroupingId
	LEFT OUTER JOIN CodeGroupingSynonyms syn ON syn.CodeGroupingID = cg.CodeGroupingID
	INNER JOIN CodeTypeGroupers CTG ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
	WHERE cg.CodeGroupingID = @i_CodeGroupingID

	INSERT INTO CodeGroupingDetailInternalHistory (
		CodeGroupingDetailInternalID
		,CodeGroupingID
		,CodeGroupingCodeTypeID
		,CodeGroupingCodeID
		,StatusCode
		,CreatedByUserId
		,CreatedDate
		)
	SELECT CodeGroupingDetailInternalID
		,CodeGroupingID
		,CodeGroupingCodeTypeID
		,CodeGroupingCodeID
		,StatusCode
		,@i_AppUserId
		,GETDATE()
	FROM CodeGroupingDetailInternal clc
	WHERE clC.CodeGroupingID = @i_CodeGroupingID

	UPDATE CodeGrouping
	SET DefinitionVersion = DBO.ufn_GetVersionNumber(@v_Version)
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
	WHERE CodeGroupingID = @i_CodeGroupingID
END TRY

-----------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CodeGrouping_SaveAsVersion] TO [FE_rohit.r-ext]
    AS [dbo];

