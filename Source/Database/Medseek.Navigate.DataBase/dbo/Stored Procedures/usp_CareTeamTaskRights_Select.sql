/*            
------------------------------------------------------------------------------            
Procedure Name: usp_CareTeamTaskRights_Select 22,1
Description   : This procedure is used to get the records from CareTeamTaskRights      
    table.          
Created By    : Aditya            
Created Date  : 22-Apr-2010            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION            
14-June-2010  NagaBabu  Added CareTeamID perameter for select statement         
------------------------------------------------------------------------------            
*/      
CREATE PROCEDURE [dbo].[usp_CareTeamTaskRights_Select]     
(      
  @i_AppUserId KEYID ,      
  @i_CareTeamTaskRightsId KEYID = NULL,      
  @i_UserId KEYID = NULL,      
  @v_StatusCode StatusCode = NULL ,    
  @i_CareTeamID KEYID    
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
               
----------- Select CareTeamTaskRights details -------------------      
      
    SELECT CareTeamTaskRights.CareTeamTaskRightsId,      
     CareTeamTaskRights.ProviderID AS UserId,      
     CareTeamTaskRights.TaskTypeId,      
     TaskType.TaskTypeName,      
     CareTeamTaskRights.CareTeamId,      
     CareTeamTaskRights.StatusCode,      
     CareTeamTaskRights.CreatedByUserId,      
     CareTeamTaskRights.CreatedDate,      
     CareTeamTaskRights.LastModifiedByUserId,      
     CareTeamTaskRights.LastModifiedDate,      
     CASE CareTeamTaskRights.StatusCode      
   WHEN 'A' THEN 'Active'      
   WHEN 'I' THEN 'InActive'      
     END AS StatusDescription      
   FROM      
     CareTeamTaskRights   WITH (NOLOCK)     
   INNER JOIN TaskType   WITH (NOLOCK)     
    ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId        
   WHERE      
   ( CareTeamTaskRights.CareTeamTaskRightsId = @i_CareTeamTaskRightsId OR @i_CareTeamTaskRightsId IS NULL )      
     AND ( CareTeamTaskRights.ProviderID = @i_UserId OR @i_UserId IS NULL )      
     AND ( @v_StatusCode IS NULL or CareTeamTaskRights.StatusCode = @v_StatusCode )    
	 AND ( CareTeamTaskRights.CareTeamID = @i_CareTeamID)           
	 AND TaskType.StatusCode = 'A'
        
      
END TRY            
       
BEGIN CATCH            
    -- Handle exception            
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH 


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamTaskRights_Select] TO [FE_rohit.r-ext]
    AS [dbo];

