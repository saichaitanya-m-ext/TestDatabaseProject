
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CodeSetProcedure_DD]        
Description   : This procedure is used for drop down from CodeSetProcedure table      
       
Created By    : Rathnam       
Created Date  : 15-Dec-2010        
------------------------------------------------------------------------------        
Log History   :        
DD-MM-YYYY  BY   DESCRIPTION   
20-Dec-2010  Rama replaced ProcedureName by ProcedureDescription  
27-Apr-2011 NagaBabu Added LeadtimeDays field  
2-Jun-2011 Pramod Included the condition "OR @vc_ProcedureCodeType = '' " in where clause  
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CodeSetProcedure_DD] (
	@i_AppUserId KEYID
	,@vc_ProcedureCodeType STYPE = NULL
	,@vc_CPTCoderORDescription SHORTDESCRIPTION = NULL
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

	SELECT ProcedureCodeID AS ProcedureID
		,ProcedureCode
		,ProcedureName AS ProcedureDescription
		,LeadtimeDays
	FROM CodeSetProcedure
	WHERE CodeTypeID = 1
		AND (
			ProcedureCode = @vc_ProcedureCodeType
			OR @vc_ProcedureCodeType IS NULL
			OR @vc_ProcedureCodeType = ''
			)
		AND (
			ProcedureCode + ' - ' + ProcedureName LIKE '%' + @vc_CPTCoderORDescription + '%'
			OR @vc_CPTCoderORDescription IS NULL
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
    ON OBJECT::[dbo].[usp_CodeSetProcedure_DD] TO [FE_rohit.r-ext]
    AS [dbo];

