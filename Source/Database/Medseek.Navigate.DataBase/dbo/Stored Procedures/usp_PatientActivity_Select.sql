/*            
------------------------------------------------------------------------------            
Procedure Name: usp_PatientActivity_Select 23           
Description   : This procedure is used to get the list of details from PatientActivity        
    table        
Created By    : Aditya            
Created Date  : 29-Apr-2010            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION            
02-Nov-2010 Rathnam added statuscode condition in where clause.            
------------------------------------------------------------------------------            
*/          
CREATE PROCEDURE [dbo].[usp_PatientActivity_Select]          
(          
 @i_AppUserId KEYID,          
 @i_PatientGoalId KEYID = NULL,  
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
          
      SELECT PatientActivity.PatientActivityId    
      ,PatientActivity.ActivityId   
      ,Activity.Name as ActivityName   
      ,PatientActivity.PatientGoalId
      ,PatientActivity.Description  
      ,CASE PatientActivity.StatusCode   
        WHEN 'A' THEN 'Active'    
     WHEN 'I' THEN 'InActive'    
     ELSE ''    
    END AS StatusCode  
      ,PatientActivity.CreatedByUserId    
      ,PatientActivity.CreatedDate    
      ,PatientActivity.LastModifiedByUserId    
      ,PatientActivity.LastModifiedDate        
       FROM  PatientActivity  WITH(NOLOCK)  
    INNER JOIN Activity   WITH(NOLOCK)
     ON Activity.ActivityId = PatientActivity.ActivityId          
      WHERE ( PatientActivity.PatientGoalId = @i_PatientGoalId OR @i_PatientGoalId IS NULL )  
        AND (PatientActivity.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)          
          
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
    ON OBJECT::[dbo].[usp_PatientActivity_Select] TO [FE_rohit.r-ext]
    AS [dbo];

