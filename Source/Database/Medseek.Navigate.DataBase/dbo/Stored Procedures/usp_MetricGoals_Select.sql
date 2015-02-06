
/*            
-----------------------------------------------------------------------------------           
Procedure Name: usp_MetricGoals_Select 2,1,3       
Description   : This procedure is used to get the numerator frequencyes and goals information  
Created By    : Rathnam  
Created Date  : 27-Nov-2012            
-----------------------------------------------------------------------------------         
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION            
                   
-----------------------------------------------------------------------------------            
*/
CREATE PROCEDURE [dbo].[usp_MetricGoals_Select] (
	@i_AppUserId KEYID
	,@i_MetricsID KEYID
	,@i_MetricNumeratorID KEYID = NULL
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

		---------Selection starts here -------------------          
		SELECT nu.MetricnumeratorFrequencyId
			,dbo.ufn_GetMetricNameByID(Nu.MetricId) + '( ' + ISNULL(CONVERT(VARCHAR, nu.FromOperator), '') + ' ' + ISNULL(CONVERT(VARCHAR, nu.FromFrequency), '') + '  ' + CASE 
				WHEN ToOperator <> ''
					THEN ' AND ' + '  ' + ISNULL(CONVERT(VARCHAR, nu.ToOperator), '') + ' ' + ISNULL(CONVERT(VARCHAR, nu.ToFrequency), '') + ' '
				ELSE ''
				END + ')' AS Frequency
			,CASE 
				WHEN @i_MetricNumeratorID IS NULL
					THEN CASE 
							WHEN nu.EntityType = 'CT'
								THEN STUFF((
											SELECT ' AND ' + c.CareTeamName
											FROM CareTeam c
											INNER JOIN NumeratorGoal ng ON c.CareTeamId = ng.EntityTypeId
											WHERE nu.MetricNumeratorFrequencyId = ng.MetricNumeratorFrequencyId
											FOR XML PATH('')
											), 1, 5, '')
							WHEN nu.EntityType = 'PC'
								THEN STUFF((
											SELECT ' AND ' + dbo.ufn_GetUserNameByID(ng.EntityTypeId)
											FROM NumeratorGoal ng
											WHERE nu.MetricNumeratorFrequencyId = ng.MetricNumeratorFrequencyId
											FOR XML PATH('')
											), 1, 5, '')
							WHEN nu.EntityType = 'MP'
								THEN STUFF((
											SELECT ' AND ' + p.ProgramName
											FROM Program p
											INNER JOIN NumeratorGoal ng ON p.ProgramId = ng.EntityTypeId
											WHERE nu.MetricNumeratorFrequencyId = ng.MetricNumeratorFrequencyId
											FOR XML PATH('')
											), 1, 5, '')
							WHEN nu.EntityType = 'EG'
								THEN STUFF((
											SELECT ' AND ' + eg.GroupName
											FROM EmployerGroup eg
											INNER JOIN NumeratorGoal ng ON eg.EmployerGroupID = ng.EntityTypeId
											WHERE nu.MetricNumeratorFrequencyId = ng.MetricNumeratorFrequencyId
											FOR XML PATH('')
											), 1, 5, '')
							WHEN nu.EntityType = 'IG'
								THEN STUFF((
											SELECT ' AND ' + ig.GroupName
											FROM InsuranceGroup ig
											INNER JOIN NumeratorGoal ng ON ig.InsuranceGroupID = ng.EntityTypeId
											WHERE nu.MetricNumeratorFrequencyId = ng.MetricNumeratorFrequencyId
											FOR XML PATH('')
											), 1, 5, '')
							END
				ELSE NULL
				END Entity
			,CAST(nu.Goal AS VARCHAR(10)) + '% of Population Should Comply to Defined Freq.' AS Goal
			,nu.EntityType
			,CASE 
				WHEN @i_MetricNumeratorID IS NOT NULL
					THEN STUFF((
								SELECT ',' + CONVERT(VARCHAR(10), ng.EntityTypeID)
								FROM NumeratorGoal ng
								WHERE nu.MetricNumeratorFrequencyId = ng.MetricNumeratorFrequencyId
								FOR XML PATH('')
								), 1, 1, '')
				ELSE NULL
				END EntityTypeList
		FROM MetricnumeratorFrequency nu WITH (NOLOCK)
		INNER JOIN Metric m WITH (NOLOCK) ON m.MetricID = nu.MetricID
		WHERE (
				m.MetricID = @i_MetricsID
				OR @i_MetricsID IS NULL
				)
			AND (
				nu.MetricnumeratorFrequencyID = @i_MetricNumeratorID
				OR @i_MetricNumeratorID IS NULL
				)
			AND FromOperator IS NOT NULL
	END TRY

	-----------------------------------------------------------------------------------------------------------------------------        
	BEGIN CATCH
		-- Handle exception            
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MetricGoals_Select] TO [FE_rohit.r-ext]
    AS [dbo];

