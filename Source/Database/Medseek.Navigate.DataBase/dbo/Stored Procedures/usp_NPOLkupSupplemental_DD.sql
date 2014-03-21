
/*  
------------------------------------------------------------------------------  
Procedure Name: usp_NPOLkupSupplemental_DD 1,'S'
Description   : This procedure is used to getting the drop down values for NPOLkupSupplemental
Created By    : Rathnam
Created Date  : 10-June-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_NPOLkupSupplemental_DD] --1,'S'
	(
	 @i_AppUserId KeyID
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

	SELECT LkUpCodeID EthnicityID
		,DESCRIPTION EthnicityName
	FROM NPOLkup lm
	INNER JOIN NpoLkupType lt
		ON lm.NPOLkUpTypeID = lt.NPOLkUpTypeID
	WHERE LkUpTypeName = 'Ethnicity'

	SELECT LkUpCodeID RaceID
		,DESCRIPTION RaceName
	FROM NPOLkup lm
	INNER JOIN NpoLkupType lt
		ON lm.NPOLkUpTypeID = lt.NPOLkUpTypeID
	WHERE LkUpTypeName = 'Race'

	SELECT LkUpCodeID LanguageID
		,DESCRIPTION LanguageName
	FROM NPOLkup lm
	INNER JOIN NpoLkupType lt
		ON lm.NPOLkUpTypeID = lt.NPOLkUpTypeID
	WHERE LkUpTypeName = 'Language'

	SELECT LkUpCode LabResultTextID
		,DESCRIPTION LabResultTextName
	FROM NPOLkup lm
	INNER JOIN NpoLkupType lt
		ON lm.NPOLkUpTypeID = lt.NPOLkUpTypeID
	WHERE LkUpTypeName = 'LabResultText'
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
    ON OBJECT::[dbo].[usp_NPOLkupSupplemental_DD] TO [FE_rohit.r-ext]
    AS [dbo];

