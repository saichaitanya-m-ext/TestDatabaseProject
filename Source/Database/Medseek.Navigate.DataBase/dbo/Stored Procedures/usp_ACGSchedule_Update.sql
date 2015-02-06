/*        
------------------------------------------------------------------------------        
Procedure Name: usp_ACGSchedule_Update       
Description   : This procedure is used to Update record into ACGSchedule table    
Created By    : NagaBabu
Created Date  : 01-Mar-2011       
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
------------------------------------------------------------------------------        
*/ 
CREATE PROCEDURE [dbo].[usp_ACGSchedule_Update]  
(  
 @i_AppUserId KeyID ,  
 @vc_Frequency VARCHAR(1) , 
 @vc_StatusCode StatusCode , 
 @i_ACGScheduleID KeyID  
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
		 
		 UPDATE ACGSchedule
			SET Frequency = @vc_Frequency ,
				StatusCode = @vc_StatusCode , 
				LastModifiedByUserid = @i_AppUserId ,
				LastModifiedDate = GETDATE()
		  WHERE ACGScheduleID = @i_ACGScheduleID		

                         
		 SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
		 
		 IF @l_numberOfRecordsUpdated <> 1          
		 BEGIN          
			 RAISERROR      
				 (  N'Invalid row count %d in Update ACGSchedule'
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
    ON OBJECT::[dbo].[usp_ACGSchedule_Update] TO [FE_rohit.r-ext]
    AS [dbo];

