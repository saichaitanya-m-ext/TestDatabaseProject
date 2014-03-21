

/*          
------------------------------------------------------------------------------------------          
Procedure Name: [usp_CodegroupSummary_Select_DD] 23 
Description   : This procedure is Drop Downs for reportname and reporttype,Metric,Denominator,Numerator,CodegroupersName,CodegroupingName
Created By    : Santosh          
Created Date  : 12-August-2013
------------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION

-------------------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_CodegroupSummary_Select_DD]
	(
	@i_AppUserId KEYID
	--@i_CodeGroupingTypeID KEYID = NULL
 --  ,@i_CodegroupersID KEYID = NULL
 --  ,@vc_CodegroupingName VARCHAR(20) = NULL
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

---------- Code Type Groupers---------------
				
			SELECT 
				CodeGroupingTypeID,
				CodeGroupType 
			FROM CodeGroupingType 
			WHERE StatusCode = 'A'
			ORDER BY CodeGroupType

----------Code Type Source Details----------------

			SELECT DISTINCT 
				CodeTypeGroupersID
				, CGT.CodeGroupType  + ' - '  + REPLACE(CodeTypeGroupersName,'HEDIS-ECT','HEDIS') AS CodeTypeGroupersName
			FROM CodeTypeGroupers CTG
				INNER JOIN CodeGroupingType CGT
					ON CTG.CodeGroupingTypeID = CGT.CodeGroupingTypeID
			WHERE CTG.StatusCode = 'A'
				AND CGT.StatusCode = 'A'
			ORDER BY CodeTypeGroupersName
			

----------- Code Grouping Name ------------
			SELECT DISTINCT TOP 500
				CodeGroupingID,
				CodeGroupingName 
			FROM CodeGrouping
			WHERE StatusCode = 'A'
			ORDER BY CodeGroupingName

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
    ON OBJECT::[dbo].[usp_CodegroupSummary_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

