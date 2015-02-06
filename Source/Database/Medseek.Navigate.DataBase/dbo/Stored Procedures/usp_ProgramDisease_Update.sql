/*  
-----------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_ProgramDisease_Update]  
Description   : This procedure is used to update the data in ProgramDisease table based on the   
    ProgramDiseaseId   
Created By    : Aditya  
Created Date  : 23-Mar-2010  
------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
08-07-2010 Rathnam StatusCode column added.  
27-Sep-2010 NagaBabu Modified @i_numberOfRecordsUpdated > 1 by  <>1
28-Sep-2011 Rathnam added LastModified by & lastModifieddate column to the update statement  
------------------------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_ProgramDisease_Update]
(
 @i_AppUserId KEYID
,@i_ProgramId KEYID
,@i_DiseaseId KEYID
,@v_StatusCode STATUSCODE
,@i_ProgramDiseaseId KEYID
)
AS
BEGIN TRY

    SET NOCOUNT ON   
-- Check if valid Application User ID is passed  
    DECLARE @i_numberOfRecordsUpdated INT
    IF ( @i_AppUserId IS NULL )
    OR ( @i_AppUserId <= 0 )
       BEGIN
             RAISERROR ( N'Invalid Application User ID %d passed.'
             ,17
             ,1
             ,@i_AppUserId )
       END  
------------ Updation operation takes place here --------------------------  

    UPDATE
        ProgramDisease
    SET
        ProgramId = @i_ProgramId
       ,DiseaseId = @i_DiseaseId
       ,StatusCode = @v_StatusCode
       ,LastModifiedByUserId = @i_AppUserId
       ,LastModifiedDate = GETDATE()
    WHERE
        ProgramDiseaseId = @i_ProgramDiseaseId

    SET @i_numberOfRecordsUpdated = @@ROWCOUNT

    IF @i_numberOfRecordsUpdated <> 1
       BEGIN
             RAISERROR ( N'Update of ProgramDisease table experienced invalid row count of %d'
             ,17
             ,1
             ,@i_numberOfRecordsUpdated )
       END

    RETURN 0
END TRY   
------------ Exception Handling --------------------------------  
BEGIN CATCH
    DECLARE @i_ReturnedErrorID INT
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramDisease_Update] TO [FE_rohit.r-ext]
    AS [dbo];

