
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_LoinAndCPT_ByNumeratorId  1,55        
Description   : This procedure is used to get the details from Measure table         
Created By    : Rathnam          
Created Date  : 30-Nov-2012  
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_LoinAndCPT_ByNumeratorId] (
	@i_AppUserId KEYID
	,@i_NumeratorId KEYID
	)
AS
BEGIN
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

		CREATE TABLE #CPT (
			ID INT IDENTITY(1, 1)
			,ProcedureID INT
			,NAME VARCHAR(500)
			)

		CREATE TABLE #Loinc (
			ID INT IDENTITY(1, 1)
			,LoincID INT
			,NAME VARCHAR(500)
			)

		DECLARE @v_CPTList VARCHAR(4000)
			,@v_LoincList VARCHAR(4000)

		SELECT @v_CPTList = CohortGeneralizedIdList
		FROM PopulationDefinitionCriteria pc
		INNER JOIN PopulationDefPanelConfiguration pdc ON pc.PopulationDefPanelConfigurationID = pdc.PopulationDefPanelConfigurationID
		WHERE pdc.PopulationType = 'Numerator'
			AND pdc.PanelorGroupName = 'CPT'
			AND pc.PopulationDefinitionID = @i_NumeratorId

		SELECT @v_LoincList = CohortGeneralizedIdList
		FROM PopulationDefinitionCriteria pc
		INNER JOIN PopulationDefPanelConfiguration pdc ON pc.PopulationDefPanelConfigurationID = pdc.PopulationDefPanelConfigurationID
		WHERE pdc.PopulationType = 'Numerator'
			AND pdc.PanelorGroupName = 'Loinc'
			AND pc.PopulationDefinitionID = @i_NumeratorId

		INSERT INTO #CPT
		SELECT csp.ProcedureCodeID
			,csp.ProcedureCode + '-' + csp.ProcedureName ProcedureCode
		FROM dbo.udf_SplitStringToTable(@v_CPTList, ',') lm
		INNER JOIN CodeSetProcedure csp ON lm.KeyValue = csp.ProcedureCodeID

		INSERT INTO #Loinc
		SELECT CONVERT(VARCHAR, cl.LoincCodeId) LoincCodeId
			,cl.LoincCode + '-' + cl.ShortDescription LoincCode
		FROM dbo.udf_SplitStringToTable(@v_LoincList, ',') lm
		INNER JOIN CodeSetLoinc cl ON cl.LoincCodeId = lm.KeyValue

		SELECT c.ProcedureID
			,c.NAME ProcdureName
			,l.LoincID
			,l.NAME LoincName
		FROM #CPT c
		FULL JOIN #Loinc l ON c.ID = l.ID
	END TRY

	--------------------------------------------------------           
	BEGIN CATCH
		-- Handle exception          
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LoinAndCPT_ByNumeratorId] TO [FE_rohit.r-ext]
    AS [dbo];

