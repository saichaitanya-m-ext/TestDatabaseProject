
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_Program_Update      
Description   : This procedure is used to Update record into Program table    
Created By    : Aditya        
Created Date  : 23-Mar-2010 
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
27-09-2012 Rathnam added  @v_ConflictType, @b_IsAutomaticTermination parameters      
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Program_update] (
	@i_AppUserId KeyID
	,@vc_ProgramName ShortDescription
	,@vc_Description LongDescription
	,@vc_StatusCode StatusCode
	,@vc_AllowAutoEnrollment IsIndicator
	,@i_ProgramId KeyID
	,@v_ConflictType VARCHAR(1)
	,@b_IsAutomaticTermination isindicator
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

	UPDATE Program
	SET ProgramName = @vc_ProgramName
		,Description = @vc_Description
		,AllowAutoEnrollment = @vc_AllowAutoEnrollment
		,LastModifiedByUserId = @i_AppUserId
		,LastModifiedDate = GETDATE()
		,StatusCode = @vc_StatusCode
		,ConflictType = @v_ConflictType
		,IsAutomaticTermination = @b_IsAutomaticTermination
	WHERE ProgramId = @i_ProgramId

	SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT

	IF @l_numberOfRecordsUpdated <> 1
	BEGIN
		RAISERROR (
				N'Invalid Row count %d passed to update Program table'
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
    ON OBJECT::[dbo].[usp_Program_update] TO [FE_rohit.r-ext]
    AS [dbo];

