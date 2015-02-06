/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ProfessionalType_Select    
Description   : This procedure is used to get the list of all Professional Types  
    for a particular profesisonal Type or get lsit of all the types  
Created By    : Pramod    
Created Date  : 24-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
01-Sep-2010 NagaBabu Modified LastModifiedDate as it shows CreatedDate value when LastModifiedDate is NULL    
03-Oct-2011 Rathnam removed the nagababu's 01-sept-2010 statement
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ProfessionalType_Select]  
(  
	@i_AppUserId INT,  
	@i_ProfessionalTypeID INT = NULL,
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
  
      SELECT 
			ProfessionalTypeID  
			,ProfessionalType Name  
			,Description  
			,CreatedByUserId  
			,CreatedDate  
			,LastModifiedByUserId  
			,LastModifiedDate 
			,CASE StatusCode   
				WHEN 'A' THEN 'Active'  
				WHEN 'I' THEN 'InActive'  
				ELSE ''  
			END AS StatusDescription  
       FROM CodesetProfessionalType  
      WHERE ( ProfessionalTypeID = @i_ProfessionalTypeID   
               OR @i_ProfessionalTypeID IS NULL  
             )  
       AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )
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
    ON OBJECT::[dbo].[usp_ProfessionalType_Select] TO [FE_rohit.r-ext]
    AS [dbo];

