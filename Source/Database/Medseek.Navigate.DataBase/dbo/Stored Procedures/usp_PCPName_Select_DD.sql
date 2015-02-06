/* 

---------------------------------------------------------------------------------------  
Procedure Name: usp_PCPName_Select_DD
Description   : This procedure is used to get PCPNAme for user 
Created By    : Mohan
Created Date  : 14-Nov-2013
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PCPName_Select_DD]
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
-------------------------------------------------------- 
			select
			 ProviderID,
			    COALESCE(ISNULL(provider.FirstName , '') + ', '         
				+ ISNULL(provider.MiddleName , '') + ' '         
				+ ISNULL(provider.LastName , '') + ' '             
				,'') AS LastName 
					from 
			provider 
					where  
			IsExternalProvider = 1


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
    ON OBJECT::[dbo].[usp_PCPName_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

