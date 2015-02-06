
/*
-----------------------------------------------------------------------------------------------
Procedure Name: [dbo].[[usp_LookUpCodeType_Update]]
Description	  : This procedure is used to update the data from LkUpCodeType_Test based on the CodeTypeID (Node) 
Created By    :	Rama krishna
Created Date  : 05-12-2013
------------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_LookUpCodeType_Update]
(
	
	@i_AppUserId KeyID,
	@i_CodeTypeID KeyID,
	@vc_CodeTypeCode VARCHAR(150) ,
	@vc_CodeTypeName VARCHAR(300) ,
	@vc_TypeDescription VARCHAR(4000) ,
	@vc_CodeTableName VARCHAR(300),
	@o_CodeTypeId KeyID OUTPUT 
)

AS
BEGIN TRY 

	SET NOCOUNT ON	
	-- Check if valid Application User ID is passed
	DECLARE @i_numberOfRecordsUpdated INT
	IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR
		(	 N'Invalid Application User ID %d passed.'
			,17
			,1
			,@i_AppUserId
		)
	END
------------    Updation operation takes place   --------------------------
			
	UPDATE LkUpCodeType_Test
	   SET CodeTypeCode=@vc_CodeTypeCode ,
			CodeTypeName=@vc_CodeTypeName,
			TypeDescription=@vc_TypeDescription ,
			CodeTableName =@vc_CodeTableName
	 WHERE 
		CodeTypeID = @i_CodeTypeID
		  	 
	SET @i_numberOfRecordsUpdated = @@ROWCOUNT
			
	IF @i_numberOfRecordsUpdated <> 1 
		RAISERROR
		(	 N'Update of Activity table experienced invalid row count of %d'
			,17
			,1
			,@i_numberOfRecordsUpdated         
	)        
			
	RETURN 0
	
END TRY 
------------ Exception Handling --------------------------------
BEGIN CATCH
    DECLARE @i_ReturnedErrorID	INT
    
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
				@i_UserId = @i_AppUserId
                        
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LookUpCodeType_Update] TO [FE_rohit.r-ext]
    AS [dbo];

