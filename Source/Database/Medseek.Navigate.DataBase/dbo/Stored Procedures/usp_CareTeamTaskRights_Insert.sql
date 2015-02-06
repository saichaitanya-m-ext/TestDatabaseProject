/*          
------------------------------------------------------------------------------          
Procedure Name: usp_CareTeamTaskRights_Insert          
Description   : This procedure is used to insert record into CareTeamTaskRights table      
Created By    : Aditya          
Created Date  : 22-Apr-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
          
------------------------------------------------------------------------------          
*/  
CREATE PROCEDURE [dbo].[usp_CareTeamTaskRights_Insert]  
(  
 @i_AppUserId KEYID ,  
 @i_UserId KEYID ,  
 @i_TaskTypeId KEYID ,  
 @i_CareTeamId KEYID ,  
 @vc_StatusCode StatusCode,  
 @o_CareTeamTaskRightsId KEYID OUTPUT  
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON  
      DECLARE @l_numberOfRecordsInserted INT       
 -- Check if valid Application User ID is passed          
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END       
  
------------------insert operation into CareTeamTaskRights table-----        
  
     INSERT INTO  
         CareTeamTaskRights  
         (  
			ProviderID,  
			TaskTypeId,  
			CareTeamId,  
			StatusCode,  
			CreatedByUserId  
         )  
     VALUES  
         (  
			@i_UserId ,  
			@i_TaskTypeId ,  
			@i_CareTeamId ,  
			@vc_StatusCode,  
			@i_AppUserId  
          )  
  
       SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,  
		   @o_CareTeamTaskRightsId = SCOPE_IDENTITY()  
  
         IF @l_numberOfRecordsInserted <> 1            
 BEGIN            
  RAISERROR        
   (  N'Invalid row count %d in insert CareTeamTaskRights'  
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
    ON OBJECT::[dbo].[usp_CareTeamTaskRights_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

