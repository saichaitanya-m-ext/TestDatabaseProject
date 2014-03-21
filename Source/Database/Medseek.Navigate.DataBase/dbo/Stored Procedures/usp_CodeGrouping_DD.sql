
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_CodeGrouping_DD
Description   : This procedure is used to get the details from CodeGroupingNames
Created By    : RATHNAM      
Created Date  : 30-May-2013
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION   
25-07-13 Rathnam added condition cgt.CodeGroupType <> 'Diagnosis Groupers'	
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_CodeGrouping_DD] (
	@i_AppUserId KEYID
	,@vc_CodeGroupingName VARCHAR(100)
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

	SELECT CodeGroupingID
		,CodeGroupingName + ' - ' + CTG.CodeTypeGroupersName AS CodeGroupingName
	FROM CodeGrouping cg
	INNER JOIN CodeTypeGroupers CTG ON CTG.CodeTypeGroupersID = cg.CodeTypeGroupersID
	INNER JOIN CodeGroupingType cgt ON CTG.CodeGroupingTypeID = cgt.CodeGroupingTypeID
	WHERE cg.IsPrimary = 1
		AND cg.ProductionStatus = 'F'
		AND cg.StatusCode = 'A'
		AND DisplayStatus = 1
		AND (
			CodeGroupingName LIKE '%' + @vc_CodeGroupingName + '%'
			OR @vc_CodeGroupingName IS NULL
			)
		AND cgt.CodeGroupType <> 'Diagnosis Groupers'	

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
    ON OBJECT::[dbo].[usp_CodeGrouping_DD] TO [FE_rohit.r-ext]
    AS [dbo];

