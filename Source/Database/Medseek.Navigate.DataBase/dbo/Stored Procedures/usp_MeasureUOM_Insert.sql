/*        
------------------------------------------------------------------------------        
Procedure Name: usp_MeasureUOM_Insert    
Description   : This procedure is used to Insert the details into MeasureUOM table    
Created By    : Aditya    
Created Date  : 13-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------        
*/     
CREATE PROCEDURE [dbo].[usp_MeasureUOM_Insert]      
(      
 @i_AppUserId KeyID,    
 @vc_UOMCode SourceName,  
 @vc_UOMText SourceName,    
 @vc_UOMDescription varchar(200),    
 @i_DataSourceID KeyID,  
 @i_DataSourceFileID KeyID,  
 @vc_StatusCode StatusCode,    
 @o_MeasureUOMId KEYID OUTPUT    
)      
AS      
BEGIN TRY      
    SET NOCOUNT ON         
-- Check if valid Application User ID is passed      
      
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )      
    BEGIN      
           RAISERROR ( N'Invalid Application User ID %d passed.' ,      
           17 ,      
           1 ,      
           @i_AppUserId )      
    END      
      
 DECLARE @l_numberOfRecordsInserted INT    
    
 INSERT INTO CodeSetUnitOfMeasure    
 (      
			UnitCode,   
			UnitName,  
			CodeDescription,  
			StatusCode,  
			DataSourceID,  
			DataSourceFileID,      
			CreatedByUserId    
 )    
 VALUES    
 (   
			  @vc_UOMCode,  
			  @vc_UOMText ,    
			  @vc_UOMDescription,   
			  @vc_StatusCode,  
			  @i_DataSourceID ,  
			  @i_DataSourceFileID,  
			  @i_AppUserId    
 )    
    
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT    
          ,@o_MeasureUOMId  = SCOPE_IDENTITY()    
          
    IF @l_numberOfRecordsInserted <> 1              
 BEGIN              
  RAISERROR          
   (  N'Invalid row count %d in Insert MeasureUOM'    
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
    ON OBJECT::[dbo].[usp_MeasureUOM_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

