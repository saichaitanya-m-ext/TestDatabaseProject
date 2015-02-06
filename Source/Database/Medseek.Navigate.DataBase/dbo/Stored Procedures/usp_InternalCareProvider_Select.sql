
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_InternalCareProvider_Select      
Description   : This procedure is used to get the Internal provider info    
    ( Users whose IsProvider = 1 )    
Created By    : Pramod      
Created Date  : 08-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
16-May-2011 Rathnam added  @v_ProviderName name for searching based on Provider name       
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_InternalCareProvider_Select] (
	@i_AppUserId KEYID
	,@i_PatientUserId KEYID = NULL
	,@v_ProviderName VARCHAR(200) = NULL
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

	SELECT DISTINCT TOP 100 Provider.ProviderID UserId
		,ISNULL(Provider.FirstName, '') + ' ' + ISNULL(Provider.MiddleName, '') + ' ' + ISNULL(Provider.LastName, '') AS UserName
	FROM PatientProvider WITH (NOLOCK)
	INNER JOIN Provider WITH (NOLOCK) ON PatientProvider.ProviderID = Provider.ProviderID
	WHERE PatientProvider.PatientID = @i_PatientUserId
		AND @i_PatientUserId IS NOT NULL
		AND PatientProvider.StatusCode = 'A'
		AND (
			(ISNULL(Provider.FirstName, '') + ' ' + ISNULL(Provider.MiddleName, '') + ' ' + ISNULL(Provider.LastName, '')) LIKE '%' + @v_ProviderName + '%'
			OR @v_ProviderName IS NULL
			)
	
	UNION
	
	SELECT TOP 100 Provider.ProviderID UserId
		,ISNULL(Provider.FirstName, '') + ' ' + ISNULL(Provider.MiddleName, '') + ' ' + ISNULL(Provider.LastName, '') AS UserName
	FROM Provider WITH (NOLOCK)
	WHERE
		--ISNULL(Provider.IsExternalProvider , 0) = 1   
		--AND @i_PatientUserId IS NULL   
		Provider.AccountStatusCode = 'A'
		AND (
			(ISNULL(Provider.FirstName, '') + ' ' + ISNULL(Provider.MiddleName, '') + ' ' + ISNULL(Provider.LastName, '')) LIKE '%' + @v_ProviderName + '%'
			OR @v_ProviderName IS NULL
			)
		AND ISNULL(Provider.FirstName, '') + ' ' + ISNULL(Provider.MiddleName, '') + ' ' + ISNULL(Provider.LastName, '') <> ''
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
    ON OBJECT::[dbo].[usp_InternalCareProvider_Select] TO [FE_rohit.r-ext]
    AS [dbo];

