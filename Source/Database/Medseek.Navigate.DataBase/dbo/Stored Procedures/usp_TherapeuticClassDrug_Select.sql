/*      
------------------------------------------------------------------------------      
Procedure Name: usp_TherapeuticClassDrug_Select      
Description   : This procedure is used to get the Drug related info based on   
    the DrugCodeID or list all Drugs when passed NULL.  
Created By    : Aditya      
Created Date  : 5-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_TherapeuticClassDrug_Select]    
(    
 @i_AppUserId INT,    
 @i_TherapeuticID INT = NULL,
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
    TherapeuticClassDrug.DrugCodeID    
   ,CodeSetDrug.DrugCode    
   ,CodeSetDrug.DrugCodeType as 'CodeType'   
   ,CodeSetDrug.DrugName as 'Name'  
   ,CodeSetDrug.DrugDescription as 'Description'  
   ,CodeSetDrug.CreatedByUserId   
   ,CodeSetDrug.CreatedDate    
   ,CodeSetDrug.CreatedByUserId    
   ,CodeSetDrug.LastModifiedDate    
   ,'' AS StatusDescription   
       FROM TherapeuticClassDrug   WITH(NOLOCK)
   INNER JOIN CodeSetDrug WITH(NOLOCK) ON CodeSetDrug.DrugCodeID = TherapeuticClassDrug.DrugCodeID  
    WHERE ( TherapeuticClassDrug.TherapeuticID  = @i_TherapeuticID     
               OR @i_TherapeuticID IS NULL    
             )  
          --AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )    
      ORDER BY CodeSetDrug.DrugName  
    
END TRY      
--------------------------------------------------------       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TherapeuticClassDrug_Select] TO [FE_rohit.r-ext]
    AS [dbo];

