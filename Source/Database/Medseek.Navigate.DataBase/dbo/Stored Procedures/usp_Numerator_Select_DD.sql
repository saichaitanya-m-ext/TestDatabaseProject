
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_MetricGoals_Select_DD]
Description   : This Procedure used to provide CareTeamName,UserLoginName for dropdown
Created By    : P.V.P.Mohan
Created Date  : 23-Nov-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Numerator_Select_DD] (
	@i_AppUserId KEYID
	,@i_NumeratorID INT = NULL
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
	IF (@i_NumeratorID IS NULL)
	BEGIN
		SELECT PopulationDefinitionID AS NumeratorId
			,PopulationDefinitionName AS NumeratorName
		FROM PopulationDefinition WITH (NOLOCK)
		WHERE DefinitionType = 'N'
			AND StatusCode = 'A'
			AND ProductionStatus = 'F'
	END
	ELSE
	BEGIN
		IF @i_NumeratorID IS NOT NULL
		BEGIN
			SELECT CASE 
					WHEN NumeratorType = 'C'
						THEN 'Process Metric'
					WHEN NumeratorType = 'V'
						THEN 'Outcome Metric'
					END MetricType
			FROM PopulationDefinition WITH (NOLOCK)
			WHERE PopulationDefinitionID = @i_NumeratorID
				AND DefinitionType = 'N'

			SELECT LookupValueID
				,Value
			FROM LOOKUPValue WITH (NOLOCK)
			INNER JOIN LookupType WITH (NOLOCK) ON LookupType.LookupCode = LookupValue.LookupCode
			WHERE LookupType.LookupCode = 'VD'
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
    ON OBJECT::[dbo].[usp_Numerator_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

