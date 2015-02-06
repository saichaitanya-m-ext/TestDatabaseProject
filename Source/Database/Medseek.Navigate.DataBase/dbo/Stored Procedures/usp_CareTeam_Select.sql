/*          
------------------------------------------------------------------------------          
Procedure Name: usp_CareTeam_Select          
Description   : This procedure is used to get the CareTeam Details based on the       
    CareTeamID or get all the careteams when passed NULL        
Created By    : Aditya          
Created Date  : 15-Mar-2010          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
18-Aug-2010 NagaBabu Replaced INNER JOIN by LEFT OUTER JOIN IN Select statement  
19-Aug-2010 NagaBabu  Deleted CareTeamId from ORDER BY clause to the select statement   
23-Sep-10 Pramod Included a subquery for IsCareTeamManager  
------------------------------------------------------------------------------          
*/    
CREATE PROCEDURE [dbo].[usp_CareTeam_Select]  
(    
 @i_AppUserId KEYID ,    
 @i_CareTeamId KEYID = NULL,    
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
             
----------- Select CareTeam details -------------------    
    
      SELECT    
          CareTeam.CareTeamId ,    
          CareTeam.CareTeamName ,    
          CareTeam.Description ,    
          CareTeam.DiseaseId ,    
          Condition.ConditionName AS Name ,    
          CareTeam.CreatedByUserId ,  
          CareTeam.CreatedDate,  
		  CareTeam.LastModifiedByUserId,  
          CareTeam.LastModifiedDate,   
          CASE CareTeam.StatusCode    
            WHEN 'A' THEN 'Active'    
            WHEN 'I' THEN 'InActive'    
          END AS StatusDescription,  
          (SELECT CareTeamMembers.IsCareTeamManager   
             FROM CareTeamMembers   
            WHERE CareTeamMembers.CareTeamId = CareTeam.CareTeamId   
              AND CareTeamMembers.ProviderID = @i_AppUserId  
              AND CareTeamMembers.StatusCode = 'A'  
           ) AS IsCareTeamManager  
      FROM    
          CareTeam     WITH (NOLOCK) 
      LEFT OUTER JOIN Condition   WITH (NOLOCK)    
          ON Condition.ConditionID = CareTeam.DiseaseId    
      WHERE    
          (CareTeam.CareTeamId = @i_CareTeamId OR @i_CareTeamId IS NULL )    
          AND ( @v_StatusCode IS NULL or CareTeam.StatusCode = @v_StatusCode )          
      ORDER BY    
          CareTeam.CareTeamName    
END TRY          
     
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH  
  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeam_Select] TO [FE_rohit.r-ext]
    AS [dbo];

