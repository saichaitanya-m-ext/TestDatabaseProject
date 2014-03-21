
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_CodeGrouping_Search @i_AppUserId = 2,@i_CodeGroupingID = 70 
Description   : This procedure is used to get the details from CodeGroupingName table      
    or a complete list of all the CodeGroupingName      
Created By    : P.V.P.Mohan    
Created Date  : 22-May-2013
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
06-07-2013 Modified By prathyusha. Added New parameter ECTTableColumn    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CodeGrouping_Search] --2,1  
	(
	@i_AppUserId KEYID
	,@i_CodeGroupingID INT = NULL
	,@i_CodeGroupTypeID INT = NULL
	,@vc_CodeGroupingName VARCHAR(10) = NULL
	,@vc_CodeGroupingDescription VARCHAR(500) = NULL
	,@i_CodeTypeGroupersID VARCHAR(20) = NULL
	,@b_IsPrimary BIT = NULL
	,@b_ProductionStatus StatusCode = NULL
	,@b_DisplayStatus BIT = NULL
	,@b_StatusCode StatusCode = NULL
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

	SELECT CodeGrouping.CodeGroupingID
		,CASE 
			WHEN LEN(CodeGrouping.CodeGroupingName) > 20
				THEN SUBSTRING(CodeGrouping.CodeGroupingName, 0, 20) + '...'
			ELSE CodeGrouping.CodeGroupingName
			END AS ShortCodeGroupingName
		,CASE 
			WHEN CTG.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group'
				THEN CodeGrouping.CodeGroupingName + ' - Chronic'
			ELSE CodeGrouping.CodeGroupingName
			END AS CodeGroupingName
		,CASE 
			WHEN LEN(CodeGrouping.CodeGroupingCode) > 0
				THEN CodeGrouping.CodeGroupingDescription + ' - ' + LTRIM(RTRIM(ISNULL(CTG.CodeTypeShortDescription, ''))) + ' ' + ISNULL(CodeGrouping.CodeGroupingCode, '') + ''
			ELSE CodeGrouping.CodeGroupingDescription
			END AS CodeGroupingDescription
		,CodeGrouping.CodeTypeGroupersID
		,CGT.CodeGroupType
		,CGT.CodeGroupingTypeID
		,CTG.CodeTypeGroupersName AS CodeGroupingSource
		,CGS.CodeGroupingSynonym
		,CGET.ECThedisTableID
		,CGET.ECTTableDescription
		,csehct.ECTHedisCodeTypeCode ECTTableColumn
		,CASE CodeGrouping.IsPrimary
			WHEN 1
				THEN 'Yes'
			WHEN 0
				THEN 'No'
			END AS IsPrimary
		,CASE CodeGrouping.ProductionStatus
			WHEN 'D'
				THEN 'Draft'
			WHEN 'F'
				THEN 'Final'
			END AS ProductionStatus
		,CodeGrouping.DefinitionVersion
		,CASE CodeGrouping.NonModifiable
			WHEN 1
				THEN 'Yes'
			WHEN 0
				THEN 'No'
			END AS NonModifiable
		,CASE CodeGrouping.DisplayStatus
			WHEN 1
				THEN 'Public'
			WHEN 0
				THEN 'Private'
			END AS DisplayStatus
		,CONVERT(VARCHAR(10), CodeGrouping.CreatedDate, 101) CreatedDate
		,dbo.ufn_GetUserNameByID(CodeGrouping.CreatedByUserId) AS CreatedBy
		,CONVERT(VARCHAR(10), CodeGrouping.LastModifiedDate, 101) UpdateDate
		,dbo.ufn_GetUserNameByID(CodeGrouping.LastModifiedByUserId) AS UpdateBy
		,CASE CodeGrouping.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS STATUS
	FROM CodeGrouping
	LEFT JOIN CodeGroupingECTTable CGET ON CodeGrouping.CodeGroupingID = CGET.CodeGroupingID
	LEFT JOIN CodeTypeGroupers CTG ON CTG.CodeTypeGroupersID = CodeGrouping.CodeTypeGroupersID
	INNER JOIN CodeGroupingType CGT ON CTG.CodeGroupingTypeID = CGT.CodeGroupingTypeID
	LEFT JOIN CodeGroupingSynonyms CGS ON CodeGrouping.CodeGroupingID = CGS.CodeGroupingID
	LEFT JOIN CodeSetECTHedisCodeType csehct ON csehct.ECTHedisCodeTypeID = CGET.ECTHedisCodeTypeID
	WHERE CodeGrouping.DisplayStatus = 1
		AND (
			CodeGrouping.CodeGroupingName LIKE '%' + @vc_CodeGroupingName + '%'
			OR CodeGroupingSynonym LIKE '%' + @vc_CodeGroupingName + '%'
			OR @vc_CodeGroupingName IS NULL
			)
		AND (
			CodeGrouping.CodeGroupingDescription LIKE '%' + @vc_CodeGroupingDescription + '%'
			OR @vc_CodeGroupingDescription IS NULL
			)
		AND (
			CodeGrouping.StatusCode = @b_StatusCode
			OR @b_StatusCode IS NULL
			)
		AND (
			CodeGrouping.CodeTypeGroupersID = @i_CodeTypeGroupersID
			OR @i_CodeTypeGroupersID IS NULL
			)
		AND (
			CodeGrouping.ProductionStatus = @b_ProductionStatus
			OR @b_ProductionStatus IS NULL
			)
		AND (
			CodeGrouping.DisplayStatus = @b_DisplayStatus
			OR @b_DisplayStatus IS NULL
			)
		AND (
			CodeGrouping.IsPrimary = @b_IsPrimary
			OR @b_IsPrimary IS NULL
			)
		AND (
			CodeGrouping.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)
		AND (
			CTG.CodeGroupingTypeID = @i_CodeGroupTypeID
			OR @i_CodeGroupTypeID IS NULL
			)
	
	UNION ALL
	
	SELECT CodeGrouping.CodeGroupingID
		,CASE 
			WHEN LEN(CodeGrouping.CodeGroupingName) > 20
				THEN SUBSTRING(CodeGrouping.CodeGroupingName, 0, 20) + '...'
			ELSE CodeGrouping.CodeGroupingName
			END AS ShortCodeGroupingName
		,CASE 
			WHEN CTG.CodeTypeGroupersName = 'CCS Chronic Diagnosis Group'
				THEN CodeGrouping.CodeGroupingName + ' - Chronic'
			ELSE CodeGrouping.CodeGroupingName
			END AS CodeGroupingName
		,CASE 
			WHEN LEN(CodeGrouping.CodeGroupingCode) > 0
				THEN CodeGrouping.CodeGroupingDescription + ' - ' + LTRIM(RTRIM(CTG.CodeTypeShortDescription)) + ' ' + ISNULL(CodeGrouping.CodeGroupingCode, '') + ''
			ELSE CodeGrouping.CodeGroupingDescription
			END AS CodeGroupingDescription
		,CodeGrouping.CodeTypeGroupersID
		,CGT.CodeGroupType
		,CGT.CodeGroupingTypeID
		,CTG.CodeTypeGroupersName AS CodeGroupingSource
		,CGS.CodeGroupingSynonym
		,CGET.ECThedisTableID
		,CGET.ECTTableDescription
		,CGET.ECTTableColumn
		,CASE CodeGrouping.IsPrimary
			WHEN 1
				THEN 'Yes'
			WHEN 0
				THEN 'No'
			END AS IsPrimary
		,CASE CodeGrouping.ProductionStatus
			WHEN 'D'
				THEN 'Draft'
			WHEN 'F'
				THEN 'Final'
			END AS ProductionStatus
		,CodeGrouping.DefinitionVersion
		,CASE CodeGrouping.NonModifiable
			WHEN 1
				THEN 'Yes'
			WHEN 0
				THEN 'No'
			END AS NonModifiable
		,CASE CodeGrouping.DisplayStatus
			WHEN 1
				THEN 'Public'
			WHEN 0
				THEN 'Private'
			END AS DisplayStatus
		,CONVERT(VARCHAR(10), CodeGrouping.CreatedDate, 101) CreatedDate
		,dbo.ufn_GetUserNameByID(CodeGrouping.CreatedByUserId) AS CreatedBy
		,CONVERT(VARCHAR(10), CodeGrouping.LastModifiedDate, 101) UpdateDate
		,dbo.ufn_GetUserNameByID(CodeGrouping.LastModifiedByUserId) AS UpdateBy
		,CASE CodeGrouping.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS STATUS
	FROM CodeGrouping
	LEFT JOIN CodeGroupingECTTable CGET ON CodeGrouping.CodeGroupingID = CGET.CodeGroupingID
	LEFT JOIN CodeTypeGroupers CTG ON CTG.CodeTypeGroupersID = CodeGrouping.CodeTypeGroupersID
	INNER JOIN CodeGroupingType CGT ON CTG.CodeGroupingTypeID = CGT.CodeGroupingTypeID
	LEFT JOIN CodeGroupingSynonyms CGS ON CodeGrouping.CodeGroupingID = CGS.CodeGroupingID
	WHERE CodeGrouping.CreatedByUserId = @i_AppUserId
		AND CodeGrouping.DisplayStatus = 0
		AND (
			CodeGrouping.CodeGroupingName LIKE '%' + @vc_CodeGroupingName + '%'
			OR CodeGroupingSynonym LIKE '%' + @vc_CodeGroupingName + '%'
			OR @vc_CodeGroupingName IS NULL
			)
		AND (
			CodeGrouping.CodeGroupingDescription LIKE '%' + @vc_CodeGroupingDescription + '%'
			OR @vc_CodeGroupingDescription IS NULL
			)
		AND (
			CodeGrouping.StatusCode = @b_StatusCode
			OR @b_StatusCode IS NULL
			)
		AND (
			CodeGrouping.CodeTypeGroupersID = @i_CodeTypeGroupersID
			OR @i_CodeTypeGroupersID IS NULL
			)
		AND (
			CodeGrouping.ProductionStatus = @b_ProductionStatus
			OR @b_ProductionStatus IS NULL
			)
		AND (
			CodeGrouping.DisplayStatus = @b_DisplayStatus
			OR @b_DisplayStatus IS NULL
			)
		AND (
			CodeGrouping.IsPrimary = @b_IsPrimary
			OR @b_IsPrimary IS NULL
			)
		AND (
			CodeGrouping.CodeGroupingID = @i_CodeGroupingID
			OR @i_CodeGroupingID IS NULL
			)
		AND (
			CTG.CodeGroupingTypeID = @i_CodeGroupTypeID
			OR @i_CodeGroupTypeID IS NULL
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
    ON OBJECT::[dbo].[usp_CodeGrouping_Search] TO [FE_rohit.r-ext]
    AS [dbo];

