
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_Standards_Select]
Description   : This Procedure is used to get Standards table details 
Created By    : P.V.P.Mohan
Created Date  : 6-nov-2012
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Standards_Select] (@i_AppUserId KeyID)
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

	SELECT st.StandardId StandardsId
		,st.NAME StandardsName
		,so.StandardOrganizationId
		,So.NAME StandardOrganizationName
		,CASE st.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			END AS StatusCode
		,dbo.ufn_GetUserNameByID(st.CreatedByUserId) AS CreatedBy
		,CONVERT(VARCHAR, st.CreatedDate, 101) AS CreatedDate
	FROM Standard st WITH (NOLOCK)
	LEFT JOIN StandardOrganization so WITH (NOLOCK) ON st.StandardOrganizationId = so.StandardOrganizationId
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
    ON OBJECT::[dbo].[usp_Standards_Select] TO [FE_rohit.r-ext]
    AS [dbo];

