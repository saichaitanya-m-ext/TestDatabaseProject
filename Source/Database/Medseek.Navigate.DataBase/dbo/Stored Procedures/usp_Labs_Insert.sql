/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Labs_Insert] 
Description	  : This procedure is used to Insert the data into Labs table.
Created By    :	NagaBabu
Created Date  : 26-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
---------------------------------------------------------------------------------
*/
   
CREATE PROCEDURE [dbo].[usp_Labs_Insert] 
(
	@i_AppUserId KEYID ,
	@v_LabName ShortDescription ,
	@v_StatusCode StatusCode ,
	@o_LabId KeyID OUT
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
    
---------insert operation into ACGSchedule table-----       
         INSERT INTO Labs  
             (  
               LabName ,  
               StatusCode ,
               CreatedByUserid 
             )  
         VALUES  
             ( 
			   @v_LabName ,	
               @v_StatusCode ,
               @i_AppUserId
              )  
                 
		 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
				@o_LabId = SCOPE_IDENTITY()
		 IF @l_numberOfRecordsInserted <> 1          
		 BEGIN          
			 RAISERROR      
				 (  N'Invalid row count %d in insert Labs'
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
    ON OBJECT::[dbo].[usp_Labs_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

