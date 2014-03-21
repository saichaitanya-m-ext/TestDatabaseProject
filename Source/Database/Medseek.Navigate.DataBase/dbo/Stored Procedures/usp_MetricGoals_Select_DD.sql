
/*            
------------------------------------------------------------------------------            
Procedure Name: [usp_MetricGoals_Select_DD]  23,'PC'  
Description   : This Procedure used to provide CareTeamName,UserLoginName for dropdown    
Created By    : P.V.P.Mohan    
Created Date  : 23-Nov-2012    
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION     
------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_MetricGoals_Select_DD] -- 23    
	(
	@i_AppUserId KEYID
	,@v_Type VARCHAR(2) --> - Care Team (CT), - Physician (PC), - Managed Population(MP),- Employer Group(EG), - Insurance Group(IG),- Clinic(CC), - Organization(OG)     
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

	--------------------------------------------------------------------    
	IF @v_Type = 'CT'
	BEGIN
		SELECT CareTeamId AS ID
			,CareTeamName AS NAME
		FROM CareTeam
		WHERE CareTeam.StatusCode = 'A'
		ORDER BY CareTeamName
	END
	ELSE
	BEGIN
		IF @v_Type = 'PC'
		BEGIN
			SELECT TOP 500 ProviderID AS ID
				,dbo.ufn_GetUserNameByID(Provider.ProviderID) AS NAME
			FROM Provider
			WHERE dbo.ufn_GetUserNameByID(Provider.ProviderID) <> ''
			ORDER BY 2
		END
		ELSE
		BEGIN
			IF @v_Type = 'MP'
			BEGIN
				SELECT ProgramId ID
					,ProgramName NAME
				FROM Program
				WHERE StatusCode = 'A'
			END
			ELSE
			BEGIN
				IF @v_Type = 'EG'
				BEGIN
					SELECT TOP 500 EmployerGroupID ID
						,GroupName NAME
					FROM EmployerGroup
					WHERE StatusCode = 'A'
				END
				ELSE
				BEGIN
					IF @v_Type = 'IG'
					BEGIN
						SELECT InsuranceGroupID ID
							,GroupName NAME
						FROM InsuranceGroup
						WHERE StatusCode = 'A'
					END
				END
			END
		END
	END
END TRY

---------------------------------------------------------------------       
BEGIN CATCH
	-- Handle exception            
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MetricGoals_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

