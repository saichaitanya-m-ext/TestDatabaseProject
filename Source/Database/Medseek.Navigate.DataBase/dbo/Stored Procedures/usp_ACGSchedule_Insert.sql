/*        
------------------------------------------------------------------------------        
Procedure Name: usp_ACGSchedule_Insert        
Description   : This procedure is used to insert record into ACGSchedule table    
Created By    : NagaBabu
Created Date  : 01-Mar-2011       
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_ACGSchedule_Insert]
(  
 @i_AppUserId KeyID ,  
 @vc_ACGType VARCHAR(1) ,  
 @i_ACGSubTypeID KeyID ,  
 @vc_Frequency VARCHAR(1) , 
 @d_StartDate UserDate ,
 @vc_StatusCode StatusCode , 
 @o_ACGScheduleID KeyID OUTPUT 
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
  

         INSERT INTO  
             ACGSchedule  
             (  
               ACGType ,  
               ACGSubTypeID ,  
               Frequency ,  
               StartDate ,  
               StatusCode ,
               CreatedByUserid 
             )  
         VALUES  
             ( 
               @vc_ACGType ,
               @i_ACGSubTypeID ,
               @vc_Frequency ,
               @d_StartDate ,
               @vc_StatusCode ,
               @i_AppUserId
              )  
                 
		 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
				@o_ACGScheduleID = SCOPE_IDENTITY()
		 IF @l_numberOfRecordsInserted <> 1          
		 BEGIN          
			 RAISERROR      
				 (  N'Invalid row count %d in insert ACGSchedule'
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
    ON OBJECT::[dbo].[usp_ACGSchedule_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

