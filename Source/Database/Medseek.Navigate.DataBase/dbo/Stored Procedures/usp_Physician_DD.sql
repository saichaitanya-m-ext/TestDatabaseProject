
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_Physician_DD]1 ,42  
Description   : This procedure is used to get the list of all Physician from Provider table  
Created By    : Rathanm  
Created Date  : 24-Apr-2013  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_Physician_DD] 
	(
	@i_AppUserId INT
	,@i_ClinicId INT = NULL
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

	IF @i_ClinicId IS NULL
	BEGIN
		SELECT DISTINCT p.ProviderID
			,COALESCE(ISNULL(p.LastName, '') + ' ' + ISNULL(p.FirstName, '') + ' ' + ISNULL(p.MiddleName, ''), '') OrganizationName
		FROM provider p
		INNER JOIN CodeSetProviderType ty
			ON p.ProviderTypeID = ty.ProviderTypeCodeID
		INNER JOIN ProviderHierarchyDetail phd
		    ON phd.ChildProviderID = p.ProviderID
		INNER JOIN PatientPCP pp 
		    ON pp.ProviderID = p.ProviderID    	
		WHERE p.AccountStatusCode = 'A'
			AND ty.Description = 'Physician'
	END
	ELSE
	BEGIN
		SELECT DISTINCT p.ProviderID
			,COALESCE(ISNULL(p.LastName, '') + ' ' + ISNULL(p.FirstName, '') + ' ' + ISNULL(p.MiddleName, ''), '') OrganizationName
		FROM ProviderHierarchyDetail d
		INNER JOIN Provider p
			ON p.ProviderID = d.ChildProviderID
		INNER JOIN PatientPCP ps
		    ON ps.ProviderID = d.ChildProviderID	
		WHERE 
			d.ParentProviderID = @i_ClinicId
	END
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
    ON OBJECT::[dbo].[usp_Physician_DD] TO [FE_rohit.r-ext]
    AS [dbo];

