/*      
------------------------------------------------------------------------------      
Procedure Name: usp_DiseaseTherapeuticClass_Select      
Description   : This procedure is used to get the Disease related info based on   
    the DiseaseID or list all diseases when passed NULL.  
Created By    : Aditya      
Created Date  : 5-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
      
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_DiseaseTherapeuticClass_Select]    
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
			DiseaseTherapeuticClass.DiseaseID    
		   ,Disease.Name    
		   ,Disease.Description    
		   ,DiseaseTherapeuticClass.CreatedByUserId    
		   ,DiseaseTherapeuticClass.CreatedDate 
		   ,CASE Disease.StatusCode   
						WHEN 'A' THEN 'Active'  
						WHEN 'I' THEN 'InActive'  
						ELSE ''  
		    END AS StatusDescription
    FROM DiseaseTherapeuticClass    WITH (NOLOCK) 
	     INNER JOIN TherapeuticClass  WITH (NOLOCK)   ON TherapeuticClass.TherapeuticID = DiseaseTherapeuticClass.TherapeuticID  
	     INNER JOIN Disease  WITH (NOLOCK)  ON Disease.DiseaseId = DiseaseTherapeuticClass.DiseaseID  
    WHERE ( DiseaseTherapeuticClass.TherapeuticID = @i_TherapeuticID     
               OR @i_TherapeuticID IS NULL    
             ) 
             AND ( @v_StatusCode IS NULL or Disease.StatusCode = @v_StatusCode )    
    ORDER BY Disease.SortOrder  
    
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
    ON OBJECT::[dbo].[usp_DiseaseTherapeuticClass_Select] TO [FE_rohit.r-ext]
    AS [dbo];

