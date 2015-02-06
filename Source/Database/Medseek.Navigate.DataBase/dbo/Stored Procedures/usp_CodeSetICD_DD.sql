
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CodeSetICD_DD]        
Description   : This procedure is used for drop down from CodeSetICD table      
       
Created By    : Rathnam       
Created Date  : 15-Dec-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
10-May-2011 Rathnam added left join with CodeSetICDGroups.  
2-Jun-2011 Pramod Included the condition "OR @vc_ICDCodeType = '' " in where clause  
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CodeSetICD_DD] (
	@i_AppUserId KEYID
	,@vc_ICDCodeType STYPE = NULL
	,@vc_ICDCoderORDescription SHORTDESCRIPTION = NULL
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

	SELECT DiagnosisCodeID
		,DiagnosisCode
		,DiagnosisShortDescription AS DiagnosisDescription
		,ICDGroupName
	FROM CodeSetICDDiagnosis
	LEFT OUTER JOIN CodeSetICDGroups ON CodeSetICDDiagnosis.ICDGroupID = CodeSetICDGroups.ICDCodeGroupId
	WHERE (
			CodeTypeID = @vc_ICDCodeType
			OR @vc_ICDCodeType = ''
			OR @vc_ICDCodeType IS NULL
			)
		AND (
			DiagnosisCode + ' - ' + DiagnosisShortDescription LIKE '%' + @vc_ICDCoderORDescription + '%'
			OR @vc_ICDCoderORDescription IS NULL
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
    ON OBJECT::[dbo].[usp_CodeSetICD_DD] TO [FE_rohit.r-ext]
    AS [dbo];

