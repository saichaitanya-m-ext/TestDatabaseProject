/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_Disease_SpecificCareGap_DD  
Description   : This procedure is used to get the list of all Diseases for the Dropdown
Created By    : Rathnam
Created Date  : 07-June-2011
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Disease_SpecificCareGap_DD]
 (
	 @i_AppUserId keyid ,
	 @i_ProgramId keyid = NULL ,
	 @i_UserID KeyID = NULL
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
      IF (@i_ProgramId IS NOT NULL)
      BEGIN
		  SELECT 
			  de.DiseaseId ,
			  de.Name    
		  FROM
			  Disease de
		  INNER JOIN ProgramDisease pd
			 ON de.DiseaseId = pd.DiseaseId        
		  WHERE
			  de.StatusCode = 'A'
		  AND pd.StatusCode = 'A'
		  AND (pd.ProgramId = @i_ProgramId)
		  ORDER BY de.Name
      END
      
      IF (@i_UserID IS NOT NULL)
      BEGIN
		  SELECT DISTINCT
			  de.DiseaseId ,
			  de.Name    
		  FROM
			  Disease de
		  INNER JOIN UserDisease ude
		     ON ude.DiseaseID = de.DiseaseId
		  WHERE
			  de.StatusCode = 'A'
		  AND ude.StatusCode = 'A'
		  AND (ude.UserID = @i_UserID)
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
    ON OBJECT::[dbo].[usp_Disease_SpecificCareGap_DD] TO [FE_rohit.r-ext]
    AS [dbo];

