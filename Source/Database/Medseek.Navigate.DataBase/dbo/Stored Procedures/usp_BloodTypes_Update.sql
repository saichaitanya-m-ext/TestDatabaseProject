/*      
------------------------------------------------------------------------------          
Procedure Name: usp_BloodTypes_Update          
Description   : This procedure is used to update record in BloodTypes table.      
Created By    : Sivakrishna          
Created Date  : 19-Jul-2011          
-------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_BloodTypes_Update]        
(        
 @i_AppUserId KeyID ,        
 @i_BloodTypeId KeyID ,        
 @v_BloodType SourceName ,  
 @v_StatusCode StatusCode       
   
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
     
           
      UPDATE        
          BloodTypes        
      SET        
          BloodType = @v_BloodType ,        
          StatusCode = @v_StatusCode 
      WHERE        
          BloodTypeId = @i_BloodTypeId       
          
       SET @l_numberOfRecordsUpdated = @@ROWCOUNT
       
			IF @l_numberOfRecordsUpdated <>1
			BEGIN          
			RAISERROR      
				(  N'Invalid row count %d in Update BloodTypes'
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
    ON OBJECT::[dbo].[usp_BloodTypes_Update] TO [FE_rohit.r-ext]
    AS [dbo];

