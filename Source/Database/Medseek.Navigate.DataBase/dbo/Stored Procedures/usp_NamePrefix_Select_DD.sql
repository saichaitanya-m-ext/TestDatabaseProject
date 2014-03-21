/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_NamePrefix_Select_DD]  
Description   : This procedure is used to get the list of prefixes
Created By    : Balla Kalyan
Created Date  : 16-Feb-2010  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
19-Aug-2010 NagaBabu Added ORDER BY clause to the select statement  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_NamePrefix_Select_DD]
(
 @i_AppUserId INT )
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
      SELECT
          NamePrefixID PrefixID ,
          NamePrefix Prefix ,
          PrefixDescription Description
      FROM
          CodeSetNamePrefix
      WHERE
          StatusCode = 'A'
      ORDER BY
		  SortOrder,
		  Prefix    
          
END TRY  
--------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_NamePrefix_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

