
/*  
-------------------------------------------------------------------------------------------------------------------  
Procedure Name: [usp_CohortListUsers_SelectByCareTeamUserId] 23
Description   : This procedure is used to get the non careteam members from specific cohort
Created By    : NagaBabu
Created Date  : 16-Aug-2011
--------------------------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
17-Aug-2011 NagaBabu Added @i_CareTeamId,@i_CohortListId as Input Parameters  
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers
--------------------------------------------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_CohortListUsers_SelectByCareTeamUserId]
(  
 @i_AppUserId KEYID ,
 @i_CareTeamId KEYID ,
 @i_PopulationDefinitionId KEYID
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
---------------------------------------------------------------------------  
	SELECT DISTINCT
		PopulationDefinitionUsers.Userid ,
		Fullname,
		MemberNum,
		Gender,
		Age ,
		Patients.CareTeamId ,
		PopulationDefinitionUsers.PopulationDefinitionId 
	FROM
		PopulationDefinitionUsers  WITH (NOLOCK) 
	INNER JOIN Patients  WITH (NOLOCK) 
		ON  PopulationDefinitionUsers.Userid = Patients.Userid
	WHERE 
		PopulationDefinitionUsers.PopulationDefinitionId = @i_PopulationDefinitionId
	AND	PopulationDefinitionUsers.StatusCode = 'A'
	AND Patients.UserStatusCode = 'A'
	AND Patients.CareTeamId IS NULL	
	
		
END TRY  
-------------------------------------------------------------------------------
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException   
     @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH 




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CohortListUsers_SelectByCareTeamUserId] TO [FE_rohit.r-ext]
    AS [dbo];

