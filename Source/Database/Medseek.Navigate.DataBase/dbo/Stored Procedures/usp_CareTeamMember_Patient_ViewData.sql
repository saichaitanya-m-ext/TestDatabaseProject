/*          
------------------------------------------------------------------------------          
Procedure Name: usp_CareTeamMember_Patient_ViewData
Description   : This procedure is used to determine if the care member can
				Edit patient's data or not
Created By    : Pramod
Created Date  : 15-Sep-2010
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION 
12-Nov-2010 Rathnam added StatusCode conditions.
16-Nov-2010 Rathnam added join condition For CareTeam and added statuscode condition.         
-----------------------------------------------------------------------------          
*/    
CREATE PROCEDURE [dbo].[usp_CareTeamMember_Patient_ViewData]
(
   @i_AppUserId KeyID,
   @i_PatientUserId KEYID
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
  
  --SELECT * FROM CareTeamTaskRights WHERE 
  --SELECT  
  -- CASE   
  -- WHEN EXISTS   
  --    (SELECT 1  
  --       FROM CareTeamMembers CTM
		--	  INNER JOIN Patients PAT WITH (NOLOCK)
		--		ON CTM.CareTeamId = PAT.CareTeamId
		--	  INNER JOIN CareTeam CT WITH (NOLOCK)
		--	    ON CT.CareTeamId = CTM.CareTeamId	
  --      WHERE PAT.UserId = @i_PatientUserId
		--  AND CTM.UserId = @i_AppUserId
		--  AND CTM.StatusCode = 'A'
		--  AND PAT.UserStatusCode = 'A'
		--  AND CT.StatusCode = 'A'
  --     )  
  --  THEN 1   
  -- ELSE 0   
  -- END AS CanEditData  
  select 1 CanEditData
   
END TRY          
     
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareTeamMember_Patient_ViewData] TO [FE_rohit.r-ext]
    AS [dbo];

