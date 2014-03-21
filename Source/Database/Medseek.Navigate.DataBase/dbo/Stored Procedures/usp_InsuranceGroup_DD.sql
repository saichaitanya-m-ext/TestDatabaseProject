
/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_InsuranceGroup_DD]  1
Description   : This procedure is used to get the list of all Clinics from Provider table
Created By    : Rathanm
Created Date  : 24-Apr-2013
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_InsuranceGroup_DD] (@i_AppUserId INT)
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

SELECT ProviderID InsuranceGroupID
		,ig.GroupName
	FROM provider p
	INNER JOIN CodeSetProviderType ty
		ON p.ProviderTypeID = ty.ProviderTypeCodeID
	left join InsuranceGroup ig 
		on p.InsuranceGroupID=ig.InsuranceGroupID
	WHERE p.AccountStatusCode = 'A'
		AND ty.Description = 'Insurance'
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
    ON OBJECT::[dbo].[usp_InsuranceGroup_DD] TO [FE_rohit.r-ext]
    AS [dbo];

