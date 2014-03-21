
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_LabMeasure_Update    
Description   : This procedure is used to Update record into LabMeasure table
Created By    : Aditya    
Created Date  : 16-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
24-Aug-2011 NagaBabu Added @d_StartDate,@d_EndDate,@i_ReminderDaysBeforeEnddate as Parameters while these fields
						are added to the LabMeasure table
21-Nov-2011 NagaBabu calling insert statement for inserting data into LabMeasure Table based on if condition						        
05-Dec-2011 Rathnam removed the above nagababu condition on (21-Nov-2011)
04-Oct-2012 Rathnam added @v_CPTList, @v_CPTList parameters	
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_LabMeasure_Update] (
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
	,@i_MeasureUOMId KeyID
	,@i_ProgramId KeyID = NULL
	,@i_PatientUserID KeyID = NULL
	,@i_LabMeasureId KeyID
	,@d_StartDate UserDate = NULL
	,@d_EndDate UserDate = NULL
	,@i_ReminderDaysBeforeEnddate INT = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @l_numberOfRecordsUpdated INT

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

	UPDATE LabMeasure
	SET MeasureId = @i_MeasureId
		,IsGoodControl = @b_IsGoodControl
		,Operator1forGoodControl = @v_Operator1forGoodControl
		,Operator1Value1forGoodControl = @d_Operator1Value1forGoodControl
		,Operator1Value2forGoodControl = @d_Operator1Value2forGoodControl
		,Operator2forGoodControl = @v_Operator2forGoodControl
		,Operator2Value1forGoodControl = @d_Operator2Value1forGoodControl
		,Operator2Value2forGoodControl = @d_Operator2Value2forGoodControl
		,TextValueForGoodControl = @v_TextValueForGoodControl
		,IsFairControl = @b_IsFairControl
		,Operator1forFairControl = @v_Operator1forFairControl
		,Operator1Value1forFairControl = @d_Operator1Value1forFairControl
		,Operator1Value2forFairControl = @d_Operator1Value2forFairControl
		,Operator2forFairControl = @v_Operator2forFairControl
		,Operator2Value1forFairControl = @d_Operator2Value1forFairControl
		,Operator2Value2forFairControl = @d_Operator2Value2forFairControl
		,TextValueForFairControl = @v_TextValueForFairControl
		,IsPoorControl = @b_IsPoorControl
		,Operator1forPoorControl = @v_Operator1forPoorControl
		,Operator1Value1forPoorControl = @d_Operator1Value1forPoorControl
		,Operator1Value2forPoorControl = @d_Operator1Value2forPoorControl
		,Operator2forPoorControl = @v_Operator2forPoorControl
		,Operator2Value1forPoorControl = @d_Operator2Value1forPoorControl
		,Operator2Value2forPoorControl = @d_Operator2Value2forPoorControl
		,TextValueForPoorControl = @v_TextValueForPoorControl
		,MeasureUOMId = @i_MeasureUOMId
		,ProgramId = @i_ProgramId
		,PatientUserID = @i_PatientUserID
		,LastModifiedByUserId = @i_AppUserID
		,LastModifiedDate = GETDATE()
		,StartDate = @d_StartDate
		,EndDate = @d_EndDate
		,ReminderDaysBeforeEnddate = @i_ReminderDaysBeforeEnddate
	WHERE LabMeasureId = @i_LabMeasureId

	SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT

	IF @l_numberOfRecordsUpdated <> 1
	BEGIN
		RAISERROR (
				N'Invalid Row count %d passed to update LabMeasure'
				,17
				,1
				,@l_numberOfRecordsUpdated
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
    ON OBJECT::[dbo].[usp_LabMeasure_Update] TO [FE_rohit.r-ext]
    AS [dbo];

