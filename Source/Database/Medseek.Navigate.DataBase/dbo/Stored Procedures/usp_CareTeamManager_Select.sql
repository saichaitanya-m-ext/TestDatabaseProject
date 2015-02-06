/*                
------------------------------------------------------------------------------                
Procedure Name: usp_CareTeamManager_Select  23,13,1     
Description   : This procedure is used to get the CareTeamMembers Details based on the             
    UserID          
Created By    : P.V.P.Mohan          
Created Date  : 16-Jul-2013                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY  BY   DESCRIPTION                
                
------------------------------------------------------------------------------                
*/          
CREATE PROCEDURE [dbo].[usp_CareTeamManager_Select] --85679,33         
(          
  @i_AppUserId KEYID ,          
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
                   
----------- Select CareTeamMembers details -------------------          
          
   BEGIN 
  

		SELECT ISNULL(P.FirstName,'') +' ' + ISNULL(P.lastname,'') As CareManager
			
		FROM CareTeamMembers CTM
		INNER JOIN CareTeam CT ON CT.CareTeamId = CTM.CareTeamId
		INNER JOIN Provider P ON CTM.ProviderID = P.ProviderID
		WHERE CT.CareTeamId = @i_CareTeamID
		 AND IsCareTeamManager = 1

		SELECT ISNULL(P.FirstName, '') + ' ' + ISNULL(P.lastname, '') AS CareMember
		FROM CareTeamMembers CTM
		INNER JOIN CareTeam CT 
			ON CT.CareTeamId = CTM.CareTeamId
		INNER JOIN Provider P 
			ON CTM.ProviderID = P.ProviderID
		WHERE CT.CareTeamId = @i_CareTeamID
			AND IsCareTeamManager = 0
			AND CTM.StatusCode = 'A'
 END
          
END TRY                
           
BEGIN CATCH                
    -- Handle exception                
      DECLARE @i_ReturnedErrorID INT          
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId          
          
      RETURN @i_ReturnedErrorID          
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamManager_Select] TO [FE_rohit.r-ext]
    AS [dbo];

