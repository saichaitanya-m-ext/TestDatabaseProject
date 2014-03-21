/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CodeSetICDGroups_Insert
Description   : This Procedure is used to Insert data into CodeSetICDGroups table  
Created By    : NagaBabu
Created Date  : 08-Apr-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CodeSetICDGroups_Insert]  
(  
	@i_AppUserId KeyId,  
	@v_ICDGroupName SourceName, 
	@v_StatusCode StatusCode,
	@o_ICDCodeGroupId KeyID OUTPUT
)  
AS  
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  

	INSERT INTO CodeSetICDGroups
	   ( 
		 ICDGroupName ,
		 StatusCode ,
		 CreatedByUserId 
	   )
	VALUES 
	   (
	     @v_ICDGroupName ,
	     @v_StatusCode ,
	     @i_AppUserId 
	   )  
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_ICDCodeGroupId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Insert ICDCodeGroup'
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
    ON OBJECT::[dbo].[usp_CodeSetICDGroups_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

