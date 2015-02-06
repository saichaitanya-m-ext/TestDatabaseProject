/*    
----------------------------------------------------------------------------------    
Procedure Name: usp_QuestionaireType_Update    
Description   : This procedure is used to update record in QuestionaireType table.
Created By    : ADITYA    
Created Date  : 05-Mar-2010    
-----------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
-----------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_QuestionaireType_Update]
(
 @i_AppUserId KEYID ,
 @i_QuestionaireTypeId KEYID ,
 @vc_QuestionaireTypeName SHORTDESCRIPTION ,
 @vc_Description LONGDESCRIPTION ,
 @vc_StatusCode STATUSCODE
)
AS
BEGIN TRY

      SET NOCOUNT ON
      DECLARE @l_numberOfRecordsUpdated INT   
	-- Check if valid Application User ID is passed    
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

------------------Update operation for QuestionaireType table  -----  
        
               UPDATE
                   QuestionaireType
               SET
                   QuestionaireTypeName = @vc_QuestionaireTypeName ,
                   Description = @vc_Description ,
                   LastModifiedByUserId = @i_AppUserId ,
                   LastModifiedDate = GETDATE() ,
                   StatusCode = @vc_StatusCode
               WHERE
                   QuestionaireTypeId = @i_QuestionaireTypeId

               SELECT
                   @l_numberOfRecordsUpdated = @@ROWCOUNT

               IF @l_numberOfRecordsUpdated <> 1
                  BEGIN
                        RAISERROR ( N'Invalid Row count %d passed to update Questionaire Type Details' ,
                        17 ,
                        1 ,
                        @l_numberOfRecordsUpdated )
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
    ON OBJECT::[dbo].[usp_QuestionaireType_Update] TO [FE_rohit.r-ext]
    AS [dbo];

