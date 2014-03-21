
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [usp_CommunicationTemplate_CommunicationType_Select_DD]  
Description   : This procedure is used to get the list of values for the communication template
				with only notification specific data
Created By    : NagaBabu
Created Date  : 13-July-2011 
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CommunicationTemplate_CommunicationType_Select_DD] (
	@i_AppUserId INT
	,@b_IsNotificationTemplate BIT = 0
	,@i_CommunicationTypeId KEYID
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

	-------------------------------------------------------- 
	SELECT CommunicationTemplateId
		,TemplateName
	FROM CommunicationTemplate cte WITH (NOLOCK)
	INNER JOIN CommunicationType ct WITH (NOLOCK) ON cte.CommunicationTypeId = ct.CommunicationTypeId
	WHERE ct.CommunicationTypeId = @i_CommunicationTypeId
		AND cte.StatusCode = 'A'
		AND (
			(
				@b_IsNotificationTemplate = 1
				AND TemplateName LIKE 'Notify:%'
				)
			OR @b_IsNotificationTemplate = 0
			)
	ORDER BY TemplateName
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
    ON OBJECT::[dbo].[usp_CommunicationTemplate_CommunicationType_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

