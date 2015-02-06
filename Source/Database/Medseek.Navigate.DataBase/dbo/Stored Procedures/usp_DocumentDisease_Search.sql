/*      
---------------------------------------------------------------------------------      
Procedure Name: [dbo].[usp_DocumentDisease_Search]      
Description   : This procedure is used to get the details from DocumentDisease and       
    and Library Tables.      
Created By    : Aditya      
Created Date  : 29-Mar-2010      
----------------------------------------------------------------------------------      
Log History   :       
DD-Mon-YYYY  BY  DESCRIPTION      
16-June-2010 NagaBabu deleted Disease table and replaced INNNER JOIN with LEFT OUTER JOIN in select statement       
17-Jun-2010 Pramod Removed the left outer join and moved the select into the where exists clause        
30-July-2010 NagaBabu Added DocumentTypeName field in select statement and added INNER JOIN to DocumentType,Library tables
                           and added WebSiteURLLink field also 
02-Nov-2010 Rathnam added join condition DocumentDisease and removed the exist clause.
                    and added the statuscode condition.                         
----------------------------------------------------------------------------------      
*/      
      
CREATE PROCEDURE [dbo].[usp_DocumentDisease_Search]
(      
 @i_AppUserId KEYID ,      
 @i_DiseaseID KEYID = NULL ,      
 @vc_DocumentName SHORTDESCRIPTION = NULL ,      
 @vc_DocumentDescription LONGDESCRIPTION = NULL ,      
 @dt_LastModifiedDateFrom DATETIME = NULL ,      
 @dt_LastModifiedDateTo DATETIME = NULL      
)      
AS      
BEGIN TRY       
      
 -- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL )      
      OR ( @i_AppUserId <= 0 )      
         BEGIN      
               RAISERROR ( N'Invalid Application User ID %d passed.' ,      
               17 ,      
               1 ,      
               @i_AppUserId )      
         END      
---------------- Records from DocumentDisease and Library are retrieved --------      
      SELECT  DISTINCT    
          Library.LibraryID ,      
          Library.LibraryID AS Id,      
          Library.Name AS DocumentName ,      
          Library.Description AS DocumentDescription ,      
          Library.DocumentTypeId ,      
          Library.PhysicalFileName ,      
          Library.DocumentNum ,      
          Library.DocumentLocation ,      
          Library.eDocument ,      
          Library.DocumentSourceCompany ,      
          Library.CreatedByUserId ,      
          Library.CreatedDate ,      
          Library.LastModifiedByUserId ,      
          Library.LastModifiedDate ,      
          CASE Library.StatusCode      
            WHEN 'A' THEN 'Active'      
            WHEN 'I' THEN 'InActive'      
            ELSE ''      
          END AS StatusDescription,     
          DocumentType.Name AS DocumentTypeName,
          Library.WebSiteURLLink    
      FROM      
          Library  
      INNER JOIN DocumentType  
          ON Library.DocumentTypeId = DocumentType.DocumentTypeId 
      INNER JOIN DocumentDisease
          ON DocumentDisease.LibraryID = Library.LibraryId          
      WHERE      
             ( Library.Name LIKE '%' + @vc_DocumentName + '%'      
                OR @vc_DocumentName = ''      
                OR @vc_DocumentName IS NULL )      
          AND ( Library.Description LIKE '%' + @vc_DocumentDescription + '%'      
                OR @vc_DocumentDescription = ''      
                OR @vc_DocumentDescription IS NULL )      
          AND ( ( ISNULL(Library.LastModifiedDate, Library.CreatedDate)     
      BETWEEN @dt_LastModifiedDateFrom      
                   AND ISNULL(@dt_LastModifiedDateTo,@dt_LastModifiedDateFrom) + 1    
                 )    
                OR ( @dt_LastModifiedDateFrom IS NULL    
                     AND @dt_LastModifiedDateTo IS NULL    
                   )    
               ) 
          AND (DocumentDisease.DiseaseID = @i_DiseaseID OR @i_DiseaseID IS NULL)
          AND DocumentDisease.StatusCode = 'A' 
          AND Library.StatusCode = 'A'       
                   
END TRY       
BEGIN CATCH      
      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID       
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_DocumentDisease_Search] TO [FE_rohit.r-ext]
    AS [dbo];

