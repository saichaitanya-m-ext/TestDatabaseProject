/*    
------------------------------------------------------------------------------    
Procedure Name: Usp_Communication_Update    
Description   : This procedure is used to update the Communication.    
Created By    : NagaBabu    
Created Date  : 22-July-2010    
-------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
27-Sep-2010 NagaBabu Added  RETURN 0 in this sp     
-------------------------------------------------------------------------------    
*/    
CREATE PROCEDURE [dbo].[Usp_Communication_Update ]
(    
  @i_AppUserId KeyID ,
  @v_StatusCode StatusCode,   
  @t_CommunicationId ttypeKeyID ReadOnly    
)    
AS    
BEGIN TRY    
       SET NOCOUNT ON    
       DECLARE @i_numberOfRecordsUpdated INT    
---- Check if valid Application User ID is passed    
       IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
       BEGIN    
               RAISERROR ( N'Invalid Application User ID %d passed ' ,    
               17 ,    
               1 ,    
               @i_AppUserId )    
       END    
------------    Updation operation takes place   --------------------------    
       UPDATE    
           Communication   
       SET StatusCode = @v_StatusCode ,
		   Lastmodifieddate = GETDATE() ,    
		   LastModifiedByUserId = @i_AppUserId    
       WHERE    
           CommunicationId IN (SELECT  tKeyID FROM @t_CommunicationId ) 

       SET @i_numberOfRecordsUpdated = @@ROWCOUNT    
       IF @i_numberOfRecordsUpdated < 1    
             RAISERROR     
             ( N'Update of Communication table experienced invalid row count of %d' ,    
                  17 ,    
                  1 ,    
                  @i_numberOfRecordsUpdated     
             )   
       RETURN 0        
END TRY     
------------ Exception Handling --------------------------------    
BEGIN CATCH    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Usp_Communication_Update ] TO [FE_rohit.r-ext]
    AS [dbo];

