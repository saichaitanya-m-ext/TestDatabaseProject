/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_ProgramExclusionReasons_Select_DD]  
Description   : This procedure is used to display ProgramExclusionReasons drop down  
Created By    : NagaBabu  
Created Date  : 14-Mar-2011  
----------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY     DESCRIPTION 
25-Mar-2011 NagaBabu Added statuscode = 'A' In Where clause
26-Nov-2012 Rathnam removed the progratype join condition as it is not using no more
----------------------------------------------------------------------------------  
*/

CREATE PROCEDURE [dbo].[usp_ProgramExclusionReasons_Select_DD]
(
 @i_AppUserId KEYID
)
AS
BEGIN TRY   
  
 -- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      SELECT
          PER.ProgramExcludeID
         ,PER.ExclusionReason
         ,CASE PER.StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
            ELSE ''
          END AS StatusDescription
      FROM
          ProgramExclusionReasons PER
      WHERE
          PER.StatusCode = 'A'
      ORDER BY
          ExclusionReason
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramExclusionReasons_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

