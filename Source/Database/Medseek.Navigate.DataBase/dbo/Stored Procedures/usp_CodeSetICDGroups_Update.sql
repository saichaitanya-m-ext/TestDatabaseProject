/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CodeSetICDGroups_Update
Description   : This Procedure is used to Update data into CodeSetICDGroups table  
Created By    : NagaBabu
Created Date  : 08-Apr-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CodeSetICDGroups_Update]  
(  
	@i_AppUserId KeyId,  
	@v_ICDGroupName SourceName, 
	@v_StatusCode StatusCode,
	@i_ICDCodeGroupId KeyID 
)  
AS  
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  

	UPDATE CodeSetICDGroups
	   SET ICDGroupName = @v_ICDGroupName ,
		   StatusCode = @v_StatusCode ,
		   LastModifiedByUserId = @i_AppUserId ,
		   LastModifiedDate = GETDATE()		
	 WHERE ICDCodeGroupId = @i_ICDCodeGroupId  
    
    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
      
    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update ICDCodeGroup'
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
    ON OBJECT::[dbo].[usp_CodeSetICDGroups_Update] TO [FE_rohit.r-ext]
    AS [dbo];

