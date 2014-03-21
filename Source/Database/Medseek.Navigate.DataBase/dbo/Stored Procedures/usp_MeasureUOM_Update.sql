/*        
------------------------------------------------------------------------------        
Procedure Name: usp_MeasureUOM_Update        
Description   : This procedure is used to update record in MeasureUOM table    
Created By    : Aditya        
Created Date  : 13-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
        
------------------------------------------------------------------------------        
*/     
CREATE PROCEDURE [dbo].[usp_MeasureUOM_Update]      
(      
 @i_AppUserId KeyID,    
 @vc_UOMCode SourceName,  
 @vc_UOMText SourceName,    
 @vc_UOMDescription varchar(200),    
 @i_DataSourceID KeyID,  
 @i_DataSourceFileID KeyID,  
 @vc_StatusCode StatusCode,    
 @i_MeasureUOMId KEYID     
)      
AS      
BEGIN TRY    
    
 SET NOCOUNT ON      
 DECLARE @l_numberOfRecordsUpdated INT       
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
    
  UPDATE CodeSetUnitOfMeasure    
     SET   
		UnitCode=@vc_UOMCode,  
		UnitName = @vc_UOMText,    
		CodeDescription = @vc_UOMDescription,   
		DataSourceID=@i_DataSourceID,  
		DataSourceFileID= @i_DataSourceFileID,  
		StatusCode = @vc_StatusCode,    
		LastModifiedByUserId = @i_AppUserId,    
		LastModifiedDate = GETDATE()    
			WHERE 
		UnitOfMeasureID = @i_MeasureUOMId    
    
    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT    
          
 IF @l_numberOfRecordsUpdated <> 1    
  BEGIN          
   RAISERROR      
   (  N'Invalid Row count %d passed to update MeasureUOM'      
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
    ON OBJECT::[dbo].[usp_MeasureUOM_Update] TO [FE_rohit.r-ext]
    AS [dbo];

