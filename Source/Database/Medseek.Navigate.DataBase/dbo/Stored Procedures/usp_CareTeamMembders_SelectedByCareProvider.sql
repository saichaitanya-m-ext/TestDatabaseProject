/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_CareTeamMembders_SelectedByCareProvider] 
Description   : This procedure is used to get data from Filter Tables  
Created By    : uday  
Created Date  : 16-July-2012  
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
13-01-2013	BY PRAVEEN Added extra where condition to avoid empty values in CareTeamMamberName     
------------------------------------------------------------------------------          
*/  
-- [usp_CareProvider_CareTeamMembders] 23  
CREATE PROCEDURE [dbo].[usp_CareTeamMembders_SelectedByCareProvider]  
       (  
        @i_AppUserId KEYID  
       )  
AS  
 BEGIN TRY  
      SET NOCOUNT ON           
      -- Check if valid Application User ID is passed          
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.'  
               ,17  
               ,1  
               ,@i_AppUserId )  
         END  
------------------------------------ SELECT TaskDueDates--------------------------------------    
  SELECT   
    DISTINCT  
    CTM.ProviderID AS UserId, 
    Dbo.ufn_GetUserNameByID(CTM.ProviderID) AS CareTeamMemberName  
   FROM  
    CareTeamMembers CTM  
   INNER JOIN(SELECT   
       DISTINCT   
       CareTeamId   
        FROM CareTeamMembers WHERE ProviderID = @i_AppUserId  
      AND IsCareTeamManager = 1 AND StatusCode = 'A') CTMT  
    ON CTM.CareTeamId = CTMT.CareTeamId  
   INNER JOIN CareTeam CT    WITH (NOLOCK) 
    ON CTMT.CareTeamId = CT.CareTeamId  
   INNER JOIN CareTeamTaskRights CTR    WITH (NOLOCK) 
    ON CT.CareTeamId = CTR.CareTeamId  
   WHERE CTM.StatusCode = 'A'  
     AND CTR.StatusCode  = 'A'  
     AND CT.StatusCode = 'A'  
     AND Dbo.ufn_GetUserNameByID(CTM.ProviderID) <>''
     
 END TRY          
-------------------------------------------------------------------------------     
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamMembders_SelectedByCareProvider] TO [FE_rohit.r-ext]
    AS [dbo];

