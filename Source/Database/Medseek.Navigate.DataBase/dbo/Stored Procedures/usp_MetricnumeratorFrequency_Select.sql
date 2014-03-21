
/*          
-----------------------------------------------------------------------------------         
Procedure Name: usp_MetricnumeratorFrequency_Select 23,1
Description   : This procedure is used to select the data from numerator, numeratorFrequency   
    and CodeSetICD table.          
Created By    : Rathnam           
Created Date  : 08-Dec-2012          
-----------------------------------------------------------------------------------       
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
                 
-----------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_MetricnumeratorFrequency_Select] -- 23,3
	(
	@i_AppUserId KEYID
	,@i_MetricID KEYID
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

	---------Selection starts here -------------------        
	SELECT ROW_NUMBER() OVER (
			ORDER BY nu.MetricnumeratorFrequencyId
			) Sno
		,nu.MetricID
		,pd.PopulationDefinitionName NumeratorName
		,nu.MetricnumeratorFrequencyId
		,nu.FromOperator + CONVERT(VARCHAR(10), nu.FromFrequency) + CASE 
			WHEN ISNULL(nu.ToOperator, '') <> ''
				THEN + ' To ' + nu.ToOperator + CONVERT(VARCHAR(10), nu.ToFrequency)
			ELSE ''
			END Frequency
		,nu.FromOperator
		,nu.FromFrequency
		,nu.ToOperator
		,nu.ToFrequency
		,CASE 
			WHEN nu.Label = 'GD'
				THEN 'Good'
			WHEN nu.Label = 'PR'
				THEN 'Poor'
			WHEN nu.Label = 'Fr'
				THEN 'Fair'
			WHEN nu.Label = 'NC'
				THEN 'Not Categorized'
			WHEN nu.Label = 'NT'
				THEN 'Not Tested'
			END Label
	FROM MetricnumeratorFrequency nu WITH (NOLOCK)
	INNER JOIN Metric m WITH (NOLOCK) ON m.MetricId = nu.MetricId
	INNER JOIN PopulationDefinition pd WITH (NOLOCK) ON pd.PopulationDefinitionID = m.NumeratorID
	WHERE (M.MetricId = @i_MetricID)
	ORDER BY 1
END TRY

BEGIN CATCH
	-- Handle exception          
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

	RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MetricnumeratorFrequency_Select] TO [FE_rohit.r-ext]
    AS [dbo];

