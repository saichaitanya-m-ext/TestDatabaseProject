/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_GridResolution_Select]  
Description   : This procedure is used for getting the ScrollHeight  
Created By    : Rathnam  
Created Date  : 09-Feb-2011  
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_GridResolution_Select]
( @i_AppUserId KEYID, 
  @v_ModuleName ShortDescription, 
  @v_PageName ShortDescription,  
  @i_ResolutionValue SMALLINT ,
  @v_GridName ShortDescription = NULL
)  
AS  
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
      BEGIN  
           RAISERROR ( N'Invalid Application User ID %d passed.' ,  
           17 ,  
           1 ,  
           @i_AppUserId )  
      END  
      
      SELECT 
          GridResolutionID,
          GridName,
          ScrollHeight 
      FROM  
          GridResolution
      WHERE   
          PageName = @v_PageName 
      AND ModuleName = @v_ModuleName
      AND @i_ResolutionValue BETWEEN ResolutionFrom AND ResolutionTo
      AND (GridName = @v_GridName OR @v_GridName IS NULL)
  
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_GridResolution_Select] TO [FE_rohit.r-ext]
    AS [dbo];

