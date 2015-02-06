
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_Program_ByProviderID]
Description   : Thsi proc is used to fecthc the programs which are related to the careteam member
Created By    : Rathnam
Created Date  : 14-Nov-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_Program_ByProviderID]
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
         
			SELECT DISTINCT
                p.ProgramId  
               ,p.ProgramName  
            FROM  
				Program p WITH(NOLOCK)
			INNER JOIN ProgramCareTeam pct WITH(NOLOCK)
			    ON pct.ProgramId = p.ProgramId
			INNER JOIN CareTeamMembers ctm WITH(NOLOCK)
			    ON ctm.CareTeamId = pct.CareTeamId    	  
            WHERE  
                p.StatusCode = 'A'  
            AND ctm.StatusCode = 'A'
            AND ctm.ProviderID = @i_AppUserId  
            ORDER BY  
                p.ProgramName 
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
    ON OBJECT::[dbo].[usp_Program_ByProviderID] TO [FE_rohit.r-ext]
    AS [dbo];

