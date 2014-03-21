
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TaskBundleProcedureFrequency_Select      23,9  
Description   : This procedure is used to map the procedures based on conditionalfrequency,   
                 measure and age, ageonly,TherapeuticDrugFrequency & None  
Created By    : Rathnam      
Created Date  : 23-Dec-2011      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION     
12/19/2013 prathyusha added lastmodified date column to the result set
    
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_TaskBundleProcedureFrequency_Select] -- 23,9  
	(
	@i_AppUserId KEYID
	,@i_TaskBundleProcedureFrequencyId KEYID
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsInserted INT

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

	------------------------------------------------------------------------------------  
	SELECT TaskBundleProcedureFrequency.TaskBundleId
		,CodeGrouping.CodeGroupingID
		,CodeGrouping.CodeGroupingName
		,TaskBundleProcedureFrequency.StatusCode
		,IsPreventive
		,TaskBundleProcedureFrequency.LastModifiedDate
		,CASE WHEN TaskBundleProcedureFrequency.RecurrenceType = 'O' THEN 'One Time' ELSE 'Recurring' END RecurrenceType
	FROM TaskBundleProcedureFrequency WITH (NOLOCK)
	INNER JOIN CodeGrouping WITH (NOLOCK)
		ON CodeGrouping.CodeGroupingID = TaskBundleProcedureFrequency.CodeGroupingID
	WHERE TaskBundleProcedureFrequencyId = @i_TaskBundleProcedureFrequencyid

	SELECT tbpcf.TaskBundleProcedureConditionalFrequencyID
		,m.MeasureId
		,m.NAME
		,tbpcf.FromOperatorforMeasure
		,tbpcf.FromValueforMeasure
		,tbpcf.ToOperatorforMeasure
		,tbpcf.ToValueforMeasure
		,tbpcf.FromOperatorforAge
		,tbpcf.FromValueforAge
		,tbpcf.ToOperatorforAge
		,tbpcf.ToValueforAge
		,(
			CASE 
				WHEN tbpcf.FrequencyUOM = 'D'
					THEN 'Day(s)'
				WHEN tbpcf.FrequencyUOM = 'M'
					THEN 'Month(s)'
				WHEN tbpcf.FrequencyUOM = 'W'
					THEN 'Week(s)'
				WHEN tbpcf.FrequencyUOM = 'Y'
					THEN 'Year(s)'
				END
			) FrequencyUOM
		,tbpcf.Frequency
	FROM TaskBundleProcedureConditionalFrequency tbpcf WITH (NOLOCK)
	INNER JOIN Measure m WITH (NOLOCK)
		ON m.MeasureId = tbpcf.MeasureID
	INNER JOIN TaskBundleProcedureFrequency tbpf WITH (NOLOCK)
		ON tbpf.TaskBundleProcedureFrequencyId = tbpcf.TaskBundleProcedureFrequencyId
	WHERE tbpcf.TaskBundleProcedureFrequencyId = @i_TaskBundleProcedureFrequencyId
		AND tbpf.FrequencyCondition = 'Lab Value And Age'

	SELECT tbpcf.TaskBundleProcedureConditionalFrequencyID
		,tbpcf.FromOperatorforAge
		,tbpcf.FromValueforAge
		,tbpcf.ToOperatorforAge
		,tbpcf.ToValueforAge
		,(
			CASE 
				WHEN tbpcf.FrequencyUOM = 'D'
					THEN 'Day(s)'
				WHEN tbpcf.FrequencyUOM = 'M'
					THEN 'Month(s)'
				WHEN tbpcf.FrequencyUOM = 'W'
					THEN 'Week(s)'
				WHEN tbpcf.FrequencyUOM = 'Y'
					THEN 'Year(s)'
				END
			) FrequencyUOM
		,tbpcf.Frequency
	FROM TaskBundleProcedureConditionalFrequency tbpcf WITH (NOLOCK)
	INNER JOIN TaskBundleProcedureFrequency tbpf WITH (NOLOCK)
		ON tbpf.TaskBundleProcedureFrequencyId = tbpcf.TaskBundleProcedureFrequencyId
	WHERE tbpcf.TaskBundleProcedureFrequencyId = @i_TaskBundleProcedureFrequencyId
		AND tbpf.FrequencyCondition = 'Age Only'

	SELECT TaskBundleProcedureFrequencyId
		,FrequencyNumber
		,Frequency
		,NeverSchedule
		,ExclusionReason
	FROM TaskBundleProcedureFrequency WITH (NOLOCK)
	WHERE TaskBundleProcedureFrequencyId = @i_TaskBundleProcedureFrequencyid
		AND FrequencyCondition = 'None'
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
    ON OBJECT::[dbo].[usp_TaskBundleProcedureFrequency_Select] TO [FE_rohit.r-ext]
    AS [dbo];

