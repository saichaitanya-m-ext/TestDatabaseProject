
/*   
  
------------------------------------------------------------------------------------------          
Procedure Name: [usp_CodeTypeGrouperSummary_SELECT]  1 ,2 
Description   : This procedure is used to select all the codegroupers and 
Created By    : Santosh          
Created Date  : 27-August-2013
------------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION      
-------------------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_CodeTypeGrouperSummary_SELECT] (
	@i_AppUserId KEYID
	,@i_CodeGroupingTypeID KEYID = NULL
	,@i_CodeTypeGroupersID KEYID = NULL
	,@i_CodeGroupingID KEYID = NULL
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
	END;

	WITH cteCodeGroup
	AS (
		SELECT DISTINCT '1' As ord,
			 CTG.CodeTypeGroupersID
			,CGT.CodeGroupType CodeGroupType
			,REPLACE(CTG.CodeTypeGroupersName, 'HEDIS-ECT', 'HEDIS') AS CodeTypeGroupersName
			,CTG.CodeTypeShortDescription
			,(COUNT(CodeGroupingID)) AS CodeGroupingCount
		FROM CodeGrouping CG
		LEFT OUTER JOIN CodeTypeGroupers CTG
			ON CG.CodeTypeGroupersID = CTG.CodeTypeGroupersID
		LEFT OUTER JOIN CodeGroupingType CGT
			ON CTG.CodeGroupingTypeID = CGT.CodeGroupingTypeID
		WHERE CGT.StatusCode = 'A'
			AND CTG.StatusCode = 'A'
			AND CG.StatusCode = 'A'
			AND (
				CG.CodeTypeGroupersID IN (
					SELECT CodeTypeGroupersID
					FROM CodeTypeGroupers CTG
					INNER JOIN CodeGroupingType CGT
						ON CTG.CodeGroupingTypeID = CGT.CodeGroupingTypeID
					WHERE CTG.StatusCode = 'A'
						AND CGT.CodeGroupingTypeID = @i_CodeGroupingTypeID
					)
				OR @i_CodeGroupingTypeID IS NULL
				)
			AND (
				CG.CodeTypeGroupersID = @i_CodeTypeGroupersID
				OR @i_CodeTypeGroupersID IS NULL
				)
		GROUP BY CGT.CodeGroupType
			,CTG.CodeTypeGroupersID
			,CTG.CodeTypeGroupersName
			,CTG.CodeTypeShortDescription
		)
		,cteCodeGroup_Result as 
		(
	SELECT *
	FROM cteCodeGroup
	
	UNION ALL
	
	SELECT NULL
	    ,NULL
		,NULL
		,NULL
		,'Total number of Code Groups'
		, SUM(CodeGroupingCount) 
	FROM cteCodeGroup 
	)
	select  ord,CodeTypeGroupersID,CodeGroupType,CodeTypeGroupersName,CodeTypeShortDescription,CodeGroupingCount 
	from cteCodeGroup_Result
	--order by Ord asc,CodeGroupingCount desc
	order by 1 DESC 
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
    ON OBJECT::[dbo].[usp_CodeTypeGrouperSummary_SELECT] TO [FE_rohit.r-ext]
    AS [dbo];

