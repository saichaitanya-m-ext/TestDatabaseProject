
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_CodeSetLoincCode_DD]        
Description   : This procedure is used for drop down from CodeSetLoincCode table      
       
Created By    : Rathnam       
Created Date  : 04-Oct-2012  
------------------------------------------------------------------------------        
Log History   :        
DD-MM-YYYY  BY   DESCRIPTION   
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_CodeSetLoincCode_DD] (
	@i_AppUserId KEYID
	,@vc_LoincCodeORDescription SHORTDESCRIPTION = NULL
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

	SELECT LoincCodeID
		,LoincCode
		,ShortDescription AS LoincDescription
	FROM CodeSetLoinc
	WHERE (
			LoincCode + ' - ' + ShortDescription LIKE '%' + @vc_LoincCodeORDescription + '%'
			OR @vc_LoincCodeORDescription IS NULL
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
    ON OBJECT::[dbo].[usp_CodeSetLoincCode_DD] TO [FE_rohit.r-ext]
    AS [dbo];

