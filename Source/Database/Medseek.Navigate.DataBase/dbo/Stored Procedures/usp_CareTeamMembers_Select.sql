
/*              
------------------------------------------------------------------------------              
Procedure Name: usp_CareTeamMembers_Select              
Description   : This procedure is used to get the CareTeamMembers Details based on the           
    CareTeamID or get all the CareTeamMembers when passed NULL            
Created By    : Aditya              
Created Date  : 15-Mar-2010              
------------------------------------------------------------------------------              
Log History   :               
DD-MM-YYYY  BY   DESCRIPTION              
22-Jun-10 Pramod Replaced the inner join with ProfessionalType with outer join    
27-Sep-2010 NagaBabu Added CreatedDate,LastModifiedByUserId,LastModifiedDate Fields    
25-Nov-2011 NagaBabu Changed LastName field by Taking fullname script    
------------------------------------------------------------------------------              
*/
CREATE PROCEDURE [dbo].[usp_CareTeamMembers_Select] (
	@i_AppUserId KEYID
	,@i_CareTeamId KEYID = NULL
	,@v_StatusCode StatusCode = NULL
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

	----------- Select CareTeamMembers details -------------------        
	SELECT Provider.ProviderID AS UserID
		,CareTeamMembers.CareTeamId
		,CareTeamMembers.IsCareTeamManager
		,COALESCE(ISNULL(provider.LastName, '') + ', ' + ISNULL(provider.FirstName, '') + '. ' + ISNULL(provider.MiddleName, '') + ' ' + ISNULL(provider.NameSuffix, ''), '') AS LastName
		,provider.FirstName
		,provider.ProfessionalTypeID
		,CodeSetProfessionalType.ProfessionalType AS NAME
		,provider.PrimaryEmailAddress AS EmailIdPrimary
		,CareTeamMembers.CreatedByUserId
		,CASE CareTeamMembers.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			END AS STATUS
		,CareTeamMembers.CreatedDate
		,CareTeamMembers.LastModifiedByUserId
		,CareTeamMembers.LastModifiedDate
		,CASE CareTeamMembers.IsCareTeamManager
			WHEN '0'
				THEN 'No'
			WHEN '1'
				THEN 'Yes'
			END AS IsCareManager
	FROM CareTeamMembers WITH (NOLOCK)
	INNER JOIN provider WITH (NOLOCK) ON Provider.ProviderID = CareTeamMembers.ProviderID
	LEFT OUTER JOIN CodeSetProfessionalType WITH (NOLOCK) ON CodeSetProfessionalType.ProfessionalTypeID = Provider.ProfessionalTypeID
	WHERE (
			CareTeamMembers.CareTeamId = @i_CareTeamId
			OR @i_CareTeamId IS NULL
			)
		AND (
			@v_StatusCode IS NULL
			OR CareTeamMembers.StatusCode = @v_StatusCode
			)
	ORDER BY LastName
END TRY

BEGIN CATCH
	-- Handle exception              
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamMembers_Select] TO [FE_rohit.r-ext]
    AS [dbo];

