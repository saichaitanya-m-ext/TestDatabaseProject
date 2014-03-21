/*    
------------------------------------------------------------------------------    
Procedure Name: usp_DocumentDisease_Delete    
Description   : This procedure is used to Delete record from DocumentDisease table
Created By    : Aditya    
Created Date  : 6-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_DocumentDisease_Delete]  
(  
	@i_AppUserId KeyID,
	@i_LibraryID KeyID,
    @i_DiseaseID KeyID
 )
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsDeleted INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  

	DELETE FROM DocumentDisease
	 WHERE  LibraryID = @i_LibraryID
			AND DiseaseID = @i_DiseaseID

    SELECT @l_numberOfRecordsDeleted = @@ROWCOUNT
      
	IF @l_numberOfRecordsDeleted <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to Delete DocumentDisease Details'  
				,17  
				,1 
				,@l_numberOfRecordsDeleted
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
    ON OBJECT::[dbo].[usp_DocumentDisease_Delete] TO [FE_rohit.r-ext]
    AS [dbo];

