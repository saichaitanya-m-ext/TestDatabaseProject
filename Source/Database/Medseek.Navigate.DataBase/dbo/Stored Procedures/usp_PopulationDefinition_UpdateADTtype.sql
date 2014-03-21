

/*  
-----------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_PopulationDefinition_Update]  
Description   : This procedure is used to update the data into PopulationDefinition  
Created By    : NagaBabu  
Created Date  : 20-01-2014
------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
------------------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationDefinition_UpdateADTtype] 
(
	@i_AppUserId KeyID ,
	@i_PopulationDefinitionID KeyID ,
	@vc_ADTtype VARCHAR(1) 
)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed  
	DECLARE @i_numberOfRecordsUpdated INT

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

	------------    Updation operation takes place   --------------------------  
	UPDATE PopulationDefinition
	SET ADTtype = @vc_ADTtype ,
		LastModifiedByUserId = @i_AppUserId ,
		LastModifiedDate = GETDATE()
	WHERE PopulationDefinitionID = @i_PopulationDefinitionID

	SELECT @i_numberOfRecordsUpdated = @@ROWCOUNT
	
	IF @i_numberOfRecordsUpdated <> 1  
		BEGIN        
			 RAISERROR    
			   (  N'Invalid Row count %d passed to update PopulationDefinition'    
				,17    
				,1   
				,@i_numberOfRecordsUpdated              
			   )            
		END    
    
    RETURN 0    
	
END TRY
------------ Exception Handling --------------------------------  
BEGIN CATCH
	DECLARE @i_ReturnedErrorID INT
	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
	RETURN @i_ReturnedErrorID
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinition_UpdateADTtype] TO [FE_rohit.r-ext]
    AS [dbo];

