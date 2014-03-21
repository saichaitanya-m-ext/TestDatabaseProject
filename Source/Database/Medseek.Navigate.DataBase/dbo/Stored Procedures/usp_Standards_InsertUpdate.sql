/*      
---------------------------------------------------------------------------------------      
Procedure Name: usp_Standards_InsertUpdate    
Description   : This proc is used to insert or Update record in Standards Table  
Created By    : P.V.P.Mohan  
Created Date  : 06-NOV-2012  
---------------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
  
---------------------------------------------------------------------------------------      
*/  
--select * from Standards  
CREATE PROCEDURE [dbo].[usp_Standards_InsertUpdate]  
(  
 @i_AppUserId KeyID,  
 @i_StandardOrganizationId KeyID,  
 @v_StandardsName VARCHAR(100) ,  
 @v_StatusCode STATUSCODE,  
 @o_StandardsId KeyId OUTPUT,  
 @i_StandardsId KeyId = NULL   
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON  
     
 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.'  
               ,17  
               ,1  
               ,@i_AppUserId )  
         END  
  
      DECLARE  
              @l_numberOfRecordsInserted INT  
             ,@l_numberOfRecordsUpdated INT  
      IF @i_StandardsId IS NULL  
         BEGIN      
         
               INSERT INTO  
                   Standard  
                   (  
					 StandardOrganizationId,  
					 Name,  
					 StatusCode,  
					 CreatedByUserId  
                   )  
               VALUES  
                   (  
					 @i_StandardOrganizationId,  
					 @v_StandardsName,  
					 'A',  
					 @i_AppUserId  
                   ) 
            
            SELECT  
                   @l_numberOfRecordsInserted = @@ROWCOUNT  
                  ,@o_StandardsId = SCOPE_IDENTITY()  
  
               IF @l_numberOfRecordsInserted <> 1  
                  BEGIN  
                        RAISERROR ( N'Invalid row count %d in insert TaskBundle'  
                        ,17  
                        ,1  
                        ,@l_numberOfRecordsInserted )  
                  END  
         END  
      ELSE  
         BEGIN  
               IF @i_StandardsId IS NOT NULL  
                  BEGIN  
  
                        UPDATE  
                            Standard  
                        SET  
                            StandardOrganizationId = @i_StandardOrganizationId  
                           ,Name = @v_StandardsName  
                           ,StatusCode = @v_StatusCode  
                        WHERE  
                            StandardId = @i_StandardsId  
  
                        SET @l_numberOfRecordsUpdated = @@ROWCOUNT  
  
                        IF @l_numberOfRecordsUpdated <> 1  
                           BEGIN  
                                 RAISERROR ( N'Invalid row count %d in Update TaskBundle'  
                                 ,17  
                                 ,1  
                                 ,@l_numberOfRecordsUpdated )  
                           END  
  
                  END  
         END  
  
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
    ON OBJECT::[dbo].[usp_Standards_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

