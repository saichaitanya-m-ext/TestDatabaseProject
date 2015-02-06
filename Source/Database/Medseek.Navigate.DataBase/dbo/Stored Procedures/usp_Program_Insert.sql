
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_Program_Insert        
Description   : This procedure is used to insert record into Program table    
Created By    : Aditya        
Created Date  : 23-Mar-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
27-09-2012         
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Program_Insert] (
	@i_AppUserId KeyID
	,@vc_ProgramName ShortDescription
	,@vc_Description LongDescription
	,@vc_StatusCode StatusCode
	,@vc_AllowAutoEnrollment IsIndicator
	,@v_ConflictType VARCHAR(1) = NULL
	,@b_IsAutomaticTermination ISINDICATOR
	,@o_ProgramId KeyID OUTPUT
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

	INSERT INTO Program (
		ProgramName
		,Description
		,CreatedByUserId
		,StatusCode
		,AllowAutoEnrollment
		,ConflictType
		,IsAutomaticTermination
		)
	VALUES (
		@vc_ProgramName
		,@vc_Description
		,@i_AppUserId
		,@vc_StatusCode
		,@vc_AllowAutoEnrollment
		,@v_ConflictType
		,@b_IsAutomaticTermination
		)

	SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		,@o_ProgramId = SCOPE_IDENTITY()

	IF @l_numberOfRecordsInserted <> 1
	BEGIN
		RAISERROR (
				N'Invalid row count %d in insert Program'
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
    ON OBJECT::[dbo].[usp_Program_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

