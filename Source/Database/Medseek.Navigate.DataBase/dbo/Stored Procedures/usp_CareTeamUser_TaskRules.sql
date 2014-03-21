/*        
------------------------------------------------------------------------------        
Procedure Name: usp_CareTeamUser_TaskRules
Description   : This procedure is used to get the Care team task rights for care team member
Created By    : NagaBabu  
Created Date  : 24-Aug-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
21-Oct-10 Pramod Included statuscode = 'A' in where clause
7-Jan-2011 Pramod Included the subquery with users and care team id
-----------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_CareTeamUser_TaskRules]
(  
   @i_AppUserId KeyID,
   @v_TaskTypeName VARCHAR(50)
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
---------------------------------------------------------------------------------
	 SELECT
		 CASE 
			WHEN EXISTS 
					 (SELECT 1
					    FROM CareTeamTaskRights
							 INNER JOIN TaskType
								ON TaskType.TaskTypeId = CareTeamTaskRights.TaskTypeId
					   WHERE CareTeamTaskRights.ProviderID = @i_AppUserId
						 AND TaskType.TaskTypeName = @v_TaskTypeName
						 AND TaskType.StatusCode = 'A'
						 AND CareTeamTaskRights.StatusCode = 'A'
						 --AND CareTeamTaskRights.CareTeamId = (SELECT CareTeamId FROM Users WHERE UserId = @i_PatientUserId)
					  )
			 THEN 1 
			ELSE 0 
		 END AS CanViewData
 
END TRY        
   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamUser_TaskRules] TO [FE_rohit.r-ext]
    AS [dbo];

