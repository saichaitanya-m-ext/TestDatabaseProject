
/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Library_Select]  
Description   : This procedure is used to select the data from Library based on the   
    LibraryId if it is null it select all the records.   
Created By    : Aditya  
Created Date  : 12-Jan-2010  
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY   BY         DESCRIPTION  
28-June-2010  NagaBabu	Added WebSiteURLLink to the Select statement 
25-Aug-2010  NagaBabu	Added order by clause to the Select statement 
22-Aug-2012 P.V.P.Mohan added @b_IsPEM as per sage requirement and Written Where Condition.
----------------------------------------------------------------------------------------  
*/ 



CREATE PROCEDURE [dbo].[usp_Library_Select]-- 64,null,null,null
(  
  
  @i_AppUserId KeyID,  
  @i_LibraryId KeyID = NULL, 
  @v_StatusCode StatusCode = NULL  
   
)  
      
AS  
  
BEGIN TRY   
  
 SET NOCOUNT ON   
 -- Check if valid Application User ID is passed  
  
 IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)  
  
 BEGIN  
  RAISERROR  
  (  N'Invalid Application User ID %d passed.'  
   ,17  
   ,1  
   ,@i_AppUserId  
  )  
 END  
  
 SELECT   
	 Library.LibraryId,  
	 Library.DocumentTypeId,  
	 Library.Name as LibraryName,
	 DocumentType.Name as DocumentTypeName,  
	 Library.Description,  
	 Library.PhysicalFileName,  
	 Library.DocumentNum,  
	 Library.DocumentLocation,  
	 Library.eDocument,  
	 Library.DocumentSourceCompany, 
	 Library.MimeType,
	 Library.CreatedByUserId,  
	 Library.CreatedDate,  
	 Library.LastModifiedByUserId,  
	 Library.LastModifiedDate, 
	 Library.IsPEM,
	 CASE Library.StatusCode     
	   WHEN 'A' THEN 'Active'    
	   WHEN 'I' THEN 'InActive'    
	 ELSE ''    
	 END AS StatusDescription,
	 Library.WebSiteURLLink
      
 FROM   
     Library WITH (NOLOCK) 
 INNER JOIN DocumentType WITH (NOLOCK) 
	 ON DocumentType.DocumentTypeId = Library.DocumentTypeId    
 WHERE  
     (LibraryId = @i_LibraryId  
      OR @i_LibraryId IS NULL)  
      AND ( Library.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )   
      AND ( Library.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )  
 ORDER BY Library.LastModifiedDate DESC    
   
END TRY   
  
BEGIN CATCH  
    -- Handle exception  
    DECLARE @i_ReturnedErrorID INT  
      
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException  
    @i_UserId = @i_AppUserId  
                          
      
END CATCH  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Library_Select] TO [FE_rohit.r-ext]
    AS [dbo];

