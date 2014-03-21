/*            
-----------------------------------------------------------------------------------           
Procedure Name: usp_UserDisease_Select            
Description   : This procedure is used to select the data from User Disease table.            
Created By    : Aditya             
Created Date  : 05-Apr-2010            
-----------------------------------------------------------------------------------         
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION            
03-Aug-2011 NagaBabu Added DiseaseMarkerStatus field in select list   
12-jul-2012 Sivakrishna added DatasourceId column to existing select statement    
17-jul-2012 Sivakrishna added DatasourceId column to existing select statement    
-----------------------------------------------------------------------------------            
*/      
      
CREATE PROCEDURE [dbo].[usp_UserDisease_Select]
(      
   @i_AppUserId KEYID ,      
   @i_UserID KEYID,      
   @i_DiseaseID KEYID = NULL,      
   @v_StatusCode StatusCode = NULL      
)       
     AS      
  
BEGIN TRY             
            
      -- Check if valid Application User ID is passed            
      IF ( @i_AppUserId IS NULL )      
      OR ( @i_AppUserId <= 0 )      
         BEGIN      
               RAISERROR ( N'Invalid Application User ID %d passed.' ,      
               17 ,      
               1 ,      
               @i_AppUserId )      
         END            
            
               
---------Selection starts here -------------------          
      
     SELECT      
		 UserDisease.UserID,      
		 UserDisease.DiseaseID,    
		 Disease.Name as DiseaseName,      
		 UserDisease.Comments,      
		 UserDisease.DiagnosedDate,      
		 UserDisease.CreatedByUserId,      
		 UserDisease.CreatedDate,      
		 UserDisease.LastModifiedByUserId,      
		 UserDisease.LastModifiedDate,      
		 CASE UserDisease.StatusCode      
		     WHEN 'A' THEN 'Active'      
		     WHEN 'I' THEN 'InActive'      
		 END AS Status ,
		 '' DiseaseMarkerStatus,
		 UserDisease.DataSourceId,
		 DataSource.SourceName
	 FROM      
         UserDisease   WITH(NOLOCK)    
     INNER JOIN Disease   WITH(NOLOCK)    
         ON Disease.DiseaseId = UserDisease.DiseaseID  
     LEFT JOIN DataSource    WITH(NOLOCK)        
         ON UserDisease.DataSourceId = DataSource.DataSourceId
     WHERE      
           UserID = @i_UserID       
           AND (UserDisease.DiseaseID = @i_DiseaseID OR @i_DiseaseID IS NULL)      
           AND ( @v_StatusCode IS NULL OR UserDisease.StatusCode = @v_StatusCode )   
  ORDER BY   
           UserDisease.DiagnosedDate,Disease.Name    
                             
END TRY      
BEGIN CATCH            
            
    -- Handle exception            
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserDisease_Select] TO [FE_rohit.r-ext]
    AS [dbo];

