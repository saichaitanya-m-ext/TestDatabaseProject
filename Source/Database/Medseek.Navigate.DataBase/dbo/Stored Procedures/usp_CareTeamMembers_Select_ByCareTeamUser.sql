/*                
------------------------------------------------------------------------------                
Procedure Name: usp_CareTeamMembers_Select_ByCareTeamUser 13,2
Description   : This procedure is used to get the CareTeamMembers Details based on the             
    careteamuserid          
Created By    : Pramod          
Created Date  : 9-Jun-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY  BY   DESCRIPTION                
                
------------------------------------------------------------------------------                
*/   
CREATE PROCEDURE [dbo].[usp_CareTeamMembers_Select_ByCareTeamUser]
(          
  @i_AppUserId KEYID ,
  @i_CareTeamUserID KEYID   = null       
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

	DECLARE @tbl_CareTeam TABLE (CareTeamId INT)

	INSERT INTO @tbl_CareTeam (CareTeamId)
	SELECT DISTINCT CareTeamId
	  FROM CareTeamMembers
	 WHERE ProviderID = @i_CareTeamUserID
          
    SELECT DISTINCT           
           Provider.ProviderID UserId,          
           ISNULL(Provider.FirstName,'') + ' ' + ISNULL(Provider.MiddleName,'')         
		   + ' ' + ISNULL(Provider.LastName,'') AS UserName        
      FROM          
           CareTeamMembers WITH (NOLOCK)
           INNER JOIN @tbl_CareTeam TCT
			  ON TCT.CareTeamId = CareTeamMembers.CareTeamId
           INNER JOIN Provider   WITH (NOLOCK) 
			  ON CareTeamMembers.ProviderID = Provider.ProviderID       
     WHERE CareTeamMembers.StatusCode = 'A'          
     ORDER BY UserName        
          
END TRY                
           
BEGIN CATCH                
    -- Handle exception                
      DECLARE @i_ReturnedErrorID INT          
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId          
          
      RETURN @i_ReturnedErrorID          
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamMembers_Select_ByCareTeamUser] TO [FE_rohit.r-ext]
    AS [dbo];

