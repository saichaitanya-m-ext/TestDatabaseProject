   
/*      
---------------------------------------------------------------------------------      
Procedure Name: [usp_MedicalCondition_Select]       
Description   : This procedure is used to get data from MedicalCondition    
Created By    : Rama Krishna Prasad    
Created Date  : 07-July-2011    
----------------------------------------------------------------------------------      
Log History   :       
DD-Mon-YYYY  BY  DESCRIPTION      
----------------------------------------------------------------------------------      
*/      
      
CREATE PROCEDURE [dbo].[usp_MedicalCondition_Select]      
(     
 @i_AppUserId KEYID,  
 @v_StatusCode StatusCode = NULL  
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
   MedicalCondition.MedicalConditionID,    
   MedicalCondition.DiseaseId,    
   Condition.ConditionName AS Name,     
   MedicalCondition.Condition,    
   CASE MedicalCondition.StatusCode     
       WHEN 'A' THEN 'Active'    
       WHEN 'I' THEN 'InActive'    
       ELSE ''    
   END AS StatusCode ,    
    MedicalCondition.CreatedByUserId ,    
    MedicalCondition.CreatedDate,    
    MedicalCondition.LastModifiedByUserId,    
    MedicalCondition.LastModifiedDate      
   FROM    
    MedicalCondition WITH(NOLOCK)    
   INNER JOIN Condition  WITH(NOLOCK)  --[Here Medical Condition DiseaseId as ConditionId]
    ON MedicalCondition.DiseaseId = Condition.ConditionID    
   WHERE ( MedicalCondition.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )    
                
END TRY      
------------------------------------------------------------------------------------    
BEGIN CATCH      
      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH    
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MedicalCondition_Select] TO [FE_rohit.r-ext]
    AS [dbo];

