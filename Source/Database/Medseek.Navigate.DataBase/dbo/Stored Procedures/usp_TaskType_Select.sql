
/*    
------------------------------------------------------------------------------    
Procedure Name: usp_TaskType_Select 216
Description   : This procedure is used to get the details from TaskType table   
Created By    : Aditya    
Created Date  : 22-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
16-June-2010 NagaBabu  Added DestinationPage field   
28-July-2010 NagaBabu Added AllowSpecificSchedules field to Select Statement
02-Aug-2010  NagaBabu Added case condition to AllowSpecificSchedules     
------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_TaskType_Select] (
	@i_AppUserId KEYID
	,@i_TaskTypeId KEYID = NULL
	,@v_StatusCode StatusCode = NULL
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

	SELECT TaskTypeId
		,TaskTypeName
		,Description
		,CreatedByUserId
		,CreatedDate
		,LastModifiedByUserId
		,LastModifiedDate
		,ScheduledDays
		,CASE StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS StatusDescription
		,DestinationPage
		,CASE AllowSpecificSchedules
			WHEN '1'
				THEN 'Yes'
			ELSE 'No'
			END AS AllowSpecificSchedules
	FROM TaskType WITH (NOLOCK)
	WHERE (
			TaskTypeId = @i_TaskTypeId
			OR @i_TaskTypeId IS NULL
			)
		AND (
			@v_StatusCode IS NULL
			OR StatusCode = @v_StatusCode
			)
		AND (
			TaskTypeName <> 'Immunization'
			AND TaskTypeName <> 'Schedule Encounter\Appointment'
			AND TaskTypeName <> 'Medication Titration'
			AND TaskTypeName <> 'Schedule Health Risk Score'
			AND TaskTypeName <> 'Cohort Pending Delete Update'
			AND TaskTypeName <> 'Schedule Phone Call'
			)
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
    ON OBJECT::[dbo].[usp_TaskType_Select] TO [FE_rohit.r-ext]
    AS [dbo];

