/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CodeTypeICD_Select_DD
Description   : This Procedure is used to get all Active ICDCodetypes from LkUpCodeType for the purpose of dropdown
Created By    : Praveen
Created Date  : 20-March-2013
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------    
*/   
CREATE PROCEDURE [dbo].[usp_CodeTypeICD_Select_DD]  
(  
	@i_AppUserId KeyId 
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
  
		select 
		CodeTypeID,
		CodeTypeCode 
		FROM LkUpCodeType
		WHERE 
			StatusCode = 'A'
		ORDER BY 
			CodeTypeID
		
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
    ON OBJECT::[dbo].[usp_CodeTypeICD_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

