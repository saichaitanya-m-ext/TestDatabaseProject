
/*    
---------------------------------------------------------------------------------------    
Procedure Name: usp_TaskBundle_InsertUpdate  
Description   : This proc is used to create TaskBundle record
Created By    : Rathnam
Created Date  : 22-Dec-2011
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
18-Aug-2012 Rathnam added IsEdit, IsbuildingBlock and Productionstatus parameters
29-Aug-2012 P.V.P.Mohan added InCaseOfConflict parameters and Updated,Inserted in Procedure 
---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_TaskBundle_InsertUpdate] (
	@i_AppUserId KEYID
	,@v_TaskBundleName SOURCENAME
	,@v_Description SHORTDESCRIPTION
	,@v_StatusCode STATUSCODE
	,@i_TaskBundleId KEYID = NULL
	,@b_IsEdit BIT = 0
	,@v_ProductionStatus VARCHAR(1) = NULL --F --> Full, U--> Under construction
	,@v_ConflictType VARCHAR(1) = NULL
	,@o_TaskBundleId KEYID OUTPUT
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

	DECLARE @l_numberOfRecordsInserted INT
		,@l_numberOfRecordsUpdated INT

	IF @i_TaskBundleId IS NULL
	BEGIN
		INSERT INTO TaskBundle (
			TaskBundleName
			,Description
			,StatusCode
			,CreatedByUserId
			,CreatedDate
			,IsEdit
			,ProductionStatus
			,ConflictType
			)
		VALUES (
			@v_TaskBundleName
			,@v_Description
			,@v_StatusCode
			,@i_AppUserId
			,GETDATE()
			,@b_IsEdit
			,@v_ProductionStatus
			,@v_ConflictType
			)

		SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
			,@o_TaskBundleId = SCOPE_IDENTITY()

		IF @l_numberOfRecordsInserted <> 1
		BEGIN
			RAISERROR (
					N'Invalid row count %d in insert TaskBundle'
					,17
					,1
					,@l_numberOfRecordsInserted
					)
		END
	END
	ELSE
	BEGIN
		IF @i_TaskBundleId IS NOT NULL
		BEGIN
			UPDATE TaskBundle
			SET TaskBundleName = @v_TaskBundleName
				,Description = @v_Description
				,StatusCode = @v_StatusCode
				,LastModifiedByUserId = @i_AppUserId
				,LastModifiedDate = GETDATE()
				,IsEdit = @b_IsEdit
				,ProductionStatus = @v_ProductionStatus
				,ConflictType = @v_ConflictType
			WHERE TaskBundleId = @i_TaskBundleId

			SET @l_numberOfRecordsUpdated = @@ROWCOUNT

			IF @l_numberOfRecordsUpdated <> 1
			BEGIN
				RAISERROR (
						N'Invalid row count %d in Update TaskBundle'
						,17
						,1
						,@l_numberOfRecordsUpdated
						)
			END
		END
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
    ON OBJECT::[dbo].[usp_TaskBundle_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

