/*  
---------------------------------------------------------------------------------  
Procedure Name: usp_CareTeamMembers_ByProgram_DD   
Description   : This proc is used to getting the careteammembers based on login provider userid AND Program List  
      
Created By    : Rathnam  
Created Date  : 11-03/2013  
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_CareTeamMembers_ByProgram_DD]  
(  
 @i_AppUserId KEYID,  
 @v_TaskTypeName VARCHAR(150) = NULL  
)  
AS  
BEGIN TRY  
      SET NOCOUNT ON     
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.'  
               ,17  
               ,1  
               ,@i_AppUserId )  
         END  
---------------- All the Active CareTeam records are retrieved --------  
        
    IF EXISTS ( SELECT 1  
                                 FROM  
                                     CareTeamMembers WITH ( NOLOCK )  
                                 WHERE  
                                     ProviderID = @i_AppUserId  
                                     AND IsCareTeamManager = 1  
                                     AND StatusCode = 'A' )  
                        BEGIN  
                              IF @v_TaskTypeName <> 'Ad-hoc Task'  
                                                         
                              SELECT DISTINCT  
                                  ctm.ProviderID UserId  
                                 ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName  
                              FROM  
                                  CareTeamMembers ctm WITH ( NOLOCK )  
                              INNER JOIN CareTeam ct WITH ( NOLOCK )  
                                  ON ctm.CareTeamId = ct.CareTeamId  
                              INNER JOIN ProgramCareTeam pct WITH ( NOLOCK )  
                                  ON pct.CareTeamId = ct.CareTeamId  
                              INNER JOIN Program p WITH(NOLOCK)  
                                  on p.ProgramId = pct.ProgramId      
                              INNER JOIN CareTeamMembers ctm1 WITH(NOLOCK)  
                                  on ctm1.CareTeamId = ctm.CareTeamId    
                              INNER JOIN CareTeamTaskRights ctr WITH(NOLOCK)  
                                  on ctr.ProviderID = ctm.ProviderID  
                                 AND ctr.CareTeamId = ctm.CareTeamId  
                              INNER JOIN TaskType ty WITH(NOLOCK)  
                                 ON ty.TaskTypeId = ctr.TaskTypeId          
                              WHERE  
                                  ctm.StatusCode = 'A'  
                                  AND CT.StatusCode = 'A'  
                                  AND p.StatusCode = 'A'  
                                  AND ctm1.ProviderID = @i_AppUserId  
                                  AND (ty.TaskTypeName = @v_TaskTypeName OR @v_TaskTypeName IS NULL)  
                             ELSE  
                                 SELECT DISTINCT  
                                  ctm.ProviderID UserId  
                                 ,Dbo.ufn_GetUserNameByID(ctm.ProviderID) AS CareTeamMemberName  
                              FROM  
                                  CareTeamMembers ctm WITH ( NOLOCK )  
                              INNER JOIN CareTeam ct WITH ( NOLOCK )  
                                  ON ctm.CareTeamId = ct.CareTeamId  
                              INNER JOIN ProgramCareTeam pct WITH ( NOLOCK )  
                                  ON pct.CareTeamId = ct.CareTeamId  
                              INNER JOIN Program p WITH(NOLOCK)  
                                  on p.ProgramId = pct.ProgramId      
           INNER JOIN CareTeamMembers ctm1 WITH(NOLOCK)  
                                  on ctm1.CareTeamId = ctm.CareTeamId    
                              WHERE  
                                  ctm.StatusCode = 'A'  
                                  AND ct.StatusCode = 'A'  
                                  AND p.StatusCode = 'A'  
                                  AND ctm1.ProviderID = @i_AppUserId   
                        END  
                     ELSE  
                        BEGIN  
                              SELECT  
                                  @i_AppUserId UserId  
                                 ,Dbo.ufn_GetUserNameByID(@i_AppUserId) AS CareTeamMemberName  
                                   
                        END  
        
END TRY  
------------------------------------------------------------------------------------------------  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamMembers_ByProgram_DD] TO [FE_rohit.r-ext]
    AS [dbo];

