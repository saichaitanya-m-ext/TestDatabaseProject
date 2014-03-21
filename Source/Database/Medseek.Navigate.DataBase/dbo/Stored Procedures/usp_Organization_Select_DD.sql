/*    
----------------------------------------------------------------------------------------    
Procedure Name: usp_Organization_Select_DD  23,1  
Description   : This procedure is used to select all the  organizations  from the    
    Organization table.    
Created By    : Aditya     
Created Date  : 09-Jan-2010    
-----------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
3-Jun-10 Pramod Added parameter @b_IsClinic  
-----------------------------------------------------------------------------------------    
*/  
  
CREATE PROCEDURE [dbo].[usp_Organization_Select_DD]  
(  @i_AppUserId KEYID,  
   @b_IsClinic IsIndicator = NULL  
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
    
------------ Selection from Organization table table starts here ------------    
      SELECT  
            OrganizationId ,  
            OrganizationName  
      FROM  
            Organization  
      WHERE  
            OrganizationStatusCode = 'A'  
        AND ( IsClinic = @b_IsClinic OR @b_IsClinic IS NULL )
        AND OrganizationName IS NOT NULL  
      ORDER BY  
            OrganizationName  
END TRY  
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Organization_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

