/*          
------------------------------------------------------------------------------          
Procedure Name: usp_DocumentCategory_Select        
Description   : This procedure is used to get the detais from DocumentCategory  
    table.        
Created By    : NagaBabu         
Created Date  : 26-May-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
05-Aug-2010 NagaBabu Added isPatientViewable field in the Select statement
27-Sep-2010 NagaBabu Added ORDER BY clause to this SP               
------------------------------------------------------------------------------          
*/
CREATE PROCEDURE [dbo].[usp_DocumentCategory_Select]
(
 @i_AppUserId KEYID ,
 @i_DocumentCategoryId KEYID = NULL ,
 @v_StatusCode STATUSCODE = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON           
 -- Check if valid Application User ID is passed          
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END
--------------------- SELECT OPERATION TAKES PLACE ------------------------


      SELECT
          DocumentCategoryId ,
          CategoryName AS DocumentCategoryName ,
          Description ,
          CASE StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
          END AS StatusDescription ,
          CreatedByUserId ,
          CreatedDate ,
          LastModifiedByUserId ,
          LastModifiedDate,
          isPatientViewable
      FROM
          DocumentCategory
      WHERE
          ( DocumentCategoryId = @i_DocumentCategoryId OR @i_DocumentCategoryId IS NULL )
	  AND (DocumentCategory.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)
	  ORDER BY CreatedDate DESC
		  
	  
	  
END TRY
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_DocumentCategory_Select] TO [FE_rohit.r-ext]
    AS [dbo];

