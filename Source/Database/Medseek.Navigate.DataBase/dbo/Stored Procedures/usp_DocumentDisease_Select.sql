/*    
------------------------------------------------------------------------------    
Procedure Name: usp_DocumentDisease_Select    
Description   : This procedure is used to get the records from the DocumentDisease  
    table  
Created By    : Aditya    
Created Date  : 06-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_DocumentDisease_Select]  
(  
	@i_AppUserId KeyID,  
	@i_LibraryID KeyID = NULL,  
	@i_DiseaseID KeyID = NULL,  
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
  
   SELECT  DocumentDisease.LibraryID,  
		   DocumentDisease.DiseaseID,
		   Disease.Name AS DiseaseName,  
		   DocumentDisease.CreatedByUserId,  
		   DocumentDisease.CreatedDate,  
		   DocumentDisease.LastModifiedByUserId,  
		   DocumentDisease.LastModifiedDate,  
		   CASE DocumentDisease.StatusCode   
			WHEN 'A' THEN 'Active'  
			WHEN 'I' THEN 'InActive'  
			ELSE ''  
		   END AS StatusDescription  
   FROM   DocumentDisease  WITH (NOLOCK) 
		  INNER JOIN Disease  WITH (NOLOCK) 
				ON  Disease.DiseaseId = DocumentDisease.DiseaseID  
  WHERE ( DocumentDisease.LibraryID = @i_LibraryID OR @i_LibraryID IS NULL )  
		AND ( DocumentDisease.DiseaseID = @i_DiseaseID OR @i_DiseaseID IS NULL )  
        AND ( DocumentDisease.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )  
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
    ON OBJECT::[dbo].[usp_DocumentDisease_Select] TO [FE_rohit.r-ext]
    AS [dbo];

