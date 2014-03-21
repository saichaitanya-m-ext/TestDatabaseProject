
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_Operator_Select      
Description   : This procedure is used to get the records from Operator table    
Created By    : Aditya      
Created Date  : 16-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_Operator_Select] (
	@i_AppUserId KeyID
	,@i_OperatorId KeyID = NULL
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

	SELECT OperatorId
		,OperatorValue
		,Description
		,SortOrder
		,CreatedByUserId
		,CreatedDate
		,LastModifiedByUserId
		,LastModifiedDate
		,StatusCode
	FROM Operator
	WHERE OperatorId = @i_OperatorId
		OR @i_OperatorId IS NULL
	ORDER BY SortOrder
		,OperatorValue
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
    ON OBJECT::[dbo].[usp_Operator_Select] TO [FE_rohit.r-ext]
    AS [dbo];

