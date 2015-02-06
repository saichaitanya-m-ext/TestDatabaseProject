/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_Report_ComorbidityDisease_DD  
Description   : This procedure is used to get the list of all Diseases for the Dropdown based on roles
Created By    : Rathnam
Created Date  : 04-Jan-2011
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_DiseaseByRoleSpecific_DD]
(
 @i_AppUserId INT ,
 @b_IsMyPatients BIT = 0
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
-------------------------------------------------------- 
      IF @b_IsMyPatients = 1
		  BEGIN
			  SELECT DISTINCT
				  d.DiseaseId ,
				  d.Name    
			  FROM
				  UserDisease ud
			  INNER JOIN Patients u WITH (NOLOCK)
			      ON u.UserId = ud.UserID	  
			  INNER JOIN Disease d  WITH (NOLOCK)
				  ON ud.DiseaseID = d.DiseaseId
				 AND d.StatusCode = 'A' 
			  INNER JOIN CareTeam c WITH (NOLOCK)
				  ON c.CareTeamId = u.CareTeamId
				 AND c.StatusCode = 'A'  
			  INNER JOIN CareTeamMembers ctm WITH (NOLOCK)
			      ON ctm.CareTeamId = c.CareTeamId 	  	  
			     AND ctm.StatusCode = 'A' 
			  WHERE
				  ctm.UserId = @i_AppUserId
			  ORDER BY
				  d.Name
		  END
	  ELSE
		  BEGIN
			 SELECT DISTINCT
				  d.DiseaseId ,
				  d.Name    
			  FROM
				  UserDisease ud
			  INNER JOIN Disease d
				  ON ud.DiseaseID = d.DiseaseId
				 AND d.StatusCode = 'A' 
			  ORDER BY
				  d.Name
		  END	  		  
      
END TRY  
--------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_DiseaseByRoleSpecific_DD] TO [FE_rohit.r-ext]
    AS [dbo];

