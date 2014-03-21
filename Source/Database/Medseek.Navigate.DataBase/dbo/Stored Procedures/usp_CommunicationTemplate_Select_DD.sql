
/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_CommunicationTemplate_Select_DD  
Description   : This procedure is used to get the list of values for the communication template
				with only notification specific data
Created By    : Aditya
Created Date  : 06-May-2010  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
13-May-10 Pramod Included the following in where claure : TemplateName Like 'Notify:%'
19-Aug-2010 NagaBabu Added ORDER BY clause to the select statement
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_CommunicationTemplate_Select_DD] (
	@i_AppUserId INT
	,@b_IsNotificationTemplate BIT = 0
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
	FROM CommunicationTemplate
	WHERE StatusCode = 'A'
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
    ON OBJECT::[dbo].[usp_CommunicationTemplate_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

