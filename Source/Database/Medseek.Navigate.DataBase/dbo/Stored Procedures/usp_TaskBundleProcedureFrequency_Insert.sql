
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TaskBundleProcedureFrequency_Insert      
Description   : This procedure is used to map the procedures based on conditionalfrequency,   
                 measure and age, ageonly,TherapeuticDrugFrequency & None  
Created By    : Rathnam      
Created Date  : 23-Dec-2011      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION     
18-Jan-2012 NagaBabu Added IF (SELECT COUNT(*) FROM @tblCommunication) >= 1      
21-Jan-2012 NagaBabu Added @i_TaskBundleCommunicationScheduleID as input parameter      
01-Feb-2012 Rathnam added two column LeadDays & ScheduleDays to the  TaskBundleProcedureFrequency    
07-feb-2012 Sivakrishna Assigned parameter(@i_TaskBundleId) to inner sp  
   [usp_TaskBundleCommunicationSchedule_Insert]  
15-Feb-2012 NagaBabu Modified if else conditions while data is not inserting properly   
18-Aug-2012 Rathnam removed the The TaskBundleProcedureTherapeuticDrugFrequency table  
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_TaskBundleProcedureFrequency_Insert] (
	@i_AppUserId KEYID
	,@i_TaskBundleId KEYID
	,@i_CodeGroupingId KEYID
	,@vc_StatusCode STATUSCODE = NULL
	,@i_FrequencyNumber KEYID = NULL
	,@vc_Frequency VARCHAR(1) = NULL
	,@b_NeverSchedule BIT = NULL
	,@vc_ExclusionReason SHORTDESCRIPTION = NULL
	,@b_IsPreventive ISINDICATOR = NULL
	,@t_TaskBundleProcedureConditionalFrequency PROGRAMPROCEDURECONDITIONALFREQUENCY READONLY
	,@v_FrequencyCondition SOURCENAME
	,@vc_RecurrenceType CHAR
	--,@t_TaskBundleProcedureTherapeuticDrugFrequency PROGRAMPROCEDURETHERAPEUTICDRUGFREQUENCY READONLY  
	,@o_TaskBundleProcedureFrequencyId KEYID OUT
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
	DECLARE @l_TranStarted BIT = 0

	IF (@@TRANCOUNT = 0)
	BEGIN
		BEGIN TRANSACTION

		SET @l_TranStarted = 1 -- Indicator for start of transactions  
	END
	ELSE
		SET @l_TranStarted = 0

	IF @v_FrequencyCondition <> 'None'
	BEGIN
		INSERT INTO TaskBundleProcedureFrequency (
			TaskBundleId
			,CodeGroupingId
			,StatusCode
			,FrequencyNumber
			,Frequency
			,CreatedByUserId
			,NeverSchedule
			,ExclusionReason
			--,LabTestId  
			--,EffectiveStartDate  
			,IsPreventive
			,FrequencyCondition
			,RecurrenceType
			)
		VALUES (
			@i_TaskBundleId
			,@i_CodeGroupingId
			,@vc_StatusCode
			,@i_FrequencyNumber
			,@vc_Frequency
			,@i_AppUserId
			,@b_NeverSchedule
			,@vc_ExclusionReason
			--,@i_LabTestId  
			--,@d_EffectiveStartDate  
			,@b_IsPreventive
			,@v_FrequencyCondition
			,@vc_RecurrenceType
			)

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
			,@o_TaskBundleProcedureFrequencyId = SCOPE_IDENTITY()

		DECLARE @t_TaskBundleProcedureFrequency TABLE (
			MeasureID KEYID
			,FromOperatorForMeasure VARCHAR(5)
			,FromValueforMeasure DECIMAL(10, 2)
			,ToOperatorforMeasure VARCHAR(5)
			,ToValueforMeasure DECIMAL(10, 2)
			,MeasureTextValue SOURCENAME
			,FromOperatorforAge VARCHAR(5)
			,FromValueforAge SMALLINT
			,ToOperatorforAge VARCHAR(5)
			,ToValueforAge SMALLINT
			,Frequency SMALLINT
			,FrequencyUOM VARCHAR(10)
			)

		INSERT INTO @t_TaskBundleProcedureFrequency (
			MeasureID
			,FromOperatorForMeasure
			,FromValueforMeasure
			,ToOperatorforMeasure
			,ToValueforMeasure
			,MeasureTextValue
			,FromOperatorforAge
			,FromValueforAge
			,ToOperatorforAge
			,ToValueforAge
			,Frequency
			,FrequencyUOM
			)
		SELECT MeasureID
			,SUBSTRING(FromOperatorWithValue, 1, CHARINDEX(' ', FromOperatorWithValue, 1) - 1) AS FromOperatorForMeasure
			,CAST(SUBSTRING(FromOperatorWithValue, CHARINDEX(' ', FromOperatorWithValue, 1) + 1, LEN(FromOperatorWithValue)) AS DECIMAL(10, 2)) AS FromValueforMeasure
			,SUBSTRING(ToOperatorWithValue, 1, CHARINDEX(' ', ToOperatorWithValue, 1) - 1) AS ToOperatorforMeasure
			,CAST(SUBSTRING(ToOperatorWithValue, CHARINDEX(' ', ToOperatorWithValue, 1) + 1, LEN(ToOperatorWithValue)) AS DECIMAL(10, 2)) AS ToValueforMeasure
			,MeasureTextValue
			,SUBSTRING(FromOperatorWithAge, 1, CHARINDEX(' ', FromOperatorWithAge, 1) - 1) AS FromOperatorforAge
			,CAST(SUBSTRING(FromOperatorWithAge, CHARINDEX(' ', FromOperatorWithAge, 1) + 1, LEN(FromOperatorWithAge)) AS SMALLINT) AS FromValueforAge
			,SUBSTRING(ToOperatorWithAge, 1, CHARINDEX(' ', ToOperatorWithAge, 1) - 1) AS ToOperatorforAge
			,CAST(SUBSTRING(ToOperatorWithAge, CHARINDEX(' ', ToOperatorWithAge, 1) + 1, LEN(ToOperatorWithAge)) AS SMALLINT) ToValueforAge
			,CAST(SUBSTRING(FrequencyNumberUOM, 1, CHARINDEX(' ', FrequencyNumberUOM, 1) - 1) AS SMALLINT) AS Frequency
			,SUBSTRING(FrequencyNumberUOM, CHARINDEX(' ', FrequencyNumberUOM, 1) + 1, LEN(FrequencyNumberUOM)) AS FrequencyUOM
		FROM @t_TaskBundleProcedureConditionalFrequency

		INSERT INTO TaskBundleProcedureConditionalFrequency (
			TaskBundleProcedureFrequencyId
			,MeasureID
			,FromOperatorforMeasure
			,FromValueforMeasure
			,ToOperatorforMeasure
			,ToValueforMeasure
			,MeasureTextValue
			,FromOperatorforAge
			,FromValueforAge
			,ToOperatorforAge
			,ToValueforAge
			,FrequencyUOM
			,Frequency
			,CreatedByUserId
			)
		SELECT @o_TaskBundleProcedureFrequencyId
			,TPPCF.MeasureID
			,TPPCF.FromOperatorforMeasure
			,TPPCF.FromValueforMeasure
			,TPPCF.ToOperatorforMeasure
			,TPPCF.ToValueforMeasure
			,TPPCF.MeasureTextValue
			,TPPCF.FromOperatorforAge
			,TPPCF.FromValueforAge
			,TPPCF.ToOperatorforAge
			,TPPCF.ToValueforAge
			,CASE TPPCF.FrequencyUOM
				WHEN 'Day(s)'
					THEN 'D'
				WHEN 'Week(s)'
					THEN 'W'
				WHEN 'Month(s)'
					THEN 'M'
				WHEN 'Year(s)'
					THEN 'Y'
				END AS FrequencyUOM
			,TPPCF.Frequency
			,@i_AppUserId
		FROM @t_TaskBundleProcedureFrequency TPPCF

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT

		IF @l_numberOfRecordsInserted < 1
		BEGIN
			RAISERROR (
					N'Invalid row count %d in insert TaskBundleProcedureConditionalFrequency'
					,17
					,1
					,@l_numberOfRecordsInserted
					)
		END
	END
			--END   
	ELSE
	BEGIN
		INSERT INTO TaskBundleProcedureFrequency (
			TaskBundleId
			,CodeGroupingId
			,StatusCode
			,FrequencyNumber
			,Frequency
			,CreatedByUserId
			,NeverSchedule
			,ExclusionReason
			,IsPreventive
			,FrequencyCondition
			,IsSelfTask
			,RecurrenceType
			)
		VALUES (
			@i_TaskBundleId
			,@i_CodeGroupingId
			,@vc_StatusCode
			,@i_FrequencyNumber
			,@vc_Frequency
			,@i_AppUserId
			,@b_NeverSchedule
			,@vc_ExclusionReason
			,@b_IsPreventive
			,@v_FrequencyCondition
			,1
			,@vc_RecurrenceType
			)

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
			,@o_TaskBundleProcedureFrequencyId = SCOPE_IDENTITY()

		IF @l_numberOfRecordsInserted <> 1
		BEGIN
			RAISERROR (
					N'Invalid row count %d in insert TaskBundleProcedureFrequency'
					,17
					,1
					,@l_numberOfRecordsInserted
					)
		END
	END

	IF (@l_TranStarted = 1) -- If transactions are there, then commit  
	BEGIN
		SET @l_TranStarted = 0

		COMMIT TRANSACTION
	END
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
    ON OBJECT::[dbo].[usp_TaskBundleProcedureFrequency_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

