
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_Clinic_DD]  
Description   : This procedure is used to get the list of all Clinics from Provider table
Created By    : Rathanm
Created Date  : 24-Apr-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Clinic_DD] (@i_AppUserId INT,

@v_ClinicName varchar(100) = null
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

	SELECT DISTINCT p.ProviderID
		,OrganizationName
	FROM provider p
	INNER JOIN CodeSetProviderType ty
		ON p.ProviderTypeID = ty.ProviderTypeCodeID
	INNER JOIN ProviderHierarchyDetail phd
		ON phd.ParentProviderID = p.ProviderID
	INNER JOIN PatientPCP ps
		ON ps.ProviderID = phd.ChildProviderID
	WHERE p.AccountStatusCode = 'A'
		AND ty.Description = 'Clinic'
		AND PS.IslatestPCP = 1
		AND (p.OrganizationName like '%' + @v_ClinicName + '%' or @v_ClinicName is null)
	ORDER BY OrganizationName 
		
END TRY

----------------------------------------------------------   
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Clinic_DD] TO [FE_rohit.r-ext]
    AS [dbo];

