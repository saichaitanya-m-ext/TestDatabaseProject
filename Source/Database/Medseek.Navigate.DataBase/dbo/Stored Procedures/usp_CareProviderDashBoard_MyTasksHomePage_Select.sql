--sp_helptext usp_CareProviderDashBoard_MyTasksHomePage_Select
  
/*      
--------------------------------------------------------------------------------------------------------------      
Procedure Name: [dbo].[usp_CareProviderDashBoard_MyTasksHomePage_Select]  
Description   : This procedure is used to display the homepage information for   
    log in user(careteammember or careteammanager)  
Created By    : Sivakrishna  
Created Date  : 24-Jan-2012    
---------------------------------------------------------------------------------------------------------------      
Log History   :       
DD-Mon-YYYY  BY  DESCRIPTION   
---------------------------------------------------------------------------------------------------------------      
*/   
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyTasksHomePage_Select]  
       (  
         @i_AppUserId KEYID  
        ,@v_ReportType VARCHAR(1) = 'T'
        --,@v_CareTeamIds VARCHAR(500) = NULL        
       )  
AS  
BEGIN TRY  
      SET NOCOUNT ON      
-- Check if valid Application User ID is passed      
      IF ( @i_AppUserId IS NULL )  OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.'  
               ,17  
               ,1  
               ,@i_AppUserId )  
         END  
           
         SELECT   
   MyTaskHomePageId,  
   UserId,  
   DueDateIds,  
   PopulationIDs,  
   MeasureRanges,  
   TaskTypeIds,  
   TypeIds,  
   PcpIds,  
   CareTeamMemberIds,  
   TaskStatus,
   CareTeamIds
   FROM   
   MyTaskhomepage   
   WHERE UserId = @i_AppUserId AND ReportType = @v_ReportType -- AND (CareTeamIds IS NULL OR CareTeamIds = @v_CareTeamIds)
       
END TRY   
BEGIN CATCH      
----------------------------------------------------------------------------------------------------------     
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH  
  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyTasksHomePage_Select] TO [FE_rohit.r-ext]
    AS [dbo];

