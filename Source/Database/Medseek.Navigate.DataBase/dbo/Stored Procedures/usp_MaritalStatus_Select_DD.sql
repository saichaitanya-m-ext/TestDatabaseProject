/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_MaritalStatus_Select_DD]  
Description   : This procedure is used to get the list of Marital Status of Users 
Created By    : Mohan
Created Date  : 26-Mar-2013  
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
  
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_MaritalStatus_Select_DD]
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
            MaritalStatusID,
			MaritalStatusCode,
          MaritalStatusName Name 
      FROM
          CodeSetMaritalStatus
      ORDER BY
		  Name
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
    ON OBJECT::[dbo].[usp_MaritalStatus_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

