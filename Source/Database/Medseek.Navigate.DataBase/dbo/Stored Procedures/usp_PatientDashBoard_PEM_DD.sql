﻿
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PatientDashBoard_PEM_DD]
Description   : Thsi proc is used to fecthc the PROGRAMS & LIB for PEM drop downs
Created By    : Rathnam
Created Date  : 10-FEB-2013
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION    
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_PatientDashBoard_PEM_DD]
       (
        @i_AppUserId KEYID,
        @v_MimeType VARCHAR(20) = NULL
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
			
			  SELECT LibraryId,
					 Name    
				FROM
					 Library
			   WHERE StatusCode = 'A'
				 AND ( MimeType = @v_MimeType OR @v_MimeType IS NULL )
			   ORDER BY Name
			
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
            exec usp_CareTeamMembers_ByProgram_DD @i_AppUserId--Added by praveen
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
    ON OBJECT::[dbo].[usp_PatientDashBoard_PEM_DD] TO [FE_rohit.r-ext]
    AS [dbo];

