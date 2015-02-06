
  
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_MeasureUOM_Select        
Description   : This procedure is used to get the records from the MeasureUOM      
    table      
Created By    : Aditya        
Created Date  : 13-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
27-Sep-2010 NagaBabu Added ORDER BY clause to this SP       
------------------------------------------------------------------------------        
*/      
    
CREATE PROCEDURE [dbo].[usp_MeasureUOM_Select]  
(      
  @i_AppUserId KeyID,      
  @i_MeasureUOMId KeyID = NULL,      
  @v_StatusCode StatusCode = NULL      
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
      
  SELECT    
   CSUOM.UnitOfMeasureID AS MeasureUOMId,    
   CSUOM.UnitCode,   
   CSUOM.UnitName AS UOMText,   
   CSUOM.CodeDescription AS UOMDescription,  
   CDS.DataSourceId,  
   CDS.SourceName,  
   DSF.DataSourceFileID,  
   DSF.DataSourceFileName,  
   CSUOM.CreatedByUserId,    
   CSUOM.CreatedDate,    
   CSUOM.LastModifiedByUserId,    
   CSUOM.LastModifiedDate,     
   CASE CSUOM.StatusCode       
   WHEN 'A' THEN 'Active'      
   WHEN 'I' THEN 'InActive'      
   ELSE ''      
   END AS StatusDescription      
  FROM    
      CodeSetUnitOfMeasure  CSUOM  
		LEFT JOIN   
      CodeSetDataSource CDS ON  
      CDS.DataSourceId=CSUOM.DataSourceID  
		LEFT JOIN   
      DataSourceFile DSF  ON  
      DSF.DataSourceFileID=CSUOM.DataSourceFileID  
  WHERE    
      ( CSUOM.UnitOfMeasureID = @i_MeasureUOMId OR @i_MeasureUOMId IS NULL )      
  AND ( CSUOM.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )     
  ORDER BY     
   CSUOM.CreatedDate DESC    
          
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
    ON OBJECT::[dbo].[usp_MeasureUOM_Select] TO [FE_rohit.r-ext]
    AS [dbo];

