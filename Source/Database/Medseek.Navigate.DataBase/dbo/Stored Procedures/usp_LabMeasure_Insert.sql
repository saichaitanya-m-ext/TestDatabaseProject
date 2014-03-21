
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_LabMeasure_Insert    
Description   : This procedure is used to insert record into LabMeasure table
Created By    : Aditya    
Created Date  : 15-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
21-Apr-10 Pramod Included 3 extra fields for each of the control types  
24-Aug-2011 NagaBabu Added @d_StartDate,@d_EndDate,@i_ReminderDaysBeforeEnddate as Parameters while these fields
						are added to the LabMeasure table    
04-Oct-2012 Rathnam added @v_CPTList, @v_LoincList parameters						
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_LabMeasure_Insert] (
	@i_AppUserId KeyID
	,@i_MeasureId KeyID
	,@b_IsGoodControl IsIndicator
	,@v_Operator1forGoodControl VARCHAR(20)
	,@d_Operator1Value1forGoodControl DECIMAL(12, 2)
	,@d_Operator1Value2forGoodControl DECIMAL(12, 2)
	,@v_Operator2forGoodControl VARCHAR(20)
	,@d_Operator2Value1forGoodControl DECIMAL(12, 2)
	,@d_Operator2Value2forGoodControl DECIMAL(12, 2)
	,@v_TextValueForGoodControl SourceName
	,@b_IsFairControl IsIndicator
	,@v_Operator1forFairControl VARCHAR(20)
	,@d_Operator1Value1forFairControl DECIMAL(12, 2)
	,@d_Operator1Value2forFairControl DECIMAL(12, 2)
	,@v_Operator2forFairControl VARCHAR(20)
	,@d_Operator2Value1forFairControl DECIMAL(12, 2)
	,@d_Operator2Value2forFairControl DECIMAL(12, 2)
	,@v_TextValueForFairControl SourceName
	,@b_IsPoorControl IsIndicator
	,@v_Operator1forPoorControl VARCHAR(20)
	,@d_Operator1Value1forPoorControl DECIMAL(12, 2)
	,@d_Operator1Value2forPoorControl DECIMAL(12, 2)
	,@v_Operator2forPoorControl VARCHAR(20)
	,@d_Operator2Value1forPoorControl DECIMAL(12, 2)
	,@d_Operator2Value2forPoorControl DECIMAL(12, 2)
	,@v_TextValueForPoorControl SourceName
	,@i_MeasureUOMId KeyID = NULL
	,@i_ProgramId KeyID = NULL
	,@i_PatientUserID KeyID = NULL
	,@o_LabMeasureId KeyID OUTPUT
	,@d_StartDate UserDate
	,@d_EndDate UserDate = NULL
	,@i_ReminderDaysBeforeEnddate INT = NULL
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

	INSERT INTO LabMeasure (
		MeasureId
		,IsGoodControl
		,Operator1forGoodControl
		,Operator1Value1forGoodControl
		,Operator1Value2forGoodControl
		,Operator2forGoodControl
		,Operator2Value1forGoodControl
		,Operator2Value2forGoodControl
		,TextValueForGoodControl
		,IsFairControl
		,Operator1forFairControl
		,Operator1Value1forFairControl
		,Operator1Value2forFairControl
		,Operator2forFairControl
		,Operator2Value1forFairControl
		,Operator2Value2forFairControl
		,TextValueForFairControl
		,IsPoorControl
		,Operator1forPoorControl
		,Operator1Value1forPoorControl
		,Operator1Value2forPoorControl
		,Operator2forPoorControl
		,Operator2Value1forPoorControl
		,Operator2Value2forPoorControl
		,TextValueForPoorControl
		,MeasureUOMId
		,ProgramId
		,PatientUserID
		,CreatedByUserId
		,StartDate
		,EndDate
		,ReminderDaysBeforeEnddate
		)
	VALUES (
		@i_MeasureId
		,@b_IsGoodControl
		,@v_Operator1forGoodControl
		,@d_Operator1Value1forGoodControl
		,@d_Operator1Value2forGoodControl
		,@v_Operator2forGoodControl
		,@d_Operator2Value1forGoodControl
		,@d_Operator2Value2forGoodControl
		,@v_TextValueForGoodControl
		,@b_IsFairControl
		,@v_Operator1forFairControl
		,@d_Operator1Value1forFairControl
		,@d_Operator1Value2forFairControl
		,@v_Operator2forFairControl
		,@d_Operator2Value1forFairControl
		,@d_Operator2Value2forFairControl
		,@v_TextValueForFairControl
		,@b_IsPoorControl
		,@v_Operator1forPoorControl
		,@d_Operator1Value1forPoorControl
		,@d_Operator1Value2forPoorControl
		,@v_Operator2forPoorControl
		,@d_Operator2Value1forPoorControl
		,@d_Operator2Value2forPoorControl
		,@v_TextValueForPoorControl
		,@i_MeasureUOMId
		,@i_ProgramId
		,@i_PatientUserID
		,@i_AppUserId
		,@d_StartDate
		,@d_EndDate
		,@i_ReminderDaysBeforeEnddate
		)

	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		,@o_LabMeasureId = SCOPE_IDENTITY()

	IF @l_numberOfRecordsInserted <> 1
	BEGIN
		RAISERROR (
				N'Invalid row count %d in Insert LabMeasure'
				,17
				,1
				,@l_numberOfRecordsInserted
				)
	END

	RETURN 0
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
    ON OBJECT::[dbo].[usp_LabMeasure_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

