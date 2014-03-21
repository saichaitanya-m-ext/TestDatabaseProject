/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Labs_Update] 
Description	  : This procedure is used to Update the data into Labs table.
Created By    :	NagaBabu
Created Date  : 26-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
---------------------------------------------------------------------------------
*/
   
CREATE PROCEDURE [dbo].[usp_Labs_Update] 
(
	@i_AppUserId KEYID ,
	@v_LabName ShortDescription ,
	@v_StatusCode StatusCode ,
	@i_LabId KeyID 
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
    
---------insert operation into ACGSchedule table-----       
		 
		 UPDATE Labs
			SET LabName = @v_LabName ,
				StatusCode = @v_StatusCode , 
				LastModifiedByUserId = @i_AppUserId ,
				LastModifiedDate = GETDATE()
		  WHERE LabId = @i_LabId

		 SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
		 
		 IF @l_numberOfRecordsUpdated <> 1          
		 BEGIN          
			 RAISERROR      
				 (  N'Invalid row count %d in Update Labs'
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
    ON OBJECT::[dbo].[usp_Labs_Update] TO [FE_rohit.r-ext]
    AS [dbo];

