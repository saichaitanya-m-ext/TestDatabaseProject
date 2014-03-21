/*    
------------------------------------------------------------------------------    
Procedure Name: usp_DocumentProgram_Select    
Description   : This procedure is used to get the records from the DocumentProgram  
    table  
Created By    : Aditya    
Created Date  : 06-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_DocumentProgram_Select]  
(  
 @i_AppUserId KeyID,  
 @i_LibraryID KeyID = NULL,  
 @i_ProgramID KeyID = NULL,  
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
  
 SELECT  DocumentProgram.LibraryID,  
   DocumentProgram.ProgramID, 
   Program.ProgramName, 
   DocumentProgram.CreatedByUserId,  
   DocumentProgram.CreatedDate,  
   DocumentProgram.LastModifiedByUserId,  
   DocumentProgram.LastModifiedDate,  
   CASE DocumentProgram.StatusCode   
    WHEN 'A' THEN 'Active'  
    WHEN 'I' THEN 'InActive'  
    ELSE ''  
   END AS StatusDescription  
   FROM DocumentProgram WITH(NOLOCK)
		INNER JOIN Program  WITH(NOLOCK)
				ON Program.ProgramId = DocumentProgram.ProgramID
  WHERE ( DocumentProgram.LibraryID = @i_LibraryID OR @i_LibraryID IS NULL )  
    AND ( DocumentProgram.ProgramID = @i_ProgramID OR @i_ProgramID IS NULL )  
       AND ( DocumentProgram.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )  
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
    ON OBJECT::[dbo].[usp_DocumentProgram_Select] TO [FE_rohit.r-ext]
    AS [dbo];

